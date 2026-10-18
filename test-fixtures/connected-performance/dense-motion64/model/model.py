"""Complete source-defined Dense runtime report; no consumer execution is used."""
import argparse
import copy
import sys
from state import World, derived_shared, expected_seed_writes, listing


def report(schema, count=64, iterations=64, namespace=1, indexed=False):
    world = World(schema, count, namespace, indexed=indexed)
    world.reserve_all()
    reservations = listing(f"Reserved({namespace}:{entity}:0)" for entity in world.order)
    text = (f"DenseRuntime {schema}\ncount={count};iterations={iterations}\n"
            + f"seedOutcome=Success|reservations={reservations}\n")
    text += "seedPending=" + world.world() + "\n"
    world.populate()
    text += "seedApplied=" + world.world() + "\n"
    world.registered = True
    text += "registered=" + world.state() + "\n"
    for _ in range(iterations):
        world.update()
    text += "final=" + world.state() + "\n"
    before = copy.deepcopy(world)
    text += "logicalRows=" + world.logical_rows() + "\n"
    assert before == world
    text += "afterLogicalRead=" + world.world() + "\n"
    return (text + "\n").encode(), world


def selftest():
    for schema in ("Motion", "Health"):
        raw, world = report(schema)
        final, audit = derived_shared(schema, 64)
        assert world.clock == world.cursor == 4203
        assert world.ledger == final["ledger"]["totals"]
        assert len(world.phases) == 128 and world.phases.count("Live") == 64
        assert [sum(values) for values in world.audit] == [row["readSum"] for row in audit]
        assert all(len(values) == 64 for values in world.audit)
        assert raw.endswith(b"\n\n") and b"UNSUPPORTED" not in raw
        # A small model-only input sensitivity check, not another subject gate.
        _, shorter = report(schema, 64, 2)
        assert shorter.clock == expected_seed_writes(64) + 128
        assert shorter.ledger[0] == 128 and len(shorter.audit) == 2
    return True


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("schema", nargs="?", choices=["Motion", "Health"], default="Motion")
    parser.add_argument("count", nargs="?", type=int, default=64)
    parser.add_argument("iterations", nargs="?", type=int, default=64)
    parser.add_argument("--self-test", "--selftest", action="store_true")
    parser.add_argument("--indexed", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        assert selftest()
        print("PASS")
    else:
        sys.stdout.buffer.write(report(args.schema, args.count, args.iterations, indexed=args.indexed)[0])
