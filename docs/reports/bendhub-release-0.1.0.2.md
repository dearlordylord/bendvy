# BendHub release 0.1.0.2

Package `bendvy-ecs-core@0.1.0.2` resolves to
`0xb2b0f04555daca474f0f77d0966945c9`. Source/export commit is
`e3dbf4ad65e01260d81092e58ee044a043a94c8b`. Checks use unchanged Bend 2.0.39
and Clang 19.1.7. License remains MIT OR Apache-2.0.

## Change and compatibility

Component reads combine validation and Store access without reconstructing an
intermediate World. Namespace, generation and live checks remain. Pending,
stale, foreign and absent-component behavior is preserved. Arbitrary Type
payloads and resources retain ownership, as do commands, events and metadata.

Public compatibility change: `Raw.Text` in decode-data becomes
`Raw.BendvyText` because Bend 2.0.39 Base defines Text. Callers constructing
or matching this variant must update its spelling. Fields and variant position
are unchanged. No compiler or toolchain changes are included.

## Behavior and package checks

JavaScript and native outputs match for affine custody, query composition,
captured rollback, clock-system and user simulation. Ten authority controls
pass on both candidate and compatibility-only baseline. The stale positive
detached-frame control now uses the current factory-created World, EntityKey
and optional cursor. Its oracle and all negative controls are unchanged. A
forced-invalid namespace mutant fails the custody oracle. These finite checks
do not constitute a universal equivalence proof.

The official importer populated an empty isolated cache. All 367 downloaded
files match the normalized export byte for byte. The publisher omits the
export's unreachable `internal/machine_handler_events.bend`. Manifest SHA256
is `b2b0f04555daca474f0f77d0966945c972904472ad9ebb634d169584f07f1b3a`.

A Survivors consumer from c39d149 changes only four package import prefixes.
Two 1,200-step solo scenarios produce 2,402 equal complete observations and
identical final states against deployed version 47, including reward choices.
Late missing-component rollback returns equal complete worlds. A two-player
600-step co-op comparison also matches all observations and final state. The
native full run passes at tick 36,786 with level 32, 2,941 kills, 36 decisions
and boss, chest and evolution coverage, matching the earlier scenario.

## Performance scope

Five rotating early-game Linux WebKit trials reduce median 600-step simulation
and observation time from 7,050 ms (7,005..7,144) on version 47 to 6,841 ms
(6,696..6,932). Every paired replacement trial is faster. Historical median is
7,865 ms (7,795..7,906). These are simulation timings, not whole-page FPS.

A separate populated cohort reuses a validated tick-9,000 prefix. Before
timing, 603 complete observations and both final states match the frozen
oracle. All 20 trials complete 600 moves and two rewards, alive at tick 9,600
with 509 actors. Each side has five samples.

| Version | Median ms | Range ms |
| --- | ---: | ---: |
| Retained historical build | 8,162 | 8,056..8,321 |
| Original regression | 13,129 | 11,805..13,439 |
| Deployed version 47 | 7,673 | 7,263..8,095 |
| This package | 7,345 | 7,162..7,570 |

All five replacement trials beat historical. Savings against version 47 are
101, -18, 103, 659 and 637 ms, with overlapping ranges. The observed 4.3% median
difference does not establish a reliable additional populated-scene gain.
Fresh pages use cold prepared states. Parsing the complete fixture before
timing may influence later GC on all sides. No earlier timings are imported;
a serialization failure before any trial is preserved separately.

Separate five-pair getter microbenchmarks reduce WebKit median time for one
million reads from 221 to 190 ms, and native time for ten million reads from
0.703616 to 0.409510 seconds. These are not game-level speedups. Instrumented
ten-step game runs retain exactly 126,972 component reads, 184,656 allocator
checks and 126,972 column views on both versions. Normalizing only package
hash namespaces, common emitted game function bodies differ only in nine
getter specializations; eighteen old helpers become eighteen fused helpers.

Physical iPhone restoration and whole-page performance remain unverified.
The historical source matches a saved Site artifact but is not a verified
identification of the user's last fast phone deployment. Temporary scripts,
captures and receipts remain outside tracked source under
`/tmp/survivors-night-20261026`. Credentials are excluded.
