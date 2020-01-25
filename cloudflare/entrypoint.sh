#!/bin/sh
set -e

if [ "$1" = 'initialize' ]; then
    initialize.sh
elif [ "$1" = 'renew' ]; then
    renew.sh
    certbot renew
elif [ "$1" = 'request' ]; then
    request.sh
elif [ "$1" = 'help' ]; then
    echo "Something coming soon"
else
    exec "$@"
fi
