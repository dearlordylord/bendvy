# Shared command runner

Linux command execution lives in `scripts/task_runner.py`. It uses only the Python standard library and requires `/proc`, `fork`, `prctl` subreapers and pidfds. Each command gets a dedicated owner process: only its descendants are adopted and cleaned up. Concurrent commands and unrelated children remain outside that ownership tree. No shell or unsupervised fallback is provided.

## Task integration

- `execute_result(argv, timeout, env=None, cwd=None, capture='split')` returns raw `stdout`/`stderr`, exit status, supervisor failure, capture mode and the runner source SHA256. Use `merged-stdout` only for an explicitly merged pipe; its stderr is empty.
- `Runner(logs, inputs=Inputs(files=[...], directories=[...]), env=..., cwd=...)` combines planned immutable `CommandLogs` with input byte/membership checks before and after execution. `run(label, argv, timeout, expected=0)` records raw logs before refusing a deadline, unexpected exit or in-flight drift. Output artifacts must be outside declared input directories. Include returned metadata and the task's declared input snapshot in its receipt.
- Existing `execute`, `execute_split` and captured `run` adapters retain caller return shapes. Exceptions retain raw failure output. Caller cancellation is re-raised after bounded cleanup with the actual terminal result attached as `result`, `stdout`, and `stderr` when the command owner publishes it. `Runner.run` records those partial raw streams before propagating the same interruption. Cleanup preserves the Popen child wait status; a timeout or cancellation result can therefore contain the actual killed exit (for example `-9`) alongside its failure, rather than `None`. Missing owner publication remains a failure and never manufactures a result. Text conversion occurs only at the adapter boundary; underlying results remain raw bytes. The captured `run` adapter returns `CompletedProcess.runner_result` with the raw result and implementation pin.

Deadline values, environment, CPU affinity and cwd come from the caller. A command deadline excludes owner setup and bounded cleanup. This implementation adds one owner fork per command: previously recorded benchmark times cannot qualify the changed harness. Re-run measurement preparation and startup/repetition controls before publishing new comparisons; no workload, baseline or performance target is changed here.

Pass `timeout=None` for no command wall deadline. Owner-death detection and bounded
cancellation/descendant cleanup still apply. An unset
`BENDVY_SOURCE_TIMEOUT_SECONDS` similarly leaves `scripts/bend-check` without a
wall deadline while retaining its CPU locks.

## Resuming a sequence

`StageCache(directory, cwd=..., env=...).run(label, argv, files=[...], outputs=[...],
timeout=None, expected=0)` stores raw stdout/stderr and a JSON receipt for each
attempt. The binding includes argv, cwd, a hash of the effective environment, runner and
executable hashes, declared input hashes, output paths and expected exit.
Declare the full imported source/tool closure in `files`, not only the entry.
Successful attempts are reused only while their binding and all artifact hashes
match. A failure raises after its receipt is written; a later call preserves that
attempt and can run a successor. No automatic retry or acceptance decision occurs.

Keep stage inputs local to their actual dependency. A comparison declares the
expected file and saved stdout; emission declares the source closure. Changing
expected output then reruns comparison while reusing intact emission, build and
runtime artifacts. Keep the existing cohort heavy lock around the sequence; the
per-stage cache lock only prevents duplicate execution of that label. Adopt this
interface after a live source-bound command terminates, with the new runner pin.

## Maintained entrypoints

Public feature scenarios and benchmark harnesses import the common module directly. Local supervisors, raw wrappers, donor provenance and completed-task launchers are removed. Current capability fixtures, Bend/JS sources and benchmark contracts remain; closed-task tools survive in Git history rather than as alternative launch commands.

The former segment launcher is also retired: it was an old first-stage proposal requiring an expired 3600-second start receipt and old experimental pipelines. Its reference in open #23 is historical, not authorization or a usable current entrypoint. New research must use a current accepted experiment contract and the shared runner.

The still-used query control is now `scripts/query-controls.py`; event-reader checks invoke that maintained location. No ECS payload/ownership semantics, reference expectations or numerical targets change. Full Bend/application replay remains distinct from the infrastructure tests.

## Verification

The active [Infrastructure checks](../.github/workflows/infrastructure.yml) workflow runs runner ownership/capture controls, immutable-log tests, tool-pin tests and statistics tests on pull requests and master pushes. It separately compiles and exercises runnable examples. The local pre-commit hook checks affected Python sources, experiment state and whitespace, with optional delivery admission checks. Runner tests cover detached sessions, inherited pipes, successful parents leaving descendants, timeout output, cancellation, concurrent commands, source/input drift and staged shared-module imports.

Failure receipts must distinguish command status from supervisor failure. Cleanup failure refuses acceptance; an OS-level uninterruptible task or externally killed owner cannot be given a successful cleanup guarantee by a Python runner. The runner does not impose numeric acceptance thresholds, interpret Bend diagnostics or prove ECS semantics.
