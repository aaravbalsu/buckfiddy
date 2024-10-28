#!/bin/bash

# Update package list
sudo apt update

# Install x11vnc
sudo apt install -y x11vnc

# Create a systemd service file for x11vnc
sudo bash -c 'cat <<EOF > /etc/systemd/system/x11vnc.service
[Unit]
Description=Start x11vnc at startup
After=multi-user.target

[Service]
Type=simple
# Tailsubnet for BuckFiddy is `100.192.0.`
ExecStart=/usr/bin/x11vnc -auth guess -forever -loop -noxdamage -repeat -rfbport 5900 -allow $TAIL_SUBNET -shared -ncache 0

[Install]
WantedBy=multi-user.target
EOF'

# Reload systemd daemon to recognize the new service
sudo systemctl daemon-reload

# Enable the x11vnc service to start at boot
sudo systemctl enable x11vnc.service

# Start the x11vnc service immediately
sudo systemctl start x11vnc.service
