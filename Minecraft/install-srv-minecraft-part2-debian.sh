#run as debian user
#based on https://www.vultr.com/docs/how-to-install-a-minecraft-server-on-debian-11/


#Install the Temurin 17 OpenJDK Distribution
sudo apt install wget apt-transport-https -y
wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo tee /usr/share/keyrings/adoptium.asc
echo "deb [signed-by=/usr/share/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/adoptium.list

sudo apt update
sudo apt install temurin-17-jdk -y

echo "export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")" | sudo tee -a /etc/profile && source /etc/profile
echo "export PATH=$PATH:$JAVA_HOME/bin" | sudo tee -a /etc/profile && source /etc/profile
echo $JAVA_HOME
echo $PATH

#Install Minecraft Java Edition Server 1.18.2
sudo mkdir /opt/minecraft
sudo chown mcninja:mcninja /opt/minecraft

cd /opt/minecraft
wget https://launcher.mojang.com/v1/objects/c8f83c5655308435b3dcf03c06d9fe8740a77469/server.jar -O minecraft_server.1.18.2.jar
echo "eula=true" > /opt/minecraft/eula.txt

touch /opt/minecraft/start.sh
echo "java -Xmx1024M -Xms256M -jar minecraft_server.1.18.2.jar nogui" >> /opt/minecraft/start.sh
chmod +x /opt/minecraft/start.sh

#Install Supervisor
sudo apt install supervisor -y
supervisord -v
sudo systemctl daemon-reload
sudo systemctl start supervisor.service
sudo systemctl enable supervisor.service
touch /etc/supervisor/conf.d/minecraft.conf
echo "[program:minecraft]" >> /etc/supervisor/conf.d/minecraft.conf
echo "directory=/opt/minecraft/" >> /etc/supervisor/conf.d/minecraft.conf
echo "command=/opt/minecraft/start.sh" >> /etc/supervisor/conf.d/minecraft.conf
user=debian
auto_start=true
autorestart=true
stderr_logfile=/var/log/supervisor/error_minecraft.log
stderr_logfile_maxbytes=100MB
stdout_logfile=/var/log/supervisor/out_minecraft.log
stdout_logfile_maxbytes=100MB

sudo supervisorctl reread
sudo supervisorctl update
