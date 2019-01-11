#!/bin/sh
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=$(bosh int ~/deployments/vbox/creds.yml --path /admin_password)
export BOSH_ENVIRONMENT=vbox

route -n | grep -q 192.168.50.6 || sudo route add -net 10.244.0.0/16 gw 192.168.50.6