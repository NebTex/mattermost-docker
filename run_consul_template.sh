#!/usr/bin/dumb-init /bin/bash
set -e

export VAULT_TOKEN=`cat /secrets/vault-token | jq .clientToken -r`
export VAULT_ADDR=`cat /secrets/vault-token | jq .vaultAddr -r`
export APP_NAME=`cat /etc/app_name`
export NAMESPACE=`cat /etc/namespace`
export APP_ROLE=$NAMESPACE-$APP_NAME


consul-template \
    -exec-reload-signal="SIGHUP" \
    -template="/templates/consul-child.conf:/tmp/ct-child" \
    -exec="consul-template -config=\"/tmp/ct-child\""