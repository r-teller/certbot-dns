# certbot-dns-cloudflar
https://developer.epages.com/blog/tech-stories/managing-lets-encrypt-certificates-in-vault/

```bash
docker run --rm -it --name certbot-vault \
  -e "VAULT_ADDR=http://dev-vault:8200" \
  -e "VAULT_TOKEN=${VAULT_TOKEN}" \
  --network certbot-vault-net \
  certbot-vault sh
```
```bash
docker pull rteller/certbot-dns-cloudflare
docker run --rm -it --name certbot-vault \
  -e "VAULT_ADDR=http://192.168.13.250:8200" \
  -e "VAULT_TOKEN=s.PNqyBhwl5mgmzpwg2OeJ3o7a" \
  rteller/certbot-dns-cloudflare sh

certbot register --non-interactive --agree-tos -m no-reply@teller.house

vault kv put secret/prd/saas/lets-encrypt "account_id=$ACCOUNT_ID"
for i in meta private_key regr; do
  echo vault kv put "secret/lets-encrypt/account/$i" "@$ACCOUNT_PARENT_PATH/$ACCOUNT_ID/$i.json"
done


```

```bash
certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini \
  -d "example.com"
```