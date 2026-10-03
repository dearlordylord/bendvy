# T03 reproducible negative experiment

Issue [#4](https://github.com/dearlordylord/bendvy/issues/4), parent [#1](https://github.com/dearlordylord/bendvy/issues/1), [SPEC](../../docs/SPEC.md), task base `74e48cd44825a3a306c04900ec33bc1509d54f4a`. GitHub bodies read with `gh issue view {1,4} --json body,title`. Applied `/home/node/.codex/skills/bend-ldd/SKILL.md`; `bend version` and `bend guide` run before Bend edits. Date 2026-10-03.

**Report complete; T03 capability gate FAILED.** This is a bounded negative result for a constructor-based access API, not an impossibility theorem about Bend. Dependent implementation/proof work remains blocked pending redesign. No data-only product restriction, law approval or performance acceptance is claimed.

## Reproduce

Run `experiments/t03/run.sh` from this worktree. Requires the existing pinned references at `/workspace/formal-proofs/bendvy/.references/{bevy-ts,bevy,bend2}`, Node v24.20.0, Bend 2.0.34, clang, timeout and rg. No packages installed. Script checks all reference HEADs against tracked sources.json and the T01 Base hash; it reads the guide and checks every Bend invocation through the existing five-second wrapper. Build directory is removed on exit. Native CPU uses one worker, GPU off; JS uses Node single event loop. Compilation is separate from compiled runtime. This is not a timing workload.

Observed command: `experiments/t03/run.sh`, exit 0 means **reproduced negative report**, not acceptance of the failed capability gate. Environment: Debian clang 14.0.6, Bend 2.0.34, Node v24.20.0. Normalized final outputs from TS/native/JS:

```text
6,2
11,3,1
```

Inputs: one Motion entity Position=0, Velocity=2; one Health entity HitPoints=20, Damage=3, Armor=1. Three executions of the same closed system template update only Position/HitPoints; Velocity/Damage are supplied as read-only values, Armor is retained outside the callback. Schemas differ in component composition (two versus three). Storage is an affine Type; component values are U32 Data. No world is supplied to the callback. Closed template substitution permits repetition without duplicating an affine closure. The initial prototype used computed destructuring in a match branch; checker rejected it, and dedicated return helpers fixed that language error before acceptance checks.

`reference.mjs` imports the pinned core directly with Node and executes public spawn, deferred barrier, query read/write, and the same Step value three times. It records the final read-only query only. This is a newly observed bounded variant of R2, **not full R2**: no optional/tag membership, multiple entity order, lookup mismatch or intermediate/read-your-writes checkpoints are claimed. TS adapter setup includes structural commands; Bend explicitly initializes one row and compares only the component-update phase. No full ECS query membership implementation exists in this probe.

## Negative evidence

- `read-write.bend` fails rc=1 at main: expected A.WriteMotion, observed A.ReadMotion. `control.bend` succeeds after replacing only the capability constructor.
- `undeclared.bend` fails rc=1 at bad: expected A.WriteMotion, observed A.ReadMotion. `undeclared-control.bend` successfully reads its declared capability.
- `cross-schema.bend` fails rc=1 at main: expected A.MotionToken, observed A.HealthToken. `cross-schema-control.bend` succeeds with MotionToken.
- **Planted bypass `forge.bend` succeeds** and outputs `99` on native and JS: exported constructors let `bad(c: ReadMotion)` read c and fabricate MotionWrite before calling write. The system signature claims only read input but returns a fabricated write grant. This demonstrates absence of an unforgeable authority boundary; it does not demonstrate mutation of an independently stored world. The prototype must not be promoted to the requested public capability API.

Runner asserts verdicts, exit statuses, intended expected/observed types, exact outputs and backend/reference equality. `ALL PROOFS CHECK` on these files is ordinary checker wording; they contain no ECS laws/proofs. [Candidate statements and falsification status](CANDIDATE-LAWS.md) are saved before proof work. No ECS proof was written.

## Immediate bounded redesign decision

Reject ordinary exported datatype constructors as sufficient authority evidence. Investigate a capability with no live constructor available to application systems, while retaining ownership and a trusted provisioning path. Base uses constructor-free opaque laws for IO handles (`base.bend` lines 94 onward); that fact alone does not establish a safe user-defined provider, and an unfilled law cannot be called by live code. Do not add unsafe/foreign authority constructors to get a passing proof. Alternative experiment: an explicitly checked declaration/action representation interpreted inside storage orchestration, with schema-indexed selection and updates; this must still support required repeatedly executable systems and reject undeclared actions by intended type errors. It is a proposal, not an approved replacement of arbitrary callbacks or a new dependency.

Return gate: a candidate provider must reject this reconstruction bypass and direct negatives, with positive controls, then run two compositionally different schemas through actual declared capabilities on native/JS and full agreed reference checkpoints. If no safe provisioning path can be established, request the exact specification decision: whether a checked action representation satisfies the system contract, or whether compiler-level opacity is required. Neither option is silently adopted here. T04/T06/T11 implementation/proof work cannot treat this report as passing access authority.

## Follow-ups and limits

- Open: capability redesign above; return before fixing System/Schedule/query APIs. No language-wide impossibility claimed.
- Open: full R2 ordered multi-entity/optional/lookup/intermediate observations; return after redesigned authority API. Final-value matching is narrower evidence.
- Open: affine Type payload access and ownership/update/rollback cost (T04/T06); Data payload slice is experimental, not approved product scope.
- Open: arbitrary captured system state, composition, provisioning and errors; closed templates avoid affine repetition issues but do not resolve these contracts.
- Open: dense/sparse arrays, query membership and scaling; one-row explicit records are probes, not approved storage design. Return with actual storage architecture and representative workloads.
- Open: mandatory native substantial speedup and JS comparable performance, memory/scaling and agreed numerical thresholds (T10). No performance ratios or thresholds asserted here.
- Open: specific law approval, expanded falsification/planted mutants, model versus executable proofs and runtime refinement (T11); no universal correctness result inferred from finite traces.

No changes to references, master, DALPH.md, coordinator state, original jev/dalph or new dependencies. Node direct import resolves the narrow adapter need without T02's proposed test-toolchain installation. No Dalph execution problem observed.
