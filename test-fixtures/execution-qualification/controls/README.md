# Canonical collector orchestration refusal controls

DRAFT, NOT ADMITTED, NOT EXECUTED. These controls invoke the current source-bound canonical
`collect.py`, with disposable copies of its four existing helpers. They exercise
actual collector orchestration, rather than calling ReceiptBoundary in isolation.
Control workloads use the frozen `child.py` under the existing Python 3.11 binary;
selected infrastructure regressions use small Python children and pure fixtures.
No Bend, Node, native ECS consumer, instrumentation, dependency install or network
request is included. The collector preserves the GH80 optional diagnostic hook but now compiles each
consumed helper's frozen source bytes instead of consulting bytecode caches. It
and the repaired Runner are successors to worker source
`99b51d4b20d47f5b525b8803f803586d796d8948`; the other three helpers match
byte-for-byte. The old worker plan is stale for both collector and Runner and
requires a rebound successor and independent review before consumer launch. Controls omit `workerDiagnostic`, exercising the same
current orchestration without invoking instrumentation or the optional validator.

The data shape is twelve fixed instances of nine refusal families. Source/helper
and environment/interpreter-flags variants remain separate so bootstrap paths do
not mask one another. Each instance has its own exact plan, synthetic inner
approval fixture, resources, artifacts, raw logs and terminal receipt. The inner
approval fixture is test input; it does not authorize execution. Only independent
outer admission of the exact manifest permits the harness launch.

| Instance | Injection and required result |
| --- | --- |
| source-drift | Append to disposable frozen source before entry; no commands, INCOMPLETE. |
| helper-drift | Append to disposable Runner before entry; no commands, INCOMPLETE. |
| environment | Add one environment key; no commands, INCOMPLETE. |
| interpreter | Plan deliberately selects another pinned executable as interpreter; actual Python launch refuses before commands, INCOMPLETE. |
| interpreter-flags | Omit `-I`; no commands, INCOMPLETE at pinned interpreter flags check. |
| wrong-approval | Inner approval selects all-zero digest; no commands, INCOMPLETE. |
| nonzero | Child flushes both streams then exits7; retain exit7, both raw streams, INCOMPLETE. |
| artifact-drift | Produce/register value, mutate it in second stage; hash changed bytes, INCOMPLETE; third consuming stage never executes. |
| input-drift | Child changes isolated resource token then exits0; retain actual exit0 and both raw streams, postguard refusal, INCOMPLETE. |
| oracle | Child exits0 with complete stdout differing from frozen independent literal; preserve actual exit0, both streams, INCOMPLETE. |
| cancel | Child flushes both streams and records its PID/start identity, then SIGTERMs its exact collector ancestor; owned child must terminate and both partial raw streams plus terminal command metadata must persist, INCOMPLETE. |
| receipt-failure | Child creates directory at receipt destination; actual raw streams persist and collector raises publication error; outer terminal evidence records UNPUBLISHABLE, never invents inner receipt. |

The cancellation control is normative. The admitted v5 run failed this requirement: cleanup succeeded but terminal
metadata and both raw child streams were lost. The v7 Runner source repairs that
path by receiving the owner's actual terminal result during bounded cleanup,
retaining Popen wait status and recording raw streams before rethrowing interruption. That is a control FAILURE, not an allowed empty-log outcome. The
harness continues remaining cases, records each actual collector exit separately
from semantic verdict, and ends INCOMPLETE/nonzero if any required observation is
missing. A reviewed repair and a preserved successor would then be necessary.
The optional diagnostic hook behavior is preserved; the collector loader bytes
and Runner changed. Both remain unexecuted pending review 3. Publication failure intentionally
cannot promise an inner receipt; the outer receipt and raw collector traceback
are the terminal evidence. Unwritable outer destination/SIGKILL remain exceptions.

Preparation copies only disposable files and hashes inputs; it launches nothing:

```sh
python3 test-fixtures/execution-qualification/controls/prepare.py \
  --root /tmp/bendvy-gh77-evidence \
  --destination /tmp/gh77-collector-controls-v7 \
  --current-source-commit EXACT_CONTROLS_COMMIT \
  --worker-root /tmp/bendvy-gh80-worker-evidence \
  --tool-snapshots /home/node/.claude/orchestrate/bendvy-gh78-94/evidence-plan/tool-snapshots.json
```

The prepared manifest pins the package, plans, synthetic approvals, Python,
ldd/taskset, discovered Python ELF libraries, Python stdlib, host library directory
and loader configuration inventory. Its Python-only ToolPins baseline is a pure
projection of the existing retained discovery snapshot, retaining original raw
ldd bytes and environment. Each actual collector re-verifies it through unchanged
ToolPins before/after commands, retaining fresh raw probe logs. This projection
is not new discovery or a claim that prior ECS evidence qualifies this collector.
Source and resource mutations are restricted to the new disposable case roots.

Independent GH80 launch review must bind manifest SHA256, all sources and plans,
this oracle table, imported discovery, environment, finite budgets and current
heavy-owner terminal state. Admission JSON must have `manifestSHA256`,
`verdict: "APPROVED"`, review report pointer, and `prerequisitesSatisfied` equal
to every manifest prerequisite string. Do not generate an approval as preparation.
After that independent admission only, the exact launch command is:

```sh
env -i HOME=/home/node PATH=/usr/bin:/bin LANG=C.UTF-8 LC_ALL=C.UTF-8 \
  BEND_NO_TELEMETRY=1 BENDVY_CLANG19_ROOT=/tmp/bendvy-clang19-diagnostic/root \
  /usr/bin/python3.11 -I -S -B \
  /tmp/bendvy-gh77-evidence/test-fixtures/execution-qualification/controls/run.py \
  --manifest /tmp/gh77-collector-controls-v7/manifest.json \
  --admission /absolute/independent-gh80-control-admission.json \
  --output /tmp/gh77-collector-controls-v7/results
```

Per child cap5s, case cap40s, outer per-collector cap55s, twelve serial instances.
The collector alone owns the shared heavy lock; no outer nested acquisition.
The harness uses the existing Runner/Inputs/CommandLogs/ReceiptBoundary. Output
must be fresh. Preserve every failed attempt; preparation requires a fresh root.
Passing these finite controls grants no consumer launch, issue acceptance,
performance, concurrency, or law approval claim. ECS workload freezing is separate
and still needs current source, complete independent oracles and launch review.

## Review 3 regression sequence

Preserve the failed v5 packet and unexecuted v6 packet unchanged. Before controls, independently admit the
changed Runner and regression source. The existing infrastructure test entry
needs no new test framework. Its exact fourteen selected test names and argv are frozen in the manifest's
`regression` field, with cap120s. The v7 harness runs that command through the
existing Runner first, preserving `runner-regressions.stdout/.stderr` and actual
terminal metadata. It then executes the twelve normative collector controls.
A regression failure stops before controls and retains INCOMPLETE. This whole
sequence requires independent review 3 before execution.

Tests require original interruption identity, actual -SIGKILL child exit, both
binary streams larger than a pipe buffer, child cleanup, immutable publication,
concurrent input-guard failure and preserved secondary errors. Selected existing
ownership/deadline/concurrency tests remain included; the timeout assertion now
requires actual killed exit instead of absent status. The cancellation control
also requires actual -SIGKILL exit plus the owner's cancellation failure metadata.
No consumer is admitted by this sequence. All twelve normative outcomes remain
required before considering a separately rebound worker successor.

Review 2's two findings are addressed together: the regression wrapper records
`error.result` metadata when available, retains the original exception, and always
indexes available raw logs before propagation. The outer boundary refreshes the
log index on every terminal path. No result is invented when absent. A pure
receipt-assembly regression covers nonzero, deadline, cancellation, publication,
postguard and result-less failures.

All local helper loaders in the harness, collector (including optional validator)
and regression entry compile the read source bytes directly. They verify the
consumed bytes against the frozen manifest/plan, register modules during execution
and restore prior registration on initialization failure. The regression entry
receives `--source-bindings` selecting this manifest, preloads the actual Runner,
then loads logs and source checker; the checker's Runner import resolves to that
registered module. Helpers/validator otherwise import only standard-library
modules from the frozen host inventory. Harness, collector, regression and
synthetic Python commands use `-I -S -B`; isolation removes local module search
paths, while direct source compilation prevents local cache reads. `-B` alone
is not a cache-read prohibition. Valid-timestamp hostile-bytecode regression
fixtures require source behavior for all three loaders and preserve the cache
bytes unchanged. Shared caches are never deleted.
