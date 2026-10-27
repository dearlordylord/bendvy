// SOURCE ONLY: exact emitted closure wrapper/layout require independent review.
#include <stdlib.h>
#include <stdio.h>
static void bendvy_trampoline_fatal(const char *reason) {
  fprintf(stderr, "bendvy trampoline ABI violation: %s\n", reason);
  abort();
}
static Term bendvy_trampoline_drive(Env e, Term *f, IoWork *w) {
  (void)w;
  Term entry = f[0];
  Term state = f[1];
  // Request fields have been moved out; no pointer into request storage is used
  // across corpus_eval. The sole state owner lives in this local Term.
  f[0] = TERM_HOLE;
  f[1] = TERM_HOLE;
  // This only establishes representation. Closed fixed reachability is an
  // artifact audit obligation; no generic callback reuse is authorized.
  if (term_tag(entry) != TAG_CLO || term_loc(entry) != 0 ||
      (entry & RFC_BIT) != 0 || fid_arity(term_aux(entry)) != 1)
    bendvy_trampoline_fatal("entry must be the audited zero-capture wrapper");
  u32 entry_id = term_aux(entry);
  term_drop(e, entry);
  for (;;) {
    u64 call = task_node(e, FID_CLO_APPLY, TERM_HOLE, 0, 0);
    e.mem[call] = term_clo(entry_id, 0);
    e.mem[call + 1] = state;
    // Synchronous return joins this whole round before next global-root call.
    Term round = corpus_eval(e.mem, term_tsk(FID_CLO_APPLY, call));
    if (term_tag(round) != TAG_CTR ||
        (term_aux(round) != CID_FAIL && term_aux(round) != CID_DONE))
      bendvy_trampoline_fatal("unexpected round tag; owner recovery is impossible");
    u32 tag = term_aux(round);
    if (cid_arity(tag) != 1)
      bendvy_trampoline_fatal("round envelope arity");
    Term payload;
    spare_free(e, cls_fit(1), ctr_take(e, round, 1, &payload));
    if (tag == CID_DONE) return payload;
    state = payload;
  }
}
static void bendvy_trampoline_register_two(void (*reg)(u32, Effect)) {
  reg(CID(trusted_drive), bendvy_trampoline_drive);
}
static void bendvy_trampoline_register_three(void (*reg)(u32, Effect, u32)) {
  // Third argument is readiness flags (IoEff.ask), not allocation need.
  reg(CID(trusted_drive), bendvy_trampoline_drive, 0);
}
static void __attribute__((constructor)) bendvy_trampoline_register(void) {
  _Generic(&io_eff,
    void (*)(u32, Effect): bendvy_trampoline_register_two,
    void (*)(u32, Effect, u32): bendvy_trampoline_register_three)(&io_eff);
}
