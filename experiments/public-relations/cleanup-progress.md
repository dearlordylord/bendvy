# Automatic cleanup completion — source-backed candidate

Research for production coordination, not an approved ECS law or proof. Existing backend freezes and `src` are unchanged. The diagnostic128 limit need not force a new public pause policy.

## Supported premises

Use a finite valid graph built by the standard public descriptor/relate operations: each hierarchy descriptor is individually acyclic; ordinary descriptors do not recurse; inverse snapshots agree with authoritative edges; registry order is fixed, each descriptor key is registered exactly once, and E counts precisely those registered descriptors’ authoritative edges. No dynamically supplied callback changes the registry. During cleanup no relation edges or live records are created. The real Runtime hooks only append debug effects (`Runtime.ts754–756,1873`), and `world.ts631–670` snapshots incoming lists, unlinks outgoing edges and deletes records. The Bend component-clear callback receives only the component pack and handle, so it cannot mutate the separate graph or revive World metadata. Forged raw cyclic hierarchy graphs, arbitrary mutating hooks and dishonest metadata are outside these premises.

## Progress argument

Let N bound initially live records, E be the initial authoritative edge count, and D the descriptor count. Edge removals and first live-record removals divide execution into at most E+N+1 progress phases. Within a phase, the same live entity cannot be entered twice:

A repeated live entry is a recursive ancestor re-entry, since an earlier completed invocation would already have removed that live record. Along its recursion path, an outgoing edge with a lower descriptor ordinal would have been unlinked before following a later descriptor. Without an edge removal, descriptor labels along the path therefore cannot increase. Closing the cycle forces all labels equal, contradicting same-descriptor hierarchy acyclicity. Snapshot children are captured within those new invocations; an earlier snapshot that triggered the first entry does not invalidate the internal-cycle argument.

Thus live entries F are at most N*(E+N+1). Each live frame processes at most E child entries and 3+2D+E interpreter transitions (enter, descriptor/child continuations, finish). Dead entries contribute at most F*E extra transitions, plus one possible dead root. A conservative complete-step budget is:

`B = 1 + N*(E+N+1)*(3+2D+2E)`

The bound covers interpreter transitions only, not component-clear or callback runtime cost. B is a mathematical integer bound. Emitted Nat is48-bit; a scalar polynomial Nat computation can overflow at legal World sizes and is unsuitable. A new structural product-budget candidate uses shrinking original edge/descriptor lists and safe U32-to-Nat N loops, with only1/2/3-step fuel values, avoiding scalar multiplication/overflow. An actual allocated/high-water bound may conservatively replace the number of live records, subject to metadata validity. This is an argument for the actual source shape; finite tests below do not constitute a universal runtime proof.

## Falsification and actual observations

`evidence/cleanup-bound-research/receipt.json` retains the exact pure frame interpreter, commands, independent chronological-model comparisons and public TS outputs. Exhaustive finite fixtures cover160,670 graph/root/order subjects:3 nodes/3 hierarchy descriptors;3 nodes/2 mixed descriptors;4 nodes/2 hierarchy descriptors. They check no repeated live entry without progress, complete graph/owner/removal/despawn equality, and the conservative bound. Maximum observed transition counts109/55/103 are below bounds631/361/837.

Fresh actual public TS execution checks three adversarial multi-descriptor carriers under both nominal schemas,18 complete pre/queued/post observations. A four-node/three-descriptor carrier produces22 entered-frame despawn notices but only four component removals, matching the independent model. Its faithful frame interpreter needs219 steps: the old diagnostic128 budget is insufficient on a valid accepted carrier. Naive unique-entry/unique-notice bounds are falsified; no visited-set or new cycle rejection is appropriate.

## Minimal integration direction

Keep `drive` structural on small Nat fuel and derive an overflow-free nested structural budget from N/E/D at the command application point. Automatically continue the existing exact interpreter to completion; do not publish a paused notice as a normal public outcome. Preserve the incomplete result internally as a defensive diagnostic, with all owners/frames, for malformed/unsupported carriers or implementation errors. Retest219-step witness on actual JS/Native and reached budget/owner/order mutations before promotion. Inspect the cost of Nat-bound calculation/representation rather than assume it is free.

This source-backed route removes the need to ask the user to select novel fixed-budget cleanup semantics. Human law approval remains necessary before any ECS proof. Production descriptor validation, complete reader integration and default/performance gates remain required.
