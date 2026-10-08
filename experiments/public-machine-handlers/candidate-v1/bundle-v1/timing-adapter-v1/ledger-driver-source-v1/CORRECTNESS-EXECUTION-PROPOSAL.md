# Complete IO ledger correctness — proposed bounded execution

Await frozen plan admission. No clocks, elapsed samples or ratios are executed by this proposal.

Root: `correctness-main.bend`, already development source5 typed. It calls only `L.Correctness{}` with one actual application per scenario/schema; this finite fixture count does not select a measurement population. `now(Correctness)` and `timed(Correctness)` use IO.pure, retaining actual Batch.step returned owners and zero timestamps.

Two subjects under the shared exclusive slot:

- Bend emit `correctness-main.bend -o ledger.js`, cap30 CPU8. Choose `.js`, not `.mjs`: pinned main.ts359–362 routes js_book; comp.ts3223–3229 roots actual main and io_exit. A library export consumer would bypass the intended IO continuation path.
- Node `ledger.js`, cap5 CPU8, frozen memory-only environment options and no loader injection. This executes actual full IO main; require exit0, empty stderr, complete JSON stdout. The raw stdout is retained before any assertion.

Then a read/hash-only validation invokes `validate-correctness.validate(raw)` in the wrapper without launching another backend. It checks exact two schema keys, 13 scenarios each, exact setup/operation kind order from operations.json, all checkpoint names in the original order and every physical value for the one retained owner. Type-sensitive canonical DTO equality must match every one of the original42 checkpoint states. A construction refusal is failure, not a smaller workload.

Fresh metadata freeze must bind source-review.json/current closure, independent ledger/oracle/validator, development receipts plus exact stdout/stderr/source archives, old successful JS inspector prerequisites and current root byte joins. Old qualification is preserved; this new IO driver receives no transferred runtime credit. Use participating Bend+Node current configuration kinds/ancestors including reachable HOME/.bend; preserve old historical configuration sets separately. Tool discovery/snapshot reuse must retain its admitted source/tool/environment/probe provenance. Own plan hash, full staged membership, output absence, generated hash and registration in both subject/probe runner inputs are mandatory. Central ReceiptBoundary includes initial guards and all named postguards; any failure remains INCOMPLETE with raw outputs.

Expected guard structure: initial + pre/post each subject = five rounds of the existing five tool guards,25 probes. Final receipt PASS is published only after final source/config/log/generated guards. No clock invocation, TS rerun, Clang, Native runtime, six-control replay or performance sampling is included. Six Bend-specific controls remain mandatory existing separate evidence, not part of TS42 projection.

After actual full42 success, inspect this exact generated main's IO continuation path. Whole Native driver correctness/emission is a separate plan; thin three-operation C inspection does not qualify the full driver. Before timing, reconcile TS per-operation raw-history capture versus Bend checkpoint-only physical observation; capture placement can influence subsequent heap state even outside clocks.
