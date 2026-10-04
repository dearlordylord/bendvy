# T11: Replacement ECS law and falsification package

**Status:** open; draft and falsify the replacement. [GitHub #12](https://github.com/dearlordylord/bendvy/issues/12).

## Parent and governing evidence

[Full-core parent #1](https://github.com/dearlordylord/bendvy/issues/1),
[SPEC](../SPEC.md), [next checkpoint](../next-core-checkpoint.md),
[Luna source audit](../reviews/laws-source-research.md) and
[Astra decision](../reviews/laws-decision.md).

The old fourteen-law public proposal is withdrawn. Preserve its exact historical
statements and revision-specific results; they do not validate replacement laws.
No ECS law or general proof has been approved. The full core remains the goal.

## What to build

Draft and falsify a connected bounded transition/observation package: world
creation, reservation, pending/live identity, local/foreign lookup, command
publication/explicit flush and queries. Specify independent observations and
command semantics before the laws. Keep cursor helpers and later transactional
reader wrappers separate; this stage is not a Data-only production scope.

## Acceptance criteria

- [x] Audit every historical candidate against pinned Bevy, bevy-ts and Bend sources; record Astra's decision and withdraw the weak public proposal.
- [ ] Map every audit decision to a replacement obligation, retained internal helper or explicit later package; never silently drop a contract.
- [ ] Define concrete interfaces, admissible/reachable states, independent observations and preservation obligations. Query membership must be complete, unique and ordered by ascending entity ID, independently of storage layout.
- [ ] Compute authorization and capacity guards from actual state. Establish namespaces through world creation, tie command targets to authorized handles, preserve approved foreign-world lookup rejection, and cover reservation-to-live transitions. Record unresolved exhaustion and foreign-command observable policies without inventing approval.
- [ ] Specify logical command application independently of the implementation helper. Cover noncommuting commands, survivor preservation, unknown targets, queue clearing and actual schedule execution without an implicit structural flush.
- [ ] Include reachable positive and boundary controls. Always-empty queries, always-Missing lookup, always-reject reservation and no-op flush must fail. Later reader-wrapper laws must reject frozen successful cursors and preserve other readers, failed publications and earlier commits.
- [ ] State runtime/model relation, initial correspondence, operation correspondence and admissibility preservation. Explain affine Type owner return with Data observations, Nat/U32 mapping and bounds before array access; preserve abstract-handle confinement and access-negative controls.
- [ ] Falsify the replacement using meaningful compiling mutations of the decision paths, actual TS/Native/JS comparisons and explicit gaps. Bound each checker invocation to five seconds. Do not reuse old literal controls as evidence for new statements.
- [ ] Present exact replacement law IDs and revision, rationale, controls, killed mutants, proof sketches and dependencies for human approval. Separate helper/model proofs, finite comparisons, owned-runtime refinement and backend/host IO. Write no ECS proofs in this ticket.
- [ ] Update the checkpoint and follow-ups with remaining transaction/reader/provisioning obligations and unresolved gates. New detailed proof/implementation tickets remain unpublished drafts until reviewed; laws have no blanket benchmark dependency.

## Evidence prerequisites

T02 supplies the catalogue and reference traces. The failed T03 constructor design
is superseded only for the bounded query gate by R-A (#14) and R-C1 (#15).
T05 supplies bounded identity/commands; T06–T09 supply their respective rollback,
reader and provisioning probes. These are inputs, not integrated-runtime proofs.
T10's negative layout result does not block drafting independent laws.

## Outcome gates

A reproducible negative result completes research, not the missing capability.
Record a bounded redesign/follow-up and retain the full-core requirement. Approval
of this ticket's investigation does not approve its eventual specific laws,
performance thresholds, dependencies or changes to observable contracts.
