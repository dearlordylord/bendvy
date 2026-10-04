# S-CAPTURE: Repeatable system state and affine restoration

**Status:** published, `ready-for-agent`. [GitHub #17](https://github.com/dearlordylord/bendvy/issues/17). Parent: [#1](https://github.com/dearlordylord/bendvy/issues/1).

Review: [Astra assessment](../reviews/next-research-tickets.md).

## Goal and prerequisites

Establish a viable Bend-native interface for repeatable systems with persistent
per-system Local/captured state and restoration of mutated noncopyable ECS payloads.
Read SPEC, the checkpoint, T04's owned payload, T06's inverse rollback, T09's closed
callback boundary, R-A/R-C1 and the source-law decision. This bounded research can
start alongside #12 and S-LAYOUT, without approved ECS laws or a selected layout.

## Bounded deliverable

Use one small nested schedule, two system instances and an actual affine Type
payload containing owned storage. Compare a closure representation if supported
with explicit owned system state threaded through repeatable closed templates.
Both must preserve the selected public observations; a failed closure experiment
must not silently restrict the eventual public System contract. The pinned TS core
has no dedicated Local API. Use actual lexical system-capture observations as the
reference and identify the proposed Bend Local abstraction separately. ECS rollback
does not imply restoring lexical captures. New Local rollback/lifetime semantics
require an explicit contract decision, not an invented reference expectation.

## Acceptance criteria

- [ ] Record the concrete owner/call signatures and which values are consumed/returned per invocation. Demonstrate multiple executions of each instance, persistent Local state and isolation between instances; no duplication of an affine closure/payload and no fabricated reusable annotation.
- [ ] Record source-backed TS lexical-capture success, skip and failure behavior, then execute actual TS reference checkpoints alongside Native/JS. Distinguish capture persistence, proposed Bend Local state, ECS transactional state and host IO. Report absent reference APIs explicitly; do not invent Local, whole-closure or external-effect rollback.
- [ ] Exercise earlier successful commit, a later system that mutates an owned payload and stages command/message publication, typed failure, restoration and retry, followed by success. Check exact payload observations, publications, failure identity and Local state at each boundary. Include empty/no-op and successful mutation controls.
- [ ] Restore without cloning Type storage or replacing the subject with Data. Explain the supported mutation algebra and undo ownership. For arbitrary destructive operations without recoverable inverse/retained owner, record the precise limitation and required API/design decision; a reversible subset does not establish arbitrary callback rollback.
- [ ] Include a reader-position observation where supported, preserving the failed system's saved position and earlier successful commits. Cross-link the general allocation/marks/cursors rollback obligations to S-INTEGRATE rather than claiming they are proven by this bounded probe.
- [ ] Demonstrate nested failure propagation and access confinement using paired positive/negative fixtures for undeclared access, cross-schema misuse, writes through read and double consumption. Keep abstract provider handles; arbitrary Base IO remains outside the sandbox claim.
- [ ] Kill meaningful compiling mutants that lose Local persistence, share two instances' state or omit owned-payload restoration. Verify normal Native/JS traces against actual TS and report unsupported comparisons, checker failures and unrelated diagnostics as gaps, not killed mutants.
- [ ] Publish a dependency-free runner using existing tooling, pins, exact traces, explicit bounds and a five-second limit per checker invocation. Separate finite evidence, executable helpers, prospective laws and unproved universal refinement; write no ECS proofs.
- [ ] Propose the repeatable-system/restoration seam for later integration and record all remaining captured-state, resource/service, dynamic composition and arbitrary-payload obligations. Preserve full-core scope and the untouched Tower Defense repository.

## Outcome and dependencies

A negative result is a completed experiment, not acceptance of a reduced System
contract. Record a bounded redesign choice and gate dependent integration on its
resolution. S-LAYOUT is an optional comparison input, not a start blocker. Exact
laws, new dependencies and observable contract changes still require their specific
approvals; this ticket authorizes investigation and finite validation only.
