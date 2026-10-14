#!/usr/bin/env python3
"""Source-derived positive-path oracle-v4 for the #42 IO-authority reader fixture.

This model is deliberately finite.  It follows the source renderer and the
source operation order; it never invokes Bend, a generated backend, or a
runtime output.  The target IO consumer's ``own_lookup`` registers the copied
mutation writer on its canonical ``WorldIO.create`` receiver.  The imported
mutation consumer's ``start(F.fixture(~S,1))`` helper is not called by this
entrypoint and is therefore not the operation receiver modeled here.  The
positive suffix uses the receiver's second reserved handle for a same-world
Parent relation, queries it, then queues and applies a clear.

This successor fixes two source-composition omissions in v3: the outer
component-slot tree applies ``fixture.bend:53-56``'s leaf wrapper around each
``show_slot`` result, and ``system.bend:75-92`` advances a successful tracked
inverse reader's cursor to the observed world clock.  v3 is retained as a
historical source-only predecessor.
"""

from __future__ import annotations

import gzip
import hashlib
import json
from pathlib import Path


HERE = Path(__file__).resolve().parent
LEAF = HERE.parent
REPO = Path("/workspace/formal-proofs/bendvy")


# These are the source identities actually used by this finite derivation.
# The three leaf files and the copied mutation files are the direct program
# sources; the remaining entries pin the world/registration/event/failure
# operations used to derive the fields rendered by render.bend.
SOURCE_PINS = {
    str(LEAF / "consumer.bend"): "9b39d5fa18449935b605a493910a3111fcbd0465b322e1886af8f5c75beda790",
    str(LEAF / "main.bend"): "3160664a5c6bc17b34c38d2ea331d15460d573bcd22ff55c882521ce330fe4d9",
    str(LEAF / "render.bend"): "ba292d2f88178e7564b5a37cd2bf0813e455a8427f71971c572bbd33a9099096",
    str(LEAF.parent / "mutation-composition-v1/fixture.bend"): "e8f413e4add7fcdc2e09bd1d9367c0b153046d3599b435c3adbc47f2cddf85b3",
    str(LEAF.parent / "mutation-composition-v1/operations.bend"): "2b64fbe65eb968aac8bdc5c046b556f10311e5758d9ef9e88debd80852accf86",
    str(LEAF.parent / "mutation-composition-v1/consumer.bend"): "b5aa3a508fd82ee1e67ca3db2636812d97415186a0b4a006f9120a07b46d9903",
    str(REPO / "src/ecs/world-io.bend"): "1be0fcd577ecf177af89136f77e5c8e67894304a89adefaf0565591f641a63e9",
    str(REPO / "src/ecs/world.bend"): "f03b45d2349b24467a4b5b604a9416ca1a504bba36fddcb75d06fb8146d9f310",
    str(REPO / "src/ecs/world-namespace.bend"): "92f7205a5d4d633289348960e139f5797354ff7dbfb0627b5d9435e17c5f48d7",
    str(REPO / "src/ecs/world-namespace.c"): "b218011c7738b7ac8ca94963b8c8cacd97006af6fa1c6ab6f4ac506c612b4521",
    str(REPO / "src/ecs/world-namespace.js"): "f463bf328c4232fec85c67e328d93309e2191d80b7377be64355b6c1edd4f815",
    str(REPO / "src/ecs/string-equality.bend"): "2f0f31d7ab0151d0619412b68cfd8304ae20905c147628e36d9dd2918cf27723",
    str(REPO / "src/ecs/capabilities.bend"): "bc25cd83326709700de1f8ecc1fa53623883a4c3e423db67aa64eaffc3f1d6fe",
    str(REPO / "src/ecs/column.bend"): "3fec368b85fd1d43e53de3838ec32486c5d74b628a7069a82a83e60922b29f2a",
    str(REPO / "src/ecs/commands.bend"): "f62a8a7efb24ee7307bc180774c67067e1d95100a47fa4ac7a8384150047dc1d",
    str(REPO / "src/ecs/component.bend"): "0e41557cc6b8101490eaa7f4bf5fbdf896a2646e9b2359d7daf41db6de45988c",
    str(REPO / "src/ecs/indexed-lifecycle.bend"): "e997f3b089149a54afb6485fcb2167d1fd0e86979bfa16329473d3a235e8b8d5",
    str(REPO / "src/ecs/lifecycle.bend"): "6585d64ff88a3985a663d42c5b9a82ff3d5067e6ad451f506fad146c4fbd09b0",
    str(REPO / "src/ecs/owner-handoff.bend"): "91f7e7f40877da928bb64e64a87ffd218a15e982afbc24199b8778cd4e7effec",
    str(REPO / "src/ecs/registration.bend"): "34a78022a38c297b49680acecbfeb675532eb9f32bfad7aceb2a854dc35d31a5",
    str(REPO / "src/ecs/relation-cleanup.bend"): "88ebedf43b8cde2d8e4effd7413ec49bdb213352de72dd8815274935eaa1a5f3",
    str(REPO / "src/ecs/system.bend"): "e1a7e54cfd862a440bb2d2277045c0d861a4806e17015f901cfe4ab3f776d113",
    str(REPO / "src/ecs/event-runtime.bend"): "2ef936d15f30d713c1cb9a69fdbcf2d52ec3f820cbc9e7f1895c1e49d6535557",
    str(REPO / "src/ecs/relation-failure-runtime.bend"): "11df4128184ea27bd9f87993235ef9459342c17c5165858814fea1f62c460ac9",
    str(REPO / "src/ecs/relation-failure-reader.bend"): "6c355ea7f29297ee96172c39364b97cbf0f8223b7cce7f46d85636919a36c75e",
    str(REPO / "src/ecs/relation-commands.bend"): "941d8f3b11dfad4088ac324cd2d07759c6650f108c584f34bdac80e5c96403bb",
    str(REPO / "src/ecs/relation-providers.bend"): "6a69de7d29d0a150446689228878f19df5b6d2fdefdfcb2eb1ce1048246ac594",
    str(REPO / "src/ecs/relation-types.bend"): "63f433974a2650c34c84fbab359b0301a91b96f7bf3ff5d19f3f05911e869057",
    str(REPO / "src/ecs/relation-graph.bend"): "61a67454a456969463a68b4571bcc3426a5df8016dca8889cd26acaf1fc22e8d",
    str(REPO / "src/ecs/transaction.bend"): "a27dcd99fec5de95256e810ace6c5540791969dbe1e0c99916ec38b5f7e3040b",
    str(REPO / "src/ecs/internal/relation-failures/domains.bend"): "38821350d2565c576067bb4f9e2ba03cbe1b65da47258555c0c2b213eaafd379",
    str(REPO / "src/ecs/internal/relation-failures/queue.bend"): "ca7363dac7df55b46fc06e42b123a874fbeae3181abe0c8da37d99ae9da524df",
    str(REPO / "src/ecs/internal/relation-failures/readings.bend"): "09bcc21e95fbedef0c3f48025e93bc3088e7a89edfd2011d33d96884bc3d4a0e",
    str(REPO / "src/ecs/internal/relation-failures/routing.bend"): "928a41657992d49110836caa4d7dd0349e14b003f8cf9112c413206c9b9df693",
    str(REPO / "src/ecs/internal/relation-failures/barrier.bend"): "78f61ec8cd251f8362f738f264c313ec3ed15246c5227d8a90c43fbada967752",
}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def check_sources() -> None:
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
    return f"Registry{{{namespace},{identifier},{name},{ls(access)},{cursor}}}"


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
) -> str:
    # C.snapshot observes the canonical receiver registered by the target
    # consumer.  The first four requests are rejected by the namespace gate;
    # the final two requests are queued on this receiver and become visible
    # only at their respective barriers.  The tracked failure reader creates
    # one Position on the pre-positive delivery.
    return (
        f"Snapshot{{{canonical_receiver_world(receiver_namespace,clock, pending, graph)},[],[],{positions},{tick},0,0,65536,"
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
        (0, 0, 1, 0, 0, 0, "[]", "[]/[]"),
        # Four successful tracked writes advance the world and writer cursor
        # once each; the queued tick remains pending until the barrier.
        (1, 1, 1, 1, 0, 0, "[]", "[]/[]"),
        (2, 2, 1, 2, 0, 0, "[]", "[]/[]"),
        (3, 3, 1, 3, 0, 0, "[]", "[]/[]"),
        (4, 4, 1, 4, 0, 0, "[]", "[]/[]"),
        # K.barrier/B.barrier first advances to tick 5, then drains F.tick,
        # which advances the observed World clock to 6 while runtime.tick is
        # the barrier tick 5.
        (6, 5, 0, 4, 0, 0, "[]", "[]/[]"),
        # K.run advances to 7 and a successful tracked failure reader adopts
        # cursor 7; the runtime reader position is recorded at tick 7.
        (7, 7, 0, 4, 0, 7, "[Position{3,7,5}]", "[]/[]"),
        # LocalRelate runs through K.with_world at clock 8 and leaves one
        # deferred relation command; inverse has not run yet.
        (8, 8, 1, 8, 0, 7, "[Position{3,7,5}]", "[]/[]"),
        # The relation barrier advances to 9; the successful inverse query
        # advances to 10 and adopts inverse cursor 10.
        (10, 10, 0, 8, 10, 7, "[Position{3,7,5}]", "[2:Parent:Children:hierarchy:1>2]/[2:Parent:Children:hierarchy:2:[1]]"),
        # LocalClear runs at clock 11 and retains inverse cursor 10.
        (11, 11, 1, 11, 10, 7, "[Position{3,7,5}]", "[2:Parent:Children:hierarchy:1>2]/[2:Parent:Children:hierarchy:2:[1]]"),
        # The clear barrier advances to 12; the final successful inverse query
        # advances to 13 and adopts inverse cursor 13.
        (13, 13, 0, 11, 13, 7, "[Position{3,7,5}]", "[]/[]"),
    ]
    snapshots = [snapshot(receiver_namespace, c, t, p, w, i, f, pos, graph) for c, t, p, w, i, f, pos, graph in states]
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
    return {
        "bytes": len(raw),
        "sha256": hashlib.sha256(raw).hexdigest(),
        "gzipBytes": gzip_path.stat().st_size,
        "gzipSha256": hashlib.sha256(gzip_path.read_bytes()).hexdigest(),
        "lines": raw.count(b"\n"),
        "reports": 2,
        "sourcePins": len(SOURCE_PINS),
        "receiverSnapshotsPerReport": 11,
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
