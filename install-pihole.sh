#!/bin/bash
# Base on https://docs.pi-hole.net/main/basic-install/

source install-lxc-basic.sh
source dist-upgrade-nala.sh

curl -sSL https://install.pi-hole.net | bash
