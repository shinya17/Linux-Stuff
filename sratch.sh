#!/bin/sh

 : '
 algorithm,
 warning, confirmation to start, maintenance, mirror and upgrade, check needrestart: if yes create file on desktop, service if not exists,  show notification then restart service will start at boot(network) sees desktop file upgradeaur deletes file shows compplete notification; if no show notif to close apps upgrade aur then show complete or error maybe ?


 '

seperate() {
    echo -e "\n\n"

}

function maintenance {
    sudo journalctl --vacuum-time=2weeks
    seperate
    sudo paccache -rk1
    seperate
}

createAndEnableAndStartService() {

    # Set the name of the systemd service
    SERVICE_NAME="restartAndUpgradeAurService"

    # Set the path to the systemd service file
    SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

    # Create the systemd service file
    cat > "${SERVICE_FILE}" << EOF
[Unit]
Description=restartAndUpgradeAurService
After=network.target

[Service]
Type=simple
ExecStart=/home/agcgn/Linux-Stuff/updateAur.sh

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd configuration
    systemctl daemon-reload

    # Enable the systemd service
    systemctl enable "${SERVICE_NAME}.service"

    # Start the systemd service
    systemctl start "${SERVICE_NAME}.service"

    # Check the status of the systemd service
    systemctl status "${SERVICE_NAME}.service"


}

restartAndUpgrade() {
    createAndEnableAndStartService
    touch '/home/agcgn/Masaüstü/aur-upgrade-incomplete'
    shutdown -r now
}

upgradeAurPackages() {
    echo "upgrade aur"
}


function showUpgradeCompleteNotification {
    if [[ $1 == true ]]; then
        output=$(notify-send 'System upgrade complete' 'Do you want to restart and upgrade aur packages ?' --action=toRestart=Restart -u critical)
        if [[ $output = "toRestart" ]]; then
            restartAndUpgrade
        fi

    else
        output=$(notify-send 'System upgrade complete' 'Now updating aur packages, close those apps first' --action=toUpgradeAur=Done -u critical)
        if [[ $output = "toUpgradeAur" ]]; then
            upgradeAurPackages
        fi
    fi

}

function ensureMirrorsAndUpdate {

    sudo pacman-mirrors -f 10
    seperate
    sudo pacman -Syyu --noconfirm
    seperate

    #output=$(needrestart)
    # we will simply not care about needrestart
    #or maybe test exit code to see if it really works lmao

    showUpgradeCompleteNotification true


}




echo 'Ensure stable electrical connection, if upgrade is interrupted system might be corrupted. Use a bootable USB stick and Timeshift to recover.'
echo 'Revert to default themes before beginning update.'

#!/bin/bash

read -p "Enter input: " input

if [ -z "$input" ] || [ -z "$(echo "$input" | tr -d '[:space:]')" ]; then
    seperate
    echo "PROGRAM STARTS!"
    seperate
    maintenance
    ensureMirrorsAndUpdate
else
    echo "Program stopped."
fi
