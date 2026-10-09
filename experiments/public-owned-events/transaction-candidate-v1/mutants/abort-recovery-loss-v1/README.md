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
heavy lock. Raw output is retained in evidence. No JS/Native child has run and
no rejection/reached-mutant result is yet claimed. Root review/admission precedes
backend execution under the existing unchanged caps. No laws/proofs, dependencies,
shared ECS source, public event/rollback/cleanup policy or #53 closure.
