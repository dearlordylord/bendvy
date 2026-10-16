# Independent family-publisher oracle

`derive.py` models the complete stdout of the frozen `families-v1/main.bend`
trace from the pinned source bodies. It covers Workshop and Garden, each with
seven world snapshots: before and after the standalone publication, after
registration/population, after success, after semantic failure, after retry,
and after foreign-world refusal. The model includes every component/resource
owner, stamp, event log and ID, ordered publication, registry cursor, world
clock, and recovery receipt printed by the observer.

The source body emits Cargo, Alerts, Cargo, then Crates. A successful query
visits Value owners in handle order. The late failure on the second owner
restores both component values and the user resource, discards staged
publications, retains the two attempted clock ticks, and does not advance the
query cursor. The retry then commits from the restored owners. Per-family log
IDs advance independently, while the World event list keeps the cross-family
call order.

`SOURCE-BASIS.json` binds the source freeze and all 77 source pins (75 Bend
bodies and two namespace-host sidecars), plus the pinned Base and `IO.print`
implementations used for formatting and the terminal newline. The two schemas
use the actual source `WorldIO` namespace allocator; the printed IDs are
derived from creation order. Array-backed columns are modeled by raw slot
`entity id - 1`; lifecycle stamps and live-world IDs are modeled separately.

The generator does not execute Bend, JavaScript, Native, or a candidate. Run
`python3 derive.py` to regenerate the raw and deterministic gzip oracle, and
`python3 derive.py --selftest` to verify source pins, state invariants, and
retained output bytes. This oracle qualifies only this source-bound scenario;
it makes no full-feature or runtime claim.
