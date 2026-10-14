#include "tu-abi.h"
#include <unistd.h>

/* The runtime/table-owner TU is the sole definition site for both objects. */
struct RuntimeState runtime_state = { .transitions = 0 };
const WlFn wl_tab[FID_COUNT] __attribute__((visibility("hidden"))) = {
  [FID_START] = WL_FID_START,
  [FID_MID] = WL_FID_MID,
  [FID_DONE] = WL_FID_DONE,
};

WL_FN WL_FID_DONE(WL_SIG) {
  runtime_state.transitions += 100;
  return r0 + rp + r40 + e.mem[0];
}

int main(void) {
  u64 heap[1] = { 7 };
  Env e = { .mem = heap, .alc = 0 };
  Term* sp = 0;
  u32 seq = 0;
  u32 rn = FID_DONE;
  Term r0 = 4,
      r1 = 0,
      r2 = 0,
      r3 = 0,
      r4 = 0,
      r5 = 0,
      rp = 5,
      r6 = 0,
      r7 = 0,
      r8 = 0,
      r9 = 0,
      r10 = 0,
      r11 = 0,
      r12 = 0,
      r13 = 0,
      r14 = 0,
      r15 = 0,
      r16 = 0,
      r17 = 0,
      r18 = 0,
      r19 = 0,
      r20 = 0,
      r21 = 0,
      r22 = 0,
      r23 = 0,
      r24 = 0,
      r25 = 0,
      r26 = 0,
      r27 = 0,
      r28 = 0,
      r29 = 0,
      r30 = 0,
      r31 = 0,
      r32 = 0,
      r33 = 0,
      r34 = 0,
      r35 = 0,
      r36 = 0,
      r37 = 0,
      r38 = 0,
      r39 = 0,
      r40 = 6;
  Term result = WL_FID_START(WL_ALL);
  static const char observed[] = "result=46 state=111 mem=10\n";
  if (result != 46 || runtime_state.transitions != 111 || heap[0] != 10)
    return 2;
  return write(1, observed, sizeof(observed) - 1) == (long)(sizeof(observed) - 1)
           ? 0 : 3;
}
