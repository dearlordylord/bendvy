#!/usr/bin/env python3
"""Finite comparator controls; deliberately not integrated runtime evidence."""
import copy
import importlib.util
import json
import pathlib
import sys

HERE = pathlib.Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("compare", HERE / "trace-compare.py")
compare = importlib.util.module_from_spec(spec)
spec.loader.exec_module(compare)


def alter(value):
    if isinstance(value, dict):
        key = next(reversed(value))
        value[key] = alter(value[key])
    elif isinstance(value, list):
        if value:
            value[-1] = alter(value[-1])
        else:
            value.append("unexpected")
    elif isinstance(value, bool):
        value = not value
    elif isinstance(value, int):
        value += 1
    elif isinstance(value, str):
        value += ":mutant"
    else:
        value = "unexpected"
    return value


def main():
    envelope = json.loads(pathlib.Path(sys.argv[1]).read_text())
    original = compare.project(envelope)
    assert compare.difference(original, copy.deepcopy(original)) == []
    killed = []
    lane = "Motion/returned-owner"
    for channel in compare.CHANNELS:
        mutant = copy.deepcopy(original)
        mutant[lane][channel] = alter(mutant[lane][channel])
        assert compare.difference(original, mutant), channel
        killed.append(channel)
    assert compare.difference({"value": 1}, {"value": True})
    assert compare.difference({"value": [1, 2, 3, 4]}, {"value": [1, 2, 3]})
    assert compare.difference({"value": [1, 2]}, {"value": [2, 1]})
    assert compare.difference({"value": None}, {"value": None, "extra": None})
    for label in ("missing_lane", "duplicate_lane", "missing_channel"):
        mutant = copy.deepcopy(envelope)
        if label == "missing_lane":
            mutant["results"].pop()
        elif label == "duplicate_lane":
            mutant["results"].append(mutant["results"][0])
        else:
            del mutant["results"][0]["snapshots"]
        try:
            compare.project(mutant)
        except (ValueError, KeyError):
            killed.append(label)
        else:
            raise AssertionError(label)
    print(json.dumps({"scope": "comparator controls only", "status": "PASS",
                      "channel_perturbations": killed,
                      "structural_controls": ["bool_vs_int", "length", "order", "extra_field"]}))


if __name__ == "__main__":
    main()
