# Read-only feasibility: persistent packed Main cache slot

Source examined: genuine joined29 closure
`8cb83bc7467ca8e9b0192b8dadd89d3c143262d37e812079342289be1c0f6e26`.
No implementation, checker/build execution, source replacement or speed claim.

A bounded source design appears expressible using the existing generic Type storage,
Host, query and transaction APIs, but it is a new private benchmark state route, not
a transparent alias for the existing nominal Cache type. Its Native gain is unknown.

## Concrete representation and semantics

Private MotionSlot must be Type: owned coordinates:Array<U32>, raw frame, cached
four coordinate scalars and cached frame. HealthSlot analogously keeps owned levels,
raw reserve/class, cached four level scalars and cached reserve/class. Raw and cached
metadata must be separate: exported nominal Cache permits discrepancies. Do not
regenerate cached values from raw arrays except in the original uncached-get route.

The slot setter consumes the owned raw array, reads true-old cell zero using the
original Array semantics, sets that cell and cached-a only, and preserves every
other raw cell/scalar and cached scalar. Cached getters rebuild the exact original
nominal PositionView/VitalsView/Four Data values; retained snapshots remain immutable.
Rollback must use the original raw-old swap and cached patch behavior, including
incoming cached/raw discrepancies, rather than restore guessed cached-old fields.
These constraints follow [payload types](/tmp/bendvy-joined-flatjournal-ledger-v1/experiments/s-integrate/types.bend:13)
and [cached patch/swap](/tmp/bendvy-joined-flatjournal-ledger-v1/experiments/s-integrate/cached-payload.bend:14).

Generic Rows/World accept M:Type and commands carry that same M. Checked Main updates
and restore accept an M→U32→M&U32 provider; generic reads accept original Data views.
No storage kernel/public signature change is required ([Rows](/tmp/bendvy-joined-flatjournal-ledger-v1/experiments/s-integrate/storage.bend:12),
[swap/restore](/tmp/bendvy-joined-flatjournal-ledger-v1/experiments/s-integrate/transaction.bend:69)).
Original rank2 authored callbacks can receive an opaque new Owner plus slot-aware
get/set providers returning the same nominal views; their bodies/authority stay exact.
General fallback can operate directly on Tx<World<Slot,...>> with new checked providers,
not convert every component to nominal Cache. This requires a new private fold/row
provider family rather than the existing concrete Cache-typed family.

## Persistence is the critical boundary

Existing MotionHost()/HealthHost() are concrete nominal Cache aliases, and MotionBench/
HealthBench store those hosts. They cannot secretly hold World<Slot,...>; nominal type
headers cannot be changed or bypassed. Add private packed Host/Bench wrappers, using
unchanged generic Host frame/barrier/observation APIs instantiated with Slot and the
original nominal Data views ([generic Host](/tmp/bendvy-joined-flatjournal-ledger-v1/experiments/s-integrate/host.bend:21),
[concrete aliases](/tmp/bendvy-joined-flatjournal-ledger-v1/experiments/s-integrate/host.bend:160),
[Bench](/tmp/bendvy-joined-flatjournal-ledger-v1/experiments/s-integrate/measurement-bend.bend:91)).

The packed World must survive all scheduler frames. Reconstruct original views for
observation through generic getters; do not rebuild a nominal World every tick or
round-trip all rows around the existing concrete host methods. An initial wholeWorld
conversion and terminal diagnostic boundary may be finite probe adapters, but typed
initializers that create slots directly are preferable and must be counted separately.
Keep the original generic/public route unchanged and independently runnable.

Original raw factory adapters concretely construct Cache bundles; add private raw→Slot
bundle/command adapters at actual ingress, preserving rejection-returned raw values,
foreign handles and complete pending commands. Spawn/InsertMain payloads use Slot inside
World<Slot>; do not drop or reinterpret them. Generic reserve/publish can stay intact,
but original concrete factory headers remain separate ([raw adapters](/tmp/bendvy-joined-flatjournal-ledger-v1/experiments/s-integrate/raw-boundaries.bend:9)).

## Why a gain is only a hypothesis

A flat slot could replace escaping Raw/View/Cache storage constructors with one owned
record. However nominal view reconstruction at each getter may escape into row-owner,
query results or event snapshots and recreate View/Four allocation/RFC sealing.
Native may unbox those fixed Data returns under saturated static providers, but that
must be established from actual generated C and executed allocation/seal attribution;
source field count alone does not show it. A wider flat record also changes native
words/layout and JS shapes. Full storage conversion per frame would cancel the premise.

First authorized implementation should be a minimal persistent one-schema private
route with original callback invocation, full64 frames and source-bound Native counts.
Stop if it merely shifts the same escaping constructors to reads/adapters. Before
adoption require both schemas/fullfields, raw/cached discrepant views, Array lengths
1/2/4/8 and all cells/scalars, nonidentity returned owner, fallback/missing/foreign/order,
actual Tx/suppression/rollback/live mutations, abstract authority negatives and fresh
factory/provider registration/semantics. No Data-only restriction, production API,
proof/full22 or equivalent-work performance acceptance follows from this design.
