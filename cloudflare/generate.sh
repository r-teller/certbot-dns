#!/bin/sh
# Initialize the environment for certbot
# Requires vault and jq

set -eo pipefail

if ! vault token lookup > /dev/null; then
  echo "Login to Vault first."
  exit 1
fi

if [ -Z $MY_DOMAINS ]; then
  echo 'MY_DOMAINS env must be provided, it should include one or more domains'
  echo 'example... -e "MY_DOMAINS=example.com www.example.com"'
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

certbotDomains=""
for i in ${MY_DOMAINS}; do
  certbotDomains=" -d ${i} ${certbotDomains}"
done

certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini \
  ${certbotDomains}

vault kv put \
  "secret/prd/certificates/lets-encrypt/${MY_DOMAINS%% *}" \
  "cert=@/etc/letsencrypt/live/${MY_DOMAINS%% *}/cert.pem" \
  "chain=@/etc/letsencrypt/live/${MY_DOMAINS%% *}/chain.pem" \
  "privkey=@/etc/letsencrypt/live/${MY_DOMAINS%% *}/privkey.pem"