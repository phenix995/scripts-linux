#!/bin/bash
/bin/bash update.sh
apt install qemu-guest-agent qemu-utils
systemctl start qemu-guest-agent
apt install -y vim curl git htop bpytop wget tmux vim neofetch 
