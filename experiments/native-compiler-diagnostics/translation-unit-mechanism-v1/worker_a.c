#include "tu-abi.h"

WL_FN WL_FID_START(WL_SIG) {
  runtime_state.transitions += 1;
  e.mem[0] += 1;
  r0 += 2;
  rp += 3;
  WL_JMP(FID_MID);
}
