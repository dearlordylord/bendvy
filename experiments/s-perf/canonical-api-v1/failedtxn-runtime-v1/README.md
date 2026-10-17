# Canonical FailedTxn — first Motion consumer

This source repairs the frozen FailedTxn story through the current canonical
public ECS API. The first correctness case is `motion-main.bend 64 64`.
No backend or numerical performance qualification is recorded here yet.

Each process creates a warmup World through `world-io.create`, executes and prints
its complete report, then creates a second measured World through another actual
`world-io.create`. Completion of the warmup `IO.print` precedes measured creation.
Namespaces and complete index/generation handles are observed as returned; no
pure factory reset or logical-ID substitution is used.

The seed retains all four payload cells, nominal fields, optional Aux/Flag rows,
all reservations, and the physical pending/applied Worlds. B and Publications
have distinct ordinary event-reader providers. A and B have distinct registered
Local owners with affine two-cell capture Arrays. B passes its next capture count
to the pure callback and increments its actual retained Array only after an
ordinary callback completion or callback failure, preserving it on reader refusal.
The source does not claim that this Array mutation occurs inside the callback.

For each iteration an actual provisioned schedule invokes A then failing B in one
segment. Further segments execute Publications, the same B provider's retry,
Publications again, the apply barrier, and transient disposal plus its barrier.
The four boundaries retain complete query fields, current transient lookups,
every historical failed-handle lookup, physical Worlds and registered owners.
Raw Local/reader outcomes, callbacks, actual pre-finish journals and schedule
observations remain in the complete final report.

Ledger writes use the canonical Product field lens. The single quiet Recorded
Audit owner occupies the sibling service slot; the declaration-derived request
updates it without adding an ECS inverse. Effects are observed in actual cons
order, newest first. B failure restores Ledger/components and discards its staged
commands/events while retaining Audit effects and entered Local capture changes.
The ordinary reader decides commit; failure does not complete its cursor. This
is the frozen Bend transaction adapter contract, not a native Bevy rollback claim.

Journal callbacks remain opaque: the report observes actual undo counts and
ordered command constructors, staged events, full Trace.State and physical World.
Rejected component inputs remain affine returned owners until fully observed.
The service candidate and missing-service/authority controls are not qualified by
these source checks. No Console/general host-IO service, universal proof, timing,
margin, or broader workload-family claim follows from this first source slice.

This isolated successor changes report transport only: final Frame calls,
boundaries and schedule records are serialized and written individually in the
same order, with the same complete text and newline framing. ECS execution and
all capture sites are unchanged. Full warmup output still completes before the
second WorldIO creation. The predecessor Native deadline remains historical;
source equivalence does not establish that this successor meets runtime caps.
