#!/bin/bash
sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade
sudo apt-get install ca-certificates git-core
sudo wget https://raw.github.com/Hexxeh/rpi-update/master/rpi-update -O /usr/bin/rpi-update && sudo chmod +x /usr/bin/rpi-update
sudo rpi-update
sudo reboot
