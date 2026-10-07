# Public per-system Local policy — selected implementation contract

Explicit user confirmation received: “Да, Local сохраняет изменения при ошибке”.
This confirms per-instance affine Local persistence after failed system execution,
independent transactional World rollback, unchanged Local on skip and owner disposal.
This approval covers the executable Local contract, not new ECS proof laws.

Governing issue: #36. The user explicitly pre-approved task execution and its
implementation decisions on2026-10-06. The integrator initially selected the
proposed simple persistent-instance policy under that authorization; the subsequent
explicit answer above confirms the pending asynchronous question. Exact new ECS
laws are outside this approval. Executable acceptance still requires all #36 gates.

## Selected contract

Each registered system instance owns one affine Local value. The Local owner is
threaded through its runner and returned on success, failure and refusal. Two
registrations with the same runner still own independent Local values. Conditional
skip performs no Local operation. ECS World transactions continue to roll back
the failed system's writes/publications while preserving earlier commits.

Selected Local failure behavior: retain the returned Local changes after a failed
system, as with persistent instance state rather than a transactional resource.
This permits arbitrary affine payloads without cloning or fabricating destructive
inverses. Host IO remains outside rollback. Disposal unregisters the instance and
consumes its Local owner once; a closed caller-provided disposer can release or
observe owned resources. Failed cross-world execution returns the original
Local, registry, World and arguments without invoking the runner.

The alternative requiring transactional Local rollback needs an explicitly
recoverable mutation/replacement interface and cannot promise recovery of arbitrary
destructive Type/IO operations.

## Source evidence and planned tests

Pinned Rust Bevy `bevy_ecs` defines Local as a mutable reference to a system
parameter's persistent SyncCell state; its dereference/get_param expose that state
per instance. This supports the ownership/lifetime analogy, not a claim that
Bevy has Bendvy's transactional failure mechanism. No dedicated Local API was
found in the pinned bevy-ts catalogue. Comparison therefore uses a documented
explicit-state TS adapter with the same operations under the chosen policy.

Required observations: two actual Array-owning Local instances, repeated calls,
isolation, conditional skip, failure/retry, rejected foreign registration, and
exactly-once disposal. Read every array element after each boundary. Controls must
reject duplication/undeclared access and detect a compiling instance/retention
mutant. Retain source-current JS/Native receipts and feature timings, then run
#28 without changing its fixed workload or source baseline.
