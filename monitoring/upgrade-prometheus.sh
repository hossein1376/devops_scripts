#!/bin/bash

# This script will upgrade Prometheus on a linux machine.
# Hossein Yazdani, hosseinyazdani1376@gmail.com
# Last update: June 2024

# Prometheus version
version=2.52.0

# check if running as root, or exit
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

# exit in case of error
set -e

# download and extract the files
wget https://github.com/prometheus/prometheus/releases/download/v${version}/prometheus-${version}.linux-amd64.tar.gz
tar xvf prometheus-${version}.linux-amd64.tar.gz
cd prometheus-${version}.linux-amd64 || { echo "Failed to change directory."; exit 1; }

# remove old binaries
rm /usr/local/bin/prometheus /usr/local/bin/promtool

# move the main binaries and set the ownership
mv prometheus /usr/local/bin
mv promtool /usr/local/bin
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool

# remove old console files
rm -r /etc/prometheus/consoles /etc/prometheus/console_libraries

mv consoles /etc/prometheus
mv console_libraries /etc/prometheus

chown -R prometheus:prometheus /etc/prometheus/consoles
chown -R prometheus:prometheus /etc/prometheus/console_libraries

systemctl restart prometheus
systemctl status prometheus

# cleanup
cd ..
rm prometheus-${version}.linux-amd64.tar.gz
rm -rf prometheus-${version}.linux-amd64