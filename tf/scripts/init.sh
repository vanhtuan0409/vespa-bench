#!/bin/env sh

set -e

echo "Initializing"

echo "Installing docker"
yum update && yum install -y docker && usermod -a -G docker ec2-user
systemctl enable --now docker

echo "Installing docker-compose"
curl -L https://github.com/docker/compose/releases/download/v2.33.1/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo "Setting up deploy directory"
mkdir -p /opt/anduin
chown -R ec2-user:ec2-user /opt/anduin

INSTANCE_STORE_DEV="/dev/nvme1n1"
if fdisk -l | grep $INSTANCE_STORE_DEV; then
  mkfs -t xfs "$INSTANCE_STORE_DEV"
  UUID=$(blkid -s UUID -o value $INSTANCE_STORE_DEV)
  echo "UUID=${UUID} /data xfs defaults,nofail  0  2" >> /etc/fstab
  mkdir -p /data
  mount -a
fi

echo "Setting up data directory"
mkdir -p /data/vespa
chown -R ec2-user:ec2-user /data/vespa
