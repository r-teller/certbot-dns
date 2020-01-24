# certbot-dns-cloudflar
https://developer.epages.com/blog/tech-stories/managing-lets-encrypt-certificates-in-vault/


```bash
docker pull rteller/certbot-dns-cloudflare
docker run --rm -it --name certbot-vault \
  -e "VAULT_ADDR=http://${VAULT_HOST}:8200" \
  -e "VAULT_TOKEN=${VAULT_TOKEN}" \
  rteller/certbot-dns-cloudflare sh

certbot register --non-interactive --agree-tos -m no-reply@teller.house

export ACCOUNT_PARENT_PATH=/etc/letsencrypt/accounts/acme-v02.api.letsencrypt.org/directory
export ACCOUNT_ID=$(ls $ACCOUNT_PARENT_PATH)

vault kv put secret/prd/saas/lets-encrypt/primary "account_id=$ACCOUNT_ID"

for i in meta private_key regr; do
  vault kv put "secret/prd/saas/lets-encrypt/account/$i" "@$ACCOUNT_PARENT_PATH/$ACCOUNT_ID/$i.json"
done


cloudflare=`vault kv get --format=json secret/prd/saas/cloudflare/primary`
cfUsername=`echo $cloudflare | jq .data.username`
cfAPI=`echo $cloudflare | jq .data.api`
# read cfUsername cfAPI < <(vault kv get --format=json secret/prd/saas/cloudflare/primary | jq -r '.data.username, .data.api')
echo -e "dns_cloudflare_email = ${cfUsername}\r\ndns_cloudflare_api_key  = ${cfAPI}" > /etc/letsencrypt/cloudflare.ini
# echo "" > /etc/letsencrypt/cloudflare.ini
# echo "dns_cloudflare_email = $(vault kv get --format=json secret/prd/saas/cloudflare/primary | jq -r '.data.username')" > /etc/letsencrypt/cloudflare.ini
chmod 600 /etc/letsencrypt/cloudflare.ini


domain=teller.house

certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini \
  -d "${domain}"

 vault kv put \
  "secret/prd/certificates/lets-encrypt/${domain}" \
  "cert=@/etc/letsencrypt/live/${domain}/cert.pem" \
  "chain=@/etc/letsencrypt/live/${domain}/chain.pem" \
  "privkey=@/etc/letsencrypt/live/${domain}/privkey.pem"


```

```bash
certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini \
  -d "example.com"
```