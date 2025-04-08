
sudo tee monitor.sh > /dev/null <<EOL
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
sudo systemctl daemon-reload
sudo systemctl enable grafana-server

# Install Prometheus
echo "Installing Prometheus..."
# Add your Prometheus installation commands here
sudo apt-get install prometheus -y

sudo mkdir -p /mnt/data/prometheus 

sudo chown -R prometheus:prometheus /mnt/data/prometheus && sudo chmod -R 2775 /mnt/data/prometheus 

# sudo chown prometheus:prometheus /etc/prometheus/storage.yml

EOL


sudo chmod +x monitor.sh && sudo ./monitor.sh

sudo nano /lib/systemd/system/prometheus-node-exporter.service

sudo systemctl daemon-reload && sudo systemctl enable prometheus-node-exporter

sudo systemctl restart prometheus-node-exporter

sudo systemctl status -l prometheus-node-exporter --no-pager

sudo systemctl start prometheus

sudo systemctl status -l prometheus

sudo systemctl restart grafana-server

sudo systemctl status -l grafana-server --no-pager

# Set up Node Exporter as a service
# sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOL
# [Unit]
# Description=Node Exporter
# Wants=network-online.target
# After=network-online.target

# [Service]
# User=node_exporter
# Group=node_exporter
# Type=simple
# ExecStart=/usr/local/bin/node_exporter --web.listen-address=":9101"

# [Install]
# WantedBy=multi-user.target
# EOL


#Configuring Node Exporter as a Prometheus target
#sudo tee /etc/prometheus/prometheus.yml > /dev/null <<EOL
#- job_name: 'Node_Exporter'
 #   scrape_interval: 5s
  #  static_configs:
   #   - targets: ['localhost:9100']

#EOL

#sudo systemctl restart prometheus

sudo systemctl stop node_exporter
sudo systemctl disable node_exporter

# Remove the binary
sudo rm /usr/local/bin/node_exporter


sudo rm /etc/systemd/system/node_exporter.service


OTel collector setup