#!/usr/bin/env python3
"""Pure decoder checks against renderer Data fixtures, not a Host execution."""
import copy
import importlib.util
import json
import pathlib

HERE = pathlib.Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("decode", HERE / "trace-decode.py")
decoder = importlib.util.module_from_spec(spec)
spec.loader.exec_module(decoder)


def rejects(operation):
    try:
        operation()
    except (ValueError, KeyError):
        return
    raise AssertionError("invalid observation accepted")


def main():
    fixture = json.loads((HERE / "renderer-evidence.json").read_text())["expected"]
    reserved = next(value for value in fixture if isinstance(value, dict) and value.get("kind") == "Reserved")
    snapshot = next(value for value in fixture if isinstance(value, dict) and value.get("kind") == "Snapshot")
    dispatched = next(value for value in fixture if isinstance(value, dict) and value.get("kind") == "Dispatch")
    lane = decoder.Lane("Motion", "returned-owner")
    lane.event(reserved)
    assert lane.result["rawReservations"] == [{"world": "motion", "label": "raw", "rawId": 17,
        "rawHandle": 17, "components": [
            {"name": "Position", "value": {"coordinates": [1, 2, 3, 4], "frame": 5}},
            {"name": "Velocity", "value": {"rates": [6, 7, 8, 9], "moving": True}},
            {"name": "Selected", "value": {"group": 10}}]}]
    query = decoder.representation(snapshot["query"][0])
    assert lane.row(query, "motion", True) == {"label": "raw", "rawId": 17,
        "main": {"coordinates": [1, 2, 3, 4], "frame": 5},
        "aux": {"rates": [6, 7, 8, 9], "moving": True}, "flag": {"group": 10}}
    assert decoder.outcome(dispatched["outcome"]) == {"ok": False, "error": {
        "kind": "SystemFailure", "system": "B", "error": {"code": 35}}}
    rejects(lambda: lane.event(copy.deepcopy(reserved)))
    foreign = copy.deepcopy(query)
    foreign["handle"]["namespace"] += 1
    rejects(lambda: lane.row(foreign, "motion"))
    rejects(lambda: lane.event(next(value for value in fixture
        if isinstance(value, dict) and value.get("kind") == "ReadDone")))
    rejects(lambda: decoder.decode(json.dumps(reserved)))
    missing = copy.deepcopy(dispatched)
    missing["worldName"] = "alpha"
    rejects(lambda: lane.event(missing))  # This fixture omits other actual capture owners.
    invalid_tracker = copy.deepcopy(dispatched)
    invalid_tracker["tracked"] = 1
    rejects(lambda: lane.event(invalid_tracker))
    untracked = copy.deepcopy(dispatched)
    untracked["tracked"] = False
    before = copy.deepcopy(lane.result["dispatches"])
    lane.event(untracked)
    assert lane.result["dispatches"] == before
    assert lane.raw[-1] == untracked
    foreign_lane = decoder.Lane("Motion", "returned-owner")
    alpha = copy.deepcopy(reserved)
    alpha["worldName"], alpha["label"] = "alpha", "a"
    beta = copy.deepcopy(reserved)
    beta["worldName"], beta["label"] = "beta", "z"
    beta["handle"]["namespace"] += 1
    foreign_lane.event(alpha)
    foreign_lane.event(beta)
    lookup = {"kind": "ForeignLookup", "step": "E10", "receiver": "beta",
              "source": "alpha", "label": "a", "handle": alpha["handle"],
              "result": {"kind": "Missing"}}
    foreign_lane.event(lookup)
    assert foreign_lane.result["foreignLookupDivergence"] == [{
        "receiver": "beta", "source": "alpha", "label": "a", "rawHandle": 17,
        "result": {"result": "MissingEntity"}}]
    found = copy.deepcopy(lookup)
    found["result"] = {"kind": "Found", "value": query}
    rejects(lambda: foreign_lane.event(found))
    substituted = copy.deepcopy(lookup)
    substituted["handle"] = beta["handle"]
    rejects(lambda: foreign_lane.event(substituted))
    print(json.dumps({"status": "PASS", "scope": "decoder fixtures only; no actual Host execution",
        "checked": ["full payload/metadata", "raw ID", "failure code", "handle reissue",
                    "foreign namespace", "unmatched completion", "missing lane", "missing captures"]}))


if __name__ == "__main__":
    main()
