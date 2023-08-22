#!/bin/bash

# This script will remove node_exporter from a linux machine.
# Hossein Yazdani, hosseinyazdani1376@gmail.com
# August 2023

# check if running as root, or exit
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

# exit in case of error
set -e

# remove binary
rm /usr/local/bin/node_exporter

# remove node_exporter user
userdel node_exporter

# remove the service
systemctl stop node_exporter
systemctl disable node_exporter
rm /etc/systemd/system/node_exporter.service
systemctl daemon-reload