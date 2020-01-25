#!/bin/sh
set -e

if [ "$1" = 'initialize' ]; then
    initialize.sh
elif [ "$1" = 'renew' ]; then
    renew.sh
    certbot renew
elif [ "$1" = 'generate' ]; then
    generate.sh
else
    exec "$@"
fi
