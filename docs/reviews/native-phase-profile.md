# Independent Native phase sampler review

Reviewed root `experiments/s-prep/native-phase-profile/sample.py` read-only against exact frozen v8 Motion1024 generated C and `/tmp/bendvy-native1024-motion-phase-profile-r1/evidence.json`. No compilation, runtime, timing or profiling replay by reviewer. Decision: r1 is finite functional/sample diagnostic evidence with explicit provenance gaps; a new prospective r2 is needed before treating symbols/includes/tools as fully bound. Do not retroactively upgrade r1 receipts.

Independent reconstruction confirms sampled.c differs from original C only by the exact hook insertion before Dialect and exact io_now_run replacement. Actual original/derived SHA match r1 receipt. Motion r1 reports full65 equality versus actual TS,367 requested-period signal samples and0 pending-zero slots. This is source preservation and recorded finite evidence, not universal runtime refinement or performance acceptance.

The Linux/aarch64 handler performs lock-free atomic loads/fetch-add/store and ucontext PC extraction, with compile-time lock-free assertions. It performs no allocation, printing or symbolization inside signal context. Process CPU ITIMER_PROF requests1000us; delivery may go to any unblocked thread. One-worker Native flag does not establish worker-only attribution. Handler increments count before storing PC, so stop may see in-flight slots from another thread; zeroPendingSlots is a diagnostic, not a quiescence certificate. Lost/coalesced signals and unresolved/inlined locations prevent exact-duration, call-count, stack or causal bottleneck claims.

Clock3 starts sampling and clock4 stops it, consistent with original warmup then64-world Batch bracket. However stop prints all PCs BEFORE clock4's original io_tick read, so BATCH milliseconds include stop/output overhead. These values must never be used for elapsed comparison. Sample shares/locations are descriptive evidence only; report total, pending/unresolved samples and requested interval without implying statistical precision from367 observations.

Concrete r1 provenance gaps requiring fresh r2:

- Resolve/pin exact `nm` and `addr2line` executables and their ELF library dependencies before/after; avoid unbound PATH-selected tools.
- Enumerate/pin transitive C includes for newly introduced sys/time.h/ucontext.h and original includes before compilation, verify afterward. Existing original build include pins do not bind new instrumentation headers.
- Bind sampled binary immediately after compile, verify before/after symbolization/execution; bind derived C across compilation too. End-of-run artifact hashes alone do not establish consumed bytes.
- Bind sampler/tool-pin/validator scripts, actual source29/cache/build receipt/schema/count/driver joins and exact TS reference producer/program before/after. R1 checks original C against BUILD_PASS artifact but does not independently check full source29/receipt schema/count joins; earlier build review is separate evidence.
- Preserve FAILED/INCOMPLETE receipts for preflight/tool/symbol/include/runtime errors. Current preflight before try can terminate without a final failure receipt; either widen recording scope or retain exact preflight failure output separately.

Owned group kill on timeout, fixed120compile/5tool+runtime limits, exact Native threads1/gpuoff, and fullfield normalization are consistent with diagnostic scope. Inner post-kill communicate relies on descendant pipe closure; any inherited-pipe child needs the already reviewed owned-descendant supervisor or bounded cleanup, not an unlimited wait. The actual current tools do not spawn such children in the recorded pass, but generic failure handling should not claim that guarantee.

Source/compiler/kernel/reference changes, dependencies and acceptance are excluded. Newr2 repairs must remain separate with prospective pins and actual finite full65 check. No debug tools are installed or assumed. Existing allocation request/RFC evidence and this sampled CPU diagnostic must not be combined into a proven timing attribution.

## Fresh r2 follow-up

Read-only inspection of current sampler `c9830120ecfdb22d343acdd7cd2a6440c4168f008f5e72619cbd86c2ee6dde69` and both `/tmp/bendvy-native1024-{motion,health}-phase-profile-r2/evidence.json` confirms fresh full65 passes with 413/366 samples and zero pending slots. Both receipts record 182 transitive include pins, eight symbol-tool/library pins, immediately compiled and post-run identical binary hashes, and stable prospective inputs. Current input bytes independently match both recorded input maps. All six recorded commands completed within their explicit 5/120-second bounds. No compilation or workload execution was performed by this review.

The r2 repair addresses the recorded r1 symbol/include/binary/script pin gaps. It pins original build JSON, its 29 actual source files, TS core files, reference source, preparation script and validator. It does not independently recompute the source closure digest or validate the reference producer receipt/constant-only driver join; those remain supplied by the previously reviewed dense build/reference enrollment, rather than newly established by this sampler. Do not describe script hashes alone as producer-receipt validation.

The preflight artifact is now saved before compilation. Initial platform/import/input/library preflight still runs before the exception/final-receipt handler, so an early rejection can terminate without a final evidence JSON. Post-kill pipe draining remains unbounded. These are failure-path limitations, not failures of the observed completed r2 runs. Symbol commands use PATH names despite pinning resolved binaries; a stronger future runner should execute the pinned absolute paths and bind its effective environment.

The explicit r2 limit correctly excludes elapsed values because clock4 includes stop/printing overhead. Statistical interpretation remains unchanged: process-delivered diagnostic PCs, not worker stacks, exact durations, causal bottlenecks, performance acceptance or a universal runtime claim. Historical r1 remains limited and is not retroactively upgraded.
