#!/bin/bash

# cd /tmp
# echo "Installing Node Exporter..."
# wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
# sudo tar -xvf node_exporter-1.6.1.linux-amd64.tar.gz
# sudo mv node_exporter-1.6.1.linux-amd64/node_exporter /usr/bin/

# #Creating a node_exporter user to run the service
# sudo useradd -rs /bin/false node_exporter

# sudo vim node-exporter.sh && sudo chmod +x node-exporter.sh

echo "Creating a node_exporter user to run the service"
sudo useradd -rs /bin/false node_exporter

echo "Set up Node Exporter as a service"
# /etc/systemd/system/node_exporter.service

sudo tee /etc/systemd/system/prometheus-node-exporter.service > /dev/null <<EOL
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/bin/prometheus-node-exporter

[Install]
WantedBy=multi-user.target
EOL

echo "reload service and start"
sudo systemctl daemon-reload
sudo systemctl enable prometheus-node-exporter
sudo systemctl start prometheus-node-exporter

# sudo vim /etc/prometheus/prometheus.yml
# echo "Configuring Node Exporter as a Prometheus target"
# sudo tee /etc/prometheus/prometheus.yml > /dev/null <<EOL
# - job_name: 'node_exporter_metrics'
#    scrape_interval: 5s
#    static_configs:
#      - targets: ['localhost:9100']

# EOL