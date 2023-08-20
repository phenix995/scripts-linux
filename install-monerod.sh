#!/bin/bash
# Base on https://github.com/jonathancross/jc-docs.git
# https://www.coincashew.com/coins/overview-xmr/guide-or-how-to-run-a-full-node
# https://sethforprivacy.com/guides/run-a-monero-node/#recommended-hardware

source install-lxc-basic.sh
source dist-upgrade-nala.sh

git clone https://github.com/phenix995/install-monerod.git ../install-monerod
source ../install-monerod/install-monerod.sh
