#!/bin/env bash

docker exec -it vespa-config curl -s http://localhost:19092/prometheus/v1/values/?consumer=vespa | grep documents_total_last
