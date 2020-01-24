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
ACCOUNT_ID=$(vault kv get --format=json secret/prd/saas/lets-encrypt | jq -r '.data.account_id')
ACCOUNT_PATH="$ACCOUNT_PARENT_PATH/$ACCOUNT_ID"

mkdir -p "$ACCOUNT_PATH"

for i in meta private_key regr; do
  vault kv get --format=json "secret/lets-encrypt/account/$i" | \
    jq -c '.data' \
    > "$ACCOUNT_PATH/$i.json"
done

read cfUsername cfAPI < <(vault kv get --format=json secret/prd/saas/cloudflare/primary | jq -r '.data.username, .data.api')
echo "dns_cloudflare_email = ${cfUsername}" > /etc/letsencrypt/cloudflare.ini
echo "dns_cloudflare_api_key  = ${cfAPI}" > /etc/letsencrypt/cloudflare.ini
# echo "dns_cloudflare_email = $(vault kv get --format=json secret/prd/saas/cloudflare/primary | jq -r '.data.username')" > /etc/letsencrypt/cloudflare.ini
chmod 600 /etc/letsencrypt/cloudflare.ini

CERTIFICATES_TO_CHECK=$(vault kv list --format=json secret/prd/lets-encrypt/certificates | jq -r '.[]')

mkdir -p /etc/letsencrypt/renewal

for certificate in $CERTIFICATES_TO_CHECK; do
  CERTIFICATE_DATA=$(vault kv get --format=json "secret/prd/lets-encrypt/certificates/${certificate}")
  mkdir -p "/etc/letsencrypt/archive/${certificate}"
  mkdir -p "/etc/letsencrypt/live/${certificate}"
  for field in cert chain privkey; do
    cat > "/etc/letsencrypt/archive/${certificate}/${field}1.pem" <<EOF
$(echo "${CERTIFICATE_DATA}" | jq -r ".data.data.${field}")
EOF
    ln \
      -s "../../archive/${certificate}/${field}1.pem" \
      "/etc/letsencrypt/live/${certificate}/${field}.pem"
  done

  cat \
    "/etc/letsencrypt/archive/${certificate}/cert1.pem" \
    "/etc/letsencrypt/archive/${certificate}/chain1.pem" \
    > "/etc/letsencrypt/archive/${certificate}/fullchain1.pem"
  ln \
    -s "../../archive/${certificate}/fullchain1.pem" \
    "/etc/letsencrypt/live/${certificate}/fullchain.pem"

  cat > "/etc/letsencrypt/renewal/$certificate.conf" <<EOF
version = 0.33.1
archive_dir = /etc/letsencrypt/archive/$certificate
cert = /etc/letsencrypt/live/$certificate/cert.pem
privkey = /etc/letsencrypt/live/$certificate/privkey.pem
chain = /etc/letsencrypt/live/$certificate/chain.pem
fullchain = /etc/letsencrypt/live/$certificate/fullchain.pem
# Options used in the renewal process
[renewalparams]
authenticator = dns-cloudflare
account = $ACCOUNT_ID
dns_cloudflare_credentials = /etc/letsencrypt/cloudflare.ini
server = https://acme-v02.api.letsencrypt.org/directory
EOF
done