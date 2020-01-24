#!/bin/sh
set -e

if [ "$1" = 'renew' ]; then
    initialize.sh
elif [ "$1" = 'renew' ]; then
    renew.sh
    certbot renew
elif [ "$1" = 'generate' ]; then
    generate.sh
else
    exec "$@"
fi