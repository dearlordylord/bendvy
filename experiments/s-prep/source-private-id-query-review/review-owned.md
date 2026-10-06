# Independent typed-ID query review

Reviewed source29 `bdf6b2fc46d2a89615d0e9eb48d44f4a3e8c8f2ff5b8268d7ca50463e6bfbe94`
against packed-paired parent `d437d8f7e97ae66764e470c58cada7182715b8724d9dd065d20e55417e01e744`.
Read-only structural/Spec review; no new checker/runtime/proof/performance gate was executed.
Exact source hashes and assertions are in [structural-review.json](structural-review.json).

No concrete incorrect source transition found in the inspected delta. Query appends a
copy of the pinned identity-only query family with U32 results, keeping every original
query byte. Held adds a query import and two cursor loops/entries; every existing row,
getter/setter, step/guard/live/taken/returned/fallback/finish definition remains byteexact.
Only six private measurement definitions change: packed motion/health handles, flat rows
and queried continuation. All other measurement definitions and SC callbacks remain
byteexact. Calls still pass `~SC.motion_body`/`~SC.health_body` into unchanged packed steps.
The generic public query/provider route and arbitrary affine Type M/A/L remain available.

[Cursor scanning](/tmp/bendvy-private-id-query-v4/experiments/s-integrate/query.bend:283)
keeps the parent's capacity/high/live/selection/main-presence tests and swap/restore of
owned Main. Missing Main yields no ID; Aux, metadata columns, pending, ledger, mode and
World namespace stay owned and retained. IDs are prepended while scanning increasing
indices, then the unchanged struct_cols_finish reverses once, preserving ascending query
order. New query neither reads raw payload nor invokes arbitrary getters: this was
already the parent's **closed identity specialization**. It must not replace general
query clients or be described as proving arbitrary-client observer equivalence.

[Cursor type](/tmp/bendvy-private-id-query-v4/experiments/s-integrate/query.bend:327)
retains Schema in a Type constructor and captures the actual World namespace once.
The producer returns the same World and that namespace plus IDs. Cursor loops reconstruct
`S.Handle{namespace,id}` before the unchanged step, which checks namespace, bounds/high,
live/Main/Ledger presence and selects that complete Handle before callback/fallback.
Motion and Health entries require their corresponding Schema cursor. Empty cursors retain
incoming selected/context; supplied cursor order and duplicates are consumed as given,
matching a corresponding supplied Handle list. Query-produced IDs are ascending.

This is not an unforgeable cursor: its constructor is exported and accepts arbitrary
namespace/IDs. Same-schema foreign namespace is handled by the existing runtime step/
fallback, rather than rejected by cursor construction. Private names do not establish
language privacy. Cross-schema typing and foreign cursor behavior need fresh negative/
runtime controls; no universal authority claim follows from the phantom Schema parameter.

No newly omitted scheduler/observer/command/commit work found: committed/update continuations,
clocks, logs, audits, events, Host transitions and original callback bodies are unchanged.
The scan avoids intermediate Handle-list transport, then reconstructs the complete Handle
at the existing step. Allocation counts are separate diagnostics, not this review's speed
or equivalent-work acceptance.

At inspection, visible [cursor fixture](/tmp/bendvy-threehour-held-transport/experiments/s-prep/source-private-id-query/cursor.bend:43)
covers Motion valid/foreign/zero/missing/out-of-capacity/empty cursors, one-row Required
query, actual fold call and full physical rollback fields with raw/cache discrepancy.
It does not itself establish multi-row ordering/duplicates, all selections, Health,
owned generic Aux/Main arrays, schema mismatch or nonidentity returned fallback context.
Worker reports those new subjects are being produced; inspect their actual receipts
before marking gates. Old d437 Tx or parent identity-query results do not cover the cursor.

Concrete recipe review finding: inspected derive.py/pins.py checked actual29 and standalone
maps/digests but omitted equality with `overlay.cacheSpecialization`; supplied stale embedded
cache could survive input preflight. Current candidate embedded/standalone receipts match;
this is a fail-closed provenance gap, not an observed source semantic failure. Worker was
notified and agreed to add equality. The strengthened recipe/negative receipt must be
reviewed before closing this finding. No worker source was changed by this review.

## Follow-up inspection of produced controls

Worker closed the embedded-cache equality omission in derive.py and pins.py before
copy/materialization; source29 remains bdf6b2. The code finding is resolved. Reviewer
did not execute a malformed embedded-receipt control. Current recipe and producer
receipt hashes are fixed in [controls-followup.json](controls-followup.json).

Produced cursor-v5 fixture adds duplicate `[3,3]`; both backend receipts report12 literal
checkpoints, preserving original array cells/raw/cache metadata, incoming pending and
rollback. Order-v5 reports four literal lists: Required/Optional `[1,2,3]`, Present
`[1,3]`, Absent `[2]`. Generic full-shape-v4 reports20 checkpoints (depths0..4 × four
selections), with genuinely Type owned arrays in Main, Aux and Ledger, physical cells/
scalars and metadata retained. This generic shape fixture has empty pending; the Motion
cursor physical fixture covers a nonempty pending command. These are finite subjects.

Fresh fallback-v5 reports both schema/backend PASS: valid prefix then foreign cursor in
two consumed cursor phases calls the unchanged opaque nonidentity client and preserves
full returned context. It deliberately uses two namespace-specific cursors; it does not
claim one cursor can represent a mixed-namespace Handle list. Separate concrete all-context
transport remains distinct from opaque callback authority. Six new-source negatives
include owner cloning/undeclared access/cross-schema token/write-through-read plus cursor
cloning and Motion/Health cursor schema mismatch. These are producer executed gates
inspected here, not new executions or acceptance transferred by this review.

Remaining review limitations: a dedicated Health physical cursor rollback/duplicate
literal subject was not visible at this inspection; generic query fields/Health fallback
and full65 do not substitute for that exact subject. Source-bound protected Tx/suppression
matrix must be adapted to cursor entry if claimed; d437 controls still call old packed
fold entry. Universal cursor authority, arbitrary-client query equivalence and mandatory
performance acceptance remain open. No new concrete source defect found.
