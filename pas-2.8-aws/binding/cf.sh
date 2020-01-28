#!/bin/bash

set -e

wget -O om -q https://github.com/pivotal-cf/om/releases/download/4.4.1/om-linux-4.4.1 && chmod +x om

eval "$(jq -r '@sh "opsman_host=\(.opsman_host) opsman_password=\(.opsman_password)"')"

export OM_TARGET=$opsman_host
export OM_USERNAME=admin
export OM_PASSWORD=$opsman_password

cf_password=$(./om credentials -p cf -c .uaa.admin_credentials -t json | jq -r '.password')

jq -n --arg cf_password "$cf_password" '{"cf_password":$cf_password}'