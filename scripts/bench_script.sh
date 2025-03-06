#!/bin/env bash

here=`cd $(dirname $BASH_SOURCE); pwd`
doc_endpoint=$(terraform -chdir="$here/../tf" output -json | jq -r .alb_dns.value)

cat <<EOF
vespa-feed-client --show-errors --benchmark \
  --endpoint=http://$doc_endpoint:8080 \
  --file /benchmark/ext/docs.jsonl

vespa-fbench -n 8 -q /benchmark/ext/query_smalls.txt -s 300 $doc_endpoint 8080

vespa-fbench -n 8 -q /benchmark/ext/query_whale.txt -s 300 $doc_endpoint 8080

vespa-fbench -n 1 -q /benchmark/ext/query_whale.txt -s 300 $doc_endpoint 8080

vespa-fbench -n 8 -q /benchmark/ext/query_mixed.txt -s 300 $doc_endpoint 8080
EOF
