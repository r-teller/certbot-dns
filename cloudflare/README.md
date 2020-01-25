# certbot-dns-cloudflar
https://developer.epages.com/blog/tech-stories/managing-lets-encrypt-certificates-in-vault/

## Set Variables for future use
```bash
VAULT_ADDR='http://192.168.1.1:8200'
VAULT_TOKEN='somethingSecure'
```

## Initialize LetsEncrypt Account ID
Before you can request a certificate from LetsEncrypt you must generate an account and initialize a shared secret.
```bash
docker run -it --rm --name certbot-vault \
  -e "VAULT_ADDR=${VAULT_ADDR}" \
  -e "VAULT_TOKEN=${VAULT_TOKEN}" \
  -e "ACCOUNT_EMAIL=no-reply@example.com" \
  rteller/certbot-dns:cloudflare initialize
```

## Request Certificate from LetsEncrypt
Request a certificate for one or more domains, domains should be seperated with a space.
```bash
### Single Domain Request
docker run -it --rm --name certbot-vault \
  -e "VAULT_ADDR=${VAULT_ADDR}" \
  -e "VAULT_TOKEN=${VAULT_TOKEN}" \
  -e "MY_DOMAINS=example.com" \
  rteller/certbot-dns:cloudflare request

### Multiple Domain Request
docker run -it --rm --name certbot-vault \
  -e "VAULT_ADDR=${VAULT_ADDR}" \
  -e "VAULT_TOKEN=${VAULT_TOKEN}" \
  -e "MY_DOMAINS=example.com www.example.com" \
  rteller/certbot-dns:cloudflare request
```

## Renew Certificate from LetsEncrypt that will expire soon
Request a certificate for one or more domains, domains should be seperated with a space.
```bash
docker run -it --rm --name certbot-vault \
  -e "VAULT_ADDR=${VAULT_ADDR}" \
  -e "VAULT_TOKEN=${VAULT_TOKEN}" \
  rteller/certbot-dns:cloudflare renew
```