https://medium.com/@55_learning/prometheus-high-availability-with-thanos-caf00cfd3a7b

sudo curl -L -o /etc/systemd/system/query.service https://raw.githubusercontent.com/ugwulo/monitoring/main/query.service

# Install Go
https://www.digitalocean.com/community/tutorials/how-to-install-go-on-ubuntu-20-04

wget https://github.com/thanos-io/thanos/releases/download/v0.37.2/thanos-0.37.2.linux-amd64.tar.gz && sudo tar xvzf thanos-0.37.2.linux-amd64.tar.gz

# https://github.com/thanos-io/thanos/releases

sudo cp thanos-0.37.2.linux-amd64/thanos /usr/local/bin/thanos

rm -rf thanos-0.37.2.linux-amd64 && rm -rf thanos-0.37.2.linux-amd64.tar.gz

# configure Object Storage config file 


type: AZURE
config:
  storage_account: "fixxxxxtestoxxxe"
#   user_assigned_id: "/subscriptions/f8acf074-408c-xxxxxx-c2b8b18ee696/resourcegroups/fin-pxxx-rg/providers/Microsoft.Compute/virtualMachineScaleSets/fin-prod-xxxxr"
#   storage_account_key: "sv=202xxxxxxxx09:59:50Z&sip=10.15xxxxxxx"
#   container: "thanos-metrics"
#   echo "sv=2022-11-02&ss=bfqt&srt=c&sp=rwdlacupiytfx&se=2025-03-05T17:59:50Z&st=2025-03-05T09:59:50Z&sip=10.150.65.22&spr=https,htFzEkU%3D" | base64 --decode
  max_retries: 3
  reader_config:
    max_retry_requests: 3
fixxxxbsmonitorxxe
finxxxstoxxxxxe
nslookup finpiloxxxxsxxe.blob.core.windows.net
prefix: "metrics/"

sudo tee /etc/prometheus/storage.yml > /dev/null <<EOL
type: AZURE
config:
  storage_account: "fxxxxxxxxxxtore"
  container: "gh-thanos-metrics"
  max_retries: 3
  reader_config:
    max_retry_requests: 3
  # Explicitly set the MSI resource
  msi_resource: "finprxxxxe.blob.core.windows.net/"
EOL

sudo tee /etc/prometheus/storage.yml > /dev/null <<EOL
type: AZURE
config:
  storage_account: "finprodcbsmonitorstore"
  container: "thanos-metrics"
  max_retries: 3
  reader_config:
    max_retry_requests: 3
  # Explicitly set the MSI resource
  msi_resource: "fxxxxxxxxe.blob.core.windows.net/"
EOL

# id: fin-prod-pos-aks-agentpool
# blob: xxxxgxxxe

# /subscriptions/fxxxxxxxx696/resourcegroups/fin-prod-pos-managed-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/fin-prod-pos-aks-agentpool
# Storage Blob Data Reader' role

Sidecar service file 
--objstore.config-file

# sudo useradd -rs /bin/false thanos
# sudo chown -R thanos:thanos /usr/local/bin/thanos && sudo chmod +x /usr/local/bin/thanos
#&& sudo mkdir -p /mnt/data/prometheus/node-exporter/
#sudo chown -R prometheus:prometheus /mnt/data/prometheus/node-exporter/
# sudo usermod -aG prometheus thanos && sudo usermod -aG prometheus node_exporter
cd /var/lib/prometheus
#sudo chown -R thanos:thanos /var/lib/prometheus/meta-syncer/

sudo mkdir -p /mnt/data/prometheus 

sudo chown -R prometheus:prometheus /mnt/data/prometheus && sudo chmod -R 2775 /mnt/data/prometheus 

sudo chown prometheus:prometheus /etc/prometheus/storage.yml



sudo usermod -aG prometheus thanos

sudo systemctl restart store

cd /var/lib/prometheus/

getent passwd thanos 
groups thanos

sudo lsof -i :10905
sudo kill PID

#sudo chmod -R 775 /var/lib/prometheus
#sudo chown -R prometheus:prometheus /var/lib/prometheus/
#sudo chown -R root:root /etc/prometheus

sudo tee /etc/systemd/system/sidecar.service > /dev/null <<EOL
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/thanos sidecar \
    --prometheus.url=http://127.0.0.1:9090 \
    --grpc-address=:10901 \
    --http-address=:10902 \
    --tsdb.path=/mnt/data/prometheus/ \
    --objstore.config-file=/etc/prometheus/storage.yml

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload && sudo systemctl enable sidecar --now

sudo systemctl restart sidecar && sudo systemctl status -l sidecar --no-pager

sudo systemctl status -l sidecar --no-pager


# Step 3:- Setup Thanos Store
#sudo mkdir /var/lib/prometheus-store/

sudo curl -L -o /etc/systemd/system/store.service https://raw.githubusercontent.com/ugwulo/monitoring/main/store.service

sudo nano /etc/systemd/system/store.service


journalctl -u thanos-sidecar --no-pager | tail -n 50

sudo tee /etc/systemd/system/store.service > /dev/null <<EOL
[Unit]
Description=Thanos Store
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/thanos store \
       --data-dir=/mnt/data/prometheus/ \
       --objstore.config-file=/etc/prometheus/storage.yml \
       --http-address=0.0.0.0:10906 \
       --grpc-address=0.0.0.0:10905

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload && sudo systemctl enable store && sudo systemctl start store.service

sudo systemctl -l status store --no-pager

sudo nano /etc/prometheus/storage.yml

# Step 4:- Setup Thanos Query/Querier

sudo curl -L -o /etc/systemd/system/query.service https://raw.githubusercontent.com/ugwulo/monitoring/main/query.service

sudo nano /etc/systemd/system/query.service

sudo scp /etc/systemd/system/query.service finopay@10.140.9.108:/etc/systemd/system/query.service


sudo tee /etc/systemd/system/query.service > /dev/null <<EOL
[Unit]
Description=Thanos Query
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/thanos query \
     --http-address=0.0.0.0:10904 \
     --grpc-address=0.0.0.0:10903 \
     --endpoint=127.0.0.1:10901 \
     --endpoint=127.0.0.1:10905 \
     --endpoint=10.140.9.108:10901 \
     --endpoint=10.140.9.108:10905 \
     --endpoint=10.140.9.109:10901 \
     --endpoint=10.140.9.109:10905 \
     --query.replica-label=prometheus-3

[Install]
WantedBy=multi-user.target
EOL


sudo systemctl daemon-reload  && sudo systemctl enable query --now && sudo systemctl start query

sudo systemctl -l status query --no-pager

# Repeat for second and third server and change --endpoint=10.150.65.24:10901 accordingly
sudo nano /etc/systemd/system/query.service



# Step 5:- Set up prometheus configuratin file

sudo nano /etc/prometheus/prometheus.yml

# global config
global:
  scrape_interval: 15s 
  evaluation_interval: 15s 
  external_labels:
    replica: prometheus-1

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets: 
            # - localhost:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090','10.xxxxx:9090']

#   - job_name: "azure_service_discovery"
#     azure_sd_configs:
#       - subscription_id: "<your-azure-subscription-id>"
#         tenant_id: "<your-azure-tenant-id>"
#         client_id: "<your-azure-client-id>"
#         client_secret: "<your-azure-client-secret>"
#         port: 9100
#     relabel_configs:
#       - source_labels: [__meta_azure_machine_tag_Prometheus]
#         regex: service-.*
#         action: keep


Step 6:- Configure Prometheus clients