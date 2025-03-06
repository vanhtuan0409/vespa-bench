#!/bin/env bash

here=`cd $(dirname $BASH_SOURCE); pwd`
CONFIG_SERVER_IP=$(terraform -chdir="$here/../tf" output -json | jq -r .configserver_ips.value[0])

docker run --rm -it \
  --entrypoint="" \
  -e "VESPA_CONFIG=$CONFIG_SERVER_IP" \
  -e "VESPA_ENDPOINT=http://$CONFIG_SERVER_IP:19071" \
  -w /app \
  -v ./app-cloud:/app \
  vespaengine/vespa bash
