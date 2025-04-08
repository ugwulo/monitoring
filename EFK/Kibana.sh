
sudo tee kibana.sh > /dev/null <<EOL
#!/bin/bash

# Install the GPG key for Elastic
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elastic-keyring.gpg

# Add the Elastic repository if it doesn't already exist
if [ ! -f /etc/apt/sources.list.d/elastic-8.x.list ]; then
  echo "Adding Elastic repository..."
  echo "deb [signed-by=/usr/share/keyrings/elastic-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
else
  echo "Elastic repository already exists."
fi

# Update package lists
sudo apt-get update -y

# Install Kibana
if ! dpkg -l | grep -q kibana; then
  echo "Installing Kibana..."
  sudo apt-get install -y kibana
else
  echo "Kibana is already installed."
fi

# Enable Kibana service to start on boot
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable kibana.service

sudo mkdir -p /mnt/data/log/kibana/
sudo chown -R kibana:kibana /mnt/data/log/kibana/
sudo chmod -R 2755 /mnt/data/log/kibana/
EOL

sudo chmod +x kibana.sh && ./kibana.sh

# Start Kibana service
sudo systemctl restart kibana.service

# Check Kibana service status
sudo systemctl status -l kibana.service --no-pager



#----------------------------------------------------------

sudo systemctl stop kibana.service

sudo systemctl restart kibana.service

#Open the Kibana configuration file for editing:
sudo nano /etc/kibana/kibana.yml

# Kibana server configuration
#server.host: "localhost"

# Elasticsearch connection
#elasticsearch.hosts: ["https://localhost:9200"]

# Enable authentication
#elasticsearch.username: "elastic"
#elasticsearch.password: "psswd"

#Version: 8.17.0

sudo /usr/share/elasticsearch/bin/elasticsearch-setup-passwords interactive
curl -k -u elastic:passwd http://localhost:9200/_cat/nodes

Kiban Server
Fin-prod-cbs
10.150xx

curl -u elastic:fxxxx https://localhost:5601/

cd /usr/share/kibana/bin/


curl -X POST -u elastic:passwd 10.1xxx6:9200/_security/service/na/svc/credential/token/sample_token
