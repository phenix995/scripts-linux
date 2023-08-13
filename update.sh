#!/bin/bash
apt update
apt upgrade -y && echo "Update OK" || echo "Update FAILED"
apt dist-upgrade -y && echo "Dist-Update OK" || echo "Dist-Update FAILED"
