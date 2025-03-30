#!/bin/bash

# Update the system
echo "Updating system packages..."
sudo apt-get update -y && sudo apt-get upgrade -y

# Install Prometheus
echo "Installing Prometheus..."
sudo apt-get install prometheus -y

# sudo vim prometheus.sh && sudo chmod +x prometheus.sh

#make promethues owner
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

#sudo chown -R root:root /etc/prometheus

sudo chown -R prometheus:prometheus /etc/prometheus

sudo rm /lib/systemd/system/prometheus.service

# Set up Prometheus as a service
sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOL
[Unit]
Description=Prometheus Monitoring System
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/bin/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/mnt/data/prometheus/ \
    --storage.tsdb.min-block-duration=2h \
    --storage.tsdb.max-block-duration=2h \
    --web.listen-address=0.0.0.0:9090 \
    --storage.tsdb.retention.time=90d \
    --web.enable-lifecycle

Restart=always
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOL

sudo nano /etc/prometheus/prometheus.yml

sudo systemctl daemon-reload && sudo systemctl enable prometheus

sudo systemctl restart prometheus && sudo systemctl status prometheus --no-pager

# reload without downtime
sudo systemctl stop prometheus --no-pager
sudo systemctl status prometheus --no-pager
curl -X POST http://localhost:9090/-/reload