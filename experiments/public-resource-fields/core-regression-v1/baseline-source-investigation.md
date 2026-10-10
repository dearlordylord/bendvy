# Frozen #28 baseline checker: source-only investigation

Public promotion remains blocked. Original51961 and pinned CPU11 control92222
reach the unchanged five-second checker deadline. Neither produces a timing
pair or a regression decision. No checker/compiler/performance child was run
for this investigation; no baseline, cap, helper or core source was changed.

## Established facts

- Governing root PLAN selects baseline commit
  `327bec49d41f00f88950343dea1edc1e0ec97dc4`; exact archive digest is
  `567e1e0e7d27a4c111791fcd89f9afc84e301c008741a323de258b5ca1e793e3`.
  `benchmarks/run.py:110–119` extracts that archive for baseline and candidate;
  only the candidate's src/ecs is replaced. Baseline checker runs first (:170–173).
- Recursive local import inspection of the failed baseline timing-main finds
  19 files,152671 bytes,507 def lines and74 type lines (syntactic counts, not
  compiler specialization counts). Every file stays inside the frozen baseline.
  None imports the three candidate resource-field modules. All19 import Base,
  but loader realpath deduplication prevents19 independent Base loads.
- Entry digest `a7fea467df249864772e4be3e229342cddd2e457bed6fb596f28e224b203fbb6`
  matches BASELINE-PINNED-CONTROL; its CPU11-affinity attempt lasted5.24486s and
  returned null exit/child deadline, unchanged entry. Empty output identifies
  no specific compiler stage.
- Current installed `/home/node/.bend/bend2/base.bend` and pinned reference Base
  are byte-identical:71530 bytes,
  `c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661`.
  Binary symlink resolves to installed bend-2.0.35. This current source equality
  does not retrospectively establish all historical tool/environment identities.
- Historical receipts use the same baseline archive and report Bend2.0.35:
  `benchmarks/evidence/ordinary-system-combined-regression-v1/receipt.json`
  records baseline checker0/635.280731ms; `world-io-core-regression-v1/receipt.json`
  records0/600.864162ms. These are retained successful observations, not a current
  pass or proof that present tool/environment equals the historical execution.

Historical receipt hashes: ordinary-system `04d020be22dc2255ddb15263863ff93bbfea4bb3793c6e99b70643e22b119037`; world-IO `1c432eccb83bb1524706788cace0cea300dee1ed4766c85efddef81d7c8d6257`. Both record CPU5, the same entry digest and version strings, but neither receipt records full environment or executable hashes. Current PLAN uses sanitized env/PATH and CPU11. The pinned benchmark runner calls os.sched_setaffinity(0,{args.cpu}) before launching children, so the original checker inherits CPU11 even though its argv has no taskset wrapper; the separate control sets CPU11 explicitly through taskset. Lack of a wrapper does not mean unbound affinity. Path relocation changes imported nominal names; Base/config/environment and host state are not proven historically identical.

## What the pinned source explains

Pinned Bend `bend2/main.ts:299–304` calls book_read before the check-only verdict.
`book_read:801–821` loads imports then calls book_valid; `bend.ts:952–1013`
resolves/deduplicates realpaths and parses every imported module. `book_valid:3804`
checks declarations across book.order; it is not main-reachable-only validation.
The CLI emits its verdict only after these stages (`main.ts:715`). The ten IO
iterations in timing-main run neither during --check-only nor in this failed
attempt. Code generation/runtime are later benchmark stages, never reached.

Thus current failures are not evidence that #70 core additions enlarged baseline
source, that its ten applications ran slowly, or that emitted native code failed.
A cold process/Book check includes runtime startup, loading/parsing, whole-Book
validation and verdict work. The retained receipts do not locate the stalled
phase or divide five wall seconds into CPU execution, scheduler wait or IO.
External contention remains plausible, not established causation; compiler
normalization/host/runtime effects also remain unmeasured hypotheses.

## Cheapest useful changed diagnostic (not executed)

Under coordinator approval, retain the exact frozen entry/tool/environment and
five-second cap but capture process CPU/scheduler accounting (for example /proc/PID/stat CPU ticks and schedstat run/wait, sampled by a read-only external observer) and file-access
progress for that single diagnostic child. Use the existing task_runner child and unchanged command/cap; observation must not replace its kill/receipt ownership. A same-cap syscall/scheduler trace
can distinguish waiting/startup/import progress from sustained checking; it is
diagnostic evidence, not a gate verdict or timed benchmark. Avoid loading a
copied compiler or changing workload first. If phase instrumentation is needed,
a separately pinned copied compiler can mark book_load/book_valid/verdict only,
with its result explicitly excluded from stock acceptance. Do not infer a
performance fix or launch another unchanged blind attempt from this report.

Source correction: the selected benchmark runner SHA-256 `019071ae` (prefix) establishes inherited affinity before task_runner execution. The planned external observer therefore reproduces the original checker argv and parent CPU11 affinity, rather than substituting the separate taskset control. This corrects the earlier affinity description; neither timeout establishes its cause.
