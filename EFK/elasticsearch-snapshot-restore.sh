# ES Snapshot & Restore Via API
https://medium.com/orion-innovation-techclub/elasticsearch-snapshot-and-restore-feature-f7d52a9fd40
https://medium.com/@denny-saputro/tutorial-elasticsearch-snapshot-and-restore-507aec06977a

Verify that source cluster and destination cluster versions match
curl -X GET "http://localhost:9200?pretty"

# Add an index
curl -X PUT "http://localhost:9200/my_new_index" \
  -H "Content-Type: application/json" \
  -d '{
  "settings": {
    "number_of_shards": 3,
    "number_of_replicas": 2
  }
}'

# create sample doc
curl -X POST "http://localhost:9200/my_new_index/_doc/1" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Document",
    "content": "This is just a test to validate the snapshot and restore flow.",
    "timestamp": "2025-04-15T15:00:00"
  }'

# 1 ElasticSearch
Source: VMSS
Cold Node and NFS: 10.150.65.13 (fin-prod-cbs-elasticsearch_2)
Dest: VM

# 2 EFK still in a yellow state
Source: VMSS
Cold Node and NFS: 10.150.65.7 (fin-prod-cbs-efk_3)
Dest: VM

########################### NFS Setup #######################

# Step 1: Install NFS for main NFS server and cold node
sudo apt-get -y update && sudo apt-get -y install nfs-kernel-server

sudo /bin/systemctl daemon-reload && sudo /bin/systemctl enable nfs-kernel-server


# Step 2: Create a folder where the snapshots will be stored (in this case we defined one of the Cold VMs)
# on Cold-S1 node only
sudo chown -R elasticsearch:elasticsearch /mnt/data/sharing/es_backup
sudo mkdir -p /mnt/data/sharing/es_backup && sudo chmod -R 755 /mnt/data/sharing/es_backup

# Step 3: Edit the exports file and add below the line (only on the Cold-S1 node)
sudo echo "/mnt/data/sharing/es_backup *(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports


# Step 4: Reload the exports file (only on the Cold-S1 node)
exportfs -a
sudo systemctl restart nfs-kernel-server && sudo systemctl status -l nfs-kernel-server


# Step 5: Start NFS service (master & Data nodes)
# Run all other cluster nodes
sudo apt update && sudo apt install nfs-common -y

# Step 6: Create a folder where we will mount the shared folder (masters and data nodes)
sudo mkdir -p /mnt/data/es_backup

# Step 7: Mount the shared folder (masters and data nodes, Cold-S1 node IP Address)
sudo mount -t nfs ip:/mnt/data/sharing/es_backup /mnt/data/es_backup

# Optional Permanent mounting on other nodes
echo "ip:/mnt/data/sharing/es_backup /mnt/data/es_backup nfs defaults 0 0" | sudo tee -a /etc/fstab


# Step 9: Add path.repo line in elasticsearch.yml(masters and data nodes only)

echo 'path.repo: ["/mnt/data/es_backup"]' | sudo tee -a /etc/elasticsearch/elasticsearch.yml

sudo nano /etc/elasticsearch/elasticsearch.yml

path:
  repo:
    - /mount/backups
    - /mount/long_term_backups

sudo chown -R elasticsearch:elasticsearch /mnt/data/es_backup
sudo chmod -R 755 /mnt/data/es_backup

# Step10: Restart Elasticsearch service (masters and data nodes)
sudo systemctl restart elasticsearch

curl -k -u elastic:finopay http://localhost:9200/_cat/nodes


########################### Backup Restore #######################


# Step 11: Register a snapshot repository on the cluster to be backed up
# Set readonly to false on any master or data node
# Use other nodes for backup

curl -X PUT "localhost:9200/_snapshot/cbs-repo?pretty" \
  -H 'Content-Type: application/json' \
  -d '{
    "type": "fs",
    "settings": {
      "location": "/mnt/data/es_backup",
      "compress": true
    }
  }'


# Step 12: Register a snapshot repository on the cluster to be restored in
# Set readonly to true on node to restore from

curl -X PUT "localhost:9200/_snapshot/cbs-repo?pretty" \
  -H 'Content-Type: application/json' \
  -d '{
    "type": "fs",
    "settings": {
      "location": "/mnt/data/es_backup",
      "compress": true,
      "readonly": true
    }
  }'


# Create a Policy
# // Runs daily at 4:30 AM
curl -X PUT "http://localhost:9200/_slm/policy/cbs-repo-policy" \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "cbs-repo-{now}",
    "schedule": "0 30 4 * * ?",
    "repository": "cbs-repo",
    "config": {
      "ignore_unavailable": true
    },
    "retention": {
      "expire_after": "30d",
      "min_count": 1,
      "max_count": 10
    }
  }'

# Take Snapshot
curl -XPUT 'localhost:9200/_snapshot/cbs-repo/snapshot1?wait_for_completion=true' -H 'Content-Type: application/json' -d'
{
    "indices": "account-details-index,bal-change-data,acc-status-dates,acc-details,tm-proj-details-index,product-switch-count,last-txn-date-state",
    "ignore_unavailable": true
}'

# curl -XPUT 'localhost:9200/_snapshot/cbs-repo/kvs-snap-2020.12.08?pretty' -H 'Content-Type: application/json' -d'
# {
#  "indices": "my_new_index",
#  "include_global_state": false
# }'

# Get a List of Repositories
curl -X GET -u "elastic:finopay" "localhost:9200/_snapshot?pretty"

# Check repos
curl -X GET "http://localhost:9200/_cat/repositories?v"

# Get Repository Info
curl -X GET "http://localhost:9200/_snapshot/cbs-repo?pretty"

# Verify Repository
curl -X POST "localhost:9200/_snapshot/cbs-repo/_verify?pretty"

# Get Snapshot Info
curl -X GET "http://localhost:9200/_snapshot/cbs-repo/snapshot1?pretty"

# Snapshot Status
curl -XGET "localhost:9200/_snapshot/cbs-repo/snapshot1/_status?pretty"


# Restore a Snapshot
curl -X POST "localhost:9200/_snapshot/cbs-repo/snapshot1/_restore?pretty"

# Delete Snapshot
curl -XDELETE "http://localhost:9200/_snapshot/test_backup/test-snap-system-2020.12.14-gwgnmiycrcuiegvxsm4mga?pretty"

# Check for existing Index
curl -X GET "localhost:9200/_cat/indices?v"

curl -X GET "localhost:9200/_cat/indices?pretty"

curl -X GET "localhost:9200/_aliases?pretty"

# Delete an index
curl -X DELETE "localhost:9200/account-details-index"