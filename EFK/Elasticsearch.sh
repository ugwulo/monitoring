sudo tee elastic.sh > /dev/null <<EOL
#!/bin/bash

# Elasticsearch Installation
# Install the GPG key for Elasticsearch
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg

# Install apt-transport-https if not already installed
if ! dpkg -l | grep -q apt-transport-https; then
  echo "Installing apt-transport-https..."
  sudo apt-get update && sudo apt-get install -y apt-transport-https
else
  echo "apt-transport-https is already installed."
fi

# Add the Elasticsearch repository
if [ ! -f /etc/apt/sources.list.d/elastic-8.x.list ]; then
  echo "Adding Elasticsearch repository..."
  echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
else
  echo "Elasticsearch repository already exists."
fi

# Update package list and install Elasticsearch
sudo apt-get update && sudo apt-get install -y elasticsearch

# Enable Elasticsearch service to start on boot
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service

# Configure data path
sudo mkdir -p /mnt/data/elasticsearch

sudo chown -R elasticsearch:elasticsearch /mnt/data/elasticsearch

sudo chmod -R 2750 /mnt/data/elasticsearch
EOL

##############################################################

https://evermight.com/setup-elasticsearch-cluster/

sudo chmod +x elastic.sh && ./elastic.sh

sudo nano /etc/elasticsearch/elasticsearch.yml

cd /etc/elasticsearch/cert

9GT>5'=b08]j


# Start Elasticsearch service
sudo nano /etc/elasticsearch/elasticsearch.yml

sudo systemctl restart elasticsearch.service

sudo systemctl start elasticsearch

# Check Elasticsearch service status
sudo systemctl status -l elasticsearch.service --no-pager


prod-gh-es-cluster

["10.150.65.48:9300", "10.150.65.61:9300", "10.150.65.55:9300"]


xpack.security.enabled: false
xpack.ml.enabled: false
xpack.security.enrollment.enabled: true

sudo nano /etc/elasticsearch/jvm.options
-Xmx8g
-Xms8g

sudo ls -l /etc/elasticsearch/
cd /etc/elasticsearch/

sudo bash
cd /usr/share/elasticsearch/bin/

cd /etc/elasticsearch/cert/

/etc/elasticsearch/certs/

/etc/elasticsearch/certs/http.p12
/etc/elasticsearch/certs/http_ca.crt
/etc/elasticsearch/certs/transport.p12
http.p12  http_ca.crt  transport.p12


curl -k http://10.140.9.83:9200/_cat/nodes
curl -k -u elastic:psswd https://10.140.9.99:9200/_cat/nodes






curl localhost:9200/_cat/indices
curl 10.150.65.9:9200/books/_search?pretty
curl -X GET "http://localhost:9200/_cluster/health?pretty"
:9200/_cluster/stats
:9200/_cluster/settings
PUT /products
GET /_cat/indices
GE /_cluster/stats
GE /product/_settings

Health Probe

need to allow /_cluster/health to be publicly accessible

curl 10.150.65.7:9200/_cat/nodes


Prometheus
curl 10.140.9.75:9090/-/healthy


Increase Max Heap Size
sudo nano /etc/elasticsearch/sysctl.conf
sudo nano /etc/sysctl.conf

#Docs
https://www.elastic.co/guide/en/elasticsearch/reference/8.x/important-settings.html

Kibana only "reads" the data of elasticsearch, so if you have 2 instances of kibana, they will read from the same data. But having 2 kibanas does not mean more availability or security.


sudo systemctl stop elasticsearch && sudo systemctl disable elasticsearch

sudo apt-get remove --purge elasticsearch -y
sudo rm -rf /var/lib/elasticsearch/ && sudo rm -rf /etc/elasticsearch/ && sudo rm -rf /var/log/elasticsearch/

sudo systemctl stop kibana.service
sudo systemctl disable kibana.service
