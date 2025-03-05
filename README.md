# Vespa bench

The goal is to re-create [steaming search](https://blog.vespa.ai/announcing-vector-streaming-search) benchmark based on our own data size 

### High level preview

- Schema is very simple with only `id | embedding` fields. No index on either field
- We use a pseudo embedding generator for calculate vector embedding for each doc
- Generate a feeding document with configurable `num_dataroom | num_doc_per_dataroom`. Which can be feed into `vespa-feed-client` tool
- Generate a query document on a random subset of dataroom. Which can be feed into `vespa-fbench`

### Setup on single node local

```
// Setup single node
docker-compose up -d

// build pseudo embedding generator
make build

// deploy vespa package application
./scripts/deploy.sh

// gen feeding document
python ./gen_docs.py | tee ./ext/full.jsonl

// feeding docs to cluster
./scripts/feed-full.sh

// gen query document
python ./gen_query.py | tee ./ext/queries.txt

// run vespa-fbench
./scripts/query-bench.sh
```

For multi-node setup. You can tweak `./app/services.xml` to modify cluster size

### Benchmark

#### Specs

- Machine specs: 11vCPU with 64GB ram
- Benchmark specs:
    - 1000 dataroom with 10_000 docs per dataroom (uniform distribution)
    - Single node vespa

#### Result

- I was able to feed 9.2M/10M docs. The feed client got stuck on 9.2M docs after 12min
- Memory usage of vespa container remain 4.8G memory. Which is reasonable due to no indexing
- Query benchmark yield

```
***************** Benchmark Summary *****************
clients:                       4
ran for:                      20 seconds
cycle time:                    0 ms
lower response limit:          0 bytes
skipped requests:              0
failed requests:               0
successful requests:        4009
cycles not held:            4009
minimum response time:      7.78 ms
maximum response time:    150.18 ms
average response time:     19.94 ms
25   percentile:             16.30 ms
50   percentile:             18.40 ms
75   percentile:             21.40 ms
90   percentile:             24.82 ms
95   percentile:             27.56 ms
98   percentile:             32.35 ms
99   percentile:             47.91 ms
99.5 percentile:            111.67 ms
99.6 percentile:            112.80 ms
99.7 percentile:            115.66 ms
99.8 percentile:            123.49 ms
99.9 percentile:            131.49 ms
actual query rate:        200.44 Q/s
utilization:               99.94 %
zero hit queries:              0
zero hit percentage:        0.00 %
http request status breakdown:
       200 :     4009
```
