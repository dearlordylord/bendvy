# Reached eager-RHS counter oracle

The normal source/model/oracle in sibling `independent-oracle-v1` and its
qualified outputs remain unchanged. This counter oracle is source-derived
before candidate mutant execution, not an accepted semantic update.

## Exact isolated source and identity preservation

`source-freeze.json` binds a WT-only mirror at
`/tmp/bendvy48-condition-readers-eager-rhs-mutant-source01`: 67 copied relative
source bodies. Fifteen actual absolute root imports are deliberately unchanged
and bound by `externalSourceInventory`. The 82-path literal import graph remains
82 distinct paths: `originJoin` maps every original WT path to its corresponding
mirror path and every absolute root import to itself. No imports were rewritten;
there are no absolute consumer-WT imports in the selected sources. In particular,
root and WT module copies were not collapsed by same-body hash or path mapping.

All 66 unaffected WT files compare byte-identically to the normal snapshot.
The only semantic/source change is the False branch of `combined_decision` in
`src/ecs/ordinary-condition-composition.bend`:

- Before: `case False{}:Value{world,(left,right),value}`
- After: `case False{}:right_returned(~World,~Left,~Right,left,rightRun(right,world))`

The selftest checks the exact single replacement/inverse join, all source pins,
unchanged external identities, and complete import-graph bijection. The True
branch and all condition constructors/metadata, application wiring, body callbacks,
observers, init operations and print behavior are unchanged.

## Operation-to-state counter derivation

The normal condition model returns the left Value without invoking RHS when
short-circuiting. The countermodel removes only that decision: both continuation
choices invoke RHS and return its result. It preserves non-Value authority
refusals; there is no invented fallible condition. Actual registered Changed
owners therefore observe their revisions even on formerly skipped paths, and
the RHS result can change which actual system executes.

1. Initial Flow Play/Level Low at clock2: fast Level.changed sees1 and runs.
   Slow's true left OR now incorrectly evaluates Flow.changed, observing
   revision1/cursor2 instead of preserving0/0. Its RHS is true, so slow still runs.
2. Inserts Flow Pause at3/Level High at4: fast's false AND incorrectly evaluates
   Level.changed; revision2 is new, so it returns true and fast runs, consumes
   Initial High, commits body/stream cursor4, and stores that reading. Slow sees
   new Flow revision2 and runs as before. Normal schedule would skip fast here.
3. Flow-only Play insert at5: fast's ordinary true left AND evaluates Level.changed
   again, which is now unchanged2; it returns false, so fast skips. Its body last
   High reading and stream/system cursor remain4, while the reached condition
   registry cursor commits5. Slow sees Flow revision3 and runs. Normal source
   would run fast here and commit its reader cursor5.

The complete counter schedules are [ran:1,ran:2], [ran:1,ran:2],
[skipped:1,ran:2]. Level condition revisions become1/2/2 rather than1/1/2;
Flow condition revisions become1/2/3 rather than0/2/3. The mismatch is observable
in actual schedule observations, condition owners, callback retention, stream
positions and ordinary App DTO/debug bindings. No fields are removed or normalized.

The independent model recomputes the entire two-schema transcript through the
same source-derived world/owner/debug serializers. It does not patch a normal
stdout string. Every metadata descriptor still describes the authored lazy
operators, as it does in the mutated source; the operational countertrace reveals
the defect. Both nominal schemas, all physical state, full lists/order/identities,
requirements/placements/leaves and terminal transport are retained.

The unchanged entry returns a pure String containing both three-line traces.
Compiler String display quotes and escapes all six internal LF characters and
adds one physical terminal LF; no IO.print call exists. The normal oracle must
reject these complete counter bytes; the model asserts that inequality.

Run `python3 model.py` for source/inverse-join/state/serialization checks and full
raw/gzip/timeline reproduction. This is Python model execution only. No compiler,
backend, generated artifact or mutant runtime output was consulted. No universal
proof, capacity stress, foreign-authority execution or additional scenario is
claimed. Normal source and derivation limitations apply unchanged.
