#!/bin/sh
# Initialize the environment for certbot
# Requires vault and jq

set -eo pipefail

if ! vault token lookup > /dev/null; then
  echo "Login to Vault first."
  exit 1
fi

if [ -z $ACCOUNT_EMAIL ]; then
  echo 'ACCOUNT_EMAIL env must be provided.'
  echo 'example.. -e "ACCOUNT_EMAIL=no-reply@example.com"'
  exit 1
fi

certbot register --non-interactive --agree-tos -m ${ACCOUNT_EMAIL}

export ACCOUNT_PARENT_PATH=/etc/letsencrypt/accounts/acme-v02.api.letsencrypt.org/directory
export ACCOUNT_ID=$(ls $ACCOUNT_PARENT_PATH)

vault kv put secret/prd/saas/lets-encrypt/primary "account_id=$ACCOUNT_ID"

for i in meta private_key regr; do
  vault kv put "secret/prd/saas/lets-encrypt/account/$i" "@$ACCOUNT_PARENT_PATH/$ACCOUNT_ID/$i.json"
done
