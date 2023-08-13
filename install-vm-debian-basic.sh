#!/bin/bash
#run as root
<<<<<<<< HEAD:install-vm-basic-debian.sh
source dist-upgrade-apt.sh
========

>>>>>>>> cba813f108213feffa1c6869872c3c4434e59b1c:install-vm-debian-basic.sh
apt install -y sudo
apt install -y qemu-guest-agent qemu-utils
systemctl start qemu-guest-agent
apt install -y vim curl git htop bpytop wget tmux neofetch ufw fail2ban net-tools cifs-utils nala
usermod -aG sudo debian
