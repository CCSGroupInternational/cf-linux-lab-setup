#/usr/bin/env bash

# Adapted from https://starkandwayne.com/blog/running-cloud-foundry-locally-on-bosh-lite-with-bosh2/

set -eux

source $(dirname $0)/bosh_env.sh

# CF requires a DNS
bosh -n update-runtime-config ~/workspace/bosh-deployment/runtime-configs/dns.yml --name dns


function check_deployment() {
  DEPLOY_DIR=$1
  GIT_REPO=$2
  [[ -d $DEPLOY_DIR ]] || (mkdir -p $DEPLOY_DIR && git clone $GIT_REPO $DEPLOY_DIR)
  cd $DEPLOY_DIR
  git pull
}

check_deployment ~/workspace/cf-deployment https://github.com/cloudfoundry/cf-deployment.git
cd ~/workspace/cf-deployment

# *after* the git repo is updated, or version will be inaccurate
STEMCELL_VERSION=$(bosh interpolate cf-deployment.yml --path /stemcells/alias=default/version)

# determine the ubuntu code name
CODE_NAME=$(bosh interpolate cf-deployment.yml --path /stemcells/0/os)

# upload cloud config to director
bosh -n ucc iaas-support/bosh-lite/cloud-config.yml

# upload stemcell to director
bosh \
  upload-stemcell \
  https://bosh.io/d/stemcells/bosh-warden-boshlite-${CODE_NAME}-go_agent?v=${STEMCELL_VERSION}

bosh -n -d cf deploy cf-deployment.yml \
    --vars-store state/cf-deployment-vars.yml \
    -o operations/bosh-lite.yml \
    -o operations/use-compiled-releases.yml \
    -v system_domain=bosh-lite.com

cat << _EOF_

CloudFoundry deployed, you can manage your CF instance using:

  CF_ADM_PASS=\$(bosh int ~/workspace/cf-deployment/state/cf-deployment-vars.yml --path /cf_admin_password)
  cf api https://api.bosh-lite.com --skip-ssl-validation
  cf auth admin \$CF_ADM_PASS

_EOF_
