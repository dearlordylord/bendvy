# #19 fresh public TS main trace — E0–E10

**Four complete reference lanes pass the frozen E0–E10 expectations with zero
differences:** Motion/Health × returned-owner/regenerated-closure capture behavior.
Each lane creates two actual same-schema runtime worlds, executes the public
nested dispatcher and preserves every declared payload/resource field in checks.
This is fresh TS evidence; no integrated Bend subject or proof is implemented.

## Reproduce

From the repository root, using the existing Node v24.20.0 and no dependencies:

```sh
timeout 5s node experiments/s-integrate-trace/reference-main.mjs
# Optional independently limited per-schema runs:
timeout 5s node experiments/s-integrate-trace/reference-main.mjs --schema Motion
timeout 5s node experiments/s-integrate-trace/reference-main.mjs --schema Health
```

The full run and a fresh repeat both exit0 with exactly identical JSON. Both
per-schema invocations exit0 and match their full-run results. Each invocation
uses a five-second limit. `main-evidence.json` is compact JSON preserving full
ordered observations, not a count/checksum summary; format it with Python's
standard `json.tool` if needed. Its source/adapter/trace hashes pin the run.

Reference: bevy-ts `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`, checked against the
tracked source manifest before execution. Governing trace:
`docs/design/s-integrate-trace.md` at task baseline `f6ef46c`; its SHA256 and the
public API/Runtime/world/stream source hashes are recorded. References and the
original `/workspace/typescript/jev` stay read-only.

## Actual coverage

Each lane records 19 Fast/B reads, 34 ordinary α/β snapshots, 29 α dispatcher
results, all raw reservations and five complete own-write observations. Both
readers are the same base system objects throughout; nested schedules never
replace B with a new instance. Ordinary snapshots have no lifecycle/event reads
and cannot advance the test readers. Capture arrays finish A=`[1,0,0,0]`,
B=`[9,0,0,0]`, Fast=`[10,0,0,0]`; both tails finish2.

| Steps | Fresh observations and assertions |
|---|---|
| E0/E1 | Empty ticks invoke nobody; pending reservations stay missing; explicit barriers expose a/b/c/z; complete required/present/absent/optional queries, Aux-only c and mismatch lookup agree. Fast/B priming, seed additions and beta fields are checked. |
| E2/E3 | A commits a.slot0=11 and Ledger101. B sees the expected retained seed/A tuple, reads its own b30 then50 and Ledger201, escapes q, performs the real Audit service operation and fails through the nested schedule. Tail does not run; b restores20, Ledger restores101, A's pending work survives, Fast sees no leaked changes/events. |
| E4/E5 | The same B retries with the same prior reads, commits once and publishes code2. B's post-run self-event and absence of same-run changed visibility agree. FIFO barriers expose p/r and the correct Flags; empty ticks/barriers preserve membership. Raw α IDs are a1/b2/c3/p4/q5/r6/s7; β z1 collides. q remains missing and r follows the consumed q ID without reuse. |
| E6/E7 | Actual Off/On next-state systems and transition markers drive B skip, failure and retry. Fast sees p51 plus retained a/b removals and b despawn. B is skipped without capture increment, later fails/retries with identical retained lifecycle records and no skipped code3 backlog; Fast's cursor remains independent. |
| E8/E9 | Ordered insertion yields a81/c30/p71/r60, existing p is changed but not added, dead b stays missing. Disposal reports exact removal/despawn log order, empties α including Aux owners' public membership, and subsequent s is fresh. Every β query/resource field stays unchanged. |
| E10 | Public same-schema foreign lookup resolves the receiving world's colliding entity in both directions: α.a→β.z90 and β.z→α.a10. This is recorded separately from approved Bend MissingEntity divergence. Fresh missing-Ledger and missing-Audit runtimes use `tryTick` on the **actual same A/Fast/B/Tail nested E2 system objects**; exact MissingRuntimeRequirements entries agree and no callback, tail or Audit effect occurs. Fully provisioned E2 returns exact B/code7 failure. |

Main/Aux arrays, all schema-specific metadata, Flags and Ledger totals/epoch are
asserted, including Aux-only rows and optional absence. Added/changed rows carry
complete current Main values; removed/despawned records preserve real numeric
IDs and log order. All known handles are checked at snapshots. The expected
source tuples were not replaced with observed constants: every E expectation is
asserted freshly and `differences=[]`, `defect=null` is required for exit0.

Main and resource mutation use public `.set` with fresh complete objects/arrays.
No in-place aliased payload mutation, debug dump, internal counter or fabricated
cell/world implements an observation. Real declared Audit `.log` calls append
host effects during A/B execution; failed B's effect persists. Those are actual
TS service effects, not post-hoc diagnostic strings.

## Limits and retained work

The two JS capture styles reproduce the specified invocation behavior; they
establish no Bend affine checker guarantee, Type returned-owner contract or
noncopyable rollback. Two distinct nominal schemas are instantiated, with two
public TS runtimes each; a Bend trusted threaded factory/root authority is not
claimed from TS construction.

Event lag is read through the public event view's `lagged()`. Removed/despawned
views expose no direct public `lagged()` method here and are explicitly marked
`unavailable-public-api`. The runtime is now actually made with `debug:true` and
its public `runtime.debug.observe` listener captures every Fast/B `system` event:
raw frame/tick, outcome and `missed`. Each event is associated with its actual
callback's step, reader and invocation count, including both failed B attempts.
All 19 reader invocations per lane have a matching diagnostic; `missed=[]` is
asserted for every one in this non-overflow fixture. Failed B events report
`failed`; all successful reader events report `ok`. This is passive public
lifecycle/event lag provenance, kept separate in `traceDiagnostic` and
`readerDiagnostics` from actual removal/despawn/message values and callback
`events.input.lagged()`. No cursor/state introspection is used. Nondeterministic
`ms` is excluded; raw deterministic frame/tick values are preserved. Fresh full
four-lane and repeat runs pass with exact diagnostic/evidence/hash equality. E11 capacity/overflow
is separately assigned and is not implemented or passed by this package.

Native/JS Bend parity, ownership/access/reconstruction/destructive-recovery
negative controls, Type disposal guarantees, indexed relocation/map checks,
foreign structural command policy, universal refinement and performance remain
future capability gates. No new laws, dependencies or production policies are
approved by this finite reference execution.
