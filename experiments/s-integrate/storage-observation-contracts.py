#!/usr/bin/env python3
"""Independent #19 observation-contract falsification, NOT runtime execution."""
import copy
import hashlib
import json
from pathlib import Path


def main_value(schema, x):
    values = [x, x + 1, x + 2, x + 3]
    return ({"coordinates": values, "frame": 7} if schema == "Motion" else
            {"levels": values, "reserve": 9, "class": 2})


def aux_value(schema):
    return ({"rates": [1, 2, 3, 4], "moving": True} if schema == "Motion" else
            {"layers": [1, 2, 3, 4], "grade": 3})


def row(schema, entity, x, aux=False, flag=False, added=1, changed=1):
    return {"id": entity, "main": None if x is None else main_value(schema, x),
            "aux": aux_value(schema) if aux else None,
            "flag": {"group": 8} if flag else None,
            "added": 0 if x is None else added,
            "changed": 0 if x is None else changed}


def world(schema, namespace):
    return {"schema": schema, "namespace": namespace, "next": 1, "rows": [],
            "ledger": {"totals": [100, 101, 102, 103], "epoch": 4},
            "mode": "On", "pending": [], "removed": [], "despawned": []}


def handle(w, entity):
    return {"schema": w["schema"], "namespace": w["namespace"], "id": entity}


def selected(w, mode):
    return [copy.deepcopy(r) for r in sorted(w["rows"], key=lambda r: r["id"])
            if r["main"] is not None and
            (mode not in ("present", "absent") or
             (r["flag"] is not None) == (mode == "present"))]


def lookup(w, h, mode="required"):
    if h["schema"] != w["schema"] or h["namespace"] != w["namespace"]:
        return {"kind": "MissingEntity"}
    target = next((r for r in w["rows"] if r["id"] == h["id"]), None)
    if target is None:
        return {"kind": "MissingEntity"}
    match = next((r for r in selected(w, mode) if r["id"] == h["id"]), None)
    return ({"kind": "Found", "row": match} if match is not None else
            {"kind": "QueryMismatch"})


def snapshot(w):
    return {"world": copy.deepcopy(w),
            "queries": {m: selected(w, m) for m in
                        ("required", "present", "absent", "optional")},
            "lookups": {str(i): lookup(w, handle(w, i)) for i in range(1, 7)}}


def reserve_model(before, bundles):
    w = copy.deepcopy(before)
    handles = []
    for bundle in bundles:
        assert w["next"] < 2**32 - 1
        entity = w["next"]
        w["next"] += 1
        handles.append(handle(w, entity))
        value = copy.deepcopy(bundle)
        value["id"] = entity
        w["pending"].append({"op": "spawn", "row": value})
    # Model empty ticks are explicitly observational identity, not apply().
    return {"handles": handles, "afterReserve": snapshot(w),
            "afterEmptyTick": snapshot(w), "afterSecondEmptyTick": snapshot(w)}


def apply_model(before, tick):
    """Simple full-field specification, independent of any Bend representation."""
    w = copy.deepcopy(before)
    for command in w["pending"]:
        if command["op"] == "spawn":
            r = copy.deepcopy(command["row"])
            if r["main"] is not None:
                r["added"] = r["changed"] = tick
            w["rows"].append(r)
        elif command["op"] == "insert_main":
            target = next((r for r in w["rows"] if r["id"] == command["id"]), None)
            if target is not None:  # same-world stale insert is a no-op
                if target["main"] is None:
                    target["added"] = tick
                target["main"] = copy.deepcopy(command["main"])
                target["changed"] = tick
        else:
            raise AssertionError("This contract slice only models spawn/insert_main")
    w["pending"] = []
    w["rows"].sort(key=lambda r: r["id"])
    return snapshot(w)


def pending_contract(before, bundles, observed):
    return observed == reserve_model(before, bundles)


def barrier_contract(before, tick, observed):
    return observed == apply_model(before, tick)


def foreign_contract(before, foreign, payload, observed):
    if foreign["schema"] != before["schema"] or foreign["namespace"] == before["namespace"]:
        return False  # exclude a different schema or a local handle from this law
    return observed == {"status": "MissingEntity", "receiver": snapshot(before),
                        "lookup": {"kind": "MissingEntity"},
                        "returnedPayloadView": payload}


def leaves(value, path=()):
    if isinstance(value, dict):
        for key, child in value.items():
            yield from leaves(child, path + (key,))
    elif isinstance(value, list):
        for index, child in enumerate(value):
            yield from leaves(child, path + (index,))
        if not value:
            yield path, value
    else:
        yield path, value


def replace_at(value, path, replacement):
    result = copy.deepcopy(value)
    cursor = result
    for key in path[:-1]:
        cursor = cursor[key]
    cursor[path[-1]] = replacement
    return result


def perturb(value):
    if isinstance(value, bool):
        return not value
    if isinstance(value, int):
        return value + 1
    if isinstance(value, str):
        return value + "!"
    return {"unexpected": True}


def check_case(name, predicate, valid, extra=()):
    assert predicate(valid), name + ": original contract fixture rejected"
    rejected = []
    for path, value in leaves(valid):
        altered = replace_at(valid, path, perturb(value))
        assert not predicate(altered), (name, path, "altered field accepted")
        rejected.append("/".join(map(str, path)))
    for label, altered in extra:
        assert not predicate(altered), (name, label, "semantic perturbation accepted")
        rejected.append(label)
    return {"case": name, "validAccepted": True,
            "perturbedObservationsRejected": len(rejected),
            "rejectedPathSha256": hashlib.sha256("\n".join(rejected).encode()).hexdigest(),
            "additionalSemanticControls": [label for label, _ in extra]}


def run():
    results = []
    for schema in ("Motion", "Health"):
        alpha = world(schema, 1 if schema == "Motion" else 3)
        beta = world(schema, 2 if schema == "Motion" else 4)
        bundles = [row(schema, 0, 10, True, True), row(schema, 0, 20),
                   row(schema, 0, None, True, True)]
        e0 = reserve_model(alpha, bundles)
        results.append(check_case(schema + "/E0", lambda o: pending_contract(alpha, bundles, o), e0))
        pending = e0["afterReserve"]["world"]
        e1 = apply_model(pending, 1)
        assert e1["lookups"]["3"] == {"kind": "QueryMismatch"}
        assert [r["id"] for r in e1["queries"]["required"]] == [1, 2]
        results.append(check_case(schema + "/E1", lambda o: barrier_contract(pending, 1, o), e1))

        pre8 = copy.deepcopy(alpha)
        pre8["next"] = 7  # a,b,c,p,failed q,r consumed in this source-derived fixture
        pre8["rows"] = [row(schema, 1, None, True), row(schema, 3, None, True, True),
                        row(schema, 4, 51, flag=True, added=5, changed=6),
                        row(schema, 6, 60, added=5, changed=5)]
        # Cleanup wrote p.slot0 only; full retained tail differs from V(51).
        key = "coordinates" if schema == "Motion" else "levels"
        pre8["rows"][2]["main"][key] = [51, 51, 52, 53]
        pre8["ledger"]["totals"] = [201, 101, 102, 103]
        pre8["removed"] = [handle(alpha, 1), handle(alpha, 2)]
        pre8["despawned"] = [handle(alpha, 2)]
        pre8["pending"] = [{"op": "insert_main", "id": entity, "main": main_value(schema, value)}
                           for entity, value in ((4, 71), (1, 80), (3, 30), (1, 81), (2, 90))]
        e8 = apply_model(pre8, 8)
        assert [r["id"] for r in e8["queries"]["required"]] == [1, 3, 4, 6]
        assert [r["id"] for r in e8["queries"]["present"]] == [3, 4]
        reversed_input = copy.deepcopy(pre8)
        reversed_input["pending"].reverse()
        wrong_order = copy.deepcopy(e8)
        wrong_order["queries"]["required"].reverse()
        revived = copy.deepcopy(e8)
        revived["world"]["rows"].append(row(schema, 2, 90))
        results.append(check_case(schema + "/E8", lambda o: barrier_contract(pre8, 8, o), e8,
                                 (("reversedFIFO", apply_model(reversed_input, 8)),
                                  ("physicalQueryOrder", wrong_order), ("staleRevival", revived))))

        beta_pending = reserve_model(beta, [row(schema, 0, 90, flag=True)])["afterReserve"]["world"]
        beta_live = apply_model(beta_pending, 1)["world"]
        for direction, receiver, foreign in (("alpha-to-beta", beta_live, handle(alpha, 1)),
                                             ("beta-to-alpha", e1["world"], handle(beta, 1))):
            receiver = copy.deepcopy(receiver)
            receiver["pending"] = [{"op": "insert_main", "id": 1, "main": main_value(schema, 77)}]
            payload = main_value(schema, 500)
            good = {"status": "MissingEntity", "receiver": snapshot(receiver),
                    "lookup": {"kind": "MissingEntity"}, "returnedPayloadView": payload}
            predicate = lambda o: foreign_contract(receiver, foreign, payload, o)
            results.append(check_case(schema + "/E10/" + direction, predicate, good))
            assert not foreign_contract(receiver, handle(receiver, 1), payload, good)
    return {"evidenceKind": "independent observation-contract falsification",
            "integratedRuntimeExecuted": False, "proof": False,
            "actualTypeOwnerIdentityEstablished": False,
            "source": "docs/design/s-integrate-trace.md E0/E1/E8/E10",
            "cases": results, "validCases": len(results),
            "rejectedPerturbedObservations": sum(r["perturbedObservationsRejected"] for r in results),
            "excludedDomainControls": 4,
            "contractSourceSha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest()}


if __name__ == "__main__":
    print(json.dumps(run(), indent=2))
