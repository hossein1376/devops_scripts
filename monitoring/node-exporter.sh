#!/bin/bash

# This script will install node_exporter on a linux machine.
# Hossein Yazdani, hosseinyazdani1376@gmail.com
# Last update: June 2024

# node_exporter version
version=1.8.1

# check if running as root, exit otherwise
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

# exit in case of error
set -e

# create the user and group node_exporter
groupadd -f node_exporter
useradd -g node_exporter --no-create-home --shell /bin/false node_exporter

# create the main settings folder and set the ownership
mkdir /etc/node_exporter
chown node_exporter:node_exporter /etc/node_exporter

# download and extract the files
wget https://github.com/prometheus/node_exporter/releases/download/v${version}/node_exporter-${version}.linux-amd64.tar.gz
tar xvf node_exporter-${version}.linux-amd64.tar.gz
cd node_exporter-${version}.linux-amd64 || { echo "Failed to change directory."; exit 1; }

# move to path and set the ownership
mv node_exporter /usr/local/bin/
chown node_exporter:node_exporter /usr/local/bin/node_exporter

# create systemd service file
cat >> /etc/systemd/system/node-exporter.service << EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# enable and start the service
systemctl daemon-reload
sleep 2
systemctl enable node-exporter
systemctl start node-exporter
systemctl status node-exporter

# add node-exporter to the Prometheus config file
echo "
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']
" >> /etc/prometheus/prometheus.yml
systemctl restart prometheus

# cleanup
cd ..
rm node_exporter-${version}.linux-amd64.tar.gz
rm -rf node_exporter-${version}.linux-amd64