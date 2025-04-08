#!/bin/bash

# Update the system
echo "Updating system packages..."
sudo apt-get update -y && sudo apt-get upgrade -y

# Install Prometheus
echo "Installing Prometheus..."
sudo apt-get install prometheus -y

# sudo vim prometheus.sh && sudo chmod +x prometheus.sh

#make promethues owner
# sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

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

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
 # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus-3'

 # Override the global default and scrape targets from this job every 5 seconds.
scrape_interval: 5s
scrape_timeout: 5s

 # metrics_path defaults to '/metrics'
 # scheme defaults to 'http'.

static_configs: 
 - targets: ['10.xxx:9090', '10xx:9090', '10xxx:9090']

  - job_name: node
 # If prometheus-node-exporter is installed, grab stats about the local
 # machine by default.
static_configs:
 - targets: ['10.xxx:9100', '10.xxx:9100', '10xxx1:9100']

  - job_name: 'otel-collector'
scrape_interval: 10s
static_configs:
 - targets: ['<pod-ip>:9090']


sudo systemctl daemon-reload && sudo systemctl enable prometheus

sudo systemctl restart prometheus && sudo systemctl status -l prometheus --no-pager

sudo lsof -i :9100


# reload without downtime
sudo systemctl stop prometheus --no-pager
sudo systemctl status prometheus --no-pager
curl -X POST http://localhost:9090/-/reload
