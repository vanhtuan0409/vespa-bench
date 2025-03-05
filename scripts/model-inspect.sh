#!/bin/env bash

# docker exec -it vespa-config curl http://localhost:19071/application/v2/tenant/default/application/

docker exec -it vespa-config vespa-model-inspect $@
