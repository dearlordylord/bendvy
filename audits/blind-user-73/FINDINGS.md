# Independent ordinary App consumer audit

Candidate: `2a1ce30bab7e95623dd5ee6fcaacda3a5ccde3e7`.

This consumer was authored from `docs/reference/ordinary-app.md`, public
`src/ecs` signatures, pinned Bevy's ECS guide, and pinned Bend's language guide.
The auditor did not read existing health examples, public-api-usability
experiments, optimization history, other agents' solutions, or their reports.
Bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60` and Bend
`a950fd683c0d76f09794078e6174fe98a1492876` matched `.references/sources.json`.

## Result

The independently authored consumer composes a component query system and a
service counter through the ordinary App factories. It does not author a
schedule plan, dispatch numeric system IDs, transport query cursors, or copy
system registration metadata. A service requirement ID (17) is still an explicit
declaration input; it is not a caller-authored dispatch ID.

It creates three live entities from actual reservation results, with Health
40/70/90 and HealthDecay 3/5/absent. The opaque-owner query writes Health and
reads HealthDecay. The second registered system increments an owned service
counter. The same scheduled App is returned and fed into three subsequent ticks.
Each observation reads current allocator handles and actual component/resource
owners through `Entry.inspect`.

Expected output, in live-handle order, is four rows: counter followed by the
three Health values. Trailing spaces are emitted by the small printer.

```text
0 40 70 90
1 37 65 90
2 34 60 90
3 31 55 90
```

This is a finite usability consumer, not a new contract or universal proof.
It assumes the chosen Health values remain above their decay over three ticks.
Error paths retain the returned App but this small success-path consumer does
not report every failure detail. Its full expected output remains the acceptance
oracle; a source check alone does not establish runtime behavior.

## Usability findings

1. The entry removes the three targeted burdens: schedule construction, numeric
   dispatch, and cursor transport. The two heterogeneous registrations can be
   composed using the documented factories and library-derived aliases.
2. First use still requires substantial source reading. The guide lists factories
   and indices, but supplies no minimal import/alias/call sequence. Repeated
   erased index lists dominate the registration section. I generated repetitive
   alias call text locally to avoid transcription errors; every plan/dispatcher
   alias calls the library implementation. The final consumer plus IO wrapper
   is 223 lines for this small behavior.
3. The guide does not show how to create a component binding, pair observable
   queries, construct an ordinary schema for explicit storage, spawn/populate
   entities, or construct a service declaration and its Setup. These were
   recoverable from public source, so they were documentation gaps rather than
   inaccessible functionality.
4. The rank-polymorphic callback type in the guide is insufficient as authoring
   syntax. `def damage(-H:Type,-caps:Ops(H),...)` cannot pass H/caps to the
   template capability operations. The working declaration uses `~H`/`~caps`.
   A small callback example would have prevented this repair.
5. Bend requires separate result-matching helpers for computed pairs. An alias
   named `App` also collides with Base. Constructor inference needed a typed
   top-level schema definition. These are language friction encountered by the
   consumer, not evidence of ECS ownership defects. An annotation error expanded
   the entire derived App type into a very large diagnostic.
6. The original guide said to create a World and retain its returned handles.
   `world-io.create` returns only a World; entity handles come from reservation
   or spawning. This wording was reported to the coordinator during the audit.

## Reproduce source checks

From this worktree, using the shared pinned wrapper and CPU lock:

```sh
taskset -c 8 /workspace/formal-proofs/bendvy/scripts/bend-check audits/blind-user-73/consumer.bend
taskset -c 8 /workspace/formal-proofs/bendvy/scripts/bend-check audits/blind-user-73/main.bend
```

`consumer.bend` reports `ALL PROOFS CHECK`; see `source-check.txt`.
The IO entry reports only the expected three foreign-code dependencies:
`world-namespace.fresh`, `world-io.create`, and `main`; see `io-source-check.txt`.
No backend build or benchmark was run by this auditor. The coordinator owns
serialized runtime execution and must qualify the output before claiming it ran.

## Coordinator runtime verification

Both JS and ordinary Native `-O3` completed within the existing limits and
matched the independently calculated 48-byte full output, including trailing
spaces and newlines. See `backend-evidence/RESULTS.json` and the retained
source freeze, complete outputs and compressed generated artifacts. The
auditor authored the consumer before this coordinator execution.
