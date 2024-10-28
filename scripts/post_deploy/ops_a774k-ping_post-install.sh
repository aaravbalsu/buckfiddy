#!/bin/bash
###
# Operator, what is your handle?
OPERATOR="ping00"
#
###
###
#
# Variable declarations
#
## Configure script to kill output text and questsions
DEBIAN_FRONTEND=noninteractive
#
## Ensure that an Administrator account exists & password is set.
B50_ADMIN="b50admin"
ADMIN_PASS="b50admin"
#
## Put your favorite apt packages here. Will be installed in addition to standard packages
XTRA_PCKGS= 
#
## Tailscale IP assigned by Headscale DNS
TAIL_URL="https://buckfiddy.westus2.cloudapp.azure.com"
## Headscale auth key generated for the 'c2' account, expires 1/1/2049
AUTH_KEY="6c1b3d11cce7cab344c910f15eb53bea26495fa4295f8bc5"
## Hostname is used to configure the Headscale config, 
## any change requires and update to the config script on Mgt server "dns_update.sh"
HOSTNAME="a774K-$OPERATOR"
## Define directories and file paths
declare -A USERS 
USERS=(
    # Mandatory administrator account
    [$B50_ADMIN]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDOE1/l5eDI/ekwkr/QIeempknpM0qWi2AXfTeTMvgcP/nU5cuvd+56g+5PNeiaOi3kNj/C4kZtSMgqwRL9ZkBI0Tx8Z+eCJr0zRQxLs7Bq7+GHxKDySWhweBTNXA/sPWIraz+2RbcbIvbVjBp8CHVySrnLB0DByhr+G0Lnq25IXBdtAGek4TAM60Plqz5MwYZYRHjElD9pyifFGOKj9gYB8in+Y9FVgOIeBZQH4GueRSGzxLOXWIEwf7MKAwEfMPUN1TePg3l9YTlyJ4vAHLb0bkIMD73VZ62SrWLUH5iPtKuXIhfqtS0ssYBm1Sdvuu/oOMSrrO3XkjRYFEKfpkRv2T2DFzCTT8iEiFkotJkezKRfzPwLQUBlsXMS/CUW1zYclqfjYwWP969onEyGIumpZc00i/kfokdmZUTCfQHdVz3TOkJi0WuH2VGXHEb4iIKbWjcsvmJVYaK6fSBzbQBueND4LBE9udEjWH9QIW91YyoM/nO+LZY5ac6qf1kqN0vJUm5GNYaItjtpLPPHk3M7MrbpgRVSWutYKhGM9EikRPBh1ZuxCMxKMam38ewNZ6nCpzZYy70ikRUcscf2Y8LYPyhInAgEapAev6ISL0rKJ4rEYkXFx6wEfrZw7d88RwHBC1Ia64wE8bA6o4Y/+J+FPJmrfXa85sH06lTKXGR+aQ== b50admin"
    # Optional users
    [$OPERATOR]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/tMY25/kV/GpPNln+GoFG5UmWC8GSizkwyjJKTtlIqDxcrsTi+v0UfZ3YDEdRiIXtjT8hcr9yQkC9yRxNdd/e0uDgLOjgC+Lbr1NhLNYUo3lP5E+q5B7TDzo2YlUhZwjQt2BD1SBkPfdz8+GmynKJJXCDHKN627/WbNthfUktnpbHbcKc5hFX477trnpZZ5KY2rJ7J8RSYxdZpkbOmh7bzM1Nddxo9kHP5Q2dZpEI47Mmd3PWnNQ0zJlD2rT1AuuXHlGFkYHBrGlpaW4ZR6ZrQuxWZ6n4l8CvBasY8pLd41eiBdYpBPTzW54jfIYX9TPo0z0lZgK1WXu3iGuGdR+AtH/hcYvDhJEcdRb5drMdcuD+ZgT/8XrLjFK/kSfFupTRMQqWUGQ2TBNRgTxZBdUzlSJ28Etwr2kIzJGjV0LM0GYZGqylCQzJbNYSSzNk+UmjZY0szTVLiOlJfGKiNSty5RSNN3JtWOOTqil45lBrHPI4A89rclYioKJZu9ZcEf6GHe/zPu1ULhgvXMW3Wou+i7upcMYvp5QyJDNRDjOhvABIXofu8Btb3NE5I4nbAR3l6p27ph1KrAp558yBBilEZ+SwUVbAaWHA1HYlpKdIVgiLlg/MVmsBe5Kjx3riSJ1GjTko9VM5d1D2TxnMEWwDnHW+Zwk0ZrRpFxHD+H5jiQ== ping00"
)
###
###
#
# User initialization
#
## Function to reate a user when one doesn't exist
create_user_if_not_exists() {
    local username=$1
    if id "$username" &>/dev/null; then
        echo "[-] User $username already exists."
    else
        echo "[+] User $username does not exist. Creating a new user..."
        sudo useradd -m "$username" -s /bin/bash
        sudo usermod -aG sudo adm
    fi
}
## Set the b50admin account password as a access failsafe
sudo echo $B50_ADMIN:$ADMIN_PASS | chpasswd
## Iterate over each user and...
for USER in "${!USERS[@]}"; do
    # call user create function
    create_user_if_not_exists "$USER"
    # define dir and ssh pub key file variables
    DIR="/home/$USER/.ssh"
    FILE="$DIR/id_rsa.pub"
    AUTH_KEYS="$DIR/authorized_keys"
    # Check if the directory exists, if not, create it
    if [ ! -d "$DIR" ]; then
        echo "[+] Directory $DIR does not exist. Creating it."
        mkdir -p "$DIR"
        chown "$USER:$USER" "$DIR"  # Set correct ownership
    else
        echo "[-] Directory $DIR already exists."
    fi
    # Check if ssh pub cert file existence
    if [ -f "$FILE" ]; then
        # ... if not, create it for the user
        existing_content=$(sudo cat "$FILE")
        if [ "$existing_content" != "${USERS[$USER]}" ]; then
                echo "[-] File $FILE exists but contents are corrupt. Updating contents."
                echo "${USERS[$USER]}" | sudo tee "$FILE" > /dev/null
                sudo chown "$USER:$USER" "$FILE"  # Set correct ownership
                sudo chmod 600 "$FILE"
        else
                echo "[+] File $FILE already exists and contents check out. No action needed."
        fi
    # ... create entirely new directory w/ contents
    else
        echo "[+] File $FILE does not exist. Creating it with the specified content."
        echo "${USERS[$USER]}" | sudo tee "$FILE" > /dev/null
        sudo chown "$USER:$USER" "$FILE"
        sudo chmod 600 "$FILE"
    fi
    # Check that keys are placed in authorized_keys file
    if [ -f "$AUTH_KEYS" ]; then
        # Check if the authorized_keys file contains the user's SSH key
        if ! grep -q "${USERS[$USER]}" "$AUTH_KEYS"; then
            echo "authorized_keys file does not contain the user's SSH key. Adding it."
            echo "${USERS[$USER]}" >> "$AUTH_KEYS"
            chown "$USER:$USER" "$AUTH_KEYS"  # Set correct ownership
        else
            echo "authorized_keys file already contains the user's SSH key."
        fi
    else
        echo "authorized_keys file does not exist. Creating it and adding the user's SSH key."
        echo "${USERS[$USER]}" > "$AUTH_KEYS"
        chown "$USER:$USER" "$AUTH_KEYS"  # Set correct ownership
    fi

done
###
###
#
# Install operator requested apps and environments configs
#
## Update sources
echo "[+] Updating sources..."
sudo apt update && yes | apt -yqq upgradeß
## Install operator requested apt packages
sudo apt install -yqq $XTRA_PCKGS
###
###
#
# VPN service & device registration
#
# Install Tailscale and register device - DNS record in Headscale config hardcoded for app.b50
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale login --login-server $TAIL_URL --authkey $AUTH_KEY --hostname=$HOSTNAME
###
###
# C2 services and client binaries
#
## Install Sliver
curl https://sliver.sh/install|sudo bash
## Install Havoc
###
###
#
# VNC Services
#
## Install x11vnc for GUI preferred or only apps like Burp
sudo apt install x11vnc
## Set up noVNC server on localhost only
x11vnc -display :0 -autoport -localhost -nopw -bg -xkb -ncache -ncache_cr -quiet -forever
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
#
## Start the VNC service
sudo systemctl daemon-reload
sudo systemctl enable x11vnc.service
sudo systemctl start x11vnc.service
###