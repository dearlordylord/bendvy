# Large-public-input renderer checkpoint

This is finite E11 encoding evidence, not full integrated Host or performance
acceptance. The original String renderer attempted an actual Read with 65,537
nonuniform full QueryRows in each of query/added/changed. Native exceeded five
seconds; JS exited with a machine-stack fault. Tail-recursive chunk/character
builders removed the JS stack fault but both complete String outputs exceeded
five seconds. Streaming `IO.write` produced the full 41,512,431-byte JSON line on
Native in 1.498 seconds; JS still exceeded five seconds. These failures remain
failures. The baseline input varied metadata/Aux as well as main fields; the
compact positive fixture deliberately has constant actual metadata/Aux/Flag and
nonuniform consecutive main slots/IDs. Neither path is a production benchmark.

`render_motion` / `render_health` retain their full JSON API; all string/list
assembly uses task-local tail-recursive builders without changing Base.
`write_motion` / `write_health` stream Read fields/lists through `IO.write` while
preserving one JSON line; other event constructors use the String renderer.
Large Snapshot rendering is not claimed passed.

`renderer-bulk-baseline.bend` preserves the actual nonuniform baseline input.
`python3 experiments/s-integrate/renderer-bulk-streaming.py` repeats current
streaming execution, checks EVERY original full JSON row/field/order on Native,
and only then retains count/endpoints/raw digest in evidence. JS remains an
expected five-second failure in that separate diagnostic.

`compact_motion_event` / `compact_health_event` are an explicit E11-only option.
Before implementation, the retention integrator reviewed the draft: empty lists
emit []; nonempty query/added/changed lists derive the first actual complete row
as template. Every original row's namespace/ID, four main cells, schema metadata,
full optional Aux and Flag are checked directly as exact typed Data (Four,
Boolean/scalar and optional group). Per-row JSON construction/String equality has
been removed; only the actual first complete template is rendered. IDs and x (derived from actual cell1−1)
must increase consecutively without wrap. Slot0 follows x or is one actual first
cell constant. Output contains actual template, namespace, idFirst/idLast,
xFirst/xLast/count, and slot0 mode. All other Read scalars, boundary and lag flags
remain actual input values. Removed/despawned now use validated handle-range encoding: every actual namespace
and ordered ID is checked before deriving first/last/count. Messages retain full
ordered arrays. No message range capability is claimed.

Any inconsistency emits `encoding:unrepresentable`, a reason and actual failing
index; no success encoding is returned. The index may identify the last mismatch.
The admitted E11 count is bounded; arbitrary U32-length streams are not claimed.
A last ID MAX is conservatively rejected even as a singleton. If the first
slot0 equals its inferred x, mode x is selected; a constant pattern coinciding
with that first x may be conservatively rejected. E11 changed-slot0 is 11 with
x=10 and is representable; arbitrary representable-family completeness is open. x greater than
MAX−3 or initial cell1 zero is rejected. Generic project/render callbacks are a
trusted template boundary; nominal wrappers implement the tested two schemas.

Reproduce `python3 experiments/s-integrate/renderer-bulk-run.py`: actual 65,537
Motion rows appear three times, plus 65,537 actual Health rows. Both backends
complete within five seconds. Python checks every expanded cell/metadata/order
against independent fixture inputs; compact output occurs only after Bend checks
every original full Data row. Six compiling fixture controls change only a final
Motion cell2, Aux cell2, metadata or namespace, an initial zero cell1, or final ID
wrap. Each becomes unrepresentable; the independent Health lane stays valid.
Checker/runtime hard five-second bounds and task-owned cleanup are unchanged;
codegen/clang retain distinct 30/120-second bounds. Evidence pins source bytes and
records complete compact outputs/timings. No proof or limit increase is added.

## Additional failures and lifecycle-only isolation

The artificial combined stress program `renderer-bulk-combined-failed.bend` added
four 65,537-handle lists to the 264k-row workload and reached the five-second JS
deadline in a corruption lane. A later separated row-suite rerun also reached five
seconds in its last-metadata JS lane while other jobs were active. These are real
failures; no causal conclusion about scheduling is inferred. Final row diagnostics
record inherited CPU affinity and any deadline remains FAILED, never a detected
mutant. Five seconds is unchanged. Typed validation replaces per-row JSON work,
with fresh evidence at that exact source. They are bounded encoding diagnostics,
not numerical performance acceptance or a blanket scaling guarantee.

`python3 experiments/s-integrate/renderer-handle-run.py` isolates actual nominal
Data handles without asserting issued world authority. Every original handle in a
65,537-element input is checked, then the range expansion is checked independently.
Three last-handle changes (namespace, duplicate ID, wrapped ID) are rejected on
both backends. This isolates the codec from actual E11 dispatch. The reader worker
also identified a real W.publish stack fault before any renderer; its source repair
and full actual E11 replay are separate evidence, not results borrowed here.
