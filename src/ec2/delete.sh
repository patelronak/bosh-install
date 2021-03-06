#!/usr/bin/env bash

set +e

internal_cidr=$1
internal_gw=$2
internal_ip=$3
access_key_id=$4
secret_access_key=$5
subnet_id=$6
private_key_file=$7

cd ~/deployments/bosh-master

echo "-- Log in to the Director --"
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`bosh int ./creds.yml --path /admin_password`

echo "-- Alias the deployed Director --"
bosh -e ${internal_ip} --ca-cert <(bosh int ./creds.yml --path /director_ssl/ca) alias-env bosh-1

echo "-- Destroying bosh env --"
bosh -e bosh-1 delete-env ~/workspace/bosh-deployment/bosh.yml \
  --state ./state.json \
  -o ~/workspace/bosh-deployment/aws/cpi.yml \
  -o ~/workspace/bosh-deployment/uaa.yml \
  --vars-store ./creds.yml \
  -v director_name=bosh-master-director \
  -v internal_cidr=${internal_cidr} \
  -v internal_gw=${internal_gw} \
  -v internal_ip=${internal_ip} \
  -v access_key_id=${access_key_id} \
  -v secret_access_key=${secret_access_key} \
  -v az=eu-central-1a \
  -v region=eu-central-1 \
  -v default_key_name=bosh \
  -v default_security_groups=[bosh] \
  -v subnet_id=${subnet_id} \
  --var-file private_key=${private_key_file}