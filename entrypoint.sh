#!/bin/sh
set -e

if [ "$1" = 'renew' ]; then
    initialize.sh
    certbot renew
if [ "$1" = 'generate' ]; then
    export domains=$2
    generate.sh
else
    exec "$@"
fi