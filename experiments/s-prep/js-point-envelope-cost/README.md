# Point-owner envelope source cost decision

Bounded profile-directed hypothesis after the direct raw swap diagnostic. Stop at
source cost derivation: no implementation, materializer, checker/codegen, runtime,
profiling or performance claim. No existing source, callback or dependency changes.

Intended representation is exactly the proposed split: affine State carries World,
raw Main, raw Ledger, Handle, undo, commands, pings and marks (8 fields); immutable
Data Views carries Main/Ledger snapshots (2 fields); affine Envelope carries State
and Views (2 fields). Getters destruct only Envelope, preserve the same opaque
State and copied Data Views, and extract the requested view through a pure Data
helper. They do not reconstruct State or Views. Setters rebuild State, Views and
Envelope; original Cache wrappers rebuild at final restoration. Main/Ledger stay
arbitrary affine Type. Actual callback headers and algorithms remain constraints.

The successful original motion_body/health_body calls exactly two getters (Main
and Ledger) and two setters (Main and Ledger). Compare only representation records;
Access/Some/result tuples, view patch records, raw writes, journals, mark lists and
World/Rows/Tx restoration operations are common and excluded from both sides.
Incoming Main/Ledger Cache objects already exist before held entry.

| Stage | Original Held objects / payload fields | Envelope objects / payload fields | Difference |
| --- | --- | --- | --- |
| Entry | Held8: 1 / 8 | State8 + Views2 + Envelope2: 3 / 12 | +2 objects, +4 fields |
| Two reads | 2 × (Held8 + Cache2): 4 / 20 | 2 × Envelope2: 2 / 4 | −2 objects, −16 fields |
| Two setters | 2 × (Held8 + Cache2): 4 / 20 | 2 × (State8 + Views2 + Envelope2): 6 / 24 | +2 objects, +4 fields |
| Cache restoration | Existing intact caches: 0 / 0 | MainCache2 + LedgerCache2: 2 / 4 | +2 objects, +4 fields |
| Total | 9 / 48 | 13 / 44 | +4 objects, −4 fields |

The read/set portion has zero constructor-count delta. The extra four constructors
are fixed entry/restoration costs, not accidental snapshot reconstruction on reads.
Counting one tag property per constructor, both designs assign 57 properties in
this ideal direct-emitter accounting (48+9 versus44+13). Native lowering and V8
escape analysis could differ; this table is a source prediction, not measured
allocation bytes or time. Additional transport tuples would worsen the envelope
count; none is assumed here.

For r reads and w setters, original representation cost is
1+2r+2w objects and8+10r+10w payload fields. Envelope costs5+r+3w objects and
16+2r+12w fields. Its object delta is4−r+w; payload-field delta8−8r+2w.
The existing flat ten-field owner costs3+r+w objects (including final two caches)
and14+10r+10w payload fields. At r=2,w=2 that is7 objects/54 fields, so the
proposed envelope adds6 objects while removing10 payload-field assignments.

Decision: do not build this variant for the unchanged two-read/two-write callback.
It adds four short-lived records with no total property-assignment reduction;
the prior flat-owner GC regression makes that trade unconvincing without further
independent evidence. This is a prioritization decision, not a proved regression
or impossibility. A read-heavy actual callback with r>w+4 could reduce record
count, but changing the current callback algorithm to create that workload would
violate this probe's scope. Record that as a follow-up only after a real workload
and equivalent observation gate justify it.

Source inputs: the actual callbacks in prototype-static-client.bend from the
complete /tmp/bendvy-direct-raw-swap-worker overlay are unchanged from batched
baseline. Held/Cache shapes come from held.bend/cache.bend; flat transport shape
comes from the separately delivered js-flat-point-owner patch. No laws/proofs or
universal refinement claim; full22/adoption and numerical acceptance remain open.
