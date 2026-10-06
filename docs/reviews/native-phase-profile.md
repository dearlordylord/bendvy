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
