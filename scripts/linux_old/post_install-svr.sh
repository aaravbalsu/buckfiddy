#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root or with sudo."
    exit 1
fi

# Define directories and file paths
declare -A USERS 
USERS=(
    ["soxballs"]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDZYf3LETboy0X+c9uEpZJ71OYH9GJZa/nDxlrOw2Pbs6TxyAOuluK6beqNZjqX0ytv/4h/Z1kAmkqT/Fq7AsbAA5w2AFimIIO/59WV9YRJdoDVxsy9y3ZiXOUA3GoLO41MNzzbSBjghsf4QwwQOEPCjIfrLWou0MqpYqS1MYDD6MTqgLvm/+jhanFVz5Hek7u45yso3+7RZnAgiytQX6n/vCXHqcGbc1yFQjAuZmkj3+tqJ5VL02E5BVu4rTZfpyDfY+sPq0ycLLmf7a8MptIzTMUPyk6PD0AN8ermsCtXyWeC3wA8G9HSQtl/wBiYPMUS7R3F+XA5bd+A17HQS+t0aUajjlmLV/uTgos51kucT+eIKaVhi68IThMU0942/TEGSmAan12fo+Q9sQikY548aLYgmS735TcJ66tt3F4isVh+02kDwhkWRdhYwO49UaUXhj9uCBpXcUfScd8J4yrlA0itWooC+FmyoKLSjVJqaEah6X++vOvK6MrIJ/kl3TGYXXqmMVsIMfxyYBmctsB8EfhDfb8UtS3E5AUd/oowVxk3S/uVtb4vVpmMaxLSR+wNsPB8s+nXoqoePuPTw2/2pqIfHWgUgUfNXB5P9If/pcwmXjOuqADt3oUmU0c00lo4/JuY3YOiwibhWEU+fvurDqstPisctJERudhp/efpmw== soxballs"
    ["ping00"]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/tMY25/kV/GpPNln+GoFG5UmWC8GSizkwyjJKTtlIqDxcrsTi+v0UfZ3YDEdRiIXtjT8hcr9yQkC9yRxNdd/e0uDgLOjgC+Lbr1NhLNYUo3lP5E+q5B7TDzo2YlUhZwjQt2BD1SBkPfdz8+GmynKJJXCDHKN627/WbNthfUktnpbHbcKc5hFX477trnpZZ5KY2rJ7J8RSYxdZpkbOmh7bzM1Nddxo9kHP5Q2dZpEI47Mmd3PWnNQ0zJlD2rT1AuuXHlGFkYHBrGlpaW4ZR6ZrQuxWZ6n4l8CvBasY8pLd41eiBdYpBPTzW54jfIYX9TPo0z0lZgK1WXu3iGuGdR+AtH/hcYvDhJEcdRb5drMdcuD+ZgT/8XrLjFK/kSfFupTRMQqWUGQ2TBNRgTxZBdUzlSJ28Etwr2kIzJGjV0LM0GYZGqylCQzJbNYSSzNk+UmjZY0szTVLiOlJfGKiNSty5RSNN3JtWOOTqil45lBrHPI4A89rclYioKJZu9ZcEf6GHe/zPu1ULhgvXMW3Wou+i7upcMYvp5QyJDNRDjOhvABIXofu8Btb3NE5I4nbAR3l6p27ph1KrAp558yBBilEZ+SwUVbAaWHA1HYlpKdIVgiLlg/MVmsBe5Kjx3riSJ1GjTko9VM5d1D2TxnMEWwDnHW+Zwk0ZrRpFxHD+H5jiQ== ping00"
)

# Function to reate a user when one doesn't exist
create_user_if_not_exists() {
    local username=$1
    if id "$username" &>/dev/null; then
        echo "[-] User $username already exists."
    else
        echo "[+] User $username does not exist. Creating a new user..."
        sudo useradd -m "$username"
        sudo usermod -aG sudo "$username"
    fi
}

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
# Install Docker and Reqs
###

# Update sources
echo "[+] Updating sources..."
sudo apt update

# Install required packages
echo "[+] Installing required packages..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add GPG keys for Docker repository
echo "[+] Adding GPG keys for Docker source repository..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add Docker repository
echo "[+] Adding Docker source repository..."
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

# Installing from Docker repository (not Ubuntu default repository)
echo "[+] Updating sources to include Docker repository..."
sudo apt update

# Install Docker
echo "[+] Installing Docker..."
sudo apt install -y docker-ce

# Check Docker service status
echo "[+] Checking Docker service status..."
sudo systemctl status docker

# Add users to the `docker` group
for USER in "${!USERS[@]}"; do
    echo "[+] Adding user $USER to the docker group..."
    sudo usermod -aG docker "$USER"
done

###
# Install Docker Compose
###
# Download latest release
echo "[+] Downloading Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.27.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Set correct permissions
echo "[+] Setting permissions for Docker Compose..."
sudo chmod +x /usr/local/bin/docker-compose

# Verify Docker Compose installation
echo "[+] Verifying Docker Compose installation..."
docker-compose --version
