Current-master baseline versus one resource observation declaration evaluation.

Candidate N1/N4 complete TS/JS/Native outputs pass; baseline N4 acquisition qualifies JS only. Both repeat16 diagnostic batches preserve all sixteen full outputs and capture timers per invocation. Sampled allocation under resource observation falls from 27,521,008 to 4,687,496 bytes; whole sampled bytes fall from 235,086,512 to 219,790,960, while capture remains about 94 MB. Sampled allocations are not RSS; whole-process CPU includes startup/JIT/GC and does not establish comparative performance acceptance. #56 remains open.

Core source cf682d2b6 is root-owned and archived as a private candidate, not selected by this evidence-only delivery. The original helper and pre-repair plans remain archived. External tool binaries are represented by exact pins, not duplicated.

Offline: `python3 verify.py --selftest`. Full archived sourcePath identities are required, including a same-basename/wrong-parent refusal control.
