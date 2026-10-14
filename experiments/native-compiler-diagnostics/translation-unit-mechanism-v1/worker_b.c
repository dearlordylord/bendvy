#include "tu-abi.h"

WL_FN WL_FID_MID(WL_SIG) {
  runtime_state.transitions += 10;
  e.mem[0] += 2;
  r0 *= 3;
  r40 += 4;
  WL_DYN(FID_DONE);
}
