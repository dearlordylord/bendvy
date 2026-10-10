"""Source-derived mixed App observations; never reads runtime output."""
import json


def bindings(cursor):
    return (
        "[1:1:PositionRead:Update:cursor=0:[Position, Position]:"
        "[Position:Read, Position:Added], "
        f"1:2:CounterUpdate:Update:cursor={cursor}:[Counter]:[Counter:Write]]"
    )


def world(seeded, value):
    # Component columns address logical entity id - 1; activating the missing
    # second entity grows liveness, but does not grow the component owner array.
    live = "node(node(leaf:False,leaf:True),node(leaf:True,leaf:False))" if seeded else "leaf:False"
    store = "Column{values=leaf:some(Payload{leaf:42});stamps=[1:1:1]}" if seeded else "Column{values=leaf:none;stamps=[]}"
    return (
        f"namespace=1|nextId={3 if seeded else 1}|highWater={2 if seeded else 0}"
        f"|live={live}|capacity={4 if seeded else 1}|depth={2 if seeded else 0}"
        f"|store={store}|resource=leaf:{value}|events=[]|pendingCount=0|pendingEmpty=True"
        "|registrations=[2:CounterUpdate:[Counter], 1:PositionRead:[Position, Position]]"
        f"|nextSystemId=3|clock={1 if seeded else 0}"
    )


def snapshot(seeded, value, ran, enabled=True, inspector_cursor=0, companion=True):
    owners = bindings(int(seeded and ran))
    rows = "[1:1:Product(Found:42,Unit)]" if seeded and inspector_cursor == 0 else "[]"
    debug = (
        "Debug{fixtureInitialCursor=0|bindings=" + owners
        + f"|rows=[{rows}, Counter={value}]}}"
        if enabled else "Disabled"
    )
    probe = "|owners=" + owners if companion else ""
    return debug + probe + "|world{" + world(seeded, value) + "}"


def scenario(seeded, inspector_cursor=0, companion=True):
    # The failure executes replacement but existing transaction rollback restores
    # resource 11. Registered component body is never invoked by this fixture.
    def snap(value, ran, enabled=True):
        return snapshot(seeded, value, ran, enabled, inspector_cursor, companion)
    return "\n".join([
        snap(10, False),
        snap(10, False),
        snap(10, False, False),
        "Success{prior=10}",
        snap(11, True),
        "Failure{prior=11}",
        snap(11, True),
        "Success{prior=11}",
        snap(12, True),
        snap(12, True),
    ])


def report(inspector_cursor=0, companion=True):
    # Both nominal entrypoints construct independently fresh scoped factories;
    # the Report carries Strings, so nominal source names do not enter the wire.
    return ("Report{" + json.dumps(scenario(False, inspector_cursor, companion)) + ", "
            + json.dumps(scenario(True, inspector_cursor, companion)) + "}\n").encode()


if __name__ == "__main__":
    import sys
    sys.stdout.buffer.write(report(int(sys.argv[1]) if len(sys.argv) > 1 else 0,
                                  "--production" not in sys.argv))
