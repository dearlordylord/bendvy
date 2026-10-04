# Checked shared seam — draft signatures

This is signature preparation for #19, not its integrated subject or runtime
acceptance. Governing [reviewed contracts](../../docs/design/s-integrate-contracts.md),
[execution](../../docs/design/s-integrate-execution.md) and [E0–E11](../../docs/design/s-integrate-trace.md).
Only `types.bend` and `interface-controls.bend` currently have checked owner-return
shapes. Interface review/freeze and bound draft-law falsification precede subjects.

- Full nominal Motion/Health payload/resource records contain actual affine
  `Array<U32>` owners and all metadata. Arrays are length4 in the exact fixture;
  these signatures do not yet enforce their length. Four/View records are Data
  projections, never substitutes for stored owners. Payload constructors grant no
  world/handle authority. No concrete World/Factory/Handle/Tx constructor is shared.
- Provisioning quantifies schema-specific arbitrary abstract provider/Tx/handle
  owners. Each schema's factory/world/handle types must be bound consistently by
  its actual trusted provisioning path; generic envelopes alone do not establish
  namespace authority. Creation returns factory on both outcomes; reservation
  returns world and durable handle, or world plus unconsumed rejected payload.
- CommandMissing returns receiver world plus actual rejected Type payload;
  MissingEntity/queue/rows/metadata unchanged is the selected foreign rule. A
  successful command transfers payload to its real Type queue; a failed system
  disposes staged owners exactly once. Failure discards publication, not consumed
  reservations. The envelope does not implement or prove any of these transitions.
- Private Tx owns world, ordered numeric inverse journal, staged Type commands,
  messages and marks. Setter gets opaque Tx and returns Tx, capturing old value
  internally before write; callback has no inverse, restore, extraction or finish
  capability. Supplied before/first/between/second/after operations are distinct
  affine values; resource writes use the same journal. Reinsert extracted actual
  owners before finish. B's two inverses unwind 50→30→20; A remains committed.
- Invocation returns the same opaque Tx and distinct capture owner plus Outcome.
  ECS finish handles journal/publications/readers; dispatcher attaches the preserved base system name B to code7, not a generic nesting name; lexical capture and Audit side
  effects are not rolled back. Declared Audit operation must perform real IO.
  Closed dispatcher preflights all actual nested requirements (E10 exercises Ledger/Audit), threads
  returned owners, stops tails on child failure, and uses explicit D/T only.
- ReaderState/ReadBoundary are shared Data metadata, not reader authority. Registry,
  log owners, BaseInstanceId and schema-specific retained lifecycle handles stay
  abstract/private pending the reader interface freeze. Begin registers once and
  snapshots saved boundaries; success saves thisRun, failure saves neither, skip
  advances only an existing stream boundary and never registers. Post-run message
  publication has its own tick; no failed clock rewind. Persistent per-component
  added/changed marks and separate removed/despawn holders remain integration work.

`LAWS-DRAFT.bend` contains runnable observation predicates and finite perturbed
inputs, plus subject-binding templates. Lossless complete world/queue strings are
an encoding obligation, not an implemented encoder. The ownerReturned flag cannot
prove affine identity. These predicates neither quantify over an actual command
subject nor prove general ownership/rollback; exact subject-bound laws must be
written/falsified and specifically approved before their general proofs.

Still needed before parallel subjects: checked trusted storage extraction/reinsert
and private Tx construction/finish signatures; schema-specific Main/Aux/resource
capabilities; real reader/publication hooks; actual owner-return full observations;
precise command rejection/ownership tests. Preserve list/index neutrality, root/
reuse/general Local/destructive-recovery follow-ups and performance gates. No
production policy or unapproved catalogue proof is selected by this seam.


Next checked join shapes: `trusted_main` consumes world, nominal abstract handle
and affine Main→Main&Data transform, returning world plus `Access<O>` Found/Mismatch/
Missing; trusted adapter reinserts immediately on Found. `trusted_ledger` consumes
world and affine Ledger→Ledger&Data transform. Both are signature forwarding here;
the storage/transaction canaries provide actual instantiation separately. The
selected H is bound privately into Tx/provider getter/setter context from the actual
a/b handle by trusted provisioning; a bare token or numeric constant does not identify an entity. Each inverse retains
that real handle. Only Found captures a numeric inverse. A missing transform is not invoked; therefore it cannot promise returning
an arbitrary Type captured inside that unused transform. Rejected owned command
payloads use CommandResult separately. Public concrete handle constructors, where
supplied by the trusted adapter, do not prove root authority or confidentiality;
nominality and namespace checks remain explicit, not constructor privacy claims.

RollbackObservation checks every Main/Ledger field, prior A and complete pending
queue projection; AllocationObservation rejects reissuing the failed ID and requires
its missing/discarded observation; PublicationObservation separates success delta
from failed zero publication. Perturbed wrong inverse, metadata, reservation reuse
and leaked Ping are rejected. These are faithful E2–E5 observation inputs, not an
actual runtime/journal execution or exact-law approval. Planned subject bindings:
transaction.begin/set_main/set_ledger/finish; identity.reserve plus commands.queue;
commands.flush; readers.begin/complete/skip; dispatcher.tick/try_tick. Names remain
proposed pending worker/interface review, but each draft has a named subject boundary.
The failed-prefix predicate does not test journal order directly: the independent
E2 own-write30/50 inputs and inverse30/20 steps must be bound/executed separately.
