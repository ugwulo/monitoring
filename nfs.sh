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

chmod -R 2777 /nfs/export/cbs && chmod -R 277 /nfs/cbs

########################### NFS #######################

sudo vim nfs.sh && sudo chmod +x nfs.sh

#!/bin/bash

# This script should be executed on Linux Ubuntu Virtual Machine

EXPORT_DIRECTORY=${1:-/nfs/export/cbs}
DATA_DIRECTORY=${2:-/nfs/cbs}
# AKS_SUBNET=${3:-10.150.0.0/18} # Prod
AKS_SUBNET=${3:-10.140.0.0/21} # Pilot

echo "Updating packages"
apt-get -y update

echo "Installing NFS kernel server"

apt-get -y install nfs-kernel-server

echo "Making data directory ${DATA_DIRECTORY}"
mkdir -p ${DATA_DIRECTORY}

echo "Making new directory to be exported and linked to data directory: ${EXPORT_DIRECTORY}"
mkdir -p ${EXPORT_DIRECTORY}

echo "Mount binding ${DATA_DIRECTORY} to ${EXPORT_DIRECTORY}"
mount --bind ${DATA_DIRECTORY} ${EXPORT_DIRECTORY}

echo "Giving 777 permissions to ${EXPORT_DIRECTORY} directory"
chmod 777 ${EXPORT_DIRECTORY}

parentdir="$(dirname "$EXPORT_DIRECTORY")"
echo "Giving 777 permissions to parent: ${parentdir} directory"
chmod 777 $parentdir

echo "Appending bound directories into fstab"
echo "${DATA_DIRECTORY}    ${EXPORT_DIRECTORY}   none    bind  0  0" >> /etc/fstab

echo "Appending localhost and Kubernetes subnet address ${AKS_SUBNET} to exports configuration file"
echo ""/nfs/export/cbs        ${AKS_SUBNET}(rw,async,insecure,fsid=0,crossmnt,no_subtree_check)" >> /etc/exports
echo ""/nfs/export/cbs        localhost(rw,async,insecure,fsid=0,crossmnt,no_subtree_check)" >> /etc/exports

echo "/nfs/export/cbs  10.140.0.0/21(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
echo "/nfs/export/cbs  localhost(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
exportfs -ra

systemctl restart nfs-kernel-server
nohup service nfs-kernel-server restart