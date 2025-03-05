# Copyright Vespa.ai. All rights reserved.

import argparse as ap
import random
import urllib.parse


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


def gen_queries(args):
    dataroom_id_range = 900  # Must match the same definition in gen_docs.py
    dataroom_ids = list(range(1, dataroom_id_range))
    random.shuffle(dataroom_ids)
    for user_id in dataroom_ids[: args.queries]:
        print(get_query(args.targethits, args.dimension, user_id))


parser = ap.ArgumentParser()
parser.add_argument("-d", "--dimension", type=int, default=256)
parser.add_argument("-t", "--targethits", type=int, default=10)
parser.add_argument("-q", "--queries", type=int, default=10)
parser.add_argument("-s", "--seed", type=int, default=1234)
args = parser.parse_args()
random.seed(args.seed)
gen_queries(args)
