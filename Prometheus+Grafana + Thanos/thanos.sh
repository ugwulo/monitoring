https://medium.com/@55_learning/prometheus-high-availability-with-thanos-caf00cfd3a7b

sudo curl -L -o /etc/systemd/system/query.service https://raw.githubusercontent.com/ugwulo/monitoring/main/query.service

# Install Go
https://www.digitalocean.com/community/tutorials/how-to-install-go-on-ubuntu-20-04

wget https://github.com/thanos-io/thanos/releases/download/v0.37.2/thanos-0.37.2.linux-amd64.tar.gz && sudo tar xvzf thanos-0.37.2.linux-amd64.tar.gz

# https://github.com/thanos-io/thanos/releases

sudo cp thanos-0.37.2.linux-amd64/thanos /usr/local/bin/thanos

# configure Object Storage config file 
sudo curl -L -o /etc/prometheus/storage.yml https://raw.githubusercontent.com/ugwulo/monitoring/main/storage.yml

sudo nano /etc/prometheus/storage.yml

finprodcbsmonitorstore

# 8c8b9e34-8db6-41fa-935c-b5ebb49f8d7a
type: AZURE
config:
  storage_account: "finngprodstatestorage"
#   user_assigned_id: "/subscriptions/f8acf074-408c-xxxxxx-c2b8b18ee696/resourcegroups/fin-pxxx-rg/providers/Microsoft.Compute/virtualMachineScaleSets/fin-prod-xxxxr"
#   storage_account_key: "sv=2022-11-02&ss=bfqt&srt=c&sp=rwdlacupiytfx&se=2025-03-05T17:59:50Z&st=2025-03-05T09:59:50Z&sip=10.150.65.22&spr=https,http&sig=ifU%3D"
#   container: "thanos-metrics"
#   echo "sv=2022-11-02&ss=bfqt&srt=c&sp=rwdlacupiytfx&se=2025-03-05T17:59:50Z&st=2025-03-05T09:59:50Z&sip=10.150.65.22&spr=https,htFzEkU%3D" | base64 --decode

  max_retries: 3
  reader_config:
    max_retry_requests: 3

prefix: "metrics/"


type: AZURE
config:
  storage_account: "finngprodstatestorage"
  container: "thanos-metrics"
  
  max_retries: 3
  reader_config:
    max_retry_requests: 3

  # Explicitly set the MSI resource
  msi_resource: "https://finpiloxxxxre.blob.core.windows.net/"

finpilotcbsmonitorstore
finprodcbsmonitorstore
nslookup finpiloxxxxstore.blob.core.windows.net

prefix: "metrics/"

# id: fin-prod-pos-aks-agentpool
# blob: finngprodstatestorage

# /subscriptions/f8acf074-408c-409d-8cbb-c2b8b18ee696/resourcegroups/fin-prod-pos-managed-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/fin-prod-pos-aks-agentpool
# Storage Blob Data Reader' role

Sidecar service file 
--objstore.config-file

sudo curl -L -o /etc/systemd/system/sidecar.service https://raw.githubusercontent.com/ugwulo/monitoring/main/sidecar.service

sudo nano /etc/systemd/system/sidecar.service

sudo useradd -rs /bin/false thanos
sudo chown -R thanos:thanos /usr/local/bin/thanos && sudo chmod +x /usr/local/bin/thanos

sudo usermod -aG prometheus thanos

cd /var/lib/prometheus
sudo chown -R thanos:thanos /var/lib/prometheus/meta-syncer/

sudo chown -R prometheus:prometheus /var/lib/prometheus/node-exporter/

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
    --tsdb.path=/var/lib/prometheus/ \
    --objstore.config-file=/etc/prometheus/storage.yml

[Install]
WantedBy=multi-user.target


sudo systemctl daemon-reload && sudo systemctl enable sidecar --now

sudo systemctl restart sidecar && sudo systemctl status -l sidecar --no-pager

sudo systemctl status sidecar --no-pager


# Step 3:- Setup Thanos Store
#sudo mkdir /var/lib/prometheus-store/

sudo curl -L -o /etc/systemd/system/store.service https://raw.githubusercontent.com/ugwulo/monitoring/main/store.service

sudo nano /etc/systemd/system/store.service

sudo usermod -aG prometheus thanos && sudo chmod -R 775 /var/lib/prometheus

sudo chown -R prometheus:prometheus /var/lib/prometheus/

sudo chown -R root:root /etc/prometheus

journalctl -u thanos-sidecar --no-pager | tail -n 50

[Unit]
Description=Thanos Store
Wants=network-online.target
After=network-online.target

[Service]
User=thanos
Group=thanos
Type=simple
ExecStart=/usr/local/bin/thanos store \
       --data-dir=/var/lib/prometheus/ \
       --objstore.config-file=/etc/prometheus/storage.yml \
       --http-address=0.0.0.0:10906 \
       --grpc-address=0.0.0.0:10905

[Install]
WantedBy=multi-user.target

sudo systemctl daemon-reload && sudo systemctl enable store 

sudo systemctl restart store && sudo systemctl status store --no-pager

sudo lsof -i :10905
sudo kill PID

# Step 4:- Setup Thanos Query/Querier

sudo curl -L -o /etc/systemd/system/query.service https://raw.githubusercontent.com/ugwulo/monitoring/main/query.service

sudo nano /etc/systemd/system/query.service

sudo scp /etc/systemd/system/query.service finopay@10.140.9.108:/etc/systemd/system/query.service

[Unit]
Description=Thanos Query
Wants=network-online.target
After=network-online.target

[Service]
User=thanos
Group=thanos
Type=simple
ExecStart=/usr/local/bin/thanos query \
     --http-address=0.0.0.0:10904 \
     --grpc-address=0.0.0.0:10903 \
     --endpoint=127.0.0.1:10901 \
     --endpoint=127.0.0.1:10905 \
     --endpoint=10.140.9.77:10901 \
     --endpoint=10.140.9.77:10905 \
     --endpoint=10.140.9.79:10901 \
     --endpoint=10.140.9.79:10905 \
     --query.replica-label=prometheus-1

[Install]
WantedBy=multi-user.target

sudo systemctl daemon-reload  && sudo systemctl enable query --now

sudo systemctl restart query && sudo systemctl status query --no-pager

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
      - targets: ['localhost:9090','10.150.65.24:9090']

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