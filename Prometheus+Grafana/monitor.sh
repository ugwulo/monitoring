#!/bin/bash

# Update the system
echo "Updating system packages..."
sudo apt-get update -y && sudo apt-get upgrade -y

# Install Grafana
sudo apt-get install -y software-properties-common
echo "Installing Grafana..."
curl https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
sudo apt-get update -y && sudo apt-get install -y grafana

#Starting the Grafana Service
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

# Install Prometheus
echo "Installing Prometheus..."
# Add your Prometheus installation commands here
sudo apt-get install prometheus -y

sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

# Install Node Exporter
cd /tmp
echo "Installing Node Exporter..."
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
sudo tar -xvf node_exporter-1.6.1.linux-amd64.tar.gz
sudo mv node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/

#Creating a node_exporter user to run the service
sudo useradd -rs /bin/false node_exporter

# Set up Node Exporter as a service
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOL
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

#Configuring Node Exporter as a Prometheus target
#sudo tee /etc/prometheus/prometheus.yml > /dev/null <<EOL
#- job_name: 'Node_Exporter'
 #   scrape_interval: 5s
  #  static_configs:
   #   - targets: ['localhost:9100']

#EOL

#sudo systemctl restart prometheus

# Final Message
echo "Prometheus, Node Exporter, and Grafana have been installed and started successfully!"


Add Push Gateway to collect logs from Pipeline runs or external sources
Requires basic auth config for ssecure access, can also use nginx for reverse proxy

Use AlertManager for push notification
