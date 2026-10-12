# Native emitter diagnostic — side investigation

Diagnostic only. No repository/core/compiler installation edits, no acceptance or comparative performance qualification. The immutable SOURCE02 archive was verified against all 53 FREEZE02 hashes, extracted into a private temporary tree, and absolute imports relocated. This changes path-derived names. Compiler source is preserved 2.0.35 CLI SHA015d68644efcd3ed53a5dbf17f5672c3f4fcb70c8c64cd2c895b4955e1f78e62, executed with Bun1.3.14; this is not execution of the installed bundled compiler. Base/effs use existing installed resources. Jobs serialized under existing heavy lock, nice10/CPU3; external CPU contention is uncontrolled. Timings below are process CPU/profiler observations, not workload speedup claims.

## Findings

- Instrumented30: source validation and file_book finish. First native pass does not finish: 2143 def entries, last logged process CPU27.809451s, logged RSS3.175GB. mat_lits calls0; no C.
- Same instrumentation with BUN_JSC_forceRAMSize=2147483648: deadline30, first pass unfinished,2073 def entries, last CPU28.5492s, logged RSS2.759GB. Does not establish a speedup or fix. Logged RSS is not a sampled process-wide peak.
- CPU profile: controlled normal diagnostic exit77 near25s preserves emitter.cpuprofile.25.549128s sampled; stringify self7.835s(30.7%). Call stacks point mainly to lay_eq comparison and lay_of type-key construction. lay_eq inclusive4.840s(18.9%). mat_lits unused.
- Experimental lay_eq DAG structural equality with pair memo (private compiler copy only; original JSON comparison spot-checked every1000 calls): deadline30,2240 def entries, no C. At exact matching ordinal/name reached by baseline at CPU27.809451s, candidate CPU23.132692s. Single diagnostic pair, no statistical speedup claim; output equivalence/core adoption unqualified.
- Bounded extended phase observation: original instrumented compiler with2GB GC setting, diagnostic wallcap60 andRSSstop7GiB. Deadline60;2548 def entries; still first pass, mat_lits0, last logged CPU58.836441s/RSS4.086GB. Attribution between adjacent def-entry CPU readings: inspector-query30.481324s; inspector-query-projection16.604027s. Attribution includes recursively fused compiler work under each entry, not pure per-function execution. No C generated.

## Interpretation

Located hotspot: repeated JSON layout/type serialization inside expensive composed-query specialization/flattening. Not a parser/checker failure, mat_lits U32 comparison hotspot, or clang failure. PR1386's skipped repeated passes cannot resolve the observed first-pass work by itself. GC setting and the isolated layout comparator both failed to produce C inside30s. Full underlying root cause/complete remedy remains unqualified; wide affine owner layouts, inline/fused expansion and large specialization counts warrant targeted analysis. Do not conclude a proven exponential complexity from these finite traces.

## Upstream references

- https://github.com/bendlang/bend/pull/1386 (open: skip unchanged definitions after first pass)
- https://github.com/bendlang/bend/pull/1387 (open: mat_lits DAG comparison; not reached here)
- https://github.com/bendlang/bend/issues/1262 (heap/GC workaround; tested here without resolution)
- https://github.com/bendlang/bend/issues/1270 (layout-key expansion already fixed in preserved compiler's emit_native)

Next bounded diagnostic: measure layout widths and fused expansion per costly composed query; assess lay_eq/lay_of DAG-aware comparison/keying without changing observable semantics. Any candidate must retain whole consumer observations and receive required independent review before adoption. Acceptance cap remains30s;60s was phase investigation only.

## Follow-up shape/inlining measurements

All follow-ups retained full53-source snapshot/full14queries/9Checks/two schemas. Source unchanged. Only private compiler instrumentation/candidates differ; no feature removed. Serial nice10/CPU3 runs, external contention worsened (wall deadline vs process CPU differ). No C artifact or execution qualification.

- Shape counters: before30s wall deadline,1510 completed def entries; lastloggedCPU20.067391s with the final function still running. Generated file_push fragments cumulatively78,074,465chars/2,704,944lines/23,928segments. These are intermediate generated fragments, NOT a final C size. One constrain~35 entry generated3,280,652chars/105,473lines,2788emit_body calls/736emit_fuse calls. Widest observed arg/return layouts45words.
- Native boxing32 diagnostic, adapted narrowly from issue1388 reference (Word.Con exempt):1535completed entries,lastloggedCPU21.333222s,intermediate46,404,490chars/1,406,231lines. Matched constrain~35 fragment falls3,280,652→1,748,033chars and105,473→49,757lines. Matched constrained_target~35 argument/return width37/36→4/3words. Deadline30,noC. This is compiler layout change, NOT a demonstrated safe ECS source optimization or runtime speedup.
- Optional once-tail inlining removed privately: replaces only `flat_call(fl,x) || dst===null && once` with `flat_call(fl,x)` in emit_body. Mandatory flat/template behavior retained. First complete pass at totalCPU20.126305s in30wall attempt, facts0→6127,1,422,130fragmentlines/36,759,099chars. Prior default did not complete first pass at totalCPU58.836441s in60wall. Different instrumentation/environment contention; observations identify inlining expense, not a statistically qualified speedup.
- Extended60wall diagnostic of no-once candidate: completed five passes. Facts0→6127→6467→6496→6499→6505. At pass5 end totalCPU48.769002s;60,800 emit_body calls and7,588 emit_fuse calls repeated per pass (304,000/37,940 cumulatively).182,499,176 cumulative intermediate chars,6,501,193lines; loggedRSS3.072GB. Deadline60 before final C; no runtime or backend equivalence proven.

Interpretation strengthened: optional once-tail inlining is a material first-pass expansion source. Once curtailed, repeated whole-program passes become a measured second expense, matching PR1386's target. Boxing reduces code fragments/owner width but did not solve deadline. mat_lits remains0 across all attempts. Neither result justifies changing public API, dropping features, upgrading compiler silently or claiming Native acceptance. Future candidate testing should target these compiler mechanisms separately and compare complete emitted/executed output before adoption.
