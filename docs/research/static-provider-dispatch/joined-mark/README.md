# Isolated static-provider mark publication candidate

Prepared from the two current `experiments/fivehour-candidate` role overlays. This optional next candidate is not selected for the active packet. No repository source or frozen packet input was changed.

Only `experiments/s-integrate/storage.bend` differs per role. The retained publication patch adds three private transport helpers and replaces the `mark_main` body. Every original def/type/import header and every other original def body is byte-identical. The original metadata flags, added tick, membership guards and dead-row return are retained. Existing static provider routes, callback blocks and payload implementations are unchanged.

`preparation-evidence.json` records both 29-module closure hashes and changed-source pins. Role `overlay.json` and `cache-specialization.json` metadata carry the updated runtime source hashes. Historical metadata is provenance, not fresh gate evidence. `JS-storage.diff` and `Native-storage.diff` are exact source diffs.

Readiness command for each of the 58 role modules: `timeout 5 bend /tmp/bendvy-dispatch-next-mark/<role>/<path> --check-only`. `checker-readiness.json` preserves each exit, elapsed wall time and complete output. Installed tool: bend 2.0.35; `bend guide` was read before preparation. No compiler or kernel change was made.

These are source preparation and checker readiness only. No complete 22-gate aggregate, finite trace comparison, comparative timing, noise-qualified metric, keep, law approval, production selection or performance acceptance is claimed. Full review/control/measurement evidence must be fresh for these exact source closures before selection.
