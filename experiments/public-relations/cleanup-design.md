# Experiment-only linked cleanup continuation

No cleanup implementation or law is accepted by this note. Existing finite graph,
World transport and registered-provider receipts do not establish cleanup.

The pinned public TS runtime captures an entity record when `destroyEntity` enters,
then traverses registered descriptors in declaration order. For each descriptor it
snapshots the current incoming source order. Linked sources recurse; ordinary
sources are unlinked. The entered entity's outgoing edge is unlinked after that
descriptor's sources. Components are cleared after all descriptors; component
removal records precede the entered frame's despawn record.

The actual two-descriptor cycle receipt
`evidence/cross-cycle-1791357265511963071/receipt.json` distinguishes entry points:
destroy 1 produces despawn `[2,1]`; destroy 2 produces `[2,1,2]`. Both return.
The earlier expected-error oracle is retained at
`evidence/cross-cycle-1791357124446816027/receipt.json` and is falsified.

A lawful experimental adapter must thread one arbitrary-Type component store.
Its continuation frames may contain Data IDs, descriptor lists and incoming
source snapshots, but must not duplicate component owners. Each frame records
whether entry actually found the entity. A nested invocation may clear/deactivate
that entity while its outer entered frame remains pending. The outer frame still
publishes its observed despawn notice; clearing absent components does not create
another component removal. A visited set would suppress that observable effect
and is not a compatible substitute.

`Commands.despawn_apply_observed` checks current liveness and cannot alone model
an already-entered outer frame. It remains useful for nonrecursive cleanup; the
relation adapter needs separate entered-frame finalization. Namespace-only queue
acceptance and FIFO apply-time validation must also permit future targets without
accepting foreign namespaces. Component clear must consume actual removed owners,
retain unrelated full cells, and publish removal order through the actual World
notice pipeline. Hooks and per-descriptor retained failure readers remain explicit
coverage gaps.

Before Native execution: independent slow cleanup specification, exact literal
acyclic and cross-descriptor-cycle observations, owner-preserving frame machine,
complete pre/post owner and removal traces for both schemas, actual Commands and
barriers, and reached compiling owner-loss/order/notice-omission mutants. Any fuel
limit must expose an incomplete owner+continuation result; it cannot silently
return a completed/default World or become a new cycle rejection policy.
