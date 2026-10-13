#include <stdint.h>
#include <stdio.h>
typedef uint64_t Term;
typedef uint32_t u32;
typedef struct { Term* mem; Term* alc; } Env;
#ifndef DEVICE
#define DEVICE 0
#endif
#if DEVICE
#define WL_CASE_SIG(F, ...) case F:
int main(void) {
  int result = 0;
  switch (7) { WL_CASE_SIG(7, tokens_that_must_not_be_parsed, Term)
    result = 1; break; default: break; }
  if (result != 1) return 1;
  puts("PASS ABI");
  return 0;
}
#else
#define ATTR static __attribute__((noinline, preserve_none)) Term
typedef Term (__attribute__((preserve_none)) *WlFn)(Env e, Term* sp, u32 seq, u32 rn, Term r0, Term r1, Term r2, Term r3, Term r4, Term r5, Term rp, Term r6, Term r7, Term r8, Term r9, Term r10, Term r11, Term r12, Term r13, Term r14, Term r15, Term r16, Term r17, Term r18, Term r19, Term r20, Term r21, Term r22, Term r23, Term r24, Term r25, Term r26, Term r27, Term r28, Term r29, Term r30, Term r31, Term r32, Term r33, Term r34, Term r35, Term r36, Term r37, Term r38, Term r39, Term r40);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wc23-extensions"
ATTR direct(Env e, Term* sp, u32 seq, u32 rn, Term r0, Term r1, Term, Term, Term, Term, Term rp, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term) { Term x=r0,y=r1; { Term r0=x+y; return r0; }}
#pragma clang diagnostic pop
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wc23-extensions"
ATTR frame(Env e, Term* sp, u32 seq, u32 rn, Term r0, Term, Term, Term, Term, Term, Term rp, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term, Term) { Term a=sp[0],b=sp[1],x=r0; sp+=2; { Term r0=a+b+x; return r0; }}
#pragma clang diagnostic pop
ATTR bridge(Env e, Term* sp, u32 seq, u32 rn, Term r0, Term r1, Term r2, Term r3, Term r4, Term r5, Term rp, Term r6, Term r7, Term r8, Term r9, Term r10, Term r11, Term r12, Term r13, Term r14, Term r15, Term r16, Term r17, Term r18, Term r19, Term r20, Term r21, Term r22, Term r23, Term r24, Term r25, Term r26, Term r27, Term r28, Term r29, Term r30, Term r31, Term r32, Term r33, Term r34, Term r35, Term r36, Term r37, Term r38, Term r39, Term r40) { __attribute__((musttail)) return direct(e, sp, seq, rn, r0, r1, r2, r3, r4, r5, rp, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, r16, r17, r18, r19, r20, r21, r22, r23, r24, r25, r26, r27, r28, r29, r30, r31, r32, r33, r34, r35, r36, r37, r38, r39, r40); }
int main(void) { Term mem[2]={11,13}; Term* sp=mem; Env e={mem,mem}; WlFn f=direct;
if(direct(e, sp, 0, 0, 3, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)!=8) return 1;
if(f(e, sp, 0, 0, 3, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)!=8) return 2;
if(bridge(e, sp, 0, 0, 3, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)!=8) return 3;
if(frame(e, sp, 0, 0, 3, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)!=27) return 4;
puts("PASS ABI"); return 0; }
#endif
