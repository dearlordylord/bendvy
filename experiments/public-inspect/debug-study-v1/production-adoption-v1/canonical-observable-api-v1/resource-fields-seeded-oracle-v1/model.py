"""Independent seeded #70 models, derived from bf59ec413 source only."""
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
PRIOR = HERE.parent / "resource-fields-oracle-v1" / "expected.py"
spec = importlib.util.spec_from_file_location("prior_fields", PRIOR)
prior = importlib.util.module_from_spec(spec)
spec.loader.exec_module(prior)
tree = prior.tree


def scenario(schema):
    first, second = (10, 100) if schema == "a" else (30, 300)
    keys = ["First", "Second"] if schema == "a" else ["Primary", "Secondary"]
    access = "[" + ", ".join(keys) + "]"
    clauses = "[" + ", ".join(key + ":Write" for key in keys) + "]"

    def snapshot(label, f, s, cursor, barrier=False):
        resource = keys[0] + "=" + tree(f) + ";" + keys[1] + "=" + tree(s)
        if schema == "b":
            resource += ";Untouched{values=node(leaf:700,leaf:701);flags=node(leaf:True,leaf:False)}"
        owner = f"owner{{1:2:SelectedResources:access={access}:cursor={cursor}:clauses={clauses}}}"
        world = dict(
            namespace=1, nextId=3, highWater=2,
            live="node(node(leaf:False,leaf:True),node(leaf:True,leaf:False))",
            capacity=4, depth=2,
            store="Column{values=node(leaf:some(Unit),leaf:some(Unit));stamps=[]}",
            resource=resource, events="[91, 92, 99]" if barrier else "[91, 92]",
            pendingCount=0 if barrier else 1, pendingEmpty="True" if barrier else "False",
            registrations="[2:SelectedResources:" + access + ", 1:Unrelated:[unrelated:Read]]",
            nextSystemId=3, clock=3,
        )
        return label + "|" + owner + "|world{" + "|".join(key + "=" + str(value) for key, value in world.items()) + "}"

    f, s = list(range(first, first + 4)), list(range(second, second + 4))
    rows = [snapshot("Before", f, s, 0)]
    for fail in [False, True, False]:
        a, b = f[0], s[0]
        if fail:
            label = f"Failure{{{a}:{b}:{a + 1}}}"
        else:
            label = "Success{" + tree([a, b, a + 1, a + 2]) + "}"
            f, s = list(range(a + 2, a + 6)), list(range(b + 10, b + 14))
        rows.append(snapshot(label, f, s, 3))
    rows.append(snapshot("Barrier", f, s, 3, True))
    return "\n".join(rows)


def output(schema):
    return (json.dumps(scenario(schema)) + "\n").encode()
