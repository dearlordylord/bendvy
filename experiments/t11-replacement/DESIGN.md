# Replacement transition package — draft before implementation

This bounded experiment does not choose a production representation or restrict
component payloads to Data. No law is approved and no general ECS proof is written.

The model owns a logical world identifier, next reservation number, an arbitrary
physical permutation of unique live rows `(slot,value,tag)` and a FIFO command
sequence. A factory's next namespace is threaded through creation. World local allocation starts at 1, matching the raw reference IDs. Creation and
reservation use computed capacity checks. Reservation returns a scoped handle,
queues one spawn and does not make it live. Public commands take a handle and an
action without a second target. Foreign authority preserves the world; the
experiment's internal admission result is not a new public error contract.

Pure Nat model admissibility: next <= selected bound;
all live slots are unique and below next; pending spawn slots are unique, below
next and not live. Nonspawn unknown targets are permitted; application ignores missing entities.
Runtime-refinable domain additionally bounds namespace/counters/values/slots and
limits by U32 max, and requires value < U32 max before an immediate increment. A separate reachability
predicate/constructor trace demonstrates witnesses; arbitrary malformed worlds
are never evidence for a premise. Capacity exhaustion/reuse is an unresolved
production decision; this experiment's explicit limit and rejection are conditional.

The independent oracle answers one entity at a time by replaying logical commands
against that slot, then enumerates `[0,next)` for ascending-ID query observations.
The implementation traverses physically unordered rows and sorts selected results.
The oracle never calls implementation apply/query/guard/schedule helpers.

A real bounded schedule executes immediate value updates, handle-based deferred
commands, reservations and explicit barriers. Schedule completion itself does not
flush. The owned runtime uses U32 counters and affine array-backed cells; all read
operations return their owner beside Data observations. Its model relation is
namespace/counter/FIFO agreement plus equal per-slot live projections. Creation,
operation correspondence, admissibility preservation and Nat/U32 no-wrap are
separate obligations; finite backend traces will not be called universal refinement.

Required positive controls: factory creates two distinct namespaces, local lookup
succeeds, below-capacity reservation succeeds and is pending, explicit flush makes
spawn visible, noncommuting insert/remove follow FIFO, immediate schedule writes
occur while structural commands remain pending, queries sort permuted storage.
Required negative controls: cross-world colliding lookup/command authority,
unknown/dead targets, exhaustion and overflow, undeclared/schema/read-write access.

The three historical cursor helpers remain a separate exact executable-function
layer. Selected-reader transaction/skip/success/failure/retry/retention/lag laws
need a later wrapper package; this package cannot pass that missing capability.

The final proposition encoding uses erased owners only in mathematical terms;
a paired checker control rejects their reentry into live code. An independent
structural owned oracle observes actual fields and array element zero. Projection
and returned-owner observations, query/lookup/reserve results and actual tick
are direct equality subjects; no Boolean certificate is a runtime guarantee.
Conditional Type claims are independently pinned on both true/false branches.
Schedule correspondence checks each prefix for admissibility/nonoverflow.
Arbitrary owner arrays are nonempty; the declared observation covers element zero,
not all contents or physical identity. This observation scope is explicit.
