# Matched depth16 sampled diagnostics

Each role executes one complete depth256/span16/seed0 fixture: actual ECS setup/operations/query/write/barrier/rollback/cleanup, immutable full30 trace, full forcing and full serialization. Original and chunk candidate output bytes match the same independently authored oracle; Begin/completion and exactly one zero-exit audit also match. Static generated declarations precede sampling. These are instrumented diagnostics under contention, not fair timing or final ECS performance acceptance.

| Diagnostic | Original | Chunk candidate |
| --- | ---: | ---: |
| CPU samples, 100us interval | 8,409 | 6,391 |
| GC self samples | 2,014 (24.0%) | 763 (11.9%) |
| Serializer lexical-declaration self samples | 970 (11.5%) | 618 (9.7%) |
| Reported Heap selfSize sum, matched1MiB sampler | 5,415,605,976 | 5,055,972,240 |
| Reported serialize.walk selfSize | 1,601,336,272 | 1,504,919,264 |
| Reported force.walk selfSize | 505,472,232 | 504,423,960 |

Heap numbers are reported sampling weights with minor/major-collected objects included. They are neither physical memory/RSS nor measured total allocated bytes. One run per role provides no statistical/causal conclusion. CPU sample totals are not a speed ratio.

The original four-subject plan `49e403c6` stopped at its first failure: originalCPU qualified; original16KiB allocation sampling timed out5 after full output, without a heap profile. Candidate subjects were unexecuted in that receipt. A separate remaining-only plan `2a847f3d` qualified candidateCPU once, with12 fresh execution probes and explicit reuse of the unchanged four preparation probes. The historical INCOMPLETE receipt and its16 executed guard commands remain intact. Matched coarse-allocation plan `673730b3` changed only sampling interval to1MiB on BOTH roles; both runtime5 subjects passed complete30/forcing/audit/profile checks, with20 execution/four preparation probes. Failed16KiB data is not compared to the changed sampler.

`profile-analysis.json` uses recorded leaf URL/line to identify the enclosing generated top-level function. Anonymous CPS continuations at zero-based lines1383/1384 lie inside serialize.walk; earlier nearest-named-ancestor grouping undercounted them. This local/hash-bound source-location map is preferable to assuming anonymous samples are unrelated runtime work. It still does not establish an operation's cause. Full profiles and raw outputs are portable; excluded generated wrappers cannot be recomputed or reparsed by the capsule verifier.

The largest source-backed finding is unchanged per-token serialize.walk continuation creation, followed by force.walk and List.append. Graph target_edges/inverse_entries also appear prominently in sampled allocation locations. A separate direct-state/tail-walk experiment is a possible later investigation; no change or new task/contract is introduced. Further micro-optimization is deferred while parity/adoption proceeds. The population1024 pre-completion gap and candidate Native qualification remain open.

The initial profile preparation asserted a terminal LF absent from both immutable artifacts and failed before probes. Its wrapper/history and zero-probe receipt remain archived; the repaired seam accepts precisely the same invocation trailer with zero or one LF. A no-child wrapping preflight checked byte-identical body prefixes and one invocation/interceptor on both artifacts. The unexecuted remainingCPU plan before the historical execution-probe binding correction is also retained.

`profile-evidence-v1/verify.py` reconciles original full oracle bytes, all observed outputs/forcing/audits, complete CPU/heap data and actual probe/failure records without child processes. Private environments, installed binaries/libraries, caches and generated runtime/profile-wrapper bytes are excluded. It establishes retained finite evidence, not a fresh backend rerun, universal proof, Native/RSS/allocation/speed threshold or #42 completion.
