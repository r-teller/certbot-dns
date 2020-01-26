# Docker Arch (amd64, arm32v6, ...)
ARG TARGET_ARCH=amd64
FROM ${TARGET_ARCH}/python:3.8-alpine3.11
 
# Qemu Arch (x86_64, arm, ...)
# ARG QEMU_ARCH
# ENV QEMU_ARCH=${QEMU_ARCH}
# COPY qemu-${QEMU_ARCH}-static /usr/bin/


ARG CERTBOT_VERSION=1.1.0
ENV CERTBOT_VERSION=${CERTBOT_VERSION}

RUN mkdir -p /etc/letsencrypt /var/lib/letsencrypt


# Retrieve certbot code
RUN mkdir -p src \
 && wget -O certbot-${CERTBOT_VERSION}.tar.gz https://github.com/certbot/certbot/archive/v${CERTBOT_VERSION}.tar.gz \
 && tar xf certbot-${CERTBOT_VERSION}.tar.gz \
 && cp certbot-${CERTBOT_VERSION}/CHANGELOG.md certbot-${CERTBOT_VERSION}/README.rst src/ \
 && cp certbot-${CERTBOT_VERSION}/letsencrypt-auto-source/pieces/dependency-requirements.txt . \
 && cp -r certbot-${CERTBOT_VERSION}/tools tools \
 && cp -r certbot-${CERTBOT_VERSION}/acme src/acme \
 && cp -r certbot-${CERTBOT_VERSION}/certbot src/certbot \
 && rm -rf certbot-${CERTBOT_VERSION}.tar.gz certbot-${CERTBOT_VERSION}

# Generate constraints file to pin dependency versions
RUN cat dependency-requirements.txt | tools/strip_hashes.py > unhashed_requirements.txt \
 && cat tools/dev_constraints.txt unhashed_requirements.txt | tools/merge_requirements.py > docker_constraints.txt

# Install certbot runtime dependencies
RUN apk add --no-cache --virtual .certbot-deps \
        libffi \
        libssl1.1 \
        openssl \
        ca-certificates \
        binutils

# Install certbot from sources
RUN apk add --no-cache --virtual .build-deps \
        gcc \
        linux-headers \
        openssl-dev \
        musl-dev \
        libffi-dev \
    && pip install -r dependency-requirements.txt \
    && pip install --no-cache-dir --no-deps \
        --editable src/acme \
        --editable src/certbot \
&& apk del .build-deps

ARG VAULT_VERSION=1.1.3

RUN set -eux; \
    apk add --no-cache curl gnupg jq tzdata && \
    apkArch="$(apk --print-arch)"; \
    case "$apkArch" in \
        armhf) ARCH='arm' ;; \
        aarch64) ARCH='arm64' ;; \
        x86_64) ARCH='amd64' ;; \
        x86) ARCH='386' ;; \
        *) echo >&2 "error: unsupported architecture: $apkArch"; exit 1 ;; \
    esac && \
    VAULT_GPGKEY=91A6E7F85D05C65630BEF18951852D87348FFC4C; \
    found=''; \
    for server in \
        hkp://p80.pool.sks-keyservers.net:80 \
        hkp://keyserver.ubuntu.com:80 \
        hkp://pgp.mit.edu:80 \
    ; do \
        echo "Fetching GPG key $VAULT_GPGKEY from $server"; \
        gpg --batch --keyserver "$server" --recv-keys "$VAULT_GPGKEY" && found=yes && break; \
    done; \
    test -z "$found" && echo >&2 "error: failed to fetch GPG key $VAULT_GPGKEY" && exit 1; \
    mkdir -p /tmp/vault && \
    cd /tmp/vault && \
    wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_${ARCH}.zip && \
    wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_SHA256SUMS && \
    wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_SHA256SUMS.sig && \
    gpg --batch --verify vault_${VAULT_VERSION}_SHA256SUMS.sig vault_${VAULT_VERSION}_SHA256SUMS && \
    grep vault_${VAULT_VERSION}_linux_${ARCH}.zip vault_${VAULT_VERSION}_SHA256SUMS | sha256sum -c && \
    unzip -d /bin vault_${VAULT_VERSION}_linux_amd64.zip && \
    cd /tmp && \
    rm -rf /tmp/vault && \
    gpgconf --kill dirmngr && \
    gpgconf --kill gpg-agent && \
    apk del gnupg && \
    rm -rf /root/.gnupg

RUN  pip install certbot-dns-cloudflare

COPY ./entrypoint.sh /usr/local/bin/
COPY ./initialize.sh /usr/local/bin/
COPY ./request.sh /usr/local/bin/
COPY ./renew.sh /usr/local/bin/
COPY ./00-update-vault.sh /etc/letsencrypt/renewal-hooks/deploy/

WORKDIR /usr/local/bin/
ENTRYPOINT [ "entrypoint.sh" ]