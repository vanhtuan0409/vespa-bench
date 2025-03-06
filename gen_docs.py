def gen_put(dataroom: int, id: int):
    dataroom_id = f"dataroom{dataroom}"
    return f'{{"put": "id:default:doc:g={dataroom_id}:{id}", "fields": {{"id": {id}}}}}'


NUM_DATAROOM = 2_000
NUM_DOC_PER_DATAROOM = 9_000

if __name__ == "__main__":
    for dataroom in range(0, NUM_DATAROOM):
        for docid in range(0, NUM_DOC_PER_DATAROOM):
            print(gen_put(dataroom + 1, docid + 1))
