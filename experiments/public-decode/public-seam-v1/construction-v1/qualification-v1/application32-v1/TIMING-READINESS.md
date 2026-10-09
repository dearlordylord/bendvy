# #46 application32 matched timing readiness

Draft for scoped review. Complete32 JS/Native semantics pass; feature timing is
not ready. The 1,056,756-byte Bend physical report and historical TS debug dump
observe different work. Neither their process wall times nor output byte counts
establish ECS parity speed. No new threshold, baseline or ownership rule is proposed.

## Fixed workload and authority

Retain all32 cases, original order and full inputs: Workshop insert/spawn/resource
× eight codecs, Garden insert × eight codecs. Keep array sizes3/128/256,
late-invalid element127, struct64 plus unknown field, nullable/null and nested
valid/missing paths. No scalar owner, checksum-only result or shortened trace.

Rust Bevy is the semantic authority: pinned world/mod.rs1243 moves a typed Bundle
into spawn; entity_access/world_mut.rs1005 inserts a typed Bundle;
world/mod.rs2056 inserts a typed resource. Bend uses explicit reversible affine
constructors, retained nominal declarations and opaque grants. Raw validation is
the approved application boundary; it is not an automatic Rust reflection promise.
Pinned TS reference-v1/reference.mjs supplies these shared use cases and comparison
work, not the native contract. Standard Schema/JS bridge and selector extras are
outside this approved native timing workload.

## Every application operation

| Phase | Current TS32 | Current Bend32 | Timing alignment needed |
| --- | --- | --- | --- |
| Inputs/declarations | Build eight codecs, root/fragment/descriptors and owned inputs | Retained typed codec/declarations, native Raw and affine arrays | Include fresh payload/codec construction on both; language type-only information has no invented runtime charge. Keep all original values and sentinels. |
| Resource initialization | Runtime.make validates owner seed | Resource Factory validates/constructs seed, then World.create | Same raw seed and successful canonical value. Retain constructor/owner work. |
| Entity seed | Registered seed system queues typed Value9, then applyDeferred | Reserve/activate and trusted Cmp.replace typed Value9 | Current Bend setup bypasses the actual registered/deferred seed path. Source-only alignment must run an ordinary seed invocation and barrier; direct setup is not equivalent timing. |
| Queue Marker | Registered queue system inserts Marker1, leaves it pending | Direct W.enqueue actual Marker replacement | Current Bend queue setup bypasses registration/invocation. Align ordinary queue system before timing; preserve deferred visibility. |
| Insert | each().length then each()[0].setRaw | Two declared Value scans require one row; constructor then immediate Write.set/tx_set | Keep both actual scans and immediate visibility. No deferred Insert substitution. |
| Spawn | entryRaw then accepted command spawn | Constructed request accepts/prepares owner | Retain constructor admission, reservation, ownership and pending payload. Materialize only at final barrier. |
| Resource write | Registered writeResource.setRaw | Registered opaque grant, constructor then validated resource write | Same actual application World, same immediate visibility and exact refusal owner. |
| Finish/barrier | Tick finalization then applyDeferred | Local/transaction finalization and Batch delivery | Include normal commit/undo disposal, rejected owner handling, queued Marker and successful spawn delivery. No forced rollback added to these32 cases. |

Setup registration overhead and payload shape are concrete remaining alignment
gaps. They are benchmark consumer changes using existing core APIs, not new core
contracts. Keep source-current full92+22+32 semantic controls independently; their
approved rollback/Local/Pending rules must remain unchanged.

## Complete matched observations

Author a whole public application report for every case, at original input,
before, committed and final barrier boundaries. Retain raw input/canonical value,
full returned input/owner sentinels, exact validation/operation errors including
nested path/actual value, accepted entity handle, all live entities and their
Value/Marker payloads, full resource value, and pending command order/kind.
Observe the same root/operation/case labels and successful/refused construction.

Do not pretend TS mutable incomingAfter aliases are Bend affine owners. Keep exact
original input, returned input or installed owner values and the real native
handles. Do not rename IDs, coerce errors, rewrite original input or introduce
alias-identity normalization to make outputs equal. Independent backend models
must retain their native DTOs and a source-backed public value/error mapping.

Current Bend Owner also contains original Raw and two Bool array flags absent
from TS owner(value,sentinel). Before timing, align the benchmark owner data
explicitly in the TS consumer, preserving those fields through its real constructor
and installed payload, or retain the mismatch as unqualified. Do not strip Bend
fields/owners to obtain a better number. This is a fixture payload declaration,
not an application-wide ownership policy; it requires scoped source/model review.

Bend physical capacity/liveness columns, lifecycle stamps, clock/consumed counters,
Local recovery/Pending and TS frame/tick/debug storage internals remain fully
checked in their existing complete backend semantic diagnostics. They are not
shared implementation state. A matched public observer must be independently
qualified alongside those controls; it must not replace them with a projection
or assert that omitted physical work was measured.

## Proposed interval and existing infrastructure

Use a complete fresh lifecycle interval: begin before payload/codec/runtime
construction; include ordinary seed/queue/main registrations and invocations,
queries, raw construction, world mutations, transaction finalization, delivery,
all public observations and complete report materialization. Stop after full
common-format report capture; flush captured output afterward. All32 cases and
all lifecycle work remain in-region. Compilation/import/startup and final OS
stdout flush are outside; retain whole-process time separately. Raw conversion
and observation/serialization cost are included and labeled, not silently removed.

Reuse existing public-component-state/timing/{stage.py,run.py,capture.mjs} and
shared task_runner/receipt guards as the lifecycle timer pattern: full output is
captured and independently compared; its optional byte/digest telemetry is not
semantic evidence by itself. Use the existing reviewed Bend timer seam and
Clang19 recipe, no new dependency or runner framework. Any adaptation needs exact
source/output interval mapping and complete pre-output oracles before admission.

Keep setup, conversion, query/write/delivery, observation and capture boundaries
explicit in instrumentation/source. Additional phase timings may diagnose cost
but cannot replace the complete lifecycle ratio. Existing benchmark protocol,
quiet-window reservation, paired order/scales, source/tool guards and numerical
criteria remain unchanged. No timing runs or criterion changes are authorized by
this readiness document.

Next safe implementation after scoped approval: align seed/queue through ordinary
registered capabilities; align TS opaque payload fields; build complete public
observers without changing original physical consumers; independently qualify
full32 reports and reached controls; then bind exact existing timer/collector
plans. Remaining source/DTO choices need review, not a new user ownership decision.
