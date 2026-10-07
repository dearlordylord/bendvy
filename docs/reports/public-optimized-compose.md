# Optimized public Compose integration

Governing #30. Public provider implemented; performance/final review pending.

The [design](../design/public-optimized-compose.md) freezes concrete-v3 closure
`a4672d110446195e3ac92911c6f41166b62025811df8816878356d0eafd08a55`.
All29 archived hashes verify. The minimal selected handoff DAG has explicit module,
chunk and output provenance. Required/all-live source specialization preserves
actual owner evacuation/order/recovery while eliminating synthetic unused arrays.

The additive executor prepares caller-selected heterogeneous family Columns once,
uses the existing arbitrary Ops declarations and gameplay, finishes transaction
inverse recovery, then recovers the returned World's current/past/remaining owners.
Original Column constructors/API remain usable. Arbitrary Type Array and Data
families, aliases, stamps, cursor advancement and barriers remain supported.

| Current direct evidence | Observed result | Scope |
|---|---|---|
| Fresh actual pinned TS Workshop | Full23 equal expected reference | Actual Node24.20.0; reference commits checked |
| Source-bound copied Workshop JS/Native |22 exact TS points + approved foreign difference | Complete observations, including rollback/earlier commits/queues |
| Original/extracted generic handoff | Both Bend/JS observe7 | Real public affine Column owner |
| Original/specialized producer | Full3 Type Array owners, hole, ascending IDs equal on Bend/JS/Native | Finite producer equivalence, not universal refinement |
| Prepared control | `[[3,7],[41,43],[11,19],[3,7],[100,200],[3,7],[11,19]]` JS/Native | Alias replacement, old owner restore, ascending/reverse fallback, prepared growth |
| Refusal control | `[[41,43],[3,7],[11,19]]` JS/Native | Invalid ID returns incoming and both existing owners |
| Public access/schema/ownership controls |10/10 intended outcomes | Fresh source-current snapshot |
| Compiling active-owner omission | Complete-observation JSON gate fails at reached duplicate result | Actual JS/Native mutation execution, no checker/emission failure counted |
| JS emitted function entries |1920 Array-rmw vs2236 ordinary;1352 prepared swaps;140 recoveries | Transport proxies, not physical bytes or elapsed performance |

Reproduction and retained evidence are in the [experiment](../../experiments/public-optimized-compose/README.md).
`run.py` verifies complete source inventory before/after, retains outputs and generated
artifact hashes. Checker/runtime5, emission30, approved separate Clang19 compile120.
No new dependency, compiler/kernel/reference/external repository edits or laws/proofs.

The un-specialized all-five provider used3074 Array-rmw entries; its adverse
mechanism evidence is retained. Plan-specific family preparation and the exact
producer specialization reduce those costs without suppressing observations.

Current unchanged frozen regression gate, selected-provider versus fixed-baseline
paired timing and independent final reviews remain necessary for delivery.
This slice does not close full22/5x3 production qualification under #21/#24,
claim universal affine recovery, or select the old private nominal MainSlot carriers
as a universal public provider. No simplification is hidden as full-core completion.

## Independent integrated replay

The original scalar-control root replay is historical only; full-cell root replay remains required. Its receipt is retained in `experiments/public-optimized-compose/evidence/root/receipt.json`. This supersedes earlier source snapshots for the integrated correctness gate. Performance and final delivery remain separate.

Fresh root full-cell replay PASS: `experiments/public-optimized-compose/evidence/root-full-cells/receipt.json`. Independent Spec re-review resolves both former findings (full payload recovery and actual Native mutation execution). Integrated regression remains failed and must be repaired before delivery.

## Ordinary-provider regression diagnosis and repair

The unchanged frozen #28 gate rejected the first combined source: Native median
paired ratio1.2786,19/20 slower, with statistically confirmed slowdown. No baseline,
threshold or workload was advanced. A root-only copied-stage old-World-append
control retained complete outputs and gave raw Native19.63ms baseline,25.07ms
current,24.30ms old-append candidate; those five-sample medians are diagnosis only.

Read-only generated-C comparison exposes Column union transport widening:
147693 baseline versus314810 candidate C lines; global WL_RESW38 versus77;
maximum register slot41 versus80; ordinary COLUMN_RESTORE_STAMP_0 spin has37
versus93 C parameters. The new seven-field Prepared case becomes eleven native
Column transport slots, widening caller Store/World/Frame even on ordinary paths.
These structural observations support the mechanism; they do not prove exclusive
causation or establish a speed improvement.

The scoped repair preserves the original ordinary Column view as direct owned
Array transport: validate the same ID/size bounds, take with Array.swap, project
while retaining the actual Type owner, and restore with Array.swap. It avoids
ordinary temporary SwapOutcome/Column transport and an extra union dispatch.
Prepared owner access, metadata and exact selected producer/recovery are unchanged.
Fresh source-bound controls/mutation and the unchanged paired gate determine
whether this repair is deliverable. No compiler/kernel change or speed concession.

Subsequent unchanged prepared-provider regression gates still rejected the boxed
and direct-current variants. The direct-current single-Workshop diagnostic counted
745 prepared views, 2118 State literals, 1373 Owned literals and 1779 Prepared
literals: exactly 745 intermediate States and 406 restoration Prepared wrappers.
Constructor-literal evaluations are diagnostic events, not physical byte counts.
The current cohesive projection passes State fields directly, projects the actual
owner returned by the original seek, and restores it once without the second swap.
Backward access retains ordinary Array recovery/projection. Exact prior prepared
bounds (`id > 0 && id <= capacity`) remain unchanged.

The selected producer specialization now executes a typed Fetch/Taken phase loop
instead of a per-slot dynamic continuation. Fetch evacuates the same descending
Array index; Taken retains None or prepends the actual Some owner, preserving
ascending row order. Original supplied fuel remains in the phases; a separate
`2 * fuel + 1` structural gas bounds both transitions without changing the
producer's work. Exhausted Taken also returns its pending owner. The archived
original producer and extracted source provenance remain unchanged. Fresh complete
payload controls, original-versus-specialized observations, mutation detection and
the unchanged paired regression gate remain required for this variant.

## Prepared-route regression diagnosis

The reviewed fixed-baseline provider comparisons remain failed (receipts retained
in benchmarks/evidence). Whole ten-application V8 diagnostic profiles retain full
22-checkpoint outputs and generated source hashes in evidence/root-cpu-profile.
The sampled `f` is generated run_clo's trampoline wrapper (line129):8.06ms
candidate versus2.06ms baseline; GC samples approximately9.9ms each. This is
one exploratory profile per role, not a statistical speed result. The prepared
source also evaluates745 intermediate State constructors and406 restoration
wrappers per Workshop. Direct seek/project/restore and an explicit affine
Fetch/Taken evacuation phase target these mechanisms; no reduced workload,
small-row bypass, compiler change or relaxed floor is selected.

Current verification after Component's direct World destructuring:
`evidence/component-direct/receipt.json` passes six complete cases on JS/Native;
its source inventory still matches disk. Original-producer finite equivalence
passes both backends, and recovery omission remains `DETECTED_BOTH`. Exact hashes:
Column `b9bb79dabfff9553845ff769e106a7ae306346ad16ac2a67ad965c15930ffc38`,
Component `f37aa4e8758b8f4f4082744f902740d78c9ba8e02616141f8aa1b1be2735d34d`,
World `7d394b623b8bb60a3fef7b160bb69af135719edd3008126ee186e190047708f8`,
Local `8cc5b3c9d3597c60d8a1b9b7fd206a92b289669c3cd9a8575db65ce9af37bd47`.
Single-Workshop emitted-JS diagnostics preserve identical complete observations:
`run_clo` entries fall from 4625 to 3262 and `run_loop` entries from 2293 to 930;
constructor-literal evaluations remain 80727. These are source mechanism counts,
not timings or physical allocation bytes. Performance acceptance remains pending
the unchanged paired regression gate.

Fused transaction set verification (`evidence/fused-set`) uses Component
`4a378ec4aee020d06d04c0ff883911063c75f3a6afe9e278f6969e60d20dfb98`;
Column remains `b9bb79dabfff9553845ff769e106a7ae306346ad16ac2a67ad965c15930ffc38`.
Only `tx_set` selects the new internal owned operation; old public helpers and
journal inverse closures remain unchanged. It validates once, takes the typed
family once, captures the old stamp, and returns the actual old payload to the
same journal. Clock advancement on swap rejection and missing-entity precedence
remain explicit. Seven complete controls pass both backends, including paired
new/old-helper observations for foreign+clock-max refusal, valid clock-max refusal
and out-of-range Column refusal after clock advancement. These retain both cells
of incoming/old affine Arrays, stamp and exact queue/event/journal counts.
Original-producer finite equivalence passes; recovery omission is detected on both
backends. Full source inventory matches disk. Diagnostic observations remain
identical: lifecycle/swap/clock round trips each fall by 17, and constructor-literal
evaluations fall from 80727 to 80489. Runtime closure counts remain unchanged.
The unchanged paired performance gate remains pending for this source variant.

Read-only generated-code partitioning (`evidence/fused-set/generated-growth.json`)
records exact generated filenames/hashes: baseline 857 functions/327960 bytes,
fused candidate 1079/506372. Column function bodies grow from 38907 to 177490
bytes, about 78% of total growth. Counts partition at emitted top-level function
declarations and group specialization suffixes; they are code size, not runtime
allocation. Five concrete family specializations preserve their actual Type owners.
One V8 profile per frozen source validates ten complete application outputs
(`cpu-profile.json`). Sampling is sparse (35 baseline/59 candidate samples); no
recovery/List.reverse sample appears. This cannot establish a stable hotspot ranking
or performance acceptance. Actual candidate branch instrumentation independently
observes 650 discarded recovery ID-list Cons and 1400 recovery returns across ten
applications (`recovery-id-counts.json`). Removing that unused projection targets
observed work but is not claimed to explain the measured regression.

Owner-only recovery variant freezes Column
`32a81f541e475af8be98528431f6e83990b978490c48afbb751b096a250b79c5`;
extracted H remains `91f7e7f40877da928bb64e64a87ffd218a15e982afbc24199b8778cd4e7effec`.
`evidence/owner-only` passes seven JS/Native cases and complete recovery mutation
detection. Extended finite equivalence observes the archived producer/recovery's
three full Type Array owners, physical hole and original ordered ID output, versus
new full recovered physical cells. The new erased-Type helper emits one JS
function, entered 140 times per Workshop. Constructor-literal evaluations fall
from 80489 to 79939 with identical complete observations. Performance remains
subject to the unchanged paired gate. No erased-unseal conversion is active.

Isolated erased decoder variant freezes Column
`a4ab24d229590296c85940dc95de78d960c215a29e7c8811cf81b44ed0263cf2`.
Public template `unseal` remains compatible; internal operations select one erased
Type decoder. Seven JS/Native cases, including 64-deep Wrapped ownership/recovery
and refusal, extended archived equivalence, and both-backend mutation pass with
current source inventory (`evidence/erased-unseal`). Complete Workshop observations
and 79939 constructor-literal evaluations remain unchanged; erased decoder entries
are 1373, replacing five template decoder definitions with one emitted JS definition.
Installed guide describes erased binders versus syntax-substituted templates;
this preserves Type ownership and does not convert components to Data.

Native representation changes are real: `c-abi.json` binds emitted sources and
shows lifecycle2 decode returning eight Terms instead of ten, followed by a
three-cell `ctr_take`/`spare_free` payload unpack. Native C grows 204420 to 204752
lines; global return width remains 43. Erasure is not a free representation change.
The unchanged paired JS/Native gate must select or reject this isolated variant;
previous owner-only source is retained for exact rollback.

The erased decoder failed the unchanged paired gate and was reverted exactly to
owner-only Column `32a81f54`; its evidence remains historical. Same-work single
Workshop baseline instrumentation validates identical 23 complete observations:
72019 constructor literals versus owner-only 79939. Added work is principally
prepared State/carrier and evacuation/seek protocol construction; Array RMWs fall
2236 to 1920, while schema Store literals rise only 1366 to 1435.

Owned seek refinement freezes Column
`5eed33d40d4d9231bd9884c843ae8bc72f16a9d27a216727fb03cc492bd6f7f1`;
Component stays `4a378ec4aee020d06d04c0ff883911063c75f3a6afe9e278f6969e60d20dfb98`.
An internal typed Ready/Compared phase holds the actual row's affine fields across
comparison. It avoids reconstructing the same HandoffCon simply to evaluate two
booleans; equality returns its actual owner, advance moves it into History, and
before/exhaustion reconstructs the necessary returned row. Original public
SeekPhase/seek signatures and two-step fuel behavior remain compatible.
`evidence/owned-seek` passes eight JS/Native cases, including 48 paired old/new
full-owner observations for partial fuels 0–5, targets 1–4 and all Choice boolean
combinations; extended archived producer/recovery equivalence and mutation also
pass. Complete Workshop outputs remain identical; HandoffCon evaluations fall
1035 to 550 and total literals 79939 to 79454. Global Native return width remains
43, maximum bank register 51 and maximum spin arity 71. Emitted C grows 183 lines
and JS 3670 bytes; reduced constructor traffic is not a timing result. The paired
performance gate remains required.

The owned-seek variant failed the unchanged paired gate and was reverted exactly
to owner-only `32a81f54`; failed observations remain retained. A proposed structural
Array producer was rejected before implementation: selected Base source indexing
is tree-recursive, but pinned emitter `comp.ts:1743` lowers Native swaps to direct
block offsets, and `comp.ts:6014` uses direct JS array indexing. Structural ANode
matching instead emits JS slice copies (`comp.ts:280`) and Native half-block
splitting (`comp.ts:4064`), with concat/block joining on reconstruction. Source
Base.size derives capacity from left depth, so irregular interpreter trees also
cannot be treated as flat physical-leaf order. JS array_node and Native blk_node
reject unequal compiled child sizes. No tree specialization is active.

Computed-tuple direct recursion was rejected by the unchanged checker; candidate
and refusal remain under `evidence/direct-evac-rejection`. The legal pending-swap
loop instead matches original fuel and the already-fetched Array.swap tuple in one
head. Zero remaining fuel still processes that last owned payload; successor fuel
processes it and fetches exactly the next descending index. It introduces neither
Fetch/Taken phase objects nor a per-slot continuation. Original exported reusable
fuel/affine ID quantities are preserved by a narrow start helper, and the original
phase API remains available. A client explicitly assigns the original function type
and executes the producer through it.

Current Column freezes at
`aca582faa4fdc3ba57686c25310c4cb924a608fe919d4ea3d90a9909929e37a0`;
Component and extracted H remain unchanged. `evidence/pending-wrapper` passes eight
JS/Native cases, extended archived producer/recovery equivalence, recovery omission
mutation and all ten access controls. The producer control compares 42 pairs of
partial/full fuel and starting IDs (including zero, size and wrapped indices),
observing complete row payloads, retained physical cells/holes and an initial owned
row. Inventory matches the final source. Emitted JS has five direct pending loops,
zero per-slot run_clo or phase literals. Complete Workshop observations remain
identical; constructor literals fall 79939 to 77727, removing 2212 phase evaluations.
Native global return width 43, maximum bank register 51 and maximum spin arity 71
remain unchanged. These source observations are not performance acceptance.

An additional checker-accepted unequal Array node probe is refused by the installed
Bend runtime before any comparison (`evidence/irregular-runtime-refusal`); it is a
recorded runtime limitation, not positive irregular-array equivalence. Pending
extraction retains the original Array.swap indexing and makes no tree-shape
assumption. The unchanged paired JS/Native gate remains pending for final source.

Dense diagnostic profiling uses the same frozen ten-app source in a fresh function
scope 20 times per role (200 apps), CPU0, five-second cap. Every original output is
validated; only exit(0) is intercepted, with 20 completed iterations/zero exits.
Exact source/wrapper/profile hashes and commands are retained in
`evidence/warm-diagnostic`. Timeline audit records first iteration 110858/133622 us
and remaining 19 totals 822737/865665 us, baseline/candidate. These are one
exploratory pair, not performance acceptance. Sampled Column self time grows
37017 to 136074 us while Component falls 82044 to 53702; GC is 89472/89219.
Both cold and warm phases include extra Column transport. Array/schema work also
moves between stacks; these profile attributions do not prove individual causal
speedups or a GC advantage.

View-seek fusion freezes Column
`869091a81636ece3b6d8fd37bae552bcb58b76c7d3ea396e8ecdb9e6f4eeb032`.
`evidence/view-fusion` passes nine JS/Native cases, extended archived equivalence,
recovery omission mutation and ten access controls with current source inventory.
The added 51 paired old/new view observations cover partial fuels and targets,
Nil precedence, and a legal projection that changes its returned affine Array.
They verify both Data snapshot and actual recovered projected owner. Component.has
and selector projection behavior remain unchanged; the type C -> C & V provides
no universal owner-identity guarantee that would permit skipping those calls.

Complete Workshop observations remain identical. Constructor literals fall
77727 to 74817; temporary view restoration decodes disappear (unseal 1373 to 967),
prepared_swap falls 584 to 20, and view-specific seek executes 564 times. Recovery
140 and Array RMW1920 stay unchanged. Native return width43/register51/spin arity71
remain unchanged; JS grows from522660 to539775 bytes. These mechanisms still require
the unchanged paired gate; code growth and JIT effects are not waived.

### Owned Component.get validation/store fusion

The preceding view fusion failed the unchanged prepared gate (JS1.1364655,
Native1.0278109, confirmed slower). Its source remains retained. Component
36969e291b40f5bdc091ef657011c2cf22595d84b98b7664e7b46d033b9b0c0f
now destructures World and Handle once, tests the identical metadata predicate,
and reads Array.get(Bool,live,id) only after metadata success. The returned live
owner reaches either MissingEntity or unchanged get_store. Every final World
field is threaded exactly; admitted mutating family projections remain invoked.
Public get/get_allowed quantities and the old comparison path are unchanged.

Evidence/get-fusion passes ten JS/Native cases, archived producer/recovery
equivalence, recovery-omission mutation and ten confinement controls. The48 records form24 old/new pairs; observations cover foreign same-ID, zero/unreserved/reserved/dead/live,
ordinary/prepared and unchanged/mutating projection; payloads, live flag, world
metadata and event/pending counts are observed. Queue payloads are preserved by source threading; these counts are not a full queue-payload trace. These are finite observations.

On the identical complete Workshop, literal evaluations fall74817 to69795 and
World literals4403 to1893. Old get_allowed/get_world are no longer reached; new
metadata helper1256/live helper1255 execute. Validity helpers remain for other
APIs. Counts are source-bound mechanism observations, not timing acceptance.
The unchanged paired regression gate remains pending.

### Getter-source cold/warm diagnostic

The getter fusion unchanged cohort still confirms slower JS (1.1194935); Native
.9989071 is unconfirmed. Evidence/get-warm retains a fresh20×10 CPU0 profile and
per-iteration timeline for that exact source, every200 application outputs
validated per role, five-second runtime cap. The single exploratory pair has
first137950/145123µs and remaining19 totals912900/909720µs (baseline/candidate).
It does not establish a warm win or that regression is entirely cold. Column
sampled self42533/196784µs remains elevated; GC127309/77988 is exploratory.
Generated JS327960/524167 bytes and857/1083 functions include five copies each
of metadata/live wrappers5125/5539 bytes and seek_view19189 bytes. Bytes and
samples are not physical allocation or performance acceptance.

Proposed bounded follow-up: share only metadata/live validation on Array<Bool>,
with metadataFalse returning the unchanged live owner without reading it and
metadataTrue using the exact Array.get(Bool,live,id). Existing get_live_owned
would retain all World reconstruction and family projection. No erased generic
Store/C/World owner is introduced. This proposal is not yet implemented.

### Shared Bool-array validity reader

Component0e41557cc6b8101490eaa7f4bf5fbdf896a2646e9b2359d7daf41db6de45988c
adds non-template get_live_read(allowed,id,live). False returns the original
live Array and False without Array access; True calls Array.get(Bool,live,id).
Public get sends this result directly to existing get_live_owned. Legacy
get_metadata_owned/get_live_owned signatures remain intact. No schema, Store,
component payload or projection passes through the shared helper.

Single Workshop JS emits one three-argument reader, invoked1256 times, and no
reachable metadata-owned wrapper. JS547605 to542996 bytes; literals69795 to
69796, Native return width43 unchanged. This is a bounded transport-sharing
mechanism, not a timing claim. Evidence/bool-read passes ten JS/Native cases (including24 old/new getter
pairs), archived producer/recovery equivalence, reached recovery mutation on
both backends, and ten confinement controls. Source inventories match. The
unchanged paired performance gate remains pending.

### Carrier-to-view operation fusion

Columnb742477e821b3e7807d36bfbe46dc38ef89142dece5c2517d5cb28b64d32070b
adds prepared_view_carrier, directly decoding Owned{State{seven exact fields}}
to the existing checked operation, and tail-recursing over Wrapped without a
depth limit. Ordinary view and exported helpers remain unchanged. Evidence/
carrier-view passes ten JS/Native cases including deep Wrapped and24 getter
pairs/mutating projections, archived equivalence, reached mutation on both
backends and ten confinement controls; source inventories match.

Actual complete Workshop dispatch: prepared_view_state745 to0, unseal967 to222,
new carrier745. Literal evaluations remain69796. JS emits five carrier loops
and grows542996 to544356 bytes. Native width43/register51 remain unchanged;
three concrete carrier entries have FID_T(2,0,2). Precision: old Native decoder
and state helpers already lacked standalone FID entries; the new carrier has
explicit dispatch entries. Source fusion does not establish removal of a
separate emitted Native State-return call. Unchanged paired gate is pending.

### Additive owned-row provider: first correctness checkpoint

The copied owned Workshop now matches all 23 original observations on JS and
Native. Fourteen finite old/new provider pairs separately cover actual mutating
projection returns, foreign/dead/zero handles, captured-slot refusal with growth
bridge, repeated writes, clock exhaustion and rollback after two distinct writes.
Rollback restores actual predecessor payloads and stamps while preserving the
original clock advancement. Queue/event observations in these pairs are counts;
they are not complete queue-payload traces.

[Source-bound receipt](../../experiments/public-optimized-compose/evidence/owned-provider-first/receipt.json)
and full output evidence are retained. A compiling omission of the actual row
owner at restoration changes full observations on both backends. Actual JS
instrumentation validates complete outputs and reaches 195 captured extractions,
195 prepared restorations, 197 live-array checks, 180 selected reads and 17 writes.
These counts are not allocation bytes or performance evidence. Emitted Native
whole-Workshop result width remains 43 words.

The restoration closure is affine (matched positive passes; duplicate invocation
rejects). Exported raw constructors are forgeable: restoration safety applies to
capture-produced tokens preserved by trusted provisioning, with concrete `H`
unavailable to universal gameplay. The independent larger seek matrix,
confinement replay/reviews, matched CPU/allocation/GC profiles and unchanged
ordinary/prepared statistical gates remain required. No performance or full-task
acceptance is claimed.

The unchanged benchmark overlay must copy only schema/declaration provisioning:
use `owned-declarations.bend` as staged `declarations.bend`, with `owned-rows.bend`
and exact original `reference-declarations.bend` as allowlisted helper files.
Keep frozen main/driver/gameplay/observation bytes unchanged. The separate
owned-main/owned-driver files are correctness fixtures, not replacement benchmark
workload files.
