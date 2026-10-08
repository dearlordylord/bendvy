# Actual Native C dependency inspection — diagnostic only

Actual C SHA256 `fdd91ea2c692873d000885e6bd2ce7b0945ecf320ec4e7e43544f4f62b5590fd`, exact source5/Cemit30 plan `6de1c0f4da84987a2ff7f5240858858003b107f33daa44dc9404efc4c1186cfa`, successful receipt `20b88f117b2afceccf912894c416cc8c9563e763ccecf5154812ad788a093ced`. No Clang or generated-program execution occurred.

- 948 defines BANGS0. At future thread1/GPUoff, corpus_eval89976–90015 uses seq=!BANGS&&pool_size1; task/continuation paths otherwise remain explicit.
- 88472–88498 starts IO.bind with IO.now and C1068 continuation. C1068 at88500–88534 installs K1069 waiting for returned Batch.step; its task branch passes WL_CONT rather than advancing endclock.
- Batch.step87526–87567 waits for actual stepped. Stepped calls actual Stepper at85909/85971; K1033 receives57 returned application words, then waits for recursive tail at86177. K1034 uses returned head/tail to construct Con at86358–86365. These are real returned application owners, not observer thunks.
- Only returned owner reaches K1069 at88536–88551, which invokes spin20637651–37666 to construct COMPLETED.C1070. End IO.now is constructed by C1070 at88554–88575; C1071/1072 retain the returned owner.
- IO.now segment89061–89070 constructs the request. io_step90614–90648 applies the current continuation/item through corpus_eval before io_exec. corpus_eval loops scheduled work and root_take before returning that request. Actual now effect90715–90720 divides io_tick by1000000 (integer milliseconds).
- Source main retains the same owner through Queue→Marker→Read and observes full physical state after final endclock. The observer cannot supply discarded operation output or execute inside those source intervals.

This finite emitted call/task dependency supports a future interval design for this thin closed root. It is not Native feature/runtime correctness, a universal proof or a timing result. Full42 actual same-owner JS correctness remains separate qualified development evidence; six Bend-only controls remain separate mandatory baselines. Population, repetition/sample protocol, clock precision equivalence and comparative measurements remain unselected. The prior accepted Workshop gate remains distinct.
