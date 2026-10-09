# Actual transaction abort-recovery loss — frozen preparation

The sole staged source change is in Adapter.aborted: after actual canonical
T.finish returns its rolled-back World/failure, the adapter wraps returned Stage
owners in List.tail. It loses the oldest recoverable invocation-created payload.
Canonical ECS undo, component replacement, commands, Data events and owned
publication success paths are unchanged. Production adapter/staging is untouched.
Copied main/controls/observation bind the altered adapter through the actual
T.finish→failure→Stage.abort route; this is not the earlier detached-Stage mutant.

`baseline.json` is byte-identical to the independent source-corrected v2 complete
oracle. Before any backend, `prepare.py` clones that whole expected model and
removes only the first recovered EventView in failure and foreign branches.
Every other field/Array cell/metadata observation remains unchanged. It emits
both complete raw expectations through the independent original serializer.
Relocating the entry changes root module spelling relative to its folder;
SOURCE-JOIN binds the exact copied files/imports and derived namespace, while the
semantic baseline oracle is unchanged. This namespace binding requires independent
source review before a backend launch; it is not an actual-output correction.

`verify.py` checks every frozen file hash, exact one-expression delta, unchanged
other three source files, complete model transformation and source-derived raw
namespace. Guide/source5 completed; source check1 PASS, telemetry off and shared
heavy lock. Raw source output is retained in evidence. At the preparation checkpoint no
JS/Native child had run and no rejection/reached-mutant result was claimed. Root
review/admission preceded the execution below under the existing unchanged caps. No laws/proofs, dependencies,
shared ECS source, public event/rollback/cleanup policy or #53 closure.

## Actual reached JS falsifier

After independent prebackend source/oracle admission, first and only JS emit30/
Node5 CPU5 ran under the existing guarded direct recipe and shared child lock.
Both commands exit0, runtime stderr empty. Whole actual stdout6349bytes SHA256
`e9e37cd0482a56ee943724eb70183caeda8260b3cf25009277eaf39b18c8e3e3`
matches the entire preauthored counterfactual; it differs from the entire unchanged
complete baseline bound to the same staged namespace (6433bytes). Exactly the
first recovery EventView is lost in failure/foreign; all other branches/owners/
World rollback/metadata/commands/events match. No output normalization, semantic
expectation repair, retry or namespace change was performed after execution.

`development-run.py` reuses the already-reviewed direct mutant runner, adding all
frozen SOURCE-JOIN members to ordinary source/tool/environment/oracle/raw/artifact
initial, post-child-lock and terminal guards. Unconditional receipt status is
MUTANT_DETECTED. Exact raw/plan/receipt are retained in evidence/js-1; generated
JS and local environment files are excluded. `verify-execution.py` is no-child
verification of exact source/callsite binding, full raw hashes/caps/entry, complete
baseline rejection and whole counterfactual equality. Its invoked preparation
verifier checks the frozen pre-run derivation only; that message does not deny
the historical child execution. No Native mutant is required/claimed for this
scoped development falsifier. No public event policy, World reader/retention,
proof, tool-search portability, performance/regression or #53 closure.
