#!/bin/env bash

docker exec -it vespa-config vespa-fbench -n 4 -q /app/ext/queries.txt -s 300 localhost 8080
