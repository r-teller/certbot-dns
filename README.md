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
docker run --rm -it --name certbot-vault \
  -e "VAULT_ADDR=http://192.168.13.250:8200" \
  -e "VAULT_TOKEN=s.PNqyBhwl5mgmzpwg2OeJ3o7a" \
  certbot-vault sh
```

```bash
certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini \
  -d "example.com"
```