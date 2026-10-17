"""Source-derived shared Dense64 values; not the canonical consumer wire oracle."""
import hashlib
import json


def compact(value):
    return json.dumps(value, separators=(",", ":"), ensure_ascii=False).encode()


def derive(schema):
    assert schema in ("Motion", "Health")
    rows = []
    for j in range(64):
        cells = [j + 64, j + 1, j + 2, j + 3]
        main = ({"coordinates": cells, "frame": 7} if schema == "Motion"
                else {"levels": cells, "reserve": 9, "class": 2})
        aux = None
        if j % 3 == 0:
            aux = ({"rates": [1, 2, 3, 4], "moving": True} if schema == "Motion"
                   else {"layers": [1, 2, 3, 4], "grade": 3})
        rows.append({"rawId": j + 1, "main": main, "aux": aux,
                     "flag": {"group": 8} if j % 3 == 1 else None})
    final = {"rows": rows, "ledger": {"totals": [4096, 101, 102, 103], "epoch": 4}}
    audit = [{"readSum": sum(4 * j + 6 + i for j in range(64)),
              "updated": 64, "selections": {}} for i in range(64)]
    return final, audit


def selftest():
    expected = {
        "Motion": "4e6ba95d94945fdbb54a7f08905f505fc146865e257bb0e2a75dbc2bc158780d",
        "Health": "a0cd7d3a69381d98b6c21b7554ee36b94e768c3d4f6f23aa48517c9416a88db0",
    }
    for schema in expected:
        final, audit = derive(schema)
        assert len(final["rows"]) == 64
        assert sum(row["aux"] is not None for row in final["rows"]) == 22
        assert sum(row["flag"] is not None for row in final["rows"]) == 21
        assert audit[0]["readSum"] == 8448
        assert audit[-1]["readSum"] == 12480
        if expected[schema]:
            assert hashlib.sha256(compact(final)).hexdigest() == expected[schema]
    return True


if __name__ == "__main__":
    selftest()
    print(json.dumps({schema: {"final": derive(schema)[0], "audit": derive(schema)[1]}
                      for schema in ("Motion", "Health")}, separators=(",", ":")))
