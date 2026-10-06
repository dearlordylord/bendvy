# Descending cursor source review

Root independently replays the frozen derivation and obtains identical29 module
hashes, closure b0fdd6c41be12b34efc79e45edc98225c1b0158a51976b432a1646bfcae9e8f0.
Only query.bend changes; all28 other modules, original public/generic definitions,
step boundaries, callback bodies and scheduler/transaction/provider code retain
exact bytes. Reviewed parent is bdf6b2fc46d2a89615d0e9eb48d44f4a3e8c8f2ff5b8268d7ca50463e6bfbe94.

The producer initializes fuel=Nat(high) and id=high. At each supported step,
id is positive and decreases with fuel; id0 is reached only for the fuel0 finish.
Thus no positive-fuel underflow occurs on this producer path. The existing
capacity validity predicate, live/flag selection, opaque Main swap/restore and
all columns/metadata remain. Descending physical collection prepends IDs, so the
finished list and later callback execution remain ascending. The new finish
returns every original Rows field and the accumulated list without reversal.
No authored getter or callback runs during this intrinsic presence scan. Generic
Type owners are restored without inspection or discard; immutable values are
not mutated. The consumed world has no concurrent shared mutable alias in the
supported affine path.

These are source inspection and bounded-path reasoning, not a new approved ECS
law, machine proof or universal refinement/authority claim. Exported private
helpers remain callable with malformed fuel/state outside the producer contract;
public constructor/root-authority and production API decisions stay open.
Fresh source-owned lifecycle, complete-owned shape, multi-ID selection/order,
rollback and compiling drop/order/live/selection controls are independently
recorded in source-private-id-query-descending. The actual protected8/576 Tx
matrix supplies IDs directly and does not execute query enumeration; both
packages are needed and neither is full22. Native allocation evidence reports
fewer reverse RFC redirects, not fewer Cons allocations. No concrete blocker was
found for the supported source producer, and no production adoption follows.
