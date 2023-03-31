#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
source $DIR/common.sh

set +o noglob

DOCKER_DIR=${DIR}/../docker
cd $DOCKER_DIR
pushd .

note "check docker ..."

if [ -f /usr/bin/docker ]; then
  error "docker is exists."
  exit 1
fi

## backup files

note "copy system config files..."
# sysctl.conf
chattr -i /etc/sysctl.conf
if [ ! -f /etc/sysctl.conf.opsbox-bak ]; then
  cp /etc/sysctl.conf /etc/sysctl.conf.opsbox-bak
fi
cp ./etc/sysctl.conf /etc/sysctl.conf
sysctl -p
chattr +i /etc/sysctl.conf

# docker/daemon.json
if [ ! -d /etc/docker.opsbox-bak ] &&
  [ -d /etc/docker ]; then
  mv /etc/docker /etc/docker.opsbox-bak
fi
cp -r etc/docker /etc/docker

# limits.conf
if [ ! -f /etc/security/limits.d/20-nofile.conf.opsbox-bak ] &&
  [ -f /etc/security/limits.d/20-nofile.conf ]; then
  cp /etc/security/limits.d/20-nofile.conf /etc/security/limits.d/20-nofile.conf.opsbox-bak
fi
cp etc/security/limits.d/20-nofile.conf /etc/security/limits.d/20-nofile.conf


# docker.service
chmod 755 usr/bin/*
cp -r usr/bin/* /usr/bin/

if [ ! -f /usr/lib/systemd/system/docker.service.opsbox-bak ] &&  
  [ -f /usr/lib/systemd/system/docker.service ]; then
  cp /usr/lib/systemd/system/docker.service /usr/lib/systemd/system/docker.service.opsbox-bak
fi
cp usr/lib/systemd/system/docker.service /usr/lib/systemd/system/docker.service

note "start docker system..."

systemctl daemon-reload
systemctl restart docker
systemctl status docker
systemctl enable docker

note "list docker container and images"
docker ps 
docker images

note "create opsbox-network ..."
if [ -z "$(docker network ls |grep opsbox-network)" ];then
  note "--//INFO: please create a separate network--"
  note "ex: docker network create --subnet 192.168.31.0/24 --gateway 192.168.31.1 opsbox-network"
fi

popd
