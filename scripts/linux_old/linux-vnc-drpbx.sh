#!/bin/bash
###
#
# Dropbox configuration script for Kali linux machines running on lightdm desktops
# and allows for a vnc connection, after the device has been registered to a
# Tailnet; needs interface with a 100.192.0.x interface.
#
###
#!/bin/bash

# Update package list
sudo apt update

# Install x11vnc and tailscale
sudo apt install -y x11vnc tailscale

# Get an authkey from the Headscale admin and enter it
read -p "Enter the Tailscale auth key: " TAILSCALE_AUTH_KEY

# Register and get the device's tailscale ip
sudo tailscale up --login-server https://buckfiddy.westus2.cloudapp.azure.com --authkey $TAILSCALE_AUTH_KEY
TAIL_SUBNET=$(tailscale ip | grep '^100.')

# Create a systemd service file for x11vnc
sudo bash -c 'cat <<EOF > /etc/systemd/system/x11vnc.service
[Unit]
Description=Start x11vnc at startup
After=multi-user.target

[Service]
Type=simple
# Tailsubnet for BuckFiddy is `100.192.0.`
ExecStart=/usr/bin/x11vnc -auth guess -forever -loop -noxdamage -repeat -rfbport 5900 -allow 100. -shared -ncache 0

[Install]
WantedBy=multi-user.target
EOF'

# Reload systemd daemon to recognize the new service
sudo systemctl daemon-reload

# Enable the x11vnc service to start at boot
sudo systemctl enable x11vnc.service

# Start the x11vnc service immediately
sudo systemctl start x11vnc.service

# Confirm the service is running
sudo systemctl status x11vnc.service
