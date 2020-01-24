#!/bin/sh
# Initialize the environment for certbot
# Requires vault and jq

set -eo pipefail

if ! vault token lookup > /dev/null; then
  echo "Login to Vault first."
  exit 1
fi

# Get account path
ACCOUNT_PARENT_PATH=/etc/letsencrypt/accounts/acme-v02.api.letsencrypt.org/directory
ACCOUNT_ID=$(vault kv get --format=json secret/prd/saas/lets-encrypt/primary | jq -r '.data.account_id')
ACCOUNT_PATH="$ACCOUNT_PARENT_PATH/$ACCOUNT_ID"

mkdir -p "$ACCOUNT_PATH"

for i in meta private_key regr; do
  vault kv get --format=json "secret/prd/saas/lets-encrypt/account/$i" | \
    jq -c '.data' \
    > "$ACCOUNT_PATH/$i.json"
done

cloudflare=`vault kv get --format=json secret/prd/saas/cloudflare/primary`
cfUsername=`echo $cloudflare | jq .data.username`
cfAPI=`echo $cloudflare | jq .data.api`

echo -e "dns_cloudflare_email = ${cfUsername}\r\ndns_cloudflare_api_key  = ${cfAPI}" > /etc/letsencrypt/cloudflare.ini

chmod 600 /etc/letsencrypt/cloudflare.ini

certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini \
  -d "${domains}"

  vault kv put \
  "secret/lets-encrypt/certificates/${primaryDomain}" \
  "cert=@/etc/letsencrypt/live/${primaryDomain}/cert.pem" \
  "chain=@/etc/letsencrypt/live/${primaryDomain}/chain.pem" \
  "privkey=@/etc/letsencrypt/live/${primaryDomain}/privkey.pem"