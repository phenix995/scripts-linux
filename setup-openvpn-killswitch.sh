#!/bin/bash
# based on https://adamtheautomator.com/linux-killswitch/

nala install -y openvpn ufw
systemctl start ufw
ufw allow ssh
ufw allow 5901:5910/tcp
ufw default deny outgoing
ufw default deny incoming
ufw allow out on tun0 from any to any
ufw allow in on tun0 from any to any
ufw allow out to 45.88.190.100 port 1194 proto udp
ufw enable
