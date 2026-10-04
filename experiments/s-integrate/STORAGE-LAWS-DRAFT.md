# Storage/identity subject and law draft

Prepared at `9cd750b` for #19. Proposed signatures and exact finite inputs precede
integrated implementation. These statements are unapproved; no universal proofs
or integrated subject falsification results are claimed. Governing inputs are
`docs/design/s-integrate-trace.md` E0/E1/E5/E8/E9/E10 and the actual TS trace ledger.
The coordinator owns the shared-interface freeze. This file selects no production
layout, root authority, reuse policy or performance threshold.

## Intended subject names and ownership signatures

`identity.create(factory)` returns `Created(factory, world)` or the unchanged
factory on rejection. One actual affine factory creates Motion alpha/beta and
Health alpha/beta. Each nominal world owns its namespace and next local ID;
handles contain that namespace and local ID. No caller-selected namespace/target
argument is accepted by the public wrappers.

`commands.reserve(world, bundle)` returns `Reservation<W,H,Bundle>`: success
consumes one ID and transfers the genuine Type bundle into pending publication;
rejection returns world and the supplied bundle. Transaction staging uses the
same allocator, with publication directed to the private transaction queue.
The failed transaction retains the advanced allocator and drops its staged bundle.

`commands.insert_main(world, handle, main)` returns `CommandResult<W,Main>`;
`remove_main/remove_flag/despawn` use the same result envelope with Unit payload.
Only the handle derives the command target. A foreign namespace yields
`CommandMissing{world,payload}` with unchanged receiver. Same-world stale commands
remain accepted structural no-ops when applied, as the selected trace requires.
`commands.apply(world)` alone drains the pending queue in FIFO order; neither
reservation, query, successful commit nor an empty schedule is an apply barrier.

The initial list adapter has ascending numeric logical IDs, with independent
`Maybe<Main>`, `Maybe<Aux>` and `Maybe<Flag>` fields. Main/Aux are nominal Type
records; Flag is nominal Data. Aux-only c and Main-removed a remain live rows.

`storage.with_main(world, handle, transform)` has trusted shape
`W -> H -> (Main -> Main & O) -> W & Access<O>`, where O is Data and Access is
Found(O), QueryMismatch, or MissingEntity. It checks namespace and live membership,
invokes the fresh affine transform once when Main exists, and immediately
reinserts the actual returned owner. Missing Main in a live row is mismatch;
missing/foreign row is missing. A missing target does not invoke transform.
This hook is trusted provisioning, never supplied to an application callback.
`storage.with_ledger` is analogous with the missing-resource result kept distinct.
Trusted setters return the prior scalar for automatic transaction journaling;
public callbacks receive neither extraction nor restoration authority.

`query.each(world, selection, closed_callback)` and `query.lookup(world, handle,
selection, closed_callback)` preserve the owner. Callbacks quantify arbitrary
Main/Aux provider types and receive fresh nominally typed getters, never World or
Factory. Selection checks Main and Flag; optional Aux does not determine Flag.
Queries emit ascending logical IDs. Full views include all four array elements
and every schema metadata field. Ledger observations retain its actual array.

## Proposed subject-bound statements and decisive inputs

The variables below range over reachable well-formed owned worlds. `observe`
means the complete lossless view: namespace, allocator, every live entity/component
and metadata field, full Ledger and provision status, Mode, pending FIFO payloads,
and observable lifecycle metadata. It is not a checksum or a rollback snapshot.
Application-visible query rows additionally carry actual handles. Pure storage
observations thread the original owners and advance no reader or schedule clock.

| Candidate | Statement over intended subjects | Finite witness and planted defect |
|---|---|---|
| SI-ID-CREATE | Two successful sequential `identity.create` calls in the same lineage return distinct namespaces and both returned owners; initial local allocators may coincide. | E1 alpha.a and beta.z have colliding local IDs. Constant namespace must break foreign lookup/command observations. Independent bootstrap roots are excluded. |
| SI-ID-PENDING | After successful `commands.reserve(w,bundle)`, returned handle is MissingEntity under every `query.lookup`; existing rows/queries are unchanged until `commands.apply`. The allocator advances once and full bundle occurs once in pending publication. | E0 a/b/c/z remain missing through the next empty tick; E1 D makes a/b/z live and c a Main mismatch. An implicit flush or reservation-as-liveness defect must differ. |
| SI-ID-FOREIGN | For a real handle from a distinct namespace in the same factory lineage, `query.lookup` returns MissingEntity; each actual structural wrapper returns CommandMissing, preserving complete receiver and returning the unqueued Type payload. | E10 both directions with colliding a/z IDs and a nonempty receiver queue. Remove namespace check or derive a separate supplied target: local value/queue changes or false success must differ. Returned owner is exercised again, not asserted by a boolean. |
| SI-Q-EXACT | `query.each` equals the independent ascending-ID selection of exactly the live rows with Main and the requested Flag condition; optional query carries exact Aux presence/full value. Every query preserves the complete world. | E1 Q=[a,b], Q+=[a], Q-=[b], optional Aux only a; c is live but mismatch. E8 Q=[a,c,p,r], Q+=[c,p], Q-=[a,r], Aux at a/c. Defects using Aux as Flag or insertion-order traversal must differ. |
| SI-Q-LOOKUP | `query.lookup` is MissingEntity exactly for foreign/absent rows; QueryMismatch for live rows failing Main/Flag selection; otherwise Found with the same complete row as `query.each`. The operation preserves all owners and observations. | E1 c mismatches Main while a succeeds; after E8 c succeeds, stale b remains missing, failed q remains missing. Unconditional MissingEntity is caught by the successful control. |
| SI-CMD-FIFO | Observing `commands.apply` equals applying the queued operations left-to-right to an independent full-field structural model, then an empty queue. IDs and unrelated live/resource fields are preserved. Empty apply preserves membership and payloads. | E8 pending inserts p71,a80,c30,a81,b90 leave Q=[p,r] before D; after D Q=[a,c,p,r] with full V81,V30,V71,V60. Reversed FIFO yields a80; stale revival adds b; head reinsertion breaks order. |
| SI-CMD-LIFETIME | Removing Main preserves that live entity's Aux/Flag, while despawn removes the entity and all component owners; later insertion cannot revive a stale entity. Each removed Type owner transfers once to structural disposal. | E6 removes a.Main and despawns b; E8 restores a.Main and inserts c.Main without losing Aux. E9 remove c.Main then despawn a,p,r,c empties alpha and leaves beta unchanged; new s never reuses old handles. Drop-Aux and stale resurrection defects differ. |
| SI-OWNER-EDIT | Successful `storage.with_main` returns the owner produced by its transform, reinserts it in the same logical row, and preserves every untouched component/resource/metadata field. Read transform is observationally identity. Numeric setter changes only slot0 and returns its previous scalar. | Main [20,21,22,23] becomes [30,21,22,23], then [50,21,22,23]; Motion frame7 or Health reserve9/class2 remain. Ledger epoch4 and remaining slots remain. Scalar-only reconstruction or wrong-slot mutation differs. Affine substitution/consumption is checked separately. |

Transaction laws must bind reservation consumption and staging to the real failed
finish: A's p remains pending, B's q disappears, retry r is distinct and later
than q. That joint law belongs to the transaction owner; these storage candidates
cannot establish it from fabricated post-state observations.

## Guards and evidence limits

- The experimental allocator starts at 1, is monotonic and does not reuse IDs.
  Successful allocation requires an available bounded ID below U32 max; rejection
  keeps the counter and supplied owners. This is proposed adapter policy, not a
  production exhaustion/reuse decision. Record actual returned IDs; never infer
  labels from ID constants. The expected trace order is a,b,c,p,q,r,s.
- All trace arrays have length four. Reads/writes are at valid indices 0..3;
  no wrapped Array index is accepted as checked access. World/row handle namespace,
  ID uniqueness/order and component-presence consistency are explicit premises.
  Fixture V(x) requires x <= U32.max-3; selected numeric setter values fit U32.
- Each schema uses its nominal records and every metadata field. Both factory
  namespace directions and both schemas must run. No Data-only payload restriction,
  clone-based rollback, fabricated World callback or hidden-constructor premise.
- E11 public65536 workloads require scalable construction/traversal. An owned list
  baseline is not performance acceptance; expose and measure its scan/rebuild cost.
  An indexed candidate requires additional full-Type relocation and logical-order
  controls before any corresponding capability claim.
- Read-only inspection confirms all three reference HEADs equal
  `.references/sources.json`; installed Bend is 2.0.34 and its guide was read.
  No dependencies/reference files were changed. No ECS proof was written.

## Signature canary executed before integrated bodies

`storage-contracts.bend` checks a generic affine
`with_cell(Main,Observation,transform,cell)` that invokes a transform and immediately
reconstructs the enclosing cell from its returned actual owner. A rank-2 client
gets an abstract P, a fresh getter and P; a four-slot Type array remains owned.
`timeout 5 bend ... --check-only` exits0 with ALL PROOFS CHECK (0.35s).
Ordinary evaluation returns `(Cell{Position{[10,10,10,10],7}},View{10,7})`.
Paired `storage-contracts-negative.bend` tries to replace arbitrary P with a concrete
Position; checker exits1 at `bad`, expected P, observed C.Position (0.54s).
These checks establish only the stated type shape, not integrated lookup,
namespace, transactions, full-field query behavior, or a universal theorem.
