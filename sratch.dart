import 'dart:async';
import 'dart:io';

Future<String> runCommand(String command) async {
  var lis = command.split(" ");
  String comm = lis[0];
  lis.removeAt(0);
  var result = await Process.run(comm, lis);
  stdout.write(result.stdout);
  stderr.write(result.stderr);

  // StringBuffer buffer = StringBuffer();

  // for (var c in result.stdout) {
  //   buffer.writeCharCode(c);
  // }

  // return buffer.toString();
  return result.stdout;
}

Future<void> maintenance() async {
  print('Running maintenance tasks...');
  await runCommand("sudo journalctl --vacuum-time=2weeks");
  await runCommand("sudo paccache -rk1");
  print('Maintenance tasks finished');
}

void upgradeAurPackages() async {
  print('Upgrading AUR packages...');
  await runCommand("pamac upgrade -a");
  print('AUR upgrade finished');
}

Future<void> ensureMirrorsAndUpdate() async {
  print('Ensuring up-to-date mirrors...');
  await runCommand("sudo pacman-mirrors -f 10");
  print('Pacman mirrors finished');
  await runCommand("sudo pacman -Syyu --noconfirm");
  print('System update finished');

  if (await needRestart()) {
    print('A restart is required after the update.');
    print(
        'Please save your work and close all applications before restarting.');
    showUpgradeCompleteNotification(true);
  } else {
    showUpgradeCompleteNotification(false);
    upgradeAurPackages();
  }
}

Future<bool> needRestart() async {
  var result = await runCommand("sudo needrestart");
  await Future.delayed(Duration(seconds: 5));
  if (result == "Scanning processes...") {
    return false;
  } else {
    //TODO specify more
    return true;
  }
}

void createEnableStartService() async {
  var serviceName = 'upgradeAurAfterSystemUpdate';
  var servicePath = '/etc/systemd/system/$serviceName.service';

  if (File(servicePath).existsSync()) {
    // If the service file already exists, enable and start the service
    await runCommand("systemctl enable $serviceName");
    await runCommand("systemctl start $serviceName");
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
    await runCommand("systemctl enable $serviceName");
    await runCommand("systemctl start $serviceName");
    print('Service created, enabled, and started successfully');
  }
}

//TODO try Process.start if it actually gives live updates
Future<void> restartAndUpgrade() async {
  // mark to know to upgrade aur, to survive reboot
  // i know there are better methods, but now, user experience wins. i am not an engineer and i seem to will never be
  createEnableStartService();
  await runCommand("touch '/home/agcgn/Masaüstü/aur-upgrade-incomplete'");
  await runCommand("shutdown -r now");
}

void showUpgradeCompleteNotification(bool restartRequired) async {
  if (restartRequired) {
    var processResult = await runCommand(
        "notify-send 'System upgrade complete' 'Do you want to restart and upgrade aur packages ?' --action=toRestart=Restart -u critical");
    //TODO obviously wait for the notification result lmao not just check one millisecond
    if (processResult.contains('toRestart')) {
      restartAndUpgrade();
    }
  } else {
    var processResult = await runCommand(
        "notify-send 'System upgrade complete' 'Now updating aur packages, close those apps first' --action=toUpgradeAur=Done -u critical");
//TODO obviously wait for the notification result lmao not just check one millisecond
    if (processResult.contains('toUpgradeAur')) {
      upgradeAurPackages();
    }
  }
}

void main(List<String> args) async {
  // brainstorm. start a process, get sudo by sudo dart file.dart lmao
  // warning, confirmation to start, maintenance, mirror and upgrade, check needrestart: if yes create file on desktop, service if not exists,  show notification then restart service will start at boot(network) sees desktop file upgradeaur deletes file shows compplete notification; if no show notif to close apps upgrade aur then show complete or error maybe ?
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
