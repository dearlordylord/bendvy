# Owned event transaction adapter — #53 development candidate

`adapter.bend` retains actual canonical `T.Tx<World,Unit>` plus the existing
arbitrary-Type `Stage<Payload>`. Its terminal operation invokes canonical
`T.finish`: ECS inverse closures/rollback and command/Data publication are owned
by the existing engine. Success consumes Stage's committed FIFO list through a
trusted schema-author owned-publication callback. Failure returns the rolled-back
World, failure outcome and staged FIFO payload owners. Recovery contains ONLY
invocation-created/external-surviving-state payloads, never extracted
transactional component/resource values. No Data event API change is required.

The owned callback here is total affine transport into the same schema-owned
World resource log. No fallible publication callback, release, finalizer,
automatic reinsertion, cleanup or public failure policy is selected. The adapter
is a terminal integration seam; fixture Stage is directly constructed with two
invocation-created Arrays rather than claiming a public event-emission API.

`controls.bend` uses canonical `C.replace` to seed two full Array components from
an empty Column, retaining all previous/rejected incoming owners and exact
errors. It then calls actual `C.tx_set` twice through canonical opaque
`Cap.OwnedRequest` authority. These replacements create actual affine undo
closures. One canonical staged command appends resource marks8,9 on World barrier;
one Unit Data event is staged. Owned event Arrays first41,42 and second51,52
append to existing log71,72 only after success. Failure returns those created
owners while engine undo restores prior component Arrays. No resource owner is
removed into the recoverable Stage. Additional seed and transaction foreign-handle
refusal controls retain incoming Arrays31,32 and301,302 respectively; transaction
failure is explicit fixture input, not an invented automatic error policy.

`observation.bend` source-consumes complete returned owner paths and exposes a
Data DTO authored before any backend: all physical four Column slots, raw
Lifecycle.Entry list, live bits and World metadata; complete affine log; marks;
Data Unit events; pending count; every seed previous/rejected input/error;
recovered Array payloads. Before/after real W.barrier and a final snapshot through
the returned World distinguish staged commands from executed effects. Commands
are affine closures, so the observation records their count and actual flush
marker effects rather than pretending closures have serializable contents.
The fixture ordinary Column view has an explicit supported flag; any unsupported
representation must fail the full oracle, not silently count as valid output.

Final `main.bend` source3 PASS under existing five-second checker/telemetry-off/
shared heavy lock. Raw guide and all parser/binder development attempts are
retained; initial Event/Result names collided with Base, pair-pattern syntax and
runtime owner captured in a closed template were corrected. Owned publication
now threads runtime owners directly through its schema-owned World lens.
At the source checkpoint no backend/output had been obtained; the independent
whole oracle was authored from these source/DTO definitions before execution.
No law/proof, dependency, shared ECS source or public contract changed. Raw
trusted World creation is an unqualified fixture setup, not production factory
coverage. Public readers/retention, source-current negatives/mutation,
JS/Native/TS applications and performance/full #53 gates remain outstanding.

Imports use root canonical ECS modules and the integrated canonical Stage
identity. This source development commit is not clean-checkout portable delivery;
source qualification must bind those exact canonical dependencies.

## Actual development execution

First JS emit/run completed exit0 and empty stderr. Its whole-byte gate failed
against the first independent oracle because that model used entity ID as physical
Column index. Canonical Column.swap_checked uses `U32.sub(id,1)`; World.live uses
ID directly. The independent author corrected exactly eleven physical slot lists
from source, froze the entire named v2 oracle before retained-output comparison,
and preserved the old binding. No fixture/production source or other expected
field changed. Retained complete JS raw matches v2 without a backend replay;
the original failed receipt remains INCOMPLETE rather than being rewritten.

First Native emit/build/run then passed the named frozen v2 oracle. Both complete
outputs are6139bytes SHA256
`4df56e7cd82baf2731d4ef1bedc49ff57872ac34521faa2d856a6eb9d5761ce5`;
runtime stderr empty. The independent JSON is SHA256
`88a831432428c592da2d3e2029233c22ba31a12b56e5dbb25722868103431faf`.
Original old oracle SHA1d96981b and executed runner are preserved with JS evidence.
The whole observations cover all five Batch branches, physical slots/lifecycle
order, full World metadata, log/marks/Data events/pending before and after flush,
complete final owners, recovery payloads, seed previous/refused owners and errors.
Rollback restores payloads and stamp values while physical raw stamp-list order
changes; the complete oracle records this existing canonical behavior instead of
claiming representation equality. No new rollback policy is introduced.

The narrow runner uses the already-reviewed task_runner/ReceiptBoundary/
GuardBoundary/CommandLogs recipe and explicit installed configuration. Exact
original source entry and oracle namespaces are preserved, with no relocation or
constructor renaming. Initial, post-child-lock and terminal full source/tool/
resource/environment/oracle/raw/generated guards remain unchanged. CPU5 emit30,
Clang19build120, Node/Native5; Native threads1/GPUoff. No caps were increased and
no concurrent heavy child or additional JS replay was used. Plans retain exact
source/tool/environment hashes and historical commands; binaries and local
configuration files are excluded. This is direct development evidence, not
portable installed-tool/compiler-search qualification or a full #53 gate.

Run `python3 experiments/public-owned-events/transaction-candidate-v1/verify.py`
for no-child exact executed-source/whole-oracle/full-raw joins, identical entire
JS/Native Bend source closure and original failed-history verification. It does
not rediscover tools or rerun a backend. Public readers/retention/cursors,
source-current confinement negatives/reached transaction mutation, TS shared
observations and performance/regression/full task delivery remain outstanding.
