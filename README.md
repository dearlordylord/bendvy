# Bendvy

Bevy-style ECS for Bend 2. Target: the full core behavior of the pinned bevy-ts reference, with APIs and storage designed for Bend's type system, affine ownership and runtime.

This repository contains a development specification, executable bounded ECS prototypes, proof evidence and performance diagnostics. It does not yet provide an accepted production ECS API. Start from the [current checkpoint](docs/next-core-checkpoint.md), not historical experiment results.

The current [blind API audit](docs/tickets/23-blind-ecs-api-audit.md) tests whether an independent application author can use the interfaces without engine-specific workarounds.

- [Specification](docs/SPEC.md)
- [GitHub task #1](https://github.com/dearlordylord/bendvy/issues/1) (`ready-for-agent`)
- [Near-term plan](docs/next-stage-plan.md)
- [Published tickets and dependencies](docs/ticket-breakdown.md)
- [Agreed scope](docs/planning-scope.md)
- [Development roadmap](docs/development-roadmap.md)
- [Follow-up tasks](docs/follow-ups.md)
- [Bend architecture research](docs/bend2-ecs-port.md)
- [bevy-ts analysis](docs/bevy-ts-analysis.md)
- [Core catalogue and six reference traces](docs/reference/core-map.md) (T02; runtime observations pending dependency approval)
- [Pinned references](.references/sources.json)

Performance requirements: low-level native builds must substantially outperform bevy-ts; JavaScript builds must be at least comparable on equivalent workloads. Approved targets are JS/TS elapsed <=1.00 and Native/TS elapsed <=0.50 on equivalent work. These are product requirements; raw diagnostic ratios do not establish full acceptance.

Development follows bend-ldd: candidate laws, falsification, human approval, proofs, and mutation checks. Individual laws are approved before their proofs are written.

The first application is a small deterministic console simulation on CPU. A later integration check will use a separate copy of canonical-defense; its original repository must remain unchanged.

The reference source checkouts are local and excluded from Git. Their URLs and commits are recorded in the reference manifest. The default branch is `master`.
