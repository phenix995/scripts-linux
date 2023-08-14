#!/bin/bash
source install-lxc-basic.sh
source dist-upgrade-nala.sh

# Postgres (v12+)
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | sudo tee  /etc/apt/sources.list.d/pgdg.list
sudo apt-get update
sudo apt-get install -y postgresql-12 postgresql-client-12

#Elixir (v1.12+)
wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb && sudo dpkg -i erlang-solutions_2.0_all.deb
sudo apt-get update
sudo apt-get install -y elixir esl-erlang

# Grafana (v8.3.4+) & Plugins
sudo apt-get install -y apt-transport-https software-properties-common
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y grafana
sudo systemctl start grafana-server
sudo systemctl enable grafana-server.service # to start Grafana at boot time

sudo grafana-cli plugins install pr0ps-trackmap-panel 2.1.2
sudo grafana-cli plugins install natel-plotly-panel 0.0.7
sudo grafana-cli --pluginUrl https://github.com/panodata/panodata-map-panel/releases/download/0.16.0/panodata-map-panel-0.16.0.zip plugins install grafana-worldmap-panel-ng
sudo systemctl restart grafana-server

# MQTT Broker
sudo apt-get install -y mosquitto

# Node.js (v14+)
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt-get install -y nodejs

# Clone TeslaMate git repository
git clone https://github.com/adriankumpf/teslamate.git /usr/src

# Set your system locale
sudo locale-gen en_CA.UTF-5
sudo localectl set-locale LANG=en_CA.UTF-5

touch /etc/systemd/system/teslamate.service
echo "[Unit]
Description=TeslaMate
After=network.target
After=postgresql.service

[Service]
Type=simple
# User=username
# Group=groupname

Restart=on-failure
RestartSec=5

Environment="HOME=/usr/src/teslamate"
Environment="LANG=en_US.UTF-8"
Environment="LC_CTYPE=en_US.UTF-8"
Environment="TZ=Europe/Berlin"
Environment="PORT=4000"
Environment="ENCRYPTION_KEY=your_secure_encryption_key_here"
Environment="DATABASE_USER=teslamate"
Environment="DATABASE_PASS=#your secure password!
Environment="DATABASE_NAME=teslamate"
Environment="DATABASE_HOST=127.0.0.1"
Environment="MQTT_HOST=127.0.0.1"

WorkingDirectory=/usr/src/teslamate

ExecStartPre=/usr/src/teslamate/_build/prod/rel/teslamate/bin/teslamate eval "TeslaMate.Release.migrate"
ExecStart=/usr/src/teslamate/_build/prod/rel/teslamate/bin/teslamate start
ExecStop=/usr/src/teslamate/_build/prod/rel/teslamate/bin/teslamate stop

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/teslamate.service

