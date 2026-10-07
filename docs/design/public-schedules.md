# Public deterministic schedules (#33)

A static `Step` list declares authored phases, system slots and explicit command
barriers. `Schedule<S,C,R,E,H>` owns the heterogeneous affine registered-runner
record `H`. Its runner returns the complete schedule and world on success,
system failure and namespace rejection. Data phase names are observable labels,
not additional authority or runtime effects. The schedule name is descriptive;
world namespace and each actual system registry determine authority.

Closed typed dispatch and condition adapters are caller-authored provisioning,
like the existing schema lenses. Dispatch invokes the actual public registered
runners and threads every retained registry back into `H`; normalized output is
Unit. A new runner output type may be handled inside its typed adapter without
changing schedule representation. This stage does not store runtime heterogeneous
closures. A later captured-runner extension belongs to the general affine Local
and composition scope; it is not implied by this schedule capability.

Build rejects unknown slots and duplicate system identities using the supplied
registered-slot catalog. Distinct instances of the same runner function have
independent registry IDs and may occur together. Skipping an instance does not
make a second occurrence legal. Actual registry/world metadata is checked again
by `system.run`; a foreign namespace rejects before any schedule callback.
The catalog/dispatch mapping is trusted provisioning, not reflected from an
arbitrary opaque `H` value.

Conditions are evaluated per system, in authored order, and return the world
alongside their Bool. Typed abstract read providers keep gameplay predicates
from accessing undeclared state or writing through read. Phase and barrier
markers remain unconditional, matching pinned bevy-ts gated schedule behavior.

A registered runner's existing transaction owns rollback. A failed outcome stops
execution without touching earlier commits, pending commands or later barriers.
End-of-schedule never implicitly flushes. Reservations can consume IDs even when
a failed system's staged activation is discarded, matching the observed TS
reference; tests check actual final live IDs, not only entity counts.

No new laws, proofs, dependencies, global factory authority or parallel execution
are introduced. This is a finite executable slice, not universal refinement.
