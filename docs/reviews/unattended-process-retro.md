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
