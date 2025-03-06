#!/bin/env bash

set -ex

here=`cd $(dirname $BASH_SOURCE); pwd`
ALB=$(terraform -chdir="$here/../tf" output -json | jq -r .alb_dns.value)
ENDPOINT=http://${ALB}:8080

curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{"fields": {"id": 1}}' \
  $ENDPOINT/document/v1/default/doc/group/dataroom1/1

