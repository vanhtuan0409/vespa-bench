# Copyright Vespa.ai. All rights reserved.

from pathlib import Path
import random
from typing import IO
import urllib.parse

WHALE_ID = 3_000
NUM_DATAROOM = 2_000
VECTOR_DIMENSION = 256

NUM_QUERY = 10
NUM_TARGET_HITS = 10


def random_vector(dimension):
    return [random.randint(0, 100000) / 100000.0 for _ in range(dimension)]


def get_query(target_hits, dimension, dataroom_id):
    params = {
        "yql": "select * from doc where {targetHits:%s}nearestNeighbor(embedding,qemb)"
        % target_hits,
        "input.query(qemb)": random_vector(dimension),
        "streaming.groupname": "dataroom%i" % dataroom_id,
        "presentation.summary": "minimal",
        "hits": target_hits,
    }
    return "/search/?" + urllib.parse.urlencode(params)


def all_dataroom_ids():
    dataroom_ids = list(range(1, NUM_DATAROOM))
    random.shuffle(dataroom_ids)
    return dataroom_ids


DATAROOM_IDS = all_dataroom_ids()


def gen_small_only(f: IO):
    for dataroom_id in DATAROOM_IDS[:NUM_QUERY]:
        f.write(get_query(NUM_TARGET_HITS, VECTOR_DIMENSION, dataroom_id) + "\n")


def gen_whale_only(f: IO):
    for _idx in range(0, NUM_QUERY):
        f.write(get_query(NUM_TARGET_HITS, VECTOR_DIMENSION, WHALE_ID))


def gen_mixed(f: IO):
    small_count = int(NUM_QUERY * 0.8)
    for dataroom_id in DATAROOM_IDS[:small_count]:
        f.write(get_query(NUM_TARGET_HITS, VECTOR_DIMENSION, dataroom_id) + "\n")

    whale_count = NUM_QUERY - small_count
    for _idx in range(0, whale_count):
        f.write(get_query(NUM_TARGET_HITS, VECTOR_DIMENSION, WHALE_ID))


if __name__ == "__main__":
    ext_dir = Path(".") / "ext"
    with open(ext_dir / "query_smalls.txt", "w") as f:
        gen_small_only(f)
    with open(ext_dir / "query_whale.txt", "w") as f:
        gen_whale_only(f)
    with open(ext_dir / "query_mixed.txt", "w") as f:
        gen_mixed(f)
