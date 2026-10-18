# Same-artifact JS diagnosis

Separate CPU and collected-allocation runs both passed the complete226,988-byte oracle and both5448-value tuples on the unchanged qualified artifact860cb672. CPU:855 samples, including120 GC pseudo-frame samples with unknown phase. Allocation:574,161,672 sampled estimated self bytes over the preload lifetime; collected objects included. These are not exact allocated bytes, live heap, RSS or timed-only cost. Original Native/TS validator records are reused only as semantic references, never a timing cohort.

| Source location | CPU self / inclusive memberships | Sampled estimated self / inclusive bytes |
| --- | ---: | ---: |
| ordinary-query-declaration.pair~0 | 63 / 126 | 233,803,064 / 333,963,864 |
| ordinary-owned-event-family-resource.write~0 | 27 / 28 | 99,551,160 / 99,813,432 |
| lifecycle.clear_reversed | 17 / 27 | 67,674,656 / 67,936,992 |

Actual ancestor stacks classify444 CPU samples under authored Driver/body work,56 under common observer/fold,43 under final canonical rendering,73 under preparation,111 shared/Node ambiguous frames,8 pseudo leaves and120 GC. These observed stack categories are not exact timed shares. Actual timeDeltas remain in the raw profile; samples×100µs is not used as elapsed time. Allocation contexts with Driver/body ancestors total551,279,592 estimated bytes. Startup/setup/final output and instrumentation remain included. Inclusive rows overlap and must not be summed.

One proposal only: `ordinary-system.plan` consumes one constructed Query.Declaration into the existing Q.Plan, instead of constructing the closed declaration separately for grant and selector. Actual generated line12209 has both calls, reached from per-row selection and four capability operations. `SOURCE-JOINS-AND-CANDIDATE.json` records exact snippets, source hashes, helper signature and affine owner path. Arbitrary Type grant/selector move once into their existing fields; there is no new closure, erased runtime argument, cache or cross-call owner/payload hoisting. Public signatures, registration clauses, callbacks and observations remain unchanged. Pair/lifecycle edits are excluded. No implementation or speedup is claimed; root owns shared-core implementation after independent review.

CPU sampling interval100µs and collected-allocation interval65,536 bytes follow existing seams. Raw profile/clock paths and hashes, whole stdout, receipts/guards and sampling parameters are retained. Existing preload exit/throw controls are narrowly reused; historical timeout remains incomplete. No timing ranking, precision margin or product qualification follows.
