#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "[-] Please run as root or with sudo."
    exit 1
fi

# Update package index
echo "[+] Updating package index..."
apt update

# Install required packages
echo "[+] Installing required packages..."
apt install -y apache2-utils

# Pull the Docker registry image
echo "[+] Pulling Docker registry image..."
docker pull registry:2

# Create a directory for Docker registry data
echo "[+] Creating directory for Docker registry data..."
mkdir -p /opt/registry/data

# Create a directory for Docker registry authentication
echo "[+] Creating directory for Docker registry authentication..."
mkdir -p /opt/registry/auth

# Create a user for Docker registry authentication
# Replace 'your_username' and 'your_password' with the desired username and password
echo "[+] Creating user for Docker registry authentication..."
htpasswd -bc /opt/registry/auth/htpasswd your_username your_password

# Create a Docker Compose file for the private Docker registry
echo "[+] Creating Docker Compose file..."
cat <<EOF > /opt/registry/docker-compose.yml
version: '3'
services:
  registry:
    image: registry:2
    ports:
      - "5000:5000"
    environment:
      REGISTRY_AUTH: htpasswd
      REGISTRY_AUTH_HTPASSWD_REALM: "Registry Realm"
      REGISTRY_AUTH_HTPASSWD_PATH: /auth/htpasswd
    volumes:
      - /opt/registry/data:/var/lib/registry
      - /opt/registry/auth:/auth
EOF

# Navigate to the registry directory
cd /opt/registry

# Start the private Docker registry using Docker Compose
echo "[+] Starting private Docker registry..."
docker-compose up -d

# Display the status of the private Docker registry
echo "[+] Displaying status of private Docker registry..."
docker-compose ps

# Instructions to configure Docker clients to use the private registry
echo "To configure Docker clients to use the private registry, you may need to log in using the following command:"
echo "docker login <your_server_ip>:5000"
echo "Replace <your_server_ip> with the IP address of your Azure VM."
