#!/bin/env bash

docker run --rm -it \
  --entrypoint="" \
  -e "VESPA_ENDPOINT=http://172.20.0.249:19071" \
  -w /app \
  -v ./app-cloud:/app \
  vespaengine/vespa bash
