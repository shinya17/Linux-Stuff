import 'dart:io';

void main() {
  print('Ensure stable electrical connection, if upgrade is interrupted system might be corrupted. Use a bootable USB stick and Timeshift to recover.');
  print('Revert to default themes before beginning update.');

  print('Have you taken necessary precautions? Press Enter to continue or Ctrl + C to exit.');
  String input = stdin.readLineSync();

  if (input == null || input.trim().isEmpty) {
    maintenance();
    ensureMirrorsAndUpdate();
  } else {
    print('Program stopped.');
  }
}

void maintenance() {
  print('Running maintenance tasks...');
  Process.runSync('sudo', ['journalctl', '--vacuum-time=2weeks']);
  Process.runSync('sudo', ['paccache', '-rk1']);
  print('Maintenance tasks finished');
}

void ensureMirrorsAndUpdate() {
  print('Ensuring up-to-date mirrors...');
  Process.runSync('sudo', ['pacman-mirrors', '-f', '10']);
  print('Pacman mirrors finished');
  Process.runSync('sudo', ['pacman', '-Syyu']);
  print('System update finished');

  if (needRestart()) {
    print('A restart is required after the update.');
    print('Please save your work and close all applications before restarting.');
    showUpgradeCompleteNotification(true);
  } else {
    upgradeAurPackages();
    showUpgradeCompleteNotification(false);
  }
}

void upgradeAurPackages() {
  print('Upgrading AUR packages...');
  Process.runSync('pamac', ['upgrade', '-a']);
  print('AUR upgrade finished');
}

//TODO must see what it says when there is nothing to restart
bool needRestart() {
  var result = Process.runSync('sudo', ['needrestart']);
  return result.stdout.toString().contains(?????);
}

void showUpgradeCompleteNotification(bool restartRequired) {

  if (restartRequired) {
    //TODO create a systemd service that, script, looks at files to check if to update, then result notify
    //TODO konsole --noclose -e '/home/agcgn/needrestart.sh' replace with script we want

      //TODO notify-send 'System upgrade complete' 'Do you want to restart and upgrade aur packages ?' --action=toRestart=Restart -u critical

  var result = Process.runSync('notify-send', ['System upgrade complete', 'All packages have been successfully upgraded.']);
  if (result.stdout.toString().contains("toRestart")) {
    restart()
  }
  } else {
    //TODO notify-send 'System upgrade complete' 'Now updating aur packages, close those apps first' -u critical

  }
}

//TODO ensure upgradeaur service is done, maybe before reboot put huge label if not started
void restart() {
  Process.runSync("mkdir /home/agcgn/Desktop/aur-upgrade-incomplete");
  Process.runSync("shutdown -r now");
}

