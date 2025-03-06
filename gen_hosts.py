import json
import sys


def gen_host_alias(dns: str, alias: str):
    return f'<host name="{dns}"><alias>{alias}</alias></host>'


def gen_group(tf_state, alias_prefix):
    return list(
        map(
            lambda it: gen_host_alias(it[1], f"{alias_prefix}{it[0]}"),
            enumerate(tf_state["value"]),
        )
    )


def flatten(xss):
    return [x for xs in xss for x in xs]


if __name__ == "__main__":
    tf_state = sys.stdin.read()
    parsed = json.loads(tf_state)
    hosts = flatten(
        [
            gen_group(parsed["configserver_dnses"], "vespa-config"),
            gen_group(parsed["content_dnses"], "vespa-content"),
            gen_group(parsed["docproc_dnses"], "vespa-docproc"),
            gen_group(parsed["search_dnses"], "vespa-search"),
        ]
    )

    res = '<?xml version="1.0" encoding="utf-8" ?>'
    res += f"<hosts>{"".join(hosts)}</hosts>"
    print(res)
