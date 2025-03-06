#!/bin/env bash

docker exec -it vespa-config \
  vespa-feed-client --show-errors --benchmark --endpoint=http://localhost:8080 --file /app/ext/full.jsonl
