# Public removal/despawn reader policy

Issue #32, governed by SPEC and the pinned TS lifecycle contracts. This is an
executable finite-trace policy, not an approved universal law or proof.

- An observed structural removal command publishes metadata only when its
  barrier-time replacement returned a real previous component owner. Removing
  an absent component publishes nothing; rejected, discarded and failed queues
  publish nothing. The previous affine component owner is dropped at application.
- An observed despawn command rechecks live identity at application, deactivates
  once, clears every schema-owned family and then publishes those actual family
  removals followed by the despawn record. Duplicate queued despawns are no-ops.
  Cleanup is a closed schema-owned callback, not caller-authored manual flags.
- Records contain the world-derived typed entity handle and typed family tag;
  they never contain the removed component owner. Read selectors are erased
  type indices, so a registered reader cannot change its schema/family/selector.
- Independent affine registrations retain independent positions. A successful
  read advances to its observed log end; a failed callback and skipped run keep
  the old position. A reader is checked against actual namespace/registration
  metadata before its closed callback can run. Disposal removes registration
  identity rather than merely dropping a local cursor; a rejected disposal returns
  the affine reader owner for a valid-world retry. The last disposal releases
  the retained metadata log.
- This retention domain is removal-only. The event Runtime's capacity/skip policy
  must not trim this log. #35 owns scheduling and composition of the independent
  domains. Ordinary pre-existing World/Structural/Commands APIs are unchanged;
  observed command entry points are additive.

The first implementation conservatively retains metadata while any removal
reader remains registered. Minimum-reader reclamation and finite-capacity lag
reporting remain full-core #1 follow-ups; returning to those requires an actual
shared cursor ledger and source-bound slow-reader/disposal/overflow traces.
This simplification does not retain component Array owners, alter observations
in the admitted trace, approve Data-only components or qualify full-core parity.
