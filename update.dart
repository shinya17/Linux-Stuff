//TODO turn this into something proper and use blok, because it's obvious that Process.run is shitty otherwise

import 'dart:convert';
import 'dart:io';

class CommandException implements Exception {
  final String message;

  CommandException(this.message);

  @override
  String toString() => message;
}

Stream<List<int>> runCommand(String command, List<String> args,
    {String? workingDirectory}) async* {
  final process =
      await Process.start(command, args, workingDirectory: workingDirectory);

  await for (final chunk in process.stdout) {
    print("chunk $chunk");
    yield chunk;
  }

  final exitCode = await process.exitCode;

  if (exitCode != 0) {
    final errorMessage = await process.stderr.transform(utf8.decoder).join();
    throw CommandException(
        'Command failed with exit code $exitCode:\n$errorMessage');
  }
}

Future<void> main() async {
  print(
      'Ensure stable electrical connection, if upgrade is interrupted system might be corrupted. Use a bootable USB stick and Timeshift to recover.');
  print('Revert to default themes before beginning update.');

  print(
      'Have you taken necessary precautions? Press Enter to continue or Ctrl + C to exit.');
  String? input = stdin.readLineSync();

  if (input == null || input.trim().isEmpty) {
    maintenance();
    ensureMirrorsAndUpdate();
  } else {
    print('Program stopped.');
  }
}

Future<void> maintenance() async {
  print('Running maintenance tasks...');
  await runCommand('sudo', ['journalctl', '--vacuum-time=2weeks']);
  await runCommand('sudo', ['paccache', '-rk1']);
  print('Maintenance tasks finished');
}

Future<void> ensureMirrorsAndUpdate() async {
  print('Ensuring up-to-date mirrors...');
  await for (var line in runCommand('sudo', ['pacman-mirrors', '-f', '10'])) {
    print("line $line");
  }
  print('Pacman mirrors finished');
  await runCommand('sudo', ['pacman', '-Syyu']);
  print('System update finished');

  if (await needRestart()) {
    print('A restart is required after the update.');
    print(
        'Please save your work and close all applications before restarting.');
    showUpgradeCompleteNotification(true);
  } else {
    upgradeAurPackages();
    showUpgradeCompleteNotification(false);
  }
}

void upgradeAurPackages() async {
  print('Upgrading AUR packages...');
  await runCommand('pamac', ['upgrade', '-a']);
  print('AUR upgrade finished');
}

Future<bool> needRestart() async {
  var result = await runCommand('sudo', ['needrestart']);
  await Future.delayed(Duration(seconds: 5));
  if (result == "Scanning processes...") {
    return false;
  } else {
    //TODO specify more
    return true;
  }
}

void showUpgradeCompleteNotification(bool restartRequired) async {
  if (restartRequired) {
    var processResult = runCommand('notify-send', [
      'System upgrade complete',
      'Do you want to restart and upgrade aur packages ?',
      '--action=toRestart=Restart',
      '-u',
      'critical'
    ]);

    await for (var line in processResult) {
      print(line);
      if (line.contains('toRestart')) {
        restartAndUpgrade();
      }
    }
  } else {
    var processResult = runCommand('notify-send', [
      'System upgrade complete',
      'Now updating aur packages, close those apps first',
      '--action=toUpgradeAur=Done',
      '-u',
      'critical'
    ]);

    String result = '';
    await for (final line in processResult) {
      if (line.contains('toUpgradeAur')) {
      upgradeAurPackages();
    }
    }


  }
}

void createEnableStartService() async {
  var serviceName = 'upgradeAurAfterSystemUpdate';
  var servicePath = '/etc/systemd/system/$serviceName.service';

  if (File(servicePath).existsSync()) {
    // If the service file already exists, enable and start the service
    await runCommand('systemctl', ['enable', serviceName]);
    await runCommand('systemctl', ['start', serviceName]);
    print('Service already exists, enabled, and started successfully');
  } else {
    // If the service file doesn't exist, create it and set the necessary permissions
    var serviceFile = File(servicePath);
    serviceFile.writeAsStringSync('''
[Unit]
Description=Update AUR packages after reboot
After=network.target

[Service]
Type=simple
ExecStart=/home/agcgn/Linux-Stuff/updateAur.sh
Restart=always

[Install]
WantedBy=multi-user.target
''');

    // Enable and start the service
    await runCommand('systemctl', ['enable', serviceName]);
    await runCommand('systemctl', ['start', serviceName]);
    print('Service created, enabled, and started successfully');
  }
}

Future<void> restartAndUpgrade() async {
  // mark to know to upgrade aur, to survive reboot
  // i know there are better methods, but now, user experience wins. i am not an engineer and i seem to will never be
  createEnableStartService();
  await runCommand('touch', ['/home/agcgn/Masaüstü/aur-upgrade-incomplete']);
  await runCommand('shutdown', ['-r', 'now']);
}
