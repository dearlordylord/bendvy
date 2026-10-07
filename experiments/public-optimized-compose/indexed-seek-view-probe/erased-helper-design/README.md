# DRAFT — shared decision helpers

Read-only proposal; Column `dd7ead` remains unchanged. This does not select a
performance improvement. [receipt.json](receipt.json) binds the exact generated
JS/C and matched-profile summary used below.

## Observed scope

The ten-application JS emits five copies each of `indexed_view_step` (8,950
bytes) and `indexed_view_choose` (3,640 bytes). Their bodies are identical after
normalizing generated template suffixes. Five view-loop copies occupy 28,312
bytes and differ because their project callbacks differ. Only step/choose are
candidates for sharing; the callback-dependent loop must remain specialized.
Four removed step/choose copies would save roughly 10,072 textual bytes before
wrapper costs: about 1.1% of the current 915,728-byte program. This cannot by
itself explain the entire 30% whole-process slowdown.

Matched exploratory profile self CPU attribution is step 4,722 us, choose 968 us,
and loop 10,696 us across 200 applications. Sampled self allocation attribution
is approximately 1.87 MB, 2.63 MB and 18.91 MB respectively. These are sampled
stacks, not physical allocation totals or a causal partition of the gate.
Sharing does not remove Decision/history nodes or change the number of calls;
it may reduce separate JIT compilations/code footprint. A win is unobserved.

## Source-backed mechanism and risk

Installed guide lines 205 and 259–276 distinguish erased `-A` (no runtime argument)
from syntax-substituted `~A` (one emitted copy per distinct argument set).
`owner-handoff.bend` already uses `-Schema:Data,-M:Type` in actual affine owner
transport. Both proposed helpers operate only on constructors, booleans and U32;
none invokes a template project or examines the internal C representation.
Erasing the type binder does not make C Data or permit owner duplication.

Pinned compiler `bend2/comp.ts:939–951` returns BOX for an open unknown type or
recursive datatype; the Decision, HandoffRows and History carriers already have
recursive layouts. However choose's *direct C argument* changes layout. Exact
current emitted C has schema-specific owner expansion: for Queue, `spin_327`
(lines 33696–33719) receives owner tag plus two Terms, then allocates the Queue
owner node again inside Found. Locked's `spin_244` (27142–27158) specializes away
its owner argument. An erased shared helper would receive one boxed C Term;
therefore call boundaries may require packing/unpacking, and Locked loses that
constant elimination. The current decision return is already one boxed Term,
so this is narrower than returning the entire erased State in the previously
failed erased-unseal experiment. It is still a real representation change.
Pinned source explains the mechanism; actual installed emission must verify it.

The prior erased-unseal experiment emitted one decoder instead of five but
failed both unchanged gates (JS ratio 1.1663, Native 1.0434) and was reverted.
That result rejects a blanket 'fewer specializations is faster' assumption.
It does not mechanically reject this different constructor-only input seam.

## Proposed isolated canary, before any live edit

Add an isolated `shared_choose(-S:Data,-C:Type,...) -> IndexedViewDecision<S,C>`
and `shared_step(-S:Data,-C:Type,...) -> IndexedViewDecision<S,C>` with exact current
branch bodies and quantities. The erased step calls `shared_choose(S,C,...)`.
Specialized project/loop code calls `shared_step(S,C,...)`; it still reinstalls
the actual project-returned owner. Preserve the old exported template helpers
as wrappers if later promoted; public phase helpers and all fuel semantics stay.

Use the actual-core 972-triple fixture with multiple distinct Type payload
families to prove one shared emitted definition rather than an accidental
single-family observation. Include the existing legal owner-mutating project,
full recovery/history/metadata observations, Wrapped, fuels 0/1/2/odd, and the
head/history/fuel mutants on JS/Native. Keep an affine duplicate negative.
Inspect actual Native entry widths and every C packing/unpacking join for the
Array/Queue/Locked payloads. Retain original helper emissions as the comparison.
Only after the isolated controls and independent review pass should live helper
selection be considered. Parent owns the unchanged paired gate and matched
before/after profiles; no baseline/threshold change or speed promise follows.
