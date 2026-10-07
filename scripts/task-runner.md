# Shared command runner

Linux command execution lives in `scripts/task_runner.py`. It uses only the Python standard library and requires `/proc`, `fork`, `prctl` subreapers and pidfds. Each command gets a dedicated owner process: only its descendants are adopted and cleaned up. Concurrent commands and unrelated children remain outside that ownership tree. No shell or unsupervised fallback is provided.

## Task integration

- `execute_result(argv, timeout, env=None, cwd=None, capture='split')` returns raw `stdout`/`stderr`, exit status, supervisor failure, capture mode and the runner source SHA256. Use `merged-stdout` only for an explicitly merged pipe; its stderr is empty.
- `Runner(logs, inputs=Inputs(files=[...], directories=[...]), env=..., cwd=...)` combines planned immutable `CommandLogs` with input byte/membership checks before and after execution. `run(label, argv, timeout, expected=0)` records raw logs before refusing a deadline, unexpected exit or in-flight drift. Output artifacts must be outside declared input directories. Include returned metadata and the task's declared input snapshot in its receipt.
- Existing `execute`, `execute_split` and captured `run` adapters retain caller return shapes. Exceptions retain raw failure output. Text conversion occurs only at the adapter boundary; underlying results remain raw bytes. The captured `run` adapter returns `CompletedProcess.runner_result` with the raw result and implementation pin.

Deadline values, environment, CPU affinity and cwd come from the caller. A command deadline excludes owner setup and bounded cleanup. This implementation adds one owner fork per command: previously recorded benchmark times cannot qualify the changed harness. Re-run measurement preparation and startup/repetition controls before publishing new comparisons; no workload, baseline or performance target is changed here.

## Migration boundary

All subprocess execution in the tracked `experiments/public-*` Python entrypoints delegates to this module, including tool discovery, registration, identity and schedule-reader controls. The four existing supervisor paths, two relations raw wrappers and component-state timing adapter remain small compatibility entrypoints; their process logic is no longer copied. The shared connected-gates entrypoint also supplies existing callers outside public experiments.

Historical scripts under `experiments/s-prep` that implement frozen optimization packets or cumulative session budgets are not rewritten. Their policies and receipts remain historical, and they are not an alternative execution API for current feature work. Existing stored evidence is not regenerated or represented as a passing run of the changed harness. Current Bend/application suites require their external pinned sources and tools and are not executed by this infrastructure CI.

## Verification

`sh .githooks/pre-commit` runs actual-process ownership/capture controls, immutable-log tests, tool-pin/normalizer tests and statistics tests. `ci/workflows/infrastructure.yml` is the prepared GitHub Actions configuration for the same checks on pull requests and master pushes, without Bend or performance runs. It is not active: the current GitHub OAuth token lacks `workflow` scope. Once that access is available, move it to `.github/workflows/infrastructure.yml`. Runner tests cover detached sessions, inherited pipes, successful parents leaving descendants, timeout output, cancellation, concurrent commands, source/input drift and compatibility entrypoints. They also detect direct subprocess copies returning in public entrypoints.

Failure receipts must distinguish command status from supervisor failure. Cleanup failure refuses acceptance; an OS-level uninterruptible task or externally killed owner cannot be given a successful cleanup guarantee by a Python runner. The runner does not impose numeric acceptance thresholds, interpret Bend diagnostics or prove ECS semantics.
