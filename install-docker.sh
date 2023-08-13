#!/bin/sh
# Based on https://gist.github.com/EvgenyOrekhov/1ed8a4466efd0a59d73a11d753c0167b

nala install -y gnupg

set -o errexit
set -o nounset

IFS=$(printf '\n\t')

# Docker
apt remove --yes docker docker-engine docker.io containerd runc || true
apt update
apt --yes --no-install-recommends install apt-transport-https ca-certificates
wget --quiet --output-document=- https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository --yes "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release --codename --short) stable"
apt update
apt --yes --no-install-recommends install docker-ce docker-ce-cli containerd.io
usermod --append --groups docker "$USER"
systemctl enable docker
printf '\nDocker installed successfully\n\n'

printf 'Waiting for Docker to start...\n\n'
sleep 5

# Docker Compose
wget --output-document=/usr/local/bin/docker-compose "https://github.com/docker/compose/releases/download/$(wget --quiet --output-document=- https://api.github.com/repos/docker/compose/releases/latest | grep --perl-regexp --only-matching '"tag_name": "\K.*?(?=")')/run.sh"
chmod +x /usr/local/bin/docker-compose
wget --output-document=/etc/bash_completion.d/docker-compose "https://raw.githubusercontent.com/docker/compose/$(docker-compose version --short)/contrib/completion/bash/docker-compose"
printf '\nDocker Compose installed successfully\n\n'
