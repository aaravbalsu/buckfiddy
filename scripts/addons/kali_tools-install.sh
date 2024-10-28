#!/bin/bash

# B50 standard toolbox
DEBIAN_FRONTEND=noninteractive apt -yqq install curl wget vim git net-tools whois netcat-traditional pciutils \
    usbutils novnc x11nvc

# Install useful languages
DEBIAN_FRONTEND=noninteractive apt -yqq install python3-pip golang nodejs npm

# Install Kali Linux "Top 10" metapackage and a few cybersecurity useful tools
DEBIAN_FRONTEND=noninteractive apt -yqq install kali-tools-top10 exploitdb man-db dirb nikto wpscan uniscan lsof \
    apktool dex2jar ltrace strace binwalk

# Install ZSH shell with custom settings and set it as default shell
apt -yqq install zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
