# Single comparison resume — issue #23

Packet `packet-nzg08ps6` completed on 2026-10-05 at 14:43 UTC. All 22 fresh connected gates passed; all 168 measured child outputs and 112 comparisons of all 65 full world records passed. Performance qualification failed: both candidate and fixed initial baseline were noise-inconclusive. No usable metric, keep, or performance acceptance was produced.

| Candidate / pinned bevy-ts | Median ratios, two cohorts | Unqualified upper95 bounds |
| --- | --- | --- |
| JS Health | 3.18–3.31 | 3.565–4.305 |
| JS Motion | 3.39–3.63 | 4.026–4.757 |
| Native Health | 5.10–5.12 | 5.949–6.097 |
| Native Motion | 5.25–5.78 | 6.221–6.314 |

Ratios greater than one mean slower execution. These bounds are descriptive, not qualified: candidate JS cohort2 relative MAD was 13.3% in both schemas, and Health cohort median drift was 11.54%, exceeding the unchanged 10% limits. Initial baseline also failed noise/drift qualification. The targets remain JS ratio ≤1 and Native ratio ≤0.5; this result does not meet them.

The current canonical last-run receipt was matched to this exact packet before `log --from-last --status crash`; “crash” records absence of a usable metric here, not a crashed workload. Logging completed, then one `state --report` was captured. Canonical cleanup reverted the editable experiment scope and preserved four unowned dirty paths. The exact nine tested source changes remain archived in `experiments/s-prep/eight-hour-results`. No subsequent packet, segment, keep, or source optimization was started by this executor. This was global attempt eight of twenty.

The evaluator completed full-record oracles and source guards. Canonical independent metric checks were not invoked because no metric was emitted. Unknown-noise qualification still requires two accepted measurements; the focused Dense256 result cannot establish the full five-family/three-size/two-schema acceptance matrix or production adoption.

Small replay evidence, compressed terminal receipts, canonical log/state, original SHA256 digests, and stale-marker recovery receipts are retained in [single-comparison-result](../../experiments/s-prep/single-comparison-result/result.json). Raw outputs and emitted artifacts remain under `/tmp/bendvy-fivehour-packets/focused-dense256/packet-nzg08ps6`. The quarantined dead prior marker is process bookkeeping, not measurement or ledger evidence.

The latest user authorization is the [three-hour continuation](three-hour-optimization-continuation.md), 13:30:46–16:30:46 UTC. Earlier expired allowances remain historical. Issue #23 stays open; root owns further optimization and session decisions.
