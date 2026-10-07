# Unattended implementation retrospective

Repeated late repairs in #34/#39 came from incomplete refusal observations and
unbound staged inputs. #38 additionally shows why liveness-only controls cannot
qualify gameplay cleanup. Existing source-bound runners are the reusable pattern.

1. Freeze every acceptance row and its complete owner/world/queue observations
   before implementation. Reviewer checks this mapping before a full Native run.
2. Bind original, copied, mutated and generated executable inputs before and
   after use. A changed input invalidates the run rather than updating its pin.
3. Before citing old evidence, run `scripts/check-receipt-sources.py RECEIPT...`.
   This only checks recorded source bytes; missing scope, stages, outputs and
   semantic/performance acceptance still require inspection.
4. Finish the current #38/#41/#42/#46/#47 experiments before opening further
   implementation fronts. Keep #34/#35/#39 core frozen for delivery gates.

There is no existing GitHub workflow in this checkout. A source-inventory check
alone is insufficient CI qualification; paired regression remains mandatory.
Host contention defers comparative timing, not semantic work. Exact new laws,
new dependencies and unresolved observable policies remain approval-gated.

Concrete reusable sources: `experiments/s-prep/fivehour-connected-gates/supervisor.py`
for descendant-safe bounded execution and
`experiments/public-relations/tool-pins.py` for prospective installed tool/resource/
resolved-library inventories. Bind a task-local copy or the imported module in
the receipt. A fresh runner that only pins Base and the compiler entry file must
not receive Native admission; this recurring omission was caught in #41/#47
and the timer prototype before their final runs.

## Integration scope correction — 2026-10-07

Do not turn additive module delivery into repeated execution of every unrelated
feature suite. For each batch, list the changed executable dependency closure,
new public consumers and their direct semantic/ownership/negative controls.
Rerun those controls and the mandatory unchanged #28 paired gate. Its full core
inventory must include added modules; it still protects only its named workload.
Unchanged historical feature receipts retain their original source-bound scope;
never relabel them as fresh executions. Full-product matrix qualification remains
#21/#23/#24 and #61, without being duplicated for each additive module.

Use the reviewed owned-descendant supervisor and receipt/log guards from the
start. The new #38 relocation runner repeated a previously solved supervision
omission, so repair that runner before Native rather than inventing another
execution framework. Preserve failed freezes and scope the repair to the runner.
After #34/#39 delivery, reuse their executor for #48/#40 respectively; do not
create additional concurrent fronts while existing executors remain occupied.
