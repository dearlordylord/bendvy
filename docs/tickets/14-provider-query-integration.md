# R-C1: Integrate abstract capabilities with two-schema query traces

**Status:** published, `ready-for-agent`. [GitHub #15](https://github.com/dearlordylord/bendvy/issues/15). Approved conditional continuation of R-A.

## Parent and evidence

- [Parent #1](https://github.com/dearlordylord/bendvy/issues/1), [SPEC](../SPEC.md).
- [R-A #14](https://github.com/dearlordylord/bendvy/issues/14), [provider report](../../experiments/ra-provider/README.md).
- [T03 #4](https://github.com/dearlordylord/bendvy/issues/4), [negative report](../../experiments/t03/README.md).
- [R2 recipe and normalization](../reference/traces.md), [T12 checkpoint](../t12-redesign-decision.md).

## What to build

Extend the bounded rank-2 abstract-provider experiment to query access over multiple entities in two compositionally different schemas. Execute full R2 public checkpoints against the pinned bevy-ts reference on native and JavaScript. Keep application callbacks and trusted provisioning separate; this is an experimental query integration, not a production storage/API decision.

## Acceptance criteria

- [ ] Reproduce the delivered R-A controls before extending the boundary. Record pinned compiler/reference identities, available public symbols, trusted operations and abstract callback types. Do not rely on import restrictions, unsafe/foreign constructors or whole-world callback access.
- [ ] Implement two schemas differing in component composition, beyond token/type names. One executes the exact R2 Position/Tag recipe: entities a=0 with Tag and b=10 without Tag; the same Step value executes three times, adding 1. A second schema exercises a distinct component composition and declared read/write operations, with equivalent explicitly documented multi-entity/reference checkpoints. Record finite inputs before deriving outputs.
- [ ] Observe R2 setup and all three steps, including in-callback read-your-writes and a later reader in the same execution sequence. For the first schema, values are [0,10], [1,11], [2,12], [3,13] in actual query order [a,b]. Component updates become visible without a structural flush.
- [ ] Execute presence, absence and optional queries. Observe Tagged=[a], Untagged=[b], and explicit present/absent optional Tag values. Lookup live b with Tagged yields typed QueryMismatch; lookup b with Optional matches with absent Tag. Run equivalent declared observations for the second schema rather than asserting schema parity by renaming output labels.
- [ ] Obtain observations through the experimental public query/lookup/cell API and the pinned reference public API. Membership sets may be normalized, but actual query traversal order must not be sorted away. Normalize logical entity labels from setup, not storage addresses or numeric ID coincidence. Do not manufacture traces from expected constants.
- [ ] Preserve affine world/storage ownership across traversal and repeated callback execution. Writable handles support immediate reads after updates; read-only callbacks cannot modify provider-owned storage. Document fixed small storage, closed templates and Data payloads as experimental limits with explicit return conditions; affine Type payload acceptance remains #5.
- [ ] Repeat paired intended-type negative controls for undeclared access, write-through-read, cross-schema substitution and grant fabrication/reconstruction, including public constructors/provider paths relevant to the expanded API. Positive controls must succeed. Test malformed callback return paths that could replace abstract handles with concrete cells. Finite controls are not a parametricity theorem.
- [ ] Provide one reproducible runner comparing all ordered checkpoints against actual Node-only reference execution on native and JavaScript. Each checker/build invocation is bounded by five seconds. A timeout, skipped observation or unrelated error fails the runner. No new dependencies without concrete approval.
- [ ] Include a compiling semantic mutant that violates a required query checkpoint and is detected by the comparison. Record candidate statements and falsification before any proof; no ECS proofs against unapproved laws, no universal refinement or performance acceptance claims.
- [ ] Report passed, failed and inconclusive portions separately. A complete negative report is not a capability pass. Update the capability evidence/follow-up map with exact coverage and remaining blockers; keep the original full-core scope.

## Outcome gates

A complete passing report may satisfy the experimental two-schema typed-query/R2 return gate for resuming the original dependent probes (#5, #6, #10 and #12), subject to independent coordinator verification. It does not close affine payload, identity, transaction, reader, schedule, universal refinement or representative performance gates. A partial/negative result returns to bounded redesign rather than weakening the required observations or adopting checked actions. The parent issue stays open.

## Delivery

Use the exact Dalph task worktree. Proposed artifacts: `experiments/rc1-query/`. Read the issue and linked documents; follow AGENTS.md and bend-ldd. Write task artifacts and reports in English. Commit a verified candidate; coordinator/integrator owns master, publication, tracker and DALPH.md. Do not modify reference repositories or original jev/dalph.
