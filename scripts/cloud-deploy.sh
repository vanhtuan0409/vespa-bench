#!/bin/env bash

here=`cd $(dirname $BASH_SOURCE); pwd`
CONFIG_SERVER_IP=$(terraform -chdir="$here/../tf" output -json | jq -r .configserver_ips.value[0])

docker run --rm -it \
  --entrypoint="" \
  -w /app \
  -v ./app-cloud:/app \
  vespaengine/vespa vespa deploy -t $https://${configserver_ips}:19071 .
