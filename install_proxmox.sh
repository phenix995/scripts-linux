apt update
apt install -y vim git
echo "deb http://download.proxmox.com/debian/pve stretch pve-no-subscription" > /etc/apt/sources.list.d/pve-enterprise.list
apt update
apt upgrade -y
git clone https://github.com/phenix995/systemd-zram.git
chmod +x systemd-zram/install-zram.sh
