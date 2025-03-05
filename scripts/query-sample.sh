#!/bin/env bash

docker exec -it vespa-config vespa query "select * from doc where true" streaming.groupname=dataroom1 presentation.summary=minimal hits=10
