# Same-C Native compile-layout diagnostic

Hypothesis: size-oriented compilation could reduce generated helper expansion/code footprint or static stack traffic while preserving all operations and the existing calling conventions. This is one bounded `-Os` comparison against `-O3`, not a flag matrix or adoption decision. Clang19 documents O3 as adding potentially larger-code optimizations to O2, and Os as adding size-reduction optimizations to O2; that motivates the hypothesis, not a guaranteed gain. [Clang19 command guide](https://releases.llvm.org/19.1.0/tools/clang/docs/CommandGuide/clang.html#code-generation-options)

Existing `perf`, LLVM objdump and `llvm-profdata` tools are unavailable. Read-only `lscpu`, GNU objdump/size and the explicitly approved Clang19 wrapper are used. No packages, sysctl, compiler/runtime/source edits or dependencies are introduced. Without PMU evidence, there is no instruction-cache miss claim.

Exact input is joined closure `8cb83bc7467ca8e9b0192b8dadd89d3c143262d37e812079342289be1c0f6e26`. Each recipe verifies all 29 source pins and existing successful build receipt, then copies the exact generated C bytes and changes only the compiler optimization flag. C/binary/wrapper/version/commands/limits are pinned. The C uses `preserve_none`/`musttail` WL segments and `preserve_most` noinline/cold runtime helpers. Both flags define optimization; there is no size-specific conditional in the generated C.

| Static result | O3 | Os |
| --- | ---: | ---: |
| Health binary text bytes | 634,100 | 605,804 |
| Motion binary text bytes | 635,172 | 604,796 |
| Health step instructions | 1,150 | 1,370 |
| Health step total frame bytes | 704 | 704 |
| Motion step instructions | 1,527 | 1,344 |
| Motion step total frame bytes | 608 | 656 |
| Both loop frame bytes | 224 | 272 |
| Both loop static stack memory instructions | 94 | 101 |
| Both loop static direct calls | 8 | 9 |

Whole-binary text shrinks approximately 4.5–4.8%, but selected hot-family layout is mixed/adverse. Static instruction/stack/call counts do not measure dynamic execution, cache misses or accepted speed. In particular, Health step grows and both loop frames grow. This does not support a simple claim that Os improves the hot loop.

Fresh complete65 Native worlds for both schemas pass against the unmodified same-C O3 binary and fresh actual bevy-ts reference. Execution explicitly uses one worker, GPU off and the five-second runtime cap. Compilation retains 120 seconds; no Bend emission/checker/proof reruns are required for this flag-only candidate. Exact successful/failed receipts are archived when packaged.

Before any flag adoption, `tx-canary.py` recompiles existing actual reached Native controller C under Os and checks all original full records plus the unchanged independent true-old/journal/marks/rollback/order oracle. Existing compiling lost-mark and genuine inverse-order C counterexamples remain counterexamples. The gate passed all 12 Native subjects, 864 complete records. These gates are separate from the full65 success workload. Root owns coordinated raw observations; no performance qualification, full22 acceptance or production adoption is claimed here.


Three cyclic native-only rotations of TS/O3/Os passed every full65 field per schema. Raw Motion median phase times were TS 239.832/O3 177/Os 169 ms, with mixed paired Os outcomes versus O3. Raw Health medians were TS 219.013/O3 172/Os 181 ms; Os was slower in every paired run. All raw clocks/orders/ratios are retained in `observations.json`; host noise is unqualified. No Os observation reached half the TS time. This does not support adopting Os, and no O2 matrix was started.

The observer requires the truthful candidate `SAME_C_LAYOUT_BUILD_PASS` receipt rather than manufacturing a Bend `BUILD_PASS`, and checks exact same-C/source 29/binary/Clang bindings. Default proof/checker policy remains untouched. Follow-up: source-level transport/allocation improvements and independent qualified equivalent-work performance evidence, rather than claiming whole-text shrink as speed.
