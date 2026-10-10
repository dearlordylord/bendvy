"""Independent pinned TS scenario model; never consumes runtime output."""
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent


def values(n):
    return list(range(n, n + 4))


def world(schema, first, second, frame, tick, applied=False, missing=False):
    names = ["First", "Second"] if schema == "A" else ["Primary", "Secondary"]
    resources = {schema + "/" + names[0]: values(first)}
    if not missing:
        resources[schema + "/" + names[1]] = values(second)
    if schema == "Other":
        resources[schema + "/Untouched"] = {"values": [700, 701], "flags": [True, False]}
    components = {schema + "/Cell": {}}
    if applied:
        components[schema + "/Marker"] = 99
    return dict(version=1, frame=frame, tick=tick, entityCount=2,
                entities=[dict(id=1, components=components, relations={}),
                          dict(id=2, components={schema + "/Cell": {}}, relations={})],
                resources=resources, machines={},
                pendingCommands=[] if applied else [dict(tag="insert", system=schema + "/QueueMarker")])


def model():
    seeded = []
    for schema in ["A", "Other"]:
        a, b = (10, 100) if schema == "A" else (30, 300)
        names = ["First", "Second"] if schema == "A" else ["Primary", "Secondary"]
        metadata = [dict(name=schema + "/" + name, resources=dict(reads=[], writes=[]))
                    for name in ["HoldEvents", "Seed", "Unrelated", "QueueMarker"]]
        metadata.append(dict(name=schema + "/SelectedResources",
                             resources=dict(reads=[], writes=[schema + "/" + n for n in names])))
        # Setup: reader tick1, seed tick2, event publication tick3, explicit
        # deferred tick4, unrelated tick5, queue tick6. Fresh Inspector tick7.
        phases = [dict(label="before", world=world(schema, a, b, 1, 7), events=[91, 92], calls=[])]
        calls = []
        for index, (label, fail) in enumerate([("commit", False), ("failure", True), ("retry", False)]):
            before_a, before_b = a, b
            calls.append(dict(fail=fail, observed=[a, b, a + 1, a + 2]))
            if fail:
                result = dict(ok=False, error=dict(kind="SystemFailure", system=schema + "/SelectedResources",
                                                  error=dict(first=a, second=b, afterFirst=a + 1)))
            else:
                result = dict(ok=True)
                a, b = a + 2, b + 10
            phases.append(dict(label=label, result=result, world=world(schema, a, b, index + 2, 9 + index * 2),
                               events=[91, 92], calls=json.loads(json.dumps(calls))))
        phases.append(dict(label="barrier", result=dict(ok=True), world=world(schema, a, b, 5, 15, True),
                           events=[91, 92], calls=calls))
        seeded.append(dict(schema=schema, metadata=metadata, phases=phases))
    provisioning = []
    for missing in [True, False]:
        before = world("A", 10, 100, 1, 6, missing=missing)
        if missing:
            result = dict(ok=False, error=dict(kind="MissingRuntimeRequirements",
                                              requirements=[dict(kind="resource", name="A/Second")]))
            after, calls = before, []
        else:
            result = dict(ok=True)
            after = world("A", 12, 110, 2, 7)
            calls = [dict(fail=False, observed=[10, 100, 11, 12])]
        provisioning.append(dict(missingSecond=missing, before=before, result=result, after=after, calls=calls))
    return dict(seeded=seeded, duplicate="Duplicate schema key: First", provisioning=provisioning)


if __name__ == "__main__":
    expected = model()
    (HERE / "expected.json").write_text(json.dumps(expected, indent=2) + "\n")
    (HERE / "expected.stdout").write_text(json.dumps(expected, separators=(",", ":")) + "\n")
