# Freeze correctness evidence before launch

This collector is a draft. No execution is authorized by its presence or by a
generated plan. It reuses `Runner`, `Inputs`, `CommandLogs`,
`owned-tool-pins.verify`, and `ReceiptBoundary` unchanged. It adds a fixed list of
ordinary emit, compile, execute, and exact-oracle stages.

The current six cases cover the ordinary core, query, serial scheduler, planner
controls, admission controls, and two-partition parallel baseline. They do not
qualify the later compatible-ready-set scheduler, Rust reference, authority
control cohort, or actual multi-worker diagnostic. Those need explicit source
successors. Configuring four workers does not establish that four workers ran.

## Prepare the plan

1. Select source-current fixture and oracle bytes after schema and condition
   repairs. Obtain independent full-oracle review for each selected case.
2. Prepare tool snapshots with the existing `owned-tool-pins.snapshot` API and
   `task_runner.execute_result`. Preserve every returned raw `ldd` stream. JSON
   serializes those raw bytes as hexadecimal, without normalizing the stored
   streams. The runtime uses the existing verifier's ASLR-only comparison.
3. Use the exact qualified Bend 2.0.35 bundle, Node 24.20.0, the private Clang 19
   wrapper, and the wrapper's actual Clang library environment. Freeze Python,
   all helper modules, resources, oracle files, relative Bend imports, path
   aliases, configuration presence, and the complete execution environment.
4. Run the pure-input preparation command below. It performs no consumer or
   compiler execution. Preserve each previous plan unchanged.

```sh
python3 test-fixtures/execution-qualification/prepare.py \
  --root /absolute/source/worktree \
  --source-commit EXACT_COMMIT \
  --query-oracle /absolute/reviewed/query.expected.stdout \
  --tool-snapshots /absolute/prepared/tool-snapshots.json \
  --output /absolute/new/retained-output-directory \
  --plan /absolute/new/plan.json
```

5. Obtain independent launch review of the collector, helpers, exact plan,
   tool snapshots, full oracles, and all prerequisites. An approval record must
   contain the exact `planSHA256`, `verdict: "APPROVED"`, the review report
   pointer, and `prerequisitesSatisfied` containing every exact string in the
   plan's `prerequisites` list.
   The reviewer, not the collector, establishes that the prerequisites hold.
6. Only after approval, invoke the pinned Python interpreter with `-I -S -B`,
   exactly the plan's environment, and `collect.py --plan ... --approval ...
   --output ...`. The output path must match the plan and must not exist.

The collector acquires the heavy lock itself without invoking another lock
owner. It preserves generated artifacts and all raw stdout and stderr files.
It hashes generated files immediately after their producing command and checks
all registered artifacts before each subsequent command. Each consuming stage
must name a previously registered artifact. Tool discovery is verified before
and after every stage through the existing owned executor, with raw probe logs.

Commands retain the existing 300-second emission, 120-second compilation, and
360-second consumer caps. Each case has one 900-second enclosing deadline,
including tool checks. The CPU is explicit. The baseline plan pins execution to
one allowed CPU and makes no native concurrency claim.

`ReceiptBoundary` runs all final source, tool, configuration, raw-log, and
artifact guards. Failure retains an `INCOMPLETE` receipt and propagates failure.
Bootstrap refusal also writes `INCOMPLETE`, before any command runs. SIGTERM is
converted to cancellation so normal cleanup and receipt finalization run.
SIGKILL, kernel failure, or an unwritable receipt destination cannot guarantee a
persisted terminal receipt and must never be reported as success.

## Review these refusal controls before consumer launch

The collector has not been executed. Independent review must admit isolated
controls through the existing runner before any qualification consumer launch.

| Control | Required observation |
| --- | --- |
| Change a frozen source or helper before entry | `INCOMPLETE`; no child command logs. |
| Change the collector environment or interpreter | `INCOMPLETE`; no child command logs. |
| Supply approval for another plan | `INCOMPLETE`; no child command logs. |
| Child exits nonzero after printing | Raw stdout and stderr retained; command result and `INCOMPLETE` receipt. |
| Modify a produced artifact before a consuming stage | Refusal before consumer execution; changed artifact retained and hashed. |
| Change source or resource bytes during a command | Completed raw command retained; postguard failure; `INCOMPLETE`. |
| Oracle comparison differs | Complete actual stdout retained; `INCOMPLETE`. |
| Cancel the collector during a child | Existing owned-child cleanup; cancellation and `INCOMPLETE` receipt. |
| Make receipt publication fail | Raised error; no successful receipt claim. |

Existing shared-helper tests cover process ownership and boundary failure
behavior. They do not by themselves test this new orchestration. A successful
collector receipt establishes only the selected finite oracle comparisons and
source bindings. It does not establish complete issue acceptance, universal
affine-owner preservation, IO cleanup, approved laws, runtime concurrency, or
speedup.

Concrete isolated control preparation and gated commands now live in
[controls/README.md](controls/README.md). They remain unexecuted pending independent
GH80 launch review. The normative cancellation control may expose the current
partial-stream retention defect; it must fail rather than relax that oracle.
