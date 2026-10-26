# Canonical collector orchestration refusal controls

DRAFT, NOT ADMITTED, NOT EXECUTED. These controls invoke the unchanged canonical
`collect.py`, with disposable copies of its four existing helpers. They exercise
actual collector orchestration, rather than calling ReceiptBoundary in isolation.
The only workload is the frozen `child.py` under the existing Python 3.11 binary.
No Bend, Node, native ECS consumer, instrumentation, dependency install or network
request is included. The original c9b collector and helper sources stay unchanged.

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

The cancellation control is normative. Source inspection suggests the current
Runner cancellation path may clean up without returning partial streams or child
metadata. That is a control FAILURE, not an allowed empty-log outcome. The
harness continues remaining cases, records each actual collector exit separately
from semantic verdict, and ends INCOMPLETE/nonzero if any required observation is
missing. A reviewed repair and a preserved successor would then be necessary.
No collector/helper repair is included here. Publication failure intentionally
cannot promise an inner receipt; the outer receipt and raw collector traceback
are the terminal evidence. Unwritable outer destination/SIGKILL remain exceptions.

Preparation copies only disposable files and hashes inputs; it launches nothing:

```sh
python3 test-fixtures/execution-qualification/controls/prepare.py \
  --root /tmp/bendvy-gh77-evidence \
  --destination /tmp/gh77-collector-controls-v4 \
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
  --manifest /tmp/gh77-collector-controls-v4/manifest.json \
  --admission /absolute/independent-gh80-control-admission.json \
  --output /tmp/gh77-collector-controls-v4/results
```

Per child cap5s, case cap40s, outer per-collector cap55s, twelve serial instances.
The collector alone owns the shared heavy lock; no outer nested acquisition.
The harness uses the existing Runner/Inputs/CommandLogs/ReceiptBoundary. Output
must be fresh. Preserve every failed attempt; preparation requires a fresh root.
Passing these finite controls grants no consumer launch, issue acceptance,
performance, concurrency, or law approval claim. ECS workload freezing is separate
and still needs current source, complete independent oracles and launch review.
