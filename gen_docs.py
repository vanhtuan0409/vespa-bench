from pathlib import Path


WHALE_ID = 3_000
NUM_DOC_PER_WHALE = 700_000

NUM_DATAROOM = 2_000
NUM_DOC_PER_DATAROOM = 9_000


def gen_put(dataroom: int, id: int):
    dataroom_id = f"dataroom{dataroom}"
    if dataroom != WHALE_ID:
        agg_id = (dataroom - 1) * NUM_DOC_PER_DATAROOM + id
    else:
        agg_id = NUM_DATAROOM * NUM_DOC_PER_DATAROOM + id
    return f'{{"put": "id:default:doc::{agg_id}", "fields": {{"id": {agg_id}, "dataroom_id": "{dataroom_id}"}}}}'


if __name__ == "__main__":
    ext_dir = Path(".") / "ext"

    with open(ext_dir / "docs.jsonl", "w") as f:
        print("Generate small dataroom")
        for dataroom in range(0, NUM_DATAROOM):
            for docid in range(0, NUM_DOC_PER_DATAROOM):
                f.write(gen_put(dataroom + 1, docid + 1) + "\n")

        print("Generate whale dataroom")
        for docid in range(0, NUM_DOC_PER_WHALE):
            f.write(gen_put(WHALE_ID, docid + 1) + "\n")
