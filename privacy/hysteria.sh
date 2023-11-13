#!/bin/bash

# This script will install Hysteria on a linux machine.
# Hossein Yazdani, hosseinyazdani1376@gmail.com
# October 2023

# check if running as root, or exit
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

# exit in case of error
set -e

# create the folder and cd into it
mkdir /root/hy
cd /root/hy || { echo "Failed to change directory."; exit 1; }

# download the binary
wget https://github.com/apernet/hysteria/releases/download/app%2Fv2.2.0/hysteria-linux-amd64

# give it execute permission
chmod +x ./hysteria-linux-amd64

# create the config file
cat >> ./config.yaml << EOF
listen: :443
tls:
  cert: /etc/letsencrypt/live/<doamin>/fullchain.pem
  key: /etc/letsencrypt/live/<doamin>/privkey.pem
obfs:
  type: salamander
  salamander:
    password: pass
auth:
  type: password
  password: your_password
quic:
  initStreamReceiveWindow: 8388608
  maxStreamReceiveWindow: 8388608
  initConnReceiveWindow: 20971520
  maxConnReceiveWindow: 20971520
  maxIdleTimeout: 60s
  maxIncomingStreams: 1024
  disablePathMTUDiscovery: false
bandwidth:
  up: 1 gbps
  down: 1 gbps
ignoreClientBandwidth: false
disableUDP: false
udpIdleTimeout: 60s
resolver:
  type: udp
  tcp:
    addr: 8.8.8.8:53
    timeout: 4s
  udp:
    addr: 8.8.4.4:53
    timeout: 4s
  tls:
    addr: 1.1.1.1:853
    timeout: 10s
    sni: cloudflare-dns.com
    insecure: false
EOF

# create systemd service file
cat >> /etc/systemd/system/hysteria.service << EOF
[Unit]
Description=Hysteria Service
After=network.target nss-lookup.target

[Service]
User=root
WorkingDirectory=/root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
ExecStart=/root/hy/hysteria-linux-amd64 server -c /root/hy/config.yaml
ExecReload=/bin/kill -HUP $MAINPID
StandardOutput=file:/root/hy/output.log
StandardError=file:/root/hy/output.log
Restart=always
RestartSec=5
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF

# enable and start the service
systemctl daemon-reload
sleep 2
systemctl enable hysteria
echo "Edit the config file located at /root/hy/cofig.yaml then run:"
echo "systemctl start hysteria"
