#!/usr/bin/env python3
"""Build the public query/check oracle from the static fixture and writer actions."""

from __future__ import annotations

import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
SPEC = json.loads((HERE / "MODEL.json").read_text())
BASE = json.loads((HERE / SPEC["baseComponentOracle"]).read_text())
FAMILIES = ("stock", "title", "active", "count")
TARGETS = range(1, 18)


def project(family: str, value):
    if family == "title":
        return str(value)
    if family == "active":
        return bool(value)
    if family == "count":
        return list(value)
    return int(value)


def row(query, entity):
    result = {"entityId": entity["id"], "data": {}}
    for slot, family, mode in query["selection"]:
        if mode == "optional":
            if family in entity["present"]:
                result["data"][slot] = {
                    "present": True,
                    "value": project(family, entity["values"][family]),
                }
            else:
                result["data"][slot] = {"present": False}
        else:
            result["data"][slot] = project(family, entity["values"][family])
    return result


def matches(query, entity, reader_last, added_at, changed_at):
    present = set(entity["present"])
    if any(family not in present for family in query.get("with", [])):
        return False
    if any(family in present for family in query.get("without", [])):
        return False
    if any(mode == "required" and family not in present
           for _slot, family, mode in query["selection"]):
        return False
    for kind, family in query.get("filters", []):
        stamps = added_at if kind == "added" else changed_at
        if family not in present or stamps[family][entity["id"]] <= reader_last:
            return False
    return True


def result(rows, optional=False):
    if len(rows) == 0:
        if optional:
            return {"ok": True, "value": None}
        return {"ok": False, "error": {"_tag": "NoEntities"}}
    if len(rows) > 1:
        return {"ok": False, "error": {"_tag": "MultipleEntities", "count": len(rows)}}
    return {"ok": True, "value": rows[0]}


def record(query, entities, targets, reader_last, added_at, changed_at):
    selected = {
        entity["id"]: entity
        for entity in entities
        if matches(query, entity, reader_last, added_at, changed_at)
    }
    rows = [row(query, selected[entity_id]) for entity_id in sorted(selected)]
    gets = []
    live = {entity["id"]: entity for entity in entities}
    for entity_id in targets:
        if entity_id not in live:
            value = {"ok": False, "error": {"_tag": "MissingEntity", "entityId": entity_id}}
        elif entity_id not in selected:
            value = {"ok": False, "error": {"_tag": "QueryMismatch", "entityId": entity_id}}
        else:
            value = {"ok": True, "value": row(query, selected[entity_id])}
        gets.append({"target": entity_id, "result": value})
    return {
        "query": query["name"],
        "each": rows,
        "get": gets,
        "single": result(rows),
        "singleOptional": result(rows, optional=True),
    }


def build_schema(schema):
    by_id = BASE["construction"]["allProperFourFamilyPresenceSubsets"]
    entities = [
        {"id": int(entity_id), "present": list(spec["present"]), "values": dict(spec["values"])}
        for entity_id, spec in by_id.items()
    ]
    entities.sort(key=lambda entity: entity["id"])
    # The fixture allocates a seventeenth target and despawns it before reads.
    targets = list(TARGETS)
    added_at = {family: {entity["id"]: 0 for entity in entities} for family in FAMILIES}
    changed_at = {family: {entity["id"]: 0 for entity in entities} for family in FAMILIES}
    queries = BASE["queries"]
    by_name = {query["name"]: query for query in queries}

    # The failed retry callback does not advance its independent reader.
    retry_query = by_name["addedBoth"]
    retry_first = record(retry_query, entities, targets, -1, added_at, changed_at)
    retry_success = record(retry_query, entities, targets, -1, added_at, changed_at)
    retry_repeat = record(retry_query, entities, targets, 0, added_at, changed_at)
    exception_retry = {
        "refusal": "component-query-retry",
        "attempts": [retry_first, retry_success, retry_repeat],
        "retrySuccess": retry_success,
        "retryRepeat": retry_repeat,
    }

    readers = {query["name"]: -1 for query in queries}
    clock = 0
    phases = []
    for phase in SPEC["rounds"]:
        event = next(
            (item for item in SPEC["writerSource"]["events"] if item["name"] == phase.get("writer")),
            None,
        )
        if event is not None:
            clock += 1
            expected_value = SPEC["writerSource"]["initialValue"] + (
                clock - 1
            ) * SPEC["writerSource"]["successIncrement"]
            if expected_value != event["value"]:
                raise ValueError(f"writer event {event['name']} does not follow its source value sequence")
            for entity in entities:
                if not {"stock", "title"}.issubset(entity["present"]):
                    continue
                entity["values"]["stock"] = expected_value
                entity["values"]["title"] = str(expected_value + SPEC["writerSource"]["titleOffset"])
                changed_at["stock"][entity["id"]] = clock
                changed_at["title"][entity["id"]] = clock

        query_records = []
        for query in queries:
            query_records.append(record(
                query, entities, targets, readers[query["name"]], added_at, changed_at
            ))
            readers[query["name"]] = clock

        gates = []
        for query in queries:
            if query.get("filters"):
                continue
            observed = record(query, entities, targets, clock, added_at, changed_at)
            allowed = len(observed["each"]) > 0
            gates.append({
                "query": query["name"],
                "requirements": [],
                "allowed": allowed,
                "observation": "Ran" if allowed else "Skipped",
                "bodyDispatchCount": 1 if allowed else 0,
                "callbackRecords": [observed],
            })
        phases.append({
            "name": phase["name"],
            "completeQueryRecords": query_records,
            "structuralCheckGates": gates,
        })
    return {"schema": schema, "exceptionRetry": exception_retry, "phases": phases}


def main():
    output = {
        "format": 1,
        "application": "InspectorComponentComposition",
        "observations": [build_schema(schema) for schema in BASE["schemas"]],
    }
    print(json.dumps(output, separators=(",", ":")), end="")


if __name__ == "__main__":
    main()
