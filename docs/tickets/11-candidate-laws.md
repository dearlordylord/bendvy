# T11: Replacement ECS law and falsification package

**Status:** completed bounded replacement proposal; exact laws await human approval before proof. [GitHub #12](https://github.com/dearlordylord/bendvy/issues/12).

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
- [x] Map every audit decision to a replacement obligation, retained internal helper or explicit later package; never silently drop a contract.
- [x] Define concrete interfaces, admissible/reachable states, independent observations and preservation obligations. Query membership must be complete, unique and ordered by ascending entity ID, independently of storage layout.
- [x] Compute authorization and capacity guards from actual state. Establish namespaces through world creation, tie command targets to authorized handles, preserve approved foreign-world lookup rejection, and cover reservation-to-live transitions. Record unresolved exhaustion and foreign-command observable policies without inventing approval.
- [x] Specify logical command application independently of the implementation helper. Cover noncommuting commands, survivor preservation, unknown targets, queue clearing and actual schedule execution without an implicit structural flush.
- [x] Include reachable positive and boundary controls. Always-empty queries, always-Missing lookup, always-reject reservation and no-op flush must fail. Later reader-wrapper laws must reject frozen successful cursors and preserve other readers, failed publications and earlier commits.
- [x] State runtime/model relation, initial correspondence, operation correspondence and admissibility preservation. Explain affine Type owner return with Data observations, Nat/U32 mapping and bounds before array access; preserve abstract-handle confinement and access-negative controls.
- [x] Falsify the replacement using meaningful compiling mutations of the decision paths, actual TS/Native/JS comparisons and explicit gaps. Bound each checker invocation to five seconds. Do not reuse old literal controls as evidence for new statements.
- [x] Present exact replacement law IDs and revision, rationale, controls, killed mutants, proof sketches and dependencies for human approval. Separate helper/model proofs, finite comparisons, owned-runtime refinement and backend/host IO. Write no ECS proofs in this ticket.
- [x] Update the checkpoint and follow-ups with remaining transaction/reader/provisioning obligations and unresolved gates. New detailed proof/implementation tickets remain unpublished drafts until reviewed; laws have no blanket benchmark dependency.

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

## Delivered outcome

Implementation: [9fd904b](https://github.com/dearlordylord/bendvy/commit/9fd904b).
[Package report](../../experiments/t11-replacement/README.md) maps all ten acceptance
criteria and all fourteen historical decisions. [Exact approval proposal](../reviews/laws-replacement-package.md)
lists all 31 IDs and SHA256 `e0c607d723ad250a189c096d9fa3fd6a36913f4c72efd3a3be6dacd7fadb2cbc`.
Every law remains open; no general ECS proof was written.

Primary [falsification evidence](../../experiments/t11-replacement/falsification.json)
records 1411 active equality instances, 635 excluded-domain controls, 31 compiling
own-law mutants and 12 refreshed extra mutants. Execution is explicitly segmented:
the complete law stage passed; its loaded old runner subsequently exited 1 in an
obsolete extra stage. The refreshed standalone extra stage exited 0. No whole-command
PASS is inferred. [Independent verification](../reviews/laws-independent-verification.md)
covers all 31 unchanged subjects and all 12 refreshed extras; all source hashes match.

[Runtime evidence](../../experiments/t11-replacement/runtime-evidence.json) records
72 actual TS/Native/JS observations, five U32 boundaries, four paired access controls,
erased-owner live-leak rejection and twelve compiling backend mutants. The complete
independent runtime run exited 0 and produced identical evidence. Final
[Standards](../reviews/implementation-standards.md) and
[Spec/Astra](../reviews/implementation-spec.md) reviews accompany the delivery.

This completes proposal/falsification research, not law approval, universal
refinement or product capability. Independent-root authority, broader Type payload
preservation, real reader/transaction/provisioning wrappers, public foreign-command
and allocator policies, arithmetic high-bound normalization, compiler/backend and
host IO remain explicit [follow-ups](../follow-ups.md). The historical proposal
remains withdrawn. Numerical performance thresholds and later detailed tickets
remain unapproved/unpublished; the full core scope is preserved.
