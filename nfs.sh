####################### NFS ##############################

# Create a partition on the new disk
sudo fdisk /dev/sdb
# Press 'n' for new partition
# Press 'p' for primary partition
# Press '1' for first partition
# Press 'Enter' to use default first sector
# Press 'Enter' to use default last sector (full disk)
# Press 'w' to write changes


# Create filesystem
sudo mkfs.ext4 /dev/sdb1

# Create mount point
sudo mkdir /nfs

# Mount the new disk
sudo mount /dev/sdb1 /nfs

# Make mount persistent
echo '/dev/sdb1 /nfs ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab

sudo mkdir /nfs/export/cbs && sudo mkdir /nfs/cbs

sudo chmod -R 2777 /nfs/export/cbs && sudo chmod -R 277 /nfs/cbs

########################### NFS #######################


sudo tee nfs.sh > /dev/null <<EOL
#!/bin/bash

EXPORT_DIRECTORY=${1:-/nfs/export/cbs}
DATA_DIRECTORY=${2:-/nfs/cbs}
AKS_SUBNET=${3:-10.xxxx/32} # Prod
# AKS_SUBNET=${3:-10.xxxx/4} # Pilot

echo "Updating packages"
apt-get -y update

echo "Installing NFS kernel server"

apt-get -y install nfs-kernel-server

sudo /bin/systemctl daemon-reload && sudo /bin/systemctl enable nfs-kernel-server

echo "Mount binding ${DATA_DIRECTORY} to ${EXPORT_DIRECTORY}"
sudo mount --bind /nfs/cbs /nfs/export/cbs

echo "Appending bound directories into fstab"
sudo echo "/nfs/cbs /nfs/export/cbs none bind  0  0" >> /etc/fstab

echo "Appending localhost and Kubernetes subnet address ${AKS_SUBNET} to exports configuration file"
echo "/nfs/export/cbs  ${AKS_SUBNET}(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
echo "/nfs/export/cbs  localhost(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
exportfs -ra
EOL

sudo chmod +x nfs.sh && sudo ./nfs.sh

systemctl restart nfs-kernel-server

nohup service nfs-kernel-server restart

systemctl status -l nfs-kernel-server

# Data Migration
rsync -avz --rsync-path="sudo rsync" /export/cbs/LOG/ finopay@10.150.65.67:/nfs/export/cbs/LOG

scp -r /export/cbs/LOG/* finopay@10.150.65.67:/nfs/export/cbs/LOG

sudo exportfs -a && sudo systemctl restart nfs-kernel-server


rsync -avz --rsync-path="sudo rsync" /export/cbs/LOG/CORE finopay@10.150.65.67:/nfs/export/cbs/LOG