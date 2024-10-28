#!/bin/bash

DEBIAN_FRONTEND=noninteractive

# Install reqs
apt -yqq install curl git

###
# Set up a Havoc client
sudo mkdir -p /opt/havoc
sudo chown b50admin /opt/havoc
cd /opt/havoc
git clone https://github.com/HavocFramework/Havoc.git

# Build the client Binary (From Havoc Root Directory)
cd ./Havoc
make client-build

# Add it to path
sudo ln ./havoc /usr/bin/havoc
sudo chown $USER /usr/bin/havoc
###

###
# Install Sliver client
curl https://sliver.sh/install | sudo bash
###

