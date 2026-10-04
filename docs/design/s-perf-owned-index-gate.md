# Owned indexed expressibility gate (finite candidate, #20)

Recorded before executable subjects. This is an initial expressibility experiment,
not the integrated candidate, approved ECS laws, or performance acceptance.

Finite contract: independent nominal Motion and Health Type payloads each own a
nested four-cell Array<U32> and one scalar. Each nominal column owns
Array<Maybe<M>>. IDs map directly to slots, with namespace and capacity checks
before extraction. Capacity begins at four and grows to eight by ANode joining
the old owner with a freshly recursively allocated vacant subtree; old slots retain
identity. Missing, foreign, selection-mismatch and out-of-range accesses return
unchanged owners. Array.swap masks indices with capacity-1, so unchecked access
is forbidden. Extraction swaps None into a valid slot; a fresh opaque callback
returns the same abstract owned M with a Data observation; reinsertion swaps Some
back without cloning. First/middle/last slots are exercised before and after growth.
Two writes to every payload field followed by inverse writes restore all fields.

Candidate invariants (unapproved; finite falsification only):

1. A valid operation preserves every non-target slot and returns exactly one owner.
2. Invalid namespace, invalid index, missing and mismatch leave the whole column unchanged.
3. Growth preserves existing slot associations and adds only vacant slots.
4. Repeated writes and their reverse sequence restore scalar and all four nested cells.
5. Opaque callbacks cannot duplicate/reconstruct M, cross nominal schemas or write through read.

Planned falsification: a bounds-bypass runtime mutant aliases capacity onto slot zero;
compile-negative controls target owner duplication, concrete reconstruction, cross-schema
substitution and write-through-read. Checker verdicts are safe typing, not ECS proofs.

Primitive findings, commands, source pins and actual evidence follow after execution.

## Observed primitive decision and limits

Bend 2.0.34; Base SHA256
`c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661`.
Tracked source manifest was checked against the absolute read-only reference HEADs:
bevy-ts `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`,
bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60`,
bend2 `a950fd683c0d76f09794078e6174fe98a1492876`.

Base lines 2245–2285 implement size and swap; swap masks with n-1. Lines
2287–2305 and 2369–2374 restrict clone/new to Data. Safe Type-column allocation
uses recursive vacant ALeaf/ANode construction; growth uses ANode{old, vacant}
with equal subtrees. No unsafe fork/join, clone, Type-to-Data conversion, package,
checker repair or kernel change is used. Recommend power-of-two capacity with
explicit logical bounds and namespace checks before swap, retaining affine owners
through traversal and doubling. A free-list/relocation mapping is still required
for the integrated design; this direct logical-slot probe does not implement it.

Replay: `python3 experiments/s-perf/owned-index-run.py`. Native O3 uses CPU 8,
one worker, GPU off; JS uses CPU 8. Checker/runtime limits are five seconds,
codegen 30 seconds and clang 120 seconds. Temporary owned build files are removed.
The runner checks five intended diagnostics, each after a shared valid opaque
owner-return callback control. Runtime emits all 39 semantic lines on both backends
and compares them to independently assembled expected fields and statuses. The
compiling bounds-bypass mutant changes index four from rejected to slot-zero data,
and is detected on both backends. See the raw `owned-index-observed.txt` ledger.

The repeated inverse subject operates on retained old scalar/four-cell Data
values inside an owned nominal payload and returns the abstract owner through
fresh closed provisioning. It is a four-cell finite restoration canary, not a
production journal, general destructive Type recovery or approved universal law.
The four-cell branch falls back to observation on other array shapes; those shapes
are outside this finite fixture. Original scalar is (slot+1)*10 and the four fields are scalar through
scalar+3, distinguishing both slots and fields. Access primitives are opaque read/owner-return providers; the restoration
operation is supplied by trusted provisioning, not a production writable API.
Mismatch uses the same explicit checked False branch as namespace/bounds rejection.
No trace comparison to TS, integrated workload measurement, arbitrary callback
confinement theorem, model/function proof or runtime refinement is claimed.

Return gates: independent design review before candidate core implementation;
actual declared writable/read providers and full integrated replay; relocation,
stale mapping, destruction, command/journal/reader rollback controls; randomized mutation/traces; all five frozen workloads with
complete output validation. This gate alone cannot close #20 or approve production
adoption. All five candidate invariant statements remain unapproved.

## Reviewed extension contract, recorded before additional subjects

The independent architecture review requires balanced growth across several powers,
private rejected placement preserving store/incoming Main/Aux/pending Type queue,
and live-without-Main distinct from tombstone. Additional finite fixtures use
capacity2→4→8→16; metadata values 0=tombstone, 1=live-without-Main, 2=live-with-Main.
Rejected IDs zero, foreign namespace, beyond supported16, and U32 maximum must
return the entire envelope unchanged, including two queued nominal Motion owners.
No public exhaustion policy or fallback MissingEntity is introduced. Wrong-slot
and wrong-growth mutants must compile and diverge separately from typing negatives.


Extension outcomes: balanced growth2→4→8→16 is observed by complete slot
snapshots. A separate placement fixture has capacity16 for all three columns,
Main slot0 present with metadata2, slot1 vacant with metadata1, other slots
vacant with metadata0, Aux slots0/1 own Health50/60, incoming owners70/80 and pending Motion90/100.
Zero/foreign/17/65537/U32max rejection repeats its exact complete snapshot.
The preflight supported domain is explicitly IDs1..16; this finite private
canary does not execute successful placement. ID65537 is observed as unsupported,
so it cannot establish E11 integrated support. The liveness decision function
produces MissingEntity/MissingComponent/Matched for the three legal metadata
states; complete runtime lookup remains an integration gate.
Compiling wrong-slot extraction and reversed-growth association mutants each
produce Native/JS agreement on changed outputs and are independently detected.
Fixed Nat depths avoid runtime doubling arithmetic in this canary; general
checked growth/id-1/high-water arithmetic remains required in the candidate.
