"""Corrected source-derived state model for frozen family-readers-v1.

This successor preserves oracle 53ce7a6d9 and repairs source-matrix mistakes
confirmed against the frozen call chain: item-count capacity, held versus
reported frame boundary, source lag predicate, nested Crates projection,
snapshot concatenation, and observer status recomputation after disposal.
format.py only renders snapshots. No Bend-generated output is imported.
"""
from copy import deepcopy

FAMILIES = ("Cargo", "Alerts", "Crates")
VALUES = {"Cargo": 900, "Alerts": 1000, "Crates": 900}


def _empty_stream(family, capacity=2):
    return {
        "domain": family,
        "batches": [],
        "positions": [],
        "statuses": [],
        "next": 1,
        "frameStart": 0,
        "boundary": 0,
        "capacity": capacity,
        "dropped": 0,
    }


def _empty_world(namespace):
    return {
        "ns": namespace,
        "next": 1,
        "high": 0,
        "live": [False],
        "capacity": 1,
        "depth": 0,
        "column": [
            {"entity": entity, "components": [("Value", None, 0, 0)]}
            for entity in (1, 2, 3, 4)
        ],
        "user": [100, 101],
        "logs": {
            "Cargo": {"next": 1, "rows": []},
            "Alerts": {"next": 1, "rows": []},
            "Crates": {"next": 1, "rows": []},
        },
        "events": [],
        "pending": 0,
        "regs": [],
        "sid": 1,
        "clock": 0,
    }


def _runtime(namespace):
    return {
        "tick": 0,
        "world": _empty_world(namespace),
        "streams": {family: _empty_stream(family) for family in FAMILIES},
        "owners": "Unit",
        "journal": [],
        "journalSize": 0,
        "frameStart": 0,
    }


def _access(family, permission):
    return family + ":" + permission


def _register(world, name, access):
    identity = world["sid"]
    world["sid"] += 1
    world["regs"].insert(0, (identity, name, list(access)))
    return {
        "handle": (world["ns"], identity),
        "registry_id": identity,
        "cursor": 0,
        "name": name,
        "access": list(access),
    }


def _reader_registration(runtime, family, name):
    meta = _register(runtime["world"], name, [_access(family, "read")])
    stream = runtime["streams"][family]
    reader_id = stream["next"]
    stream["next"] += 1
    return {
        "handle": (runtime["world"]["ns"], reader_id),
        "registry_id": meta["registry_id"],
        "cursor": 0,
        "name": name,
        "access": meta["access"],
    }


def initial_state(workshop_ns=1, foreign_ns=2):
    """Construct actual WorldIO order, registered publisher, setup and readers."""
    primary = _runtime(workshop_ns)
    foreign = _runtime(foreign_ns)
    publisher_meta = _register(
        primary["world"],
        "empty-world-publisher",
        [_access(family, "write") for family in FAMILIES],
    )
    readers = {
        "fast": _reader_registration(primary, "Cargo", "fast"),
        "slow": _reader_registration(primary, "Cargo", "slow"),
        "alerts": _reader_registration(primary, "Alerts", "alerts"),
        "crates": _reader_registration(primary, "Crates", "crates"),
    }
    args = {"fail": False, "values": [], "scratch": (1, 2)}
    return primary, foreign, publisher_meta, readers, args


def _payload(family, index):
    # Pub.publish emits value=900 and delta=7. Each call emits A, B, A, C.
    # Cargo's second event uses value+1; Alert uses value+100; Crates is a
    # rank-two array with both inner owners retained in its row.
    is_second_cargo = index % 2 == 1
    if family == "Cargo":
        value = 901 if is_second_cargo else 900
        return [value, 7]
    if family == "Alerts":
        return [1000, 7]
    if family == "Crates":
        return [[900, 7], [902, 7]]
    raise AssertionError(family)


def _publish_one(runtime):
    """Run one standalone publisher; preserve A/B/A/C order in world/journal."""
    runtime["tick"] += 1
    tick = runtime["tick"]
    emitted = []
    # The callback order is Cargo, Alerts, Cargo, Crates, even though the
    # declared event type is a nested pair and each stream later projects its
    # own typed leaf.
    publication_order = (("Cargo", 0), ("Alerts", 0),
                         ("Cargo", 1), ("Crates", 0))
    for family, ordinal in publication_order:
        identity = runtime["world"]["logs"][family]["next"]
        row_payload = _payload(family, ordinal)
        runtime["world"]["logs"][family]["next"] += 1
        runtime["world"]["logs"][family]["rows"].append((identity, row_payload))
        record = {"family": family, "id": identity}
        emitted.append(record)
        runtime["world"]["events"].append(record)
    # Domain batches are one per family and publisher call. Keep exact family
    # order inside each typed leaf; global interleaving remains in journal.
    for family in FAMILIES:
        ids = [event["id"] for event in emitted if event["family"] == family]
        if ids:
            runtime["streams"][family]["batches"].append((tick, ids))
    runtime["journal"].append((tick, emitted))
    runtime["journalSize"] += len(emitted)
    return "published:7:recovery(Cargo=[],Alerts=[],Crates=[])\n"


def _lookup_position(stream, reader_id):
    return next((position for position in stream["positions"] if position[0] == reader_id), None)


def _set_position(stream, reader_id, cursor, registered_at, *, success):
    current = _lookup_position(stream, reader_id)
    if current is None:
        current = (reader_id, 0, registered_at)
        stream["positions"].insert(0, current)
    if success:
        updated = (reader_id, cursor, current[2])
        stream["positions"] = [updated if row[0] == reader_id else row
                               for row in stream["positions"]]


def _read_ids(stream, cursor):
    return [identity for batch_tick, ids in stream["batches"] if cursor < batch_tick
            for identity in ids]


def _lagged(position, dropped_through):
    # event-runtime.reading uses max(cursor, registeredAt), including lazy
    # first-use positions whose registeredAt is the pre-call route tick.
    _, cursor, registered_at = position
    return max(cursor, registered_at) < dropped_through


def _projection(family, identity):
    payload = _row_payload_current(family, identity)
    # Request index 0 and markers Array{90,91}; Payload.at preserves that
    # complete marker owner in every projection. Crates uses fixture.nested_at:
    # descend to the first crate's Array<U32>, then Payload.at reads cell 0.
    value = payload[0][0] if family == "Crates" else payload[0]
    assert type(value) is int
    return (value, [90, 91])


def _row_payload_current(family, identity):
    # Exact emitted values from Pub.publish_once(delta=7).
    if family == "Cargo":
        return [901 if identity % 2 == 0 else 900, 7]
    if family == "Alerts":
        return [1000, 7]
    if family == "Crates":
        return [[900, 7], [902, 7]]
    raise AssertionError(family)


def _read(runtime, family, reader_meta, args, *, fail):
    """Reader route: pre-callback tick capture, Args threading, success/failure."""
    args["fail"] = fail
    stream = runtime["streams"][family]
    pre_call_tick = runtime["tick"]
    runtime["tick"] += 1
    tick = runtime["tick"]
    reader_id = reader_meta["handle"][1]
    current = _lookup_position(stream, reader_id)
    position = current if current is not None else (reader_id, 0, pre_call_tick)
    cursor = position[1]
    registered_at = position[2]
    lagged = _lagged(position, stream["dropped"])
    selected = _read_ids(stream, cursor)
    consumed = []
    for identity in selected:
        args["values"].append(_projection(family, identity))
        args["scratch"] = (args["scratch"][0] + 1, args["scratch"][1])
        consumed.append(identity)
        if fail:
            break
    if fail:
        _set_position(stream, reader_id, cursor, registered_at, success=False)
        return "body-failed", args, lagged
    _set_position(stream, reader_id, tick, registered_at, success=True)
    return "success", args, lagged


def _skip(runtime, family, reader_meta):
    # `skip` only updates an existing event position; the slow reader has none.
    stream = runtime["streams"][family]
    reader_id = reader_meta["handle"][1]
    current = _lookup_position(stream, reader_id)
    if current is not None:
        stream["positions"] = [
            (identity, runtime["tick"], registered_at) if identity == reader_id
            else (identity, cursor, registered_at)
            for identity, cursor, registered_at in stream["positions"]
        ]
    return "skipped-slow\n"


def _at_capacity(batches, capacity, dropped):
    """Mirror Ev.at_capacity: compare capacity against all batch values."""
    remaining = list(batches)
    while remaining and sum(len(items) for _, items in remaining) > capacity:
        tick, _ = remaining.pop(0)
        dropped = max(dropped, tick)
    return remaining, dropped


def _frame(runtime):
    """Apply per-domain held cutoff, item-count capacity and log retirement."""
    runtime["tick"] += 0  # FR.frame observes current route tick; it does not run a system.
    family_dropped = {}
    receipts = {}
    for family in FAMILIES:
        stream = runtime["streams"][family]
        # event-stream.frame stores the prior frameStart as the public boundary;
        # the positions' minimum is a separate internal past-window cutoff.
        boundary = stream["frameStart"]
        held_boundary = boundary
        for _, cursor, _ in stream["positions"]:
            held_boundary = min(held_boundary, cursor)
        stream["boundary"] = boundary
        remaining = []
        dropped = stream["dropped"]
        for batch_tick, ids in stream["batches"]:
            if batch_tick <= held_boundary:
                dropped = max(dropped, batch_tick)
            else:
                remaining.append((batch_tick, ids))
        remaining, dropped = _at_capacity(remaining, stream["capacity"], dropped)
        stream["batches"] = remaining
        stream["dropped"] = dropped
        stream["frameStart"] = runtime["tick"]
        family_dropped[family] = dropped

    kept_journal = []
    for batch_tick, records in runtime["journal"]:
        kept = [record for record in records
                if batch_tick > family_dropped[record["family"]]]
        if kept:
            kept_journal.append((batch_tick, kept))
    runtime["journal"] = kept_journal
    runtime["journalSize"] = sum(len(records) for _, records in kept_journal)
    runtime["world"]["events"] = [record for _, records in kept_journal for record in records]

    for family in FAMILIES:
        retained_ids = {record["id"] for record in runtime["world"]["events"]
                        if record["family"] == family}
        rows = runtime["world"]["logs"][family]["rows"]
        receipts[family] = [row for row in rows if row[0] not in retained_ids]
        runtime["world"]["logs"][family]["rows"] = [
            row for row in rows if row[0] in retained_ids]
    runtime["frameStart"] = runtime["tick"]
    return tuple(receipts[family] for family in FAMILIES)


def _shutdown(runtime):
    receipts = tuple(list(runtime["world"]["logs"][family]["rows"])
                     for family in FAMILIES)
    for family in FAMILIES:
        runtime["world"]["logs"][family]["rows"] = []
        runtime["streams"][family]["batches"] = []
    runtime["world"]["events"] = []
    runtime["journal"] = []
    runtime["journalSize"] = 0
    return receipts


def _dispose(runtime, reader_meta, family):
    registry_id = reader_meta["registry_id"]
    runtime["world"]["regs"] = [row for row in runtime["world"]["regs"]
                                  if row[0] != registry_id]
    stream = runtime["streams"][family]
    reader_id = reader_meta["handle"][1]
    stream["positions"] = [row for row in stream["positions"] if row[0] != reader_id]


def _snapshot_line(label, primary, foreign, publisher, readers, args):
    from format import render_snapshot
    return render_snapshot(label, _observed(primary), _observed(foreign),
                           publisher, readers, args)


def _observed(runtime):
    """Recompute View.stream's derived statuses at each observation."""
    observed = deepcopy(runtime)
    for stream in observed["streams"].values():
        stream["statuses"] = [
            (identity, cursor, registered_at,
             sum(len(ids) for tick, ids in stream["batches"] if cursor < tick),
             _lagged((identity, cursor, registered_at), stream["dropped"]))
            for identity, cursor, registered_at in stream["positions"]
        ]
    return observed


def _retired_line(prefix, receipt):
    from format import render_retired
    return prefix + render_retired(receipt) + "\n"


def derive_workshop():
    primary, foreign, publisher, readers, args = initial_state(1, 2)
    output = [_snapshot_line("registered", primary, foreign, publisher, readers, args)]

    output.append(_publish_one(primary))
    output.append(_snapshot_line("publish1", primary, foreign, publisher, readers, args))

    status, args, lagged = _read(primary, "Cargo", readers["fast"], args, fail=True)
    output.append(f"fast:{status}:lag={lagged}\n")
    output.append(_snapshot_line("fastfail", primary, foreign, publisher, readers, args))

    status, args, lagged = _read(primary, "Cargo", readers["fast"], args, fail=False)
    output.append(f"fast:{status}:lag={lagged}\n")
    output.append(_snapshot_line("fastretry", primary, foreign, publisher, readers, args))

    status, args, lagged = _read(primary, "Alerts", readers["alerts"], args, fail=False)
    output.append(f"alerts:{status}:lag={lagged}\n")
    output.append(_snapshot_line("alertsread", primary, foreign, publisher, readers, args))

    status, args, lagged = _read(primary, "Crates", readers["crates"], args, fail=False)
    output.append(f"crates:{status}:lag={lagged}\n")
    output.append(_snapshot_line("cratesread", primary, foreign, publisher, readers, args))

    # Foreign-run preflight refuses the namespace mismatch before runtime update.
    output.append("fast:rejected\n")
    output.append(_snapshot_line("foreign", primary, foreign, publisher, readers, args))

    output.append(_publish_one(primary))
    output.append(_snapshot_line("publish2", primary, foreign, publisher, readers, args))

    _skip(primary, "Cargo", readers["slow"])
    output.append("skipped-slow\n")
    output.append(_snapshot_line("skip", primary, foreign, publisher, readers, args))

    receipt = _frame(primary)
    output.append(_retired_line("frame:", receipt))
    output.append(_snapshot_line("frame1", primary, foreign, publisher, readers, args))

    output.append(_publish_one(primary))
    output.append(_snapshot_line("publish3", primary, foreign, publisher, readers, args))

    receipt = _frame(primary)
    output.append(_retired_line("frame:", receipt))
    output.append(_snapshot_line("frame2", primary, foreign, publisher, readers, args))

    status, args, lagged = _read(primary, "Cargo", readers["slow"], args, fail=False)
    output.append(f"slow:{status}:lag={lagged}\n")
    output.append(_snapshot_line("slowlag", primary, foreign, publisher, readers, args))

    status, args, lagged = _read(primary, "Cargo", readers["fast"], args, fail=False)
    output.append(f"fast:{status}:lag={lagged}\n")
    output.append(_snapshot_line("fastlag", primary, foreign, publisher, readers, args))

    receipt = _shutdown(primary)
    output.append(_retired_line("shutdown:", receipt))
    output.append(_snapshot_line("shutdown1", primary, foreign, publisher, readers, args))

    receipt = _shutdown(primary)
    output.append(_retired_line("shutdown:", receipt))
    output.append(_snapshot_line("shutdown2", primary, foreign, publisher, readers, args))

    for reader_name, family in (("fast", "Cargo"), ("slow", "Cargo"),
                                 ("alerts", "Alerts"), ("crates", "Crates")):
        _dispose(primary, readers[reader_name], family)
        from format import render_runtime
        output.append(render_runtime(_observed(primary)))
    output.append("disposed-all\n")
    return "".join(output), primary, foreign, publisher, readers, args


def derive_garden():
    # The second nominal schema repeats the exact same source-level operation
    # sequence with WorldIO-assigned namespaces 3 and 4.
    return derive_workshop_for_namespaces(3, 4)


def derive_workshop_for_namespaces(primary_ns, foreign_ns):
    # Keep one operation implementation shared by the source's two nominal
    # schema specializations. `derive_workshop` is deliberately not called here
    # to ensure namespace inputs remain explicit in the source basis.
    primary, foreign, publisher, readers, args = initial_state(primary_ns, foreign_ns)
    output = [_snapshot_line("registered", primary, foreign, publisher, readers, args)]
    output.append(_publish_one(primary)); output.append(_snapshot_line("publish1", primary, foreign, publisher, readers, args))
    status, args, lagged = _read(primary, "Cargo", readers["fast"], args, fail=True)
    output.append(f"fast:{status}:lag={lagged}\n"); output.append(_snapshot_line("fastfail", primary, foreign, publisher, readers, args))
    status, args, lagged = _read(primary, "Cargo", readers["fast"], args, fail=False)
    output.append(f"fast:{status}:lag={lagged}\n"); output.append(_snapshot_line("fastretry", primary, foreign, publisher, readers, args))
    status, args, lagged = _read(primary, "Alerts", readers["alerts"], args, fail=False)
    output.append(f"alerts:{status}:lag={lagged}\n"); output.append(_snapshot_line("alertsread", primary, foreign, publisher, readers, args))
    status, args, lagged = _read(primary, "Crates", readers["crates"], args, fail=False)
    output.append(f"crates:{status}:lag={lagged}\n"); output.append(_snapshot_line("cratesread", primary, foreign, publisher, readers, args))
    output.append("fast:rejected\n"); output.append(_snapshot_line("foreign", primary, foreign, publisher, readers, args))
    output.append(_publish_one(primary)); output.append(_snapshot_line("publish2", primary, foreign, publisher, readers, args))
    _skip(primary, "Cargo", readers["slow"])
    output.append("skipped-slow\n"); output.append(_snapshot_line("skip", primary, foreign, publisher, readers, args))
    receipt = _frame(primary); output.append(_retired_line("frame:", receipt)); output.append(_snapshot_line("frame1", primary, foreign, publisher, readers, args))
    output.append(_publish_one(primary)); output.append(_snapshot_line("publish3", primary, foreign, publisher, readers, args))
    receipt = _frame(primary); output.append(_retired_line("frame:", receipt)); output.append(_snapshot_line("frame2", primary, foreign, publisher, readers, args))
    status, args, lagged = _read(primary, "Cargo", readers["slow"], args, fail=False)
    output.append(f"slow:{status}:lag={lagged}\n"); output.append(_snapshot_line("slowlag", primary, foreign, publisher, readers, args))
    status, args, lagged = _read(primary, "Cargo", readers["fast"], args, fail=False)
    output.append(f"fast:{status}:lag={lagged}\n"); output.append(_snapshot_line("fastlag", primary, foreign, publisher, readers, args))
    receipt = _shutdown(primary); output.append(_retired_line("shutdown:", receipt)); output.append(_snapshot_line("shutdown1", primary, foreign, publisher, readers, args))
    receipt = _shutdown(primary); output.append(_retired_line("shutdown:", receipt)); output.append(_snapshot_line("shutdown2", primary, foreign, publisher, readers, args))
    from format import render_runtime
    for reader_name, family in (("fast", "Cargo"), ("slow", "Cargo"), ("alerts", "Alerts"), ("crates", "Crates")):
        _dispose(primary, readers[reader_name], family)
        output.append(render_runtime(_observed(primary)))
    output.append("disposed-all\n")
    return "".join(output), primary, foreign, publisher, readers, args


def derive_complete():
    workshop = derive_workshop_for_namespaces(1, 2)[0]
    garden = derive_workshop_for_namespaces(3, 4)[0]
    return "Workshop\n" + workshop + "Garden\n" + garden + "\n"


def _selftest():
    from format import _literal_controls
    _literal_controls()

    # Projection's declared Data is Projection{value: U32, markers: List<U32>};
    # nested_at must descend the first Crates owner before Payload.at(index=0).
    assert _projection("Cargo", 1) == (900, [90, 91])
    assert _projection("Alerts", 1) == (1000, [90, 91])
    assert _projection("Crates", 1) == (900, [90, 91])
    assert all(type(_projection(family, 1)[0]) is int for family in FAMILIES)

    # Ev.at_capacity compares the total item count, not the number of batches.
    capacity_batches, capacity_dropped = _at_capacity(
        [(1, [1, 2]), (6, [3, 4])], capacity=2, dropped=0)
    assert capacity_batches == [(6, [3, 4])] and capacity_dropped == 1
    assert _at_capacity([(6, [3, 4])], capacity=2, dropped=1) == (
        [(6, [3, 4])], 1)

    # The reported boundary is old frameStart; the cursor minimum is only the
    # internal held cutoff. Reading lag is the source's max(cursor,registeredAt)
    # predicate, with lazy first-use registeredAt equal to pre-call tick.
    assert _lagged((1, 3, 1), 1) is False
    assert _lagged((1, 3, 1), 6) is True
    assert _lagged((2, 0, 7), 6) is False
    assert _lagged((2, 8, 7), 6) is False
    assert _lagged((1, 9, 1), 6) is False

    matrix, _, _, matrix_readers, matrix_args = initial_state(1, 2)
    _publish_one(matrix)
    assert _read(matrix, "Cargo", matrix_readers["fast"], matrix_args, fail=True)[2] is False
    assert _read(matrix, "Cargo", matrix_readers["fast"], matrix_args, fail=False)[2] is False
    _read(matrix, "Alerts", matrix_readers["alerts"], matrix_args, fail=False)
    _read(matrix, "Crates", matrix_readers["crates"], matrix_args, fail=False)
    _publish_one(matrix)
    frame1_receipts = _frame(matrix)
    assert frame1_receipts == ([(1, [900, 7]), (2, [901, 7])], [], [])
    cargo1 = matrix["streams"]["Cargo"]
    alerts1 = matrix["streams"]["Alerts"]
    crates1 = matrix["streams"]["Crates"]
    assert (cargo1["boundary"], cargo1["frameStart"], cargo1["dropped"],
            cargo1["batches"]) == (0, 6, 1, [(6, [3, 4])])
    assert (alerts1["boundary"], alerts1["frameStart"], alerts1["dropped"],
            alerts1["batches"]) == (0, 6, 0, [(1, [1]), (6, [2])])
    assert (crates1["boundary"], crates1["frameStart"], crates1["dropped"],
            crates1["batches"]) == (0, 6, 0, [(1, [1]), (6, [2])])
    assert matrix["journalSize"] == 6
    assert [(tick, [(r["family"], r["id"]) for r in rows])
            for tick, rows in matrix["journal"]] == [
                (1, [("Alerts", 1), ("Crates", 1)]),
                (6, [("Cargo", 3), ("Alerts", 2), ("Cargo", 4), ("Crates", 2)]),
            ]

    _publish_one(matrix)
    frame2_receipts = _frame(matrix)
    assert frame2_receipts == (
        [(3, [900, 7]), (4, [901, 7])],
        [(1, [1000, 7])],
        [(1, [[900, 7], [902, 7]])],
    )
    cargo2 = matrix["streams"]["Cargo"]
    alerts2 = matrix["streams"]["Alerts"]
    crates2 = matrix["streams"]["Crates"]
    assert (cargo2["boundary"], cargo2["frameStart"], cargo2["dropped"],
            cargo2["batches"]) == (6, 7, 6, [(7, [5, 6])])
    assert (alerts2["boundary"], alerts2["frameStart"], alerts2["dropped"],
            alerts2["batches"]) == (6, 7, 1, [(6, [2]), (7, [3])])
    assert (crates2["boundary"], crates2["frameStart"], crates2["dropped"],
            crates2["batches"]) == (6, 7, 1, [(6, [2]), (7, [3])])
    assert matrix["journalSize"] == 6
    assert [(tick, [(r["family"], r["id"]) for r in rows])
            for tick, rows in matrix["journal"]] == [
                (6, [("Alerts", 2), ("Crates", 2)]),
                (7, [("Cargo", 5), ("Alerts", 3), ("Cargo", 6), ("Crates", 3)]),
            ]
    assert _read(matrix, "Cargo", matrix_readers["slow"], matrix_args, fail=False)[2] is False
    assert _read(matrix, "Cargo", matrix_readers["fast"], matrix_args, fail=False)[2] is True
    assert matrix_args["scratch"] == (10, 2) and len(matrix_args["values"]) == 9
    assert sorted(matrix["streams"]["Cargo"]["positions"]) == [(1, 9, 1), (2, 8, 7)]

    workshop, primary, foreign, publisher, readers, args = derive_workshop_for_namespaces(1, 2)
    assert len([line for line in workshop.splitlines() if "|runtime(" in line]) == 16
    assert primary["tick"] == 9
    assert primary["frameStart"] == 7
    assert args["scratch"] == (10, 2)
    assert len(args["values"]) == 9
    assert "fast:body-failed:lag=False\nfastfail|" in workshop
    fastfail = workshop[workshop.index("fastfail|"):workshop.index("fastretry|")]
    fastretry = workshop[workshop.index("fastretry|"):workshop.index("alertsread|")]
    assert "args(fail=True,values=[(900,[90, 91])],scratch=N(L(2),L(2)))" in fastfail
    assert "args(fail=False,values=[(900,[90, 91]), (900,[90, 91]), (901,[90, 91])]" in fastretry
    assert primary["streams"]["Cargo"]["positions"] == []
    assert primary["streams"]["Cargo"]["next"] == 3
    assert primary["streams"]["Cargo"]["boundary"] == 6
    assert primary["streams"]["Cargo"]["frameStart"] == 7
    assert primary["streams"]["Cargo"]["dropped"] == 6
    assert primary["world"]["regs"] == [(1, "empty-world-publisher", ["Cargo:write", "Alerts:write", "Crates:write"])]
    assert primary["world"]["events"] == []
    assert primary["journal"] == []
    assert foreign["tick"] == 0 and foreign["world"]["regs"] == []
    assert publisher["registry_id"] == 1
    assert [readers[name]["registry_id"] for name in ("fast", "slow", "alerts", "crates")] == [2, 3, 4, 5]
    garden = derive_workshop_for_namespaces(3, 4)[0]
    assert "runtime(tick=0,world(ns=3" in garden
    complete = derive_complete()
    assert complete.startswith("Workshop\n") and "Garden\n" in complete
    assert complete.endswith("disposed-all\n\n")
    # snapshot_join emits no delimiter; following callback text is concatenated.
    initial = initial_state(1, 2)
    assert not _snapshot_line("registered", *initial[:2], *initial[2:]).endswith("\n")
    assert "args=args(fail=False,values=[],scratch=N(L(1),L(2)))published:7:" in complete
    # Re-evaluate statuses for every post-disposal View.runtime, not a cached
    # empty placeholder. The first removal leaves slow/Alerts/Crates owners.
    post, _, _, post_readers, _ = initial_state(1, 2)
    post["streams"]["Cargo"]["positions"] = [(1, 9, 1), (2, 8, 7)]
    post["streams"]["Cargo"]["dropped"] = 6
    post["streams"]["Alerts"]["positions"] = [(1, 4, 3)]
    post["streams"]["Alerts"]["dropped"] = 1
    post["streams"]["Crates"]["positions"] = [(1, 5, 4)]
    post["streams"]["Crates"]["dropped"] = 1
    _dispose(post, post_readers["fast"], "Cargo")
    observed = _observed(post)
    assert observed["streams"]["Cargo"]["statuses"] == [(2, 8, 7, 0, False)]
    assert observed["streams"]["Alerts"]["statuses"] == [(1, 4, 3, 0, False)]
    assert observed["streams"]["Crates"]["statuses"] == [(1, 5, 4, 0, False)]
    from format import render_runtime
    assert "statuses=[(2,8,7,0,False)]" in render_runtime(observed)
    assert len(complete.encode("utf-8")) > len(workshop.encode("utf-8"))
    print("family reader source-model selftest passed")


if __name__ == "__main__":
    _selftest()
