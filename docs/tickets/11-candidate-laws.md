# T11: First concrete law and falsification package

**Status:** published, `ready-for-agent`. [GitHub #12](https://github.com/dearlordylord/bendvy/issues/12).

## Parent

https://github.com/dearlordylord/bendvy/issues/1

## What to build

Present the first finite candidate-law package for experimental identity/query/commands, including explanations, falsification/controls and proof sketches. The package must define precise obligations for separate proof tickets.

## Acceptance criteria

- [ ] Identify concrete functions/interfaces and a finite set of general laws; test membership completeness, preservation and bounds rather than soundness alone.
- [ ] Identify each law's subject: an executable function or a separate model. For models, specify runtime-to-model mapping, admissible states and transition correspondence/preservation obligations.
- [ ] Runtime traces are finite test evidence, not universal refinement proofs; unproved refinement cannot justify calling the runtime API proven.
- [ ] Falsification covers premises and boundaries and detects a planted compiling defect; record skips/errors/coverage gaps and bound checker invocations to five seconds.
- [ ] Give every law a plain-language rationale, controls and proof sketch; proof-package dependencies follow the actual definitions and representation choices.
- [ ] Present the package for explicit approval; required type/storage redesign waits for relevant evidence rather than blanket approval.
- [ ] Prepare transaction/reader/provisioning laws as their modules become ready, without a blanket benchmark dependency; specify exact review/proof tickets at the next checkpoint. This ticket writes no proofs and does not mark undefined packages ready-for-agent.

## Blocked by

- T02: Core catalogue and reference traces
- T03: Repeatable type-safe queries on two worlds
- T05: Reservation, lookup and explicit structural barrier

## Outcome gates

Research may conclude with a reproducible negative result: the report is complete, but the capability gate has not passed. If mandatory behavior cannot be expressed, immediately prepare a bounded redesign/specification decision; dependent implementation/proof work remains blocked. A follow-up does not mean the behavior has been accepted or removed from the goal.
