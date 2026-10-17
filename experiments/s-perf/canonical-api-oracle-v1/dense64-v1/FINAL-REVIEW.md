# Canonical Dense64 source and evidence review

Bounded Spec/Standards PASS for the existing Dense64 workload's canonical public
API adoption and the portable joins recorded below. This is not completion
of #21 or a performance result.

The reviewer authored oracle `bd59bd25e2fbe93468ec4945c7c245481430aa9a` and is
independent of the consumer and runner authors. This report reviews their source
and execution evidence; it does not present the author's own model as an
independent re-review. The coordinator separately inspected the complete model
against source and confirmed its bounded state/format assumptions.

## Spec

Source `c8e9ded18` preserves both nominal payload families and the original shared
Dense64 work: 64 entities, 64 Update invocations, 4,096 complete Main reads/writes
and 4,096 Ledger reads/writes. Each row reads Main, sums its four old cells, writes
only its first cell, then reads and writes Ledger's first cell while preserving
the other cells and epoch. Optional Aux and Flag values and every other payload
field remain intact. Resource writes are inside the row loop, not aggregated.

The actual entries reach canonical `Commands.tx_spawn`, successful transaction
finish and `World.barrier`, followed by `Ordinary.define` and 64 `Ordinary.run`
traversals. Gameplay receives universal affine `H` and canonical declaration-
derived capabilities, not a trusted custom World/Tx lens or an old experiment
engine. The resource capability is the existing canonical family-resource grant
with a Unit sibling; it does not invent event work. Administrative seed population
uses canonical component replacement. Detached logical inspection runs after the
updates and is followed by another complete physical World observation.

Each independent report includes the pending seed World, applied seed World,
registered owner/World, final owner/World with all 4,096 row results and 64 audit
entries/statuses, all 64 detached rows, and complete World after that read. Physical
allocator slots/order, Column values/stamps, resources, command kinds/counts,
registration metadata and cursor are visible. Actual ordinary Columns remain
ordinary through these callsites; the prepared fallback is not reached. Inverse
and command callbacks remain opaque and are never executed for observation.

Seed population performs 107 component writes; Update performs another 4,096.
Resource replacement does not advance this clock. Final clock and successful
Registry cursor are 4,203. These are canonical source effects, not TS clock or
System-registration equivalence. The original pinned TS adapter and receipt are
reused only for their exact logical full-field and 64-audit assertions; retained
TS summaries contain hashes/samples, not full raw row wire. Both new full reports
preserve the source report newline plus IO.print newline without normalization.

## Standards and actual evidence

No core, old engine, runner, dependency, contract or numerical target changes are
part of this adoption. Source closures bind 58 actual Bend imports and two
namespace sidecars per entry. The pure module checks pass; IO hosts retain their
three expected foreign definitions rather than being described as proof passes.
Source/model Python policy and selected whitespace checks pass.

All four stock Bend 2.0.35 JS/Native roles have
`COMPLETE_CONSUMER_DEVELOPMENT_PASS`: Motion 89,017 bytes SHA256
`2c6d4f5ffdc79614ee4fd39045ede969016af26f0570d1dbb5ab5c0bfe62aec9`;
Health 88,773 bytes SHA256
`ed9ea2b5fbe2fbc83198666fae6456dc8bac012b7e77815dc99a6422645d1742`.
All ten emit/build/consumer commands exit zero with empty runtime stderr under
the existing 30/120/5-second caps. Read-only review joins each receipt to its exact
plan and whole raw output; no subject execution was performed by the reviewer.

Portable source/evidence commit `1727e5a1f`, with README/selection-only
precision successor `2bc79be130b9fb8255a466426d584ef13495d7b2`, retains each schema at
`experiments/s-perf/canonical-api-v1/dense64-v1/runtime-v1/{motion,health}/actual-attempt01`.
Motion manifest SHA256
`f469129fa3309f388421ce5eaf958acba488affe50b340505dfabc5e4e624b6b`;
Health manifest SHA256
`c4d4b3be00cfb12f2e8825eacedf52621c7ca957caf56e7dda1bfad39a7e134c`.
Independent read-only CPU9 verification passes for each: 507 actual path bindings,
445 gzip objects, 22 external installed ELF identities, five commands, 17 guards
and all 2,204 evolving guard pin joins. Both generated Native ELFs are archived
objects. Every plan input/resource, command stream, guard and complete raw oracle
is joined; isolated retained model/shared-model reproduction matches both reports.
No backend was replayed. The author retains the source-check diagnostics and exact
source freezes, model ancestry and delivery selection in those packets.

Pending observation is specifically a count and ordered constructor-tag list.
All 64 pre-barrier callbacks are Raw, so their captured payloads/identities are
not distinguishable from that list alone. Actual reservation order and complete
post-barrier physical rows/stamps qualify the observed FIFO effects. This does
not claim callback-capture inspection or a universal queue-order theorem.

## Remaining #21 gates

This finite correctness slice is two schemas at size64, Dense only. It does not
qualify the five workload families at 64/256/1024, seven rotated fresh samples,
same-process warmup, equal common timed observer forcing, reset peak RSS, actual
active-transaction occupancy, resolution-limited batching or its separately
approved uncertainty margin. It establishes no speed ratio, allocator optimization,
production layout, universal law, elapsed target or full #21 acceptance. Those
existing return conditions remain unchanged; no new measurement protocol is
introduced by these consumers or this review.
