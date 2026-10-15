# Current-source IO-authority independent oracle

Frozen producer `1bceb3211810fe77030e447454bdad6029e4be1d`; main SHA-256 `7bca0c2c3f6d5adca89615d41d2b23f7f0f2968ae2a6fe1a48fa39c8b0ab583b`. The immutable 33-source closure is `/tmp/bendvy43-io-authority-oracle-source01`. `source-pins.json` binds those sources plus the actual namespace C/JS effects, Base, print C/JS effects and the preceding source-only model (39 pins). `reuse-source-basis.json` additionally pins and checks four import-only body joins: main, IO consumer, fixture and operations. Historical expected bytes were not read or copied.

The prior independent-oracle-v5 model's complete source-derived scenario and serializer audit remain applicable to those operation bodies. This successor changes the ownership metadata modeled from the actual current K runtime and adapter, rather than substituting fields into an old golden. `K.started_clocked` initializes nextReader to 1. Writer and inverse registration use Sy and consume only system IDs 1 and 2. K.register creates system registry ID 3 but independently allocates reader ID 1 and increments nextReader to 2. The adapter observes the actual K.Reader field. Consequently every snapshot renders nextReader=2, the writer and inverse registry views render readerId=None, and the failure registry view renders readerId=Some(1). Successful failure delivery activates domain reader [1] and Position{1,7,5}; it does not use system ID 3 as a failure-reader identity.

## Operations and complete observed trace

Main binds Workshop then Garden in one process. The pinned C atomic allocator starts at 1; the JS Symbol.for global allocator shares the same monotonically increasing counter across nominal schema instantiations. Fresh process/realm execution therefore creates receiver/peer namespaces 1/2 and then 3/4. Each world reserves and activates IDs 1,2,3. The complete live tree, capacity4/depth2, component slot trees and nested payload arrays, resource arrays, graph, events, pending count, registrations, next system ID and world clock are retained by the source renderer. Receiver resource is [77,88]; peer resource is [177,188]. Peer snapshots remain byte-identical across all eleven checkpoints.

The real target-created receiver is passed to own_lookup and writer_registered; the imported adapter's alternate start(F.fixture(...,1)) is not reached. The receiver has one actual pending F.tick closure, writer/inverse/failure registries, and failure callback args [101,102]. Four tracked foreign namespace requests (ForeignSource, ForeignTarget, ForeignClear, ForeignClear) return MissingEntity before staging commands. They retain the original pending closure, complete peer state, store and graph. Accepted tracked invocations still advance the receiver's world clock and writer cursor. The barrier advances to tick5 and drains F.tick, which advances actual clock to6. Failure delivery advances actual clock to7 and commits its tracked registry cursor7, creates the empty Parent domain and retains its reader provenance.

LocalRelate then enqueues one actual command (clock8), barrier applies Parent edge1→2 (clock9), inverse query runs at10 and returns Some([Handle{receiver,1}]). LocalClear queues a command at11; its barrier at12 clears the graph, and inverse query at13 returns Some([]). Both relation operations succeed without failure publications. The current per-command barrier collector cannot change this fixture's history because its deferred closures publish no failures. The pending_count tail-safe transport observes the same actual closure counts.

| Checkpoint | World clock | Runtime tick | Pending | Writer / inverse / failure cursor | Domains and position |
| --- | --- | --- | --- | --- | --- |
| 0 | 0 | 0 | 1 | 0 / 0 / 0 | empty |
| 1–4 | 1–4 | 1–4 | 1 | 1–4 / 0 / 0 | empty |
| 5 | 6 | 5 | 0 | 4 / 0 / 0 | empty |
| 6 | 7 | 7 | 0 | 4 / 0 / 7 | Parent queue empty, readers[1], Position{1,7,5} |
| 7 | 8 | 8 | 1 | 8 / 0 / 7 | retained |
| 8 | 10 | 10 | 0 | 8 / 10 / 7 | retained; graph has edge and inverse |
| 9 | 11 | 11 | 1 | 11 / 10 / 7 | retained; clear still pending |
| 10 | 13 | 13 | 0 | 11 / 13 / 7 | retained; graph empty |

The failure delivery is one empty Reading for declared key2 with lagged=False. All actual queues, domain membership, positions and args remain complete in each Snapshot; no arrays are summarized. The renderer's outer component slots wrap show_slot text in L(...), separately from each payload's own nested array leaves. Registry metadata order, list comma-space separators and Maybe wrappers follow the pinned render and Base implementations.

## Wire, validation and limits

Expected stdout is **19,822 bytes**, SHA-256 `f142d9f2264e27374bc0a5faba818717472df3335ba0574a72250cae5667d5b9`. Two sequential IO.print effects each append exactly one LF to a report argument with no embedded LF. The raw and deterministic gzip golden contain both complete reports. `python3 model.py check` verifies source pins/import-only joins, full raw and gzip equality, namespace separation, all 22 full receiver/peer checkpoints, 22 nextReader/Some(1) observations, 44 None observations, retained domain/position metadata, resources/args, graph suffix, foreign refusals and exact IO framing. Python source checks pass.

This oracle uses no runtime, generated backend or actual candidate output. The producer's source check reports nine foreign/IO safety refusals and is not a mathematical proof; it does not establish backend execution. Allocator expectations require a fresh process/JS realm with no preceding namespace allocations. Fixture show_notice contains placeholder text for failure/paused notice variants. This scenario publishes neither variant: foreign requests fail the namespace gate before enqueue, F.tick only advances the clock, and local relate/clear succeed. All observed event lists are empty. Therefore this oracle makes no claim to qualify nonempty failure/paused payload rendering. This bridge does not exercise ordinary scheduler callback failure/skip/disposal; those remain separate acceptance scopes. It preserves executable Data projections and source-threaded owners without claiming an affine-owner equality theorem. Historical v5 oracle artifacts remain untouched.
