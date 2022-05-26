#run as root
#source https://www.vultr.com/docs/how-to-install-a-minecraft-server-on-debian-11/


ufw default deny
ufw allow qq22
ufw allow 11265
ufw enable
ufw status verbose

apt update
apt upgrade -y
apt autoremove -y
reboot
