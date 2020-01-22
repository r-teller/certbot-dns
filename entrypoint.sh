#!/bin/sh
set -e

if [ "$1" = 'renew' ]; then
    initialize.sh
    certbot renew
else
    exec "$@"
fi