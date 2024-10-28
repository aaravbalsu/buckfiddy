#!/bin/bash

# Check if the script is run as root
#if [ "$EUID" -ne 0 ]; then
#    echo "Please run as root or with sudo."
#    exit 1
#fi
DEBIAN_FRONTEND=noninteractive

# Ensure that an Administrator account exists & password is set.
B50_ADMIN="b50admin"
ADMIN_PASS="b50admin"

# Tailscale IP assigned by Headscale DNS
TAIL_URL="https://buckfiddy.westus2.cloudapp.azure.com"
# Headscale auth key generated for the 'c2' account, expires 1/1/2049
AUTH_KEY="6c1b3d11cce7cab344c910f15eb53bea26495fa4295f8bc5"
# Hostname is used to configure the Headscale config, 
# any change requires and update to the config script on Mgt server "dns_update.sh"
HOSTNAME="rdrct"

# Define directories and file paths
declare -A USERS 
USERS=(
    # Mandatory administrator account
    [$B50_ADMIN]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDOE1/l5eDI/ekwkr/QIeempknpM0qWi2AXfTeTMvgcP/nU5cuvd+56g+5PNeiaOi3kNj/C4kZtSMgqwRL9ZkBI0Tx8Z+eCJr0zRQxLs7Bq7+GHxKDySWhweBTNXA/sPWIraz+2RbcbIvbVjBp8CHVySrnLB0DByhr+G0Lnq25IXBdtAGek4TAM60Plqz5MwYZYRHjElD9pyifFGOKj9gYB8in+Y9FVgOIeBZQH4GueRSGzxLOXWIEwf7MKAwEfMPUN1TePg3l9YTlyJ4vAHLb0bkIMD73VZ62SrWLUH5iPtKuXIhfqtS0ssYBm1Sdvuu/oOMSrrO3XkjRYFEKfpkRv2T2DFzCTT8iEiFkotJkezKRfzPwLQUBlsXMS/CUW1zYclqfjYwWP969onEyGIumpZc00i/kfokdmZUTCfQHdVz3TOkJi0WuH2VGXHEb4iIKbWjcsvmJVYaK6fSBzbQBueND4LBE9udEjWH9QIW91YyoM/nO+LZY5ac6qf1kqN0vJUm5GNYaItjtpLPPHk3M7MrbpgRVSWutYKhGM9EikRPBh1ZuxCMxKMam38ewNZ6nCpzZYy70ikRUcscf2Y8LYPyhInAgEapAev6ISL0rKJ4rEYkXFx6wEfrZw7d88RwHBC1Ia64wE8bA6o4Y/+J+FPJmrfXa85sH06lTKXGR+aQ== b50admin"
    # Optional users
    ["soxballs"]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCwDfe3mIoqiUKjkuCkYqw2DYPr/SuD/vRq4DSYiNELgROklIVKlqPq3lt97eeeGkK34jvbtUcB2ySdbhNunSTKl2fTsp8JscBSQQVSK7uy+79EdJ+7m0tDNrewZ6gNjlw2ZKxTWYKWFoZ1NtrxXt7ohlj5tIDyeom6sTY13G5gIiJx9nZr3jGjlNE7n/P6EAXs1n1VkT8z9au6LXriT7KOrsBQzqHKLWcaCrur/u/hTCWc19bZCIFpRTgH+NdJ275QjhKG6lexR4+AMH9j3o+HcZAXKiX/e0TpvNoQ4hv4gSzzmvx+9xzMYZxV8pFc8o/klgLc0vkB7vnjubOxYl1wvx6V3wO1xU1NRrsSxN3+L1Wj7wSqW/dSXFEmFJ5atlirQZ3jTDUfxDEOz4FK56/toCBDwdcja8+Cy41dqsJYcUu683gCzlTFeMy7LvAoBqJNqEj2mZkYDujch+GQ2PFFiOASfTiGZ+/cWCb0yz6U+WYdt2ap3PIQPYZ/g/VAoXE= soxballs"
    ["ping00"]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/tMY25/kV/GpPNln+GoFG5UmWC8GSizkwyjJKTtlIqDxcrsTi+v0UfZ3YDEdRiIXtjT8hcr9yQkC9yRxNdd/e0uDgLOjgC+Lbr1NhLNYUo3lP5E+q5B7TDzo2YlUhZwjQt2BD1SBkPfdz8+GmynKJJXCDHKN627/WbNthfUktnpbHbcKc5hFX477trnpZZ5KY2rJ7J8RSYxdZpkbOmh7bzM1Nddxo9kHP5Q2dZpEI47Mmd3PWnNQ0zJlD2rT1AuuXHlGFkYHBrGlpaW4ZR6ZrQuxWZ6n4l8CvBasY8pLd41eiBdYpBPTzW54jfIYX9TPo0z0lZgK1WXu3iGuGdR+AtH/hcYvDhJEcdRb5drMdcuD+ZgT/8XrLjFK/kSfFupTRMQqWUGQ2TBNRgTxZBdUzlSJ28Etwr2kIzJGjV0LM0GYZGqylCQzJbNYSSzNk+UmjZY0szTVLiOlJfGKiNSty5RSNN3JtWOOTqil45lBrHPI4A89rclYioKJZu9ZcEf6GHe/zPu1ULhgvXMW3Wou+i7upcMYvp5QyJDNRDjOhvABIXofu8Btb3NE5I4nbAR3l6p27ph1KrAp558yBBilEZ+SwUVbAaWHA1HYlpKdIVgiLlg/MVmsBe5Kjx3riSJ1GjTko9VM5d1D2TxnMEWwDnHW+Zwk0ZrRpFxHD+H5jiQ== ping00"
)

# Function to reate a user when one doesn't exist
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
# Set the b50admin account password as a access failsafe
sudo echo $B50_ADMIN:$ADMIN_PASS | chpasswd

# Iterate over each user
for USER in "${!USERS[@]}"; do
    # Create the user if it does not exist
    create_user_if_not_exists "$USER"

    # Define dir and ssh pub key file variables
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

    if [ -f "$FILE" ]; then
        # Check if the ssh pub cert file exists, if not, create it for the user
        existing_content=$(sudo cat "$FILE")
        if [ "$existing_content" != "${USERS[$USER]}" ]; then
                echo "[-] File $FILE exists but contents are corrupt. Updating contents."
                echo "${USERS[$USER]}" | sudo tee "$FILE" > /dev/null
                sudo chown "$USER:$USER" "$FILE"  # Set correct ownership
                sudo chmod 600 "$FILE"
        else
                echo "[+] File $FILE already exists and contents check out. No action needed."
        fi
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
# Install Server specific apps and reqs
###

# Update sources
echo "[+] Updating sources..."
sudo apt update

# Install required packages
echo "[+] Installing required packages..."
sudo apt install -yqq socat screen curl

# Install Tailscale and register device 
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale login --login-server $TAIL_URL --authkey $AUTH_KEY --hostname=$HOSTNAME

###
# Set up Socat directors in screen sessions as a service
sudo bash -c 'cat <<EOF > /etc/systemd/system/socat_handlers.service
[Unit]
Description=Socat Handlers for MSF
After=network.target

[Service]
Type=forking
ExecStart=/bin/bash -c '\
screen -dmS win_https-msf_handler socat TCP4-LISTEN:443,fork TCP4:ops.infra.b50:8443; \
screen -dmS win_tcp-msf_handler socat TCP4-LISTEN:4444,fork TCP4:ops.infra.b50:4444; \
screen -dmS linux-x86_tcp-msf_handler socat TCP4-LISTEN:6444,fork TCP4:ops.infra.b50:6444; \
screen -dmS linux-x64_tcp-msf_handler socat TCP4-LISTEN:8444,fork TCP4:ops.infra.b50:8444'
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl daemon-reload
sudo systemctl enable socat_handlers.service
sudo systemctl start socat_handlers.service
##