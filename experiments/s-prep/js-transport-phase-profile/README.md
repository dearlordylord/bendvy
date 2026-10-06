# Full65 Health profiles: row/token parent and direct-Tuple candidate

Both actual programs are bound to query-v3 source29, exact derivation receipts,
producer recipes/catalogs and unchanged emitted inputs. `run-query-v1.py` is the
exact SHA-matched recipe used for these observations. `run.py` also admits the
separately pinned packed+paired normal mode; that mode has no profile result here.
The 64 measured worlds, separate warmup and original callback work remain intact.
Two IO-clock markers bracket CPU samples. Blocking stdout prevents GC trace/JSON
interleaving outside the interval. Both programs and independently executed TS
pass all65 complete worlds. CPU11, profiler100µs, runtime5s; no checker/codegen.

| Health JS role | GC self samples | GC events | Approx. pauses | Approx. allocated since prior events |
| --- | ---: | ---: | ---: | ---: |
| Row/token parent | 9.09% | 72 | 18.7ms | 1.899GB |
| Direct-Tuple candidate | 9.92% | 73 | 18.2ms | 1.932GB |

These trace sums describe approximate allocation traffic; they are **not live
heap, peak RSS or exact phase allocation**. Event timestamps have millisecond
resolution, allocation intervals can straddle phase boundaries and the profiler
perturbs execution. No heap-churn reduction is established by these observations,
despite the separate measured reduction in construction expressions. TS GC self
samples are10.6–12.2% in these two fresh profiles.

Candidate sampled self time is concentrated in unchanged callback Main read14.7%,
row-taken13.2%, step10.0%, Ledger read8.7% and query advance7.5%. Attribution changes
with JIT inlining, so these are sampled frames rather than exact operation costs.
GC alone is not the dominant sampled cost. The possibility that V8 already
eliminates some short-lived Tuples is an inference, not verified IR evidence.
Uninstrumented adjacent observations elsewhere remain adverse; instrumented
profile clocks are not accepted performance gains.

The initial local scaffold missed one indentation and failed parsing before any
execution. `preparation-failure.json` preserves that infrastructure diagnosis;
candidate/source/oracle bytes were unchanged. `archive.py` independently decodes
and verifies all62 compressed profile/input/source/provenance members. No source,
compiler, original runtime, Native, dependency, API, law or proof change follows.

## Typed cursor source profile

The exact final cursor Health chain has a new no-GC-tracing CPU profile and
full65 field validation, retaining source29, build/catalog/recipe and original
callback provenance. CPU samples inside the actual timed bracket attribute
about12% to GC,11.2% to live/take dispatch,9.7% to the callback,9.2% to Main set,
8.9% to row return,8.4% to cursor folding and7.4% to query advance. These are
perturbed samples, not elapsed acceptance or proof of allocation costs.

The first GC-tracing cursor profile fails JSON decoding: combined profiler/GC
output split a TS JSON record despite blocking stdout. Its complete failure is
retained; it is not a field pass. The successful no-GC-tracing profile reports
no GC event traffic estimate. Zero parsed events with tracing disabled must not
be interpreted as zero allocation or zero collection. Existing old-source GC
estimates are not transferred to this source.
