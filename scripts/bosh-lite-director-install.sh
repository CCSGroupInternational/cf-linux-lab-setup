#!/bin/bash

# Adapted from https://bosh.io/docs/bosh-lite/


# Use defaults
INTERNAL_IP=${INTERNAL_IP:-192.168.50.6}
INTERNAL_GW=${INTERNAL_GW:-192.168.50.1}
INTERNAL_CIDR=${INTERNAL_CIDR:-192.168.50.0/24}

set -eux

function check_deployment() {
  DEPLOY_DIR=$1
  GIT_REPO=$2
  [[ -d $DEPLOY_DIR ]] || (mkdir -p $DEPLOY_DIR && git clone $GIT_REPO $DEPLOY_DIR)
  cd $DEPLOY_DIR
  git pull
}

rm -rf ~/workspace/bosh-deployment
git clone  https://github.com/cloudfoundry/bosh-deployment ~/workspace/bosh-deployment

rm -rf ~/deployments/vbox
mkdir -p ~/deployments/vbox
cd ~/deployments/vbox

bosh create-env ~/workspace/bosh-deployment/bosh.yml \
  --state ./state.json \
  -o ~/workspace/bosh-deployment/virtualbox/cpi.yml \
  -o ~/workspace/bosh-deployment/virtualbox/outbound-network.yml \
  -o ~/workspace/bosh-deployment/bosh-lite.yml \
  -o ~/workspace/bosh-deployment/bosh-lite-runc.yml \
  -o ~/workspace/bosh-deployment/uaa.yml \
  -o ~/workspace/bosh-deployment/credhub.yml \
  -o ~/workspace/bosh-deployment/jumpbox-user.yml \
  --vars-store ./creds.yml \
  -v director_name=bosh-lite \
  -v internal_ip=$INTERNAL_IP \
  -v internal_gw=$INTERNAL_GW \
  -v internal_cidr=$INTERNAL_CIDR \
  -v outbound_network_name=NatNetwork

# CF requires a DNS release
bosh alias-env vbox -e $INTERNAL_IP --ca-cert <(bosh int ./creds.yml --path /director_ssl/ca)

