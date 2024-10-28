#!/bin/bash
# Taken mostly from Havoc's install guide: https://havocframework.com/docs/installation

# Pull latest Havoc release from Git into current dir
sudo rm -rf ./Havoc
git clone https://github.com/HavocFramework/Havoc.git
ç
# Install Havoc reqs
cd Havoc
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install -yqq python3.10 python3.10-dev
sudo apt install -yqq git build-essential apt-utils cmake \
libfontconfig1 libglu1-mesa-dev libgtest-dev libspdlog-dev libboost-all-dev libncurses5-dev \
libgdbm-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev libbz2-dev mesa-common-dev \
qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools libqt5websockets5 libqt5websockets5-dev \
qtdeclarative5-dev golang-go qtbase5-dev libqt5websockets5-dev python3-dev libboost-all-dev \
mingw-w64 nasm

# SUPER important on Ubuntu/Debian, cleans up broken paths. Fix documented almost nowhere...
sudo apt -yqq autoremove
#

# Setup Havoc Teamserver
cd ./teamserver
go mod download golang.org/x/sys
go mod download github.com/ugorji/go
cd ..

# Install musl Compiler & Build Binary (From Havoc Root Directory)
make ts-build

# Soft link to /usr/local/bin/havoc
sudo ln -s ${PWD}/havoc /usr/local/bin

# Run the teamserver
havoc server --profile ./profiles/havoc.yaotl -v --debug

