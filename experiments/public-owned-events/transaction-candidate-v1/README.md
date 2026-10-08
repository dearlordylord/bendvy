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
No backend/output was obtained; independent whole oracle is being authored from
these source/DTO definitions by the oracle worker before execution admission.
No law/proof, dependency, shared ECS source or public contract changed. Raw
trusted World creation is an unqualified fixture setup, not production factory
coverage. Public readers/retention, source-current negatives/mutation,
JS/Native/TS applications and performance/full #53 gates remain outstanding.

Imports use root canonical ECS modules and the integrated canonical Stage
identity. This source development commit is not clean-checkout portable delivery;
source qualification must bind those exact canonical dependencies.
