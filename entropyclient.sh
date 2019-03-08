#!/bin/bash

ERROR=0

if [ "$BROKER_HOST" = "none" ];then
    echo "BROKER_HOST environment is required. Aborting..." >&2
    ERROR=1
fi

if [ "$CLIENT_USERNAME" = "none" ];then
    echo "CLIENT_USERNAME environment is required. Aborting..." >&2
    ERROR=1
fi

if [ "$CLIENT_PASSWORD" = "none" ];then
    echo "CLIENT_PASSWORD environment is required. Aborting..." >&2
    ERROR=1
fi

[ $ERROR -eq 0 ] || exit $ERROR

echo -e "${CLIENT_USERNAME}\n${CLIENT_PASSWORD}" > /usr/local/entropybroker/etc/auth.txt
chown 0:0  /usr/local/entropybroker/etc/auth.txt
chmod 0400 /usr/local/entropybroker/etc/auth.txt

/usr/local/entropybroker/bin/eb_client_linux_kernel \
    -I ${BROKER_HOST}:${BROKER_PORT} \
    -X /usr/local/entropybroker/etc/auth.txt \
    -L ${LOG_LEVEL} \
    -b ${ENTROPY_STIR} \
    -n
