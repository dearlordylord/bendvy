"""Exact candidate syntax migration for the frozen generation-zero #28 workload."""
import hashlib
from pathlib import Path


BASELINE_COMMIT = "327bec49d41f00f88950343dea1edc1e0ec97dc4"
# Pin every archived workload input: the generation-zero premise depends on
# operation order as well as on the four syntax sites being adapted.
WORKLOAD_SHA256 = {'array-controls.bend': 'f5c6c28b2a563db088331309b6753ec09ccc00b2c8f22931e838b7cd5e913cd2',
 'declarations.bend': '50da7392497713d68874a609c39f418f829611654c1db05973e2249463ada9f2',
 'driver.bend': 'cf15e0ca8bbb1ea0b410776a3f74916e3f86f10ff9a92d44f0efcc5ad5974b4c',
 'expected.json': 'e042305fedcb646ff7a52d28ca3fd5ba9f11a1eda2a12cd5c945dd77f57bb742',
 'gameplay.bend': '590a878e0002afcc4904dc42c7a36df1b2afc3c3515dac8dac773cbed7d24670',
 'json.bend': '826fca39e8bd47bef326b9fd141d1784bc1f9004c7b460894a602cc3100f16be',
 'main.bend': '4339adc4de65c6bcbe25f243ba3a152ee16509fe3a74c966251d6ccc0bba97dd',
 'observe.bend': '0380c97203301393e5954aafe1be98269f5e2776de7f5aebb6eed25071f366ac',
 'reference.mjs': '40ea098e003335229a2fdbeac023ad01a786fca6322165d1a698889c01358e35',
 'scenario-ops.bend': 'fb6e87b28dd29552f530c4986b793726a6f3f00e5e29c3641e01a7d1b2c5d64e',
 'scenario.md': 'f05bf4d785d86f09052fe6b11c8f7e6c06b149b599e2fdde106ef0a11e112857',
 'schema.bend': 'd845bf538d8368406bed7473677f9c3511f311d373511d8e6322728e5d5b8384',
 'timing-main.bend': 'a7fea467df249864772e4be3e229342cddd2e457bed6fb596f28e224b203fbb6',
 'verify.py': 'e80c4264366b7380f516689964e5d0204a93b75eef4e7958351f4abbbe4a9235'}

REPLACEMENTS = {
    "scenario-ops.bend": (
        ("import ../../src/ecs/world.bend as W\n",
         "import ../../src/ecs/world.bend as W\nimport ../../src/ecs/entity-key.bend as K\n"),
        ("  W.Handle{namespace,id}\n", "  W.Handle{namespace,K.EntityKey{id,0}}\n"),
    ),
    "driver.bend": (("W.Handle{namespace,2}", "Ops.handle(namespace,2)"),),
    "observe.bend": (("  match handle:\n    case W.Handle{_,id}: id\n",
                      "  W.handle_index(~S.Schema,handle)\n"),),
    "schema.bend": (("  match handle:\n    case W.Handle{_,+id}: clear_inner(store,id)\n",
                     "  clear_inner(store,W.handle_index(~Schema,handle))\n"),),
}


def digest(body):
    return hashlib.sha256(body).hexdigest()


def migrate_candidate(stage, baseline_commit, *, provider_schema=False):
    """Validate the entire archive before writing any candidate-only edits.

    Seed IDs1..6 and churn ID7 are reserved before any release; subsequent
    operations allocate no entity. Full handles therefore have generation0,
    while existing JSON and physical-column observations retain their IDs.
    Supplied provider files are overlaid later and are never transformed here.
    """
    if baseline_commit != BASELINE_COMMIT:
        raise ValueError("Generational fixture adapter requires its exact baseline commit")
    workload = Path(stage) / "examples/query-composition"
    bodies = {path.name: path.read_bytes() for path in workload.iterdir() if path.is_file()}
    if set(bodies) != set(WORKLOAD_SHA256):
        raise ValueError("Unexpected archived workload membership")
    for name, expected in WORKLOAD_SHA256.items():
        if digest(bodies[name]) != expected:
            raise ValueError("Unexpected archived workload bytes: " + name)
    changes = []
    for name, replacements in REPLACEMENTS.items():
        if provider_schema and name == "schema.bend":
            continue
        original = bodies[name]
        body = original.decode()
        for before, after in replacements:
            if body.count(before) != 1:
                raise ValueError("Unexpected archived syntax count: " + name)
            body = body.replace(before, after)
        changed = body.encode()
        changes.append((name, changed, {"path": "examples/query-composition/" + name,
                        "beforeSHA256": digest(original), "afterSHA256": digest(changed),
                        "replacements": len(replacements)}))
    # Every hash and syntax count passes before the first candidate mutation.
    for name, body, _record in changes:
        (workload / name).write_bytes(body)
    return {"baselineCommit": baseline_commit,
            "providerFilesTransformed": False,
            "files": [record for _name, _body, record in changes]}
