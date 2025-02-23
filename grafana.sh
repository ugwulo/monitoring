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
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

# sudo vim grafana.sh && sudo chmod +x grafana.sh

sudo systemctl status grafana-server --no-pager

# setup data source with git