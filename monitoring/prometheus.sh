#!/bin/bash

# This script will install Prometheus on a linux machine.
# Hossein Yazdani, hosseinyazdani1376@gmail.com
# Last update: December 2023

# Prometheus version
version=2.48.1

# check if running as root, or exit
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

# exit in case of error
set -e

# create group prometheus and add user prometheus
groupadd --system prometheus
useradd -s /sbin/nologin --system -g prometheus prometheus

# create the default folders
mkdir /etc/prometheus
mkdir /var/lib/prometheus

# download and extract the files
wget https://github.com/prometheus/prometheus/releases/download/v${version}/prometheus-${version}.linux-amd64.tar.gz
tar xvf prometheus-${version}.linux-amd64.tar.gz
cd prometheus-${version}.linux-amd64 || { echo "Failed to change directory."; exit 1; }

# move the main binaries and set the ownership
mv prometheus /usr/local/bin
mv promtool /usr/local/bin
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool

# move others files and settings
mv consoles /etc/prometheus
mv console_libraries /etc/prometheus
mv prometheus.yml /etc/prometheus

# set the ownership of config files
chown prometheus:prometheus /etc/prometheus
chown -R prometheus:prometheus /etc/prometheus/consoles
chown -R prometheus:prometheus /etc/prometheus/console_libraries
chown -R prometheus:prometheus /var/lib/prometheus

# create systemd service file
cat >> /etc/systemd/system/prometheus.service << EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

# enable and start the service
systemctl daemon-reload
sleep 2
systemctl enable prometheus
systemctl start prometheus
systemctl status prometheus

# cleanup
cd ..
rm prometheus-${version}.linux-amd64.tar.gz
rm -rf prometheus-${version}.linux-amd64