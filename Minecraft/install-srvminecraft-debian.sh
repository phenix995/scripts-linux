#run as root
#based on https://www.vultr.com/docs/how-to-install-a-minecraft-server-on-debian-11/

#Configure Firewall ufw
ufw default deny
ufw allow qq22
ufw allow 11265
ufw enable
ufw status verbose

#Configure fail2ban
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
echo "ignoreip = 192.168.1.0/24" > /etc/fail2ban/jail.local

echo "[sshd]" > /etc/fail2ban/jail.d/ssh.conf
echo "enabled = true = true" > /etc/fail2ban/jail.d/ssh.conf
echo "port = 1122" > /etc/fail2ban/jail.d/ssh.conf
echo "filter = sshd" > /etc/fail2ban/jail.d/ssh.conf
echo "logpath = /var/log/auth.log" > /etc/fail2ban/jail.d/ssh.conf
echo "maxretry = 3" > /etc/fail2ban/jail.d/ssh.conf
echo "bantime = 300" > /etc/fail2ban/jail.d/ssh.conf
echo "ignoreip = whitelist-IP" > /etc/fail2ban/jail.d/ssh.conf

systemctl start fail2ban

apt update
apt upgrade -y
apt autoremove -y
reboot
