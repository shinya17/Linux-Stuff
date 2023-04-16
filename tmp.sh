createAndEnableAndStartService() {

    # Set the name of the systemd service
    SERVICE_NAME="restartAndUpgradeAurService"

    # Set the path to the systemd service file
    SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

    # Create the systemd service file
    sudo cat > "${SERVICE_FILE}" << EOF
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
    sudo systemctl daemon-reload

    # Enable the systemd service
    sudo systemctl enable "${SERVICE_NAME}.service"

    # Start the systemd service
    sudo systemctl start "${SERVICE_NAME}.service"


}

createAndEnableAndStartService
