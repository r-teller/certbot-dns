#!/bin/sh
set -e

if [ "$1" = 'renew' ]; then
    initialize.sh
    certbot renew
if [ "$1" = 'generate' ]; then
    primaryDomain = $2
    domains = $3
    generate.sh
else
    exec "$@"
fi