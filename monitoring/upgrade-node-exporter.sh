#!/bin/bash

# This script will upgrade node_exporter on a linux machine.
# Hossein Yazdani, hosseinyazdani1376@gmail.com
# Last update: June 2024

# node_exporter version
version=1.8.1

# check if running as root, or exit
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

# exit in case of error
set -e

# download and extract the files
wget https://github.com/prometheus/node_exporter/releases/download/v${version}/node_exporter-${version}.linux-amd64.tar.gz
tar xvf node_exporter-${version}.linux-amd64.tar.gz
cd node_exporter-${version}.linux-amd64 || { echo "Failed to change directory."; exit 1; }

# remove old binaries
rm /usr/local/bin/node_exporter

# move to path and set the ownership
mv node_exporter /usr/local/bin/
chown node_exporter:node_exporter /usr/local/bin/node_exporter

systemctl restart node-exporter
systemctl status node-exporter

# cleanup
cd ..
rm node_exporter-${version}.linux-amd64.tar.gz
rm -rf node_exporter-${version}.linux-amd64