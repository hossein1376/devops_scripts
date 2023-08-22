#!/bin/bash

# This script will remove Prometheus from a linux machine.
# Hossein Yazdani, hosseinyazdani1376@gmail.com
# August 2023

# check if running as root, or exit
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

# exit in case of error
set -e

# remove its files
rm /usr/local/bin/prometheus /usr/local/bin/promtool
rm -r /etc/prometheus /var/lib/prometheus

# remove prometheus user
userdel prometheus

# remove the service
systemctl stop prometheus
systemctl disable prometheus
rm /etc/systemd/system/prometheus.service
systemctl daemon-reload