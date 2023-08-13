#run as root
apt update
apt install -y sudo
apt install -y qemu-guest-agent qemu-utils
systemctl start qemu-guest-agent
apt install -y vim curl git htop bpytop wget tmux neofetch ufw fail2ban net-tools cifs-utils nala
usermod -aG sudo debian
