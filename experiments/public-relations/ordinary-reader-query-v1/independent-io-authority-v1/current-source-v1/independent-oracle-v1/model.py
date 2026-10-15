#!/usr/bin/env python3
"""Source-only finite IO-authority successor; see DERIVATION.md for source joins.

No candidate output, generated backend or Bend runtime is read or invoked.
Executable Data observations are derived separately from affine owner preservation.
"""

from __future__ import annotations

import gzip
import hashlib
import json
from pathlib import Path


HERE = Path(__file__).resolve().parent


# Complete frozen closure plus host effects and source-model reference.
SOURCE_PINS = json.loads((HERE / 'source-pins.json').read_text())


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def check_sources() -> None:
    for join in json.loads((HERE / 'reuse-source-basis.json').read_text()):
        previous=Path(join['previousPath'])
        assert sha256(previous)==join['previousSHA256']
        def body(path):
            return '\n'.join(line for line in path.read_text().splitlines() if not line.startswith('import '))
        assert body(previous)==body(Path(join['currentPath']))
    for raw_path, expected in SOURCE_PINS.items():
        path = Path(raw_path)
        actual = sha256(path)
        if "?" in expected:
            raise AssertionError(f"unresolved source pin: {path}")
        if actual != expected:
            raise AssertionError(f"source drift: {path}: {actual} != {expected}")


def ls(values: list[str]) -> str:
    return "[" + ", ".join(values) + "]"


def tree4(values: list[str]) -> str:
    assert len(values) == 4
    return f"N(N({values[0]},{values[1]}),N({values[2]},{values[3]}))"


def payload(identifier: int) -> str:
    return f"P(L({identifier}),N(L({identifier + 10}),L({identifier + 20})))"


def store_text(graph: str = "[]/[]") -> str:
    # fixture.bend:53-56 applies leaf(show_slot(value)) at the outer
    # component tree. Payload's nested number trees already include their
    # own L(number) leaves; this second layer is required around each slot's
    # show_slot text.
    slots = tree4(
        [
            "L(absent)",
            f"L({payload(1)})",
            f"L({payload(2)})",
            f"L({payload(3)})",
        ]
    )
    return f"{slots}/removed=/graph={graph}"


LIVE_TEXT = tree4(["L(False)", "L(True)", "L(True)", "L(True)"])


def registration(identifier: int, name: str, access: list[str]) -> str:
    return f"{identifier}:{name}:{ls(access)}"


def failure_domain() -> str:
    """The empty Parent failure domain activated for reader id 1."""
    return "Domain{Key{2},Queue{[],[],0,0},[1]}"


def failure_domains() -> str:
    """The Snapshot field containing the single activated domain."""
    return f"[{failure_domain()}]"


def canonical_receiver_world(namespace: int, clock: int, pending: int, graph: str = "[]/[]") -> str:
    # independent-io-authority-v1/consumer.bend:139 passes the canonical
    # WorldIO-created receiver into W.enqueue before the copied
    # C.writer_registered helper registers writer/inverse/failure metadata.
    # The imported mutation consumer's start(F.fixture(~S,1)) is unreachable
    # from this target entrypoint.
    regs = ls(
        [
            registration(3, "ParentFailures", ["Parent:read"]),
            registration(2, "ParentInverse", ["Parent:read"]),
            registration(1, "ForeignParentWriter", ["Parent:write"]),
        ]
    )
    return (
        f"world={namespace},4,3,{LIVE_TEXT},4,2/"
        f"{store_text(graph)}/resource=N(L(77),L(88))/events=[]"
        f"/pending={pending}/regs={regs}/nextSystem=4/clock={clock}"
    )


def canonical_peer_world(namespace: int) -> str:
    # WI.create starts an empty World and the source's seeded function then
    # reserves/activates ids 1..3.  Capacity grows 1 -> 2 -> 4; no
    # registrations, events, pending commands, or clock effects occur.
    regs = "[]"
    return (
        f"world={namespace},4,3,{LIVE_TEXT},4,2/"
        f"{store_text()}/resource=N(L(177),L(188))/events=[]"
        f"/pending=0/regs={regs}/nextSystem=1/clock=0"
    )


def registry(namespace: int, identifier: int, name: str, access: list[str], cursor: int) -> str:
    reader_id = "Some(1)" if identifier == 3 else "None"
    return f"Registry{{{namespace},{identifier},{name},{ls(access)},{cursor},readerId={reader_id}}}"


def snapshot(
    receiver_namespace: int,
    clock: int,
    tick: int,
    pending: int,
    writer_cursor: int,
    inverse_cursor: int,
    failure_cursor: int,
    positions: str,
    graph: str = "[]/[]",
    domains: str = "[]",
) -> str:
    # C.snapshot observes the canonical receiver registered by the target
    # consumer.  The first four requests are rejected by the namespace gate;
    # the final two requests are queued on this receiver and become visible
    # only at their respective barriers.  The tracked failure reader creates
    # one Position on the pre-positive delivery.  The same successful reader
    # activation retains one empty Parent failure domain in later snapshots.
    return (
        f"Snapshot{{{canonical_receiver_world(receiver_namespace,clock, pending, graph)},[],{domains},{positions},{tick},0,0,65536,nextReader=2,"
        f"{registry(receiver_namespace,1,'ForeignParentWriter',['Parent:write'],writer_cursor)},"
        f"{registry(receiver_namespace,2,'ParentInverse',['Parent:read'],inverse_cursor)},"
        f"{registry(receiver_namespace,3,'ParentFailures',['Parent:read'],failure_cursor)},[101, 102]}}"
    )


def one_report(receiver_namespace: int, peer_namespace: int) -> str:
    # Initial checkpoint, four rejected writer attempts, deferred barrier and
    # tracked failure-reader delivery, then the same-world relation write,
    # inverse query, clear write, and final inverse query.  The snapshots are
    # exactly the checkpoints in consumer.bend's stage/positive call chain.
    states = [
        # C.start/K.start: no clocked operation yet; the tick closure is
        # pending on the canonical receiver.
        (0, 0, 1, 0, 0, 0, "[]", "[]/[]", "[]"),
        # Four successful tracked writes advance the world and writer cursor
        # once each; the queued tick remains pending until the barrier.
        (1, 1, 1, 1, 0, 0, "[]", "[]/[]", "[]"),
        (2, 2, 1, 2, 0, 0, "[]", "[]/[]", "[]"),
        (3, 3, 1, 3, 0, 0, "[]", "[]/[]", "[]"),
        (4, 4, 1, 4, 0, 0, "[]", "[]/[]", "[]"),
        # K.barrier/B.barrier first advances to tick 5, then drains F.tick,
        # which advances the observed World clock to 6 while runtime.tick is
        # the barrier tick 5.
        (6, 5, 0, 4, 0, 0, "[]", "[]/[]", "[]"),
        # K.run advances to 7 and a successful tracked failure reader adopts
        # cursor 7; the runtime reader position is recorded at tick 7.
        (7, 7, 0, 4, 0, 7, "[Position{1,7,5}]", "[]/[]", failure_domains()),
        # LocalRelate runs through K.with_world at clock 8 and leaves one
        # deferred relation command; inverse has not run yet.
        (8, 8, 1, 8, 0, 7, "[Position{1,7,5}]", "[]/[]", failure_domains()),
        # The relation barrier advances to 9; the successful inverse query
        # advances to 10 and adopts inverse cursor 10.
        (10, 10, 0, 8, 10, 7, "[Position{1,7,5}]", "[2:Parent:Children:hierarchy:1>2]/[2:Parent:Children:hierarchy:2:[1]]", failure_domains()),
        # LocalClear runs at clock 11 and retains inverse cursor 10.
        (11, 11, 1, 11, 10, 7, "[Position{1,7,5}]", "[2:Parent:Children:hierarchy:1>2]/[2:Parent:Children:hierarchy:2:[1]]", failure_domains()),
        # The clear barrier advances to 12; the final successful inverse query
        # advances to 13 and adopts inverse cursor 13.
        (13, 13, 0, 11, 13, 7, "[Position{1,7,5}]", "[]/[]", failure_domains()),
    ]
    snapshots = [
        snapshot(receiver_namespace, c, t, p, w, i, f, pos, graph, domains)
        for c, t, p, w, i, f, pos, graph, domains in states
    ]
    peer = canonical_peer_world(peer_namespace)
    peers = [peer] * 11
    local_query = f"Some([Handle{{{receiver_namespace},1}}])"
    receiver = (
        f"Receiver{{{ls(snapshots)},"
        f"{ls(['MissingEntity'] * 4 + ['Queued'] * 2)},"
        f"{ls([local_query, 'Some([])'])},"
        f"[[Reading{{Key{{2}},[],False}}]]}}"
    )
    return (
        f"Some(Report{{{receiver},{ls(peers)},"
        f"Handle{{{receiver_namespace},1}},Handle{{{receiver_namespace},2}},Handle{{{peer_namespace},1}},"
        f"Some([]),[Accepted, Accepted, Accepted],[Accepted, Accepted, Accepted]}})"
    )


def generate() -> bytes:
    # world-namespace.c/.js are shared host allocators.  In one main process
    # workshop obtains (1,2), then garden obtains (3,4).
    return (one_report(1, 2) + "\n" + one_report(3, 4) + "\n").encode("utf-8")


def write_artifacts() -> dict[str, object]:
    check_sources()
    raw = generate()
    expected = HERE / "expected.stdout"
    expected.write_bytes(raw)
    with expected.open("rb") as source, (HERE / "expected.stdout.gz").open("wb") as target:
        with gzip.GzipFile(fileobj=target, mode="wb", mtime=0) as zipped:
            zipped.write(source.read())
    digest = hashlib.sha256(raw).hexdigest()
    return {"bytes": len(raw), "sha256": digest}


def selftest() -> dict[str, object]:
    check_sources()
    raw = generate()
    expected = HERE / "expected.stdout"
    if not expected.exists():
        raise AssertionError("expected.stdout is missing")
    if expected.read_bytes() != raw:
        raise AssertionError("expected.stdout is not the deterministic model output")
    gzip_path = HERE / "expected.stdout.gz"
    with gzip.open(gzip_path, "rb") as stream:
        if stream.read() != raw:
            raise AssertionError("expected.stdout.gz does not decode to expected.stdout")
    if raw.count(f",{failure_domains()},".encode("utf-8")) != 10:
        raise AssertionError("each report must retain the activated domain at five checkpoints")
    assert raw.count(b'nextReader=2,') == 22
    assert raw.count(b'readerId=Some(1)') == 22
    assert raw.count(b'readerId=None') == 44
    assert raw.count(b'Position{1,7,5}') == 10
    assert b'Position{3,' not in raw and b'readerId=Some(3)' not in raw
    assert raw.count(b'MissingEntity') == 8 and raw.count(b'Queued') == 4
    for receiver, peer in [(1,2),(3,4)]:
        report=one_report(receiver,peer)
        assert report.count(canonical_peer_world(peer)) == 11
        assert report.count('world='+str(receiver)+',4,3,') == 11
        assert report.count('resource=N(L(77),L(88))') == 11
        assert report.count('[101, 102]') == 11
        assert report.count('Position{1,7,5}') == 5
        assert report.count('Some([Handle{'+str(receiver)+',1}])') == 1
        assert report.count('/graph=[2:Parent:Children:hierarchy:1>2]/[2:Parent:Children:hierarchy:2:[1]]') == 2
    assert raw.endswith(b'\n') and raw.count(b'\n') == 2
    return {
        "bytes": len(raw),
        "sha256": hashlib.sha256(raw).hexdigest(),
        "gzipBytes": gzip_path.stat().st_size,
        "gzipSha256": hashlib.sha256(gzip_path.read_bytes()).hexdigest(),
        "lines": raw.count(b"\n"),
        "reports": 2,
        "sourcePins": len(SOURCE_PINS),
        "receiverSnapshotsPerReport": 11,
        "domainSnapshotsPerReport": 5,
        "peerSnapshotsPerReport": 11,
        "writesPerReport": 6,
        "queriesPerReport": 2,
        "deliveriesPerReport": 1,
        "runtimeOutputConsulted": False,
        "rendererAudit": {
            "slotTree": store_text(),
            "liveTree": LIVE_TEXT,
            "resourceTree": "N(L(77),L(88))",
        },
        "failureDomain": failure_domain(),
        "failureDomainsField": failure_domains(),
        "failureDomainCheckpoints": [
            "[]", "[]", "[]", "[]", "[]", "[]",
            failure_domains(), failure_domains(), failure_domains(),
            failure_domains(), failure_domains(),
        ],
        "stateTrace": [
            {"checkpoint": 0, "worldClock": 0, "runtimeTick": 0, "pending": 1, "writerCursor": 0, "inverseCursor": 0, "failureCursor": 0},
            {"checkpoint": "1-4", "worldClock": "1-4", "runtimeTick": "1-4", "pending": 1, "writerCursor": "1-4", "inverseCursor": 0, "failureCursor": 0},
            {"checkpoint": 5, "worldClock": 6, "runtimeTick": 5, "pending": 0, "writerCursor": 4, "inverseCursor": 0, "failureCursor": 0},
            {"checkpoint": 6, "worldClock": 7, "runtimeTick": 7, "pending": 0, "writerCursor": 4, "inverseCursor": 0, "failureCursor": 7},
            {"checkpoint": 7, "worldClock": 8, "runtimeTick": 8, "pending": 1, "writerCursor": 8, "inverseCursor": 0, "failureCursor": 7},
            {"checkpoint": 8, "worldClock": 10, "runtimeTick": 10, "pending": 0, "writerCursor": 8, "inverseCursor": 10, "failureCursor": 7},
            {"checkpoint": 9, "worldClock": 11, "runtimeTick": 11, "pending": 1, "writerCursor": 11, "inverseCursor": 10, "failureCursor": 7},
            {"checkpoint": 10, "worldClock": 13, "runtimeTick": 13, "pending": 0, "writerCursor": 11, "inverseCursor": 13, "failureCursor": 7},
        ],
    }


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=["write", "check"])
    args = parser.parse_args()
    if args.command == "write":
        print(json.dumps(write_artifacts(), sort_keys=True))
    else:
        print(json.dumps(selftest(), sort_keys=True))
