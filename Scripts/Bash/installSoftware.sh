#!/bin/bash
#install software on debian, ubuntu, mint

sudo apt-get update
#7zip
sudo apt-get install p7zip-full -y
#java11
sudo apt install default-jdk -y

#python
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt-get update -y
sudo apt-get install python3.8 -y

#chromium
sudo apt-get install chromium-browser

#.net
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update; \
  sudo apt-get install -y apt-transport-https && \
  sudo apt-get update && \
  sudo apt-get install -y dotnet-sdk-5.0