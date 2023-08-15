#!/bin/bash
source install-lxc-basic.sh
source dist-upgrade-nala.sh

mkdir /root/bin

git clone https://github.com/jonathancross/jc-docs.git
source jc-docs/upgrade-monero.sh