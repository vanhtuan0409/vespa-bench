#!/bin/env bash

# docker exec -it vespa-config curl http://localhost:19071/application/v2/tenant/default/application/

TENANT=default
APPLICATION=default

session=$(docker exec -it vespa-config curl http://localhost:19071/application/v2/tenant/default/application/default | jq -r .generation)
docker exec -it vespa-config curl http://localhost:19071/application/v2/tenant/default/session/$session/content/
