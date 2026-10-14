#ifndef BENDVY_TU_MECHANISM_ABI_H
#define BENDVY_TU_MECHANISM_ABI_H

#include <stdint.h>

/* Exact host scalar and Env layout shapes from the retained generated C. */
typedef uint64_t u64;
typedef uint32_t u32;
typedef u64 Term;
#define DEV
typedef struct {
  DEV u64* mem;
  DEV u64* alc;
} Env;

#if __has_attribute(preserve_none) && __has_attribute(preserve_most) \
  && defined(__OPTIMIZE__)
#define PRESERVE(A) __attribute__((A))
#else
#define PRESERVE(A)
#endif

/*
 * The real generated worker macro is TU-local (`static`). This mechanism
 * prototype changes only that linkage to hidden external symbols, which is
 * needed to test direct calls across TUs. The ABI attributes stay unchanged.
 */
#define WL_FN PRESERVE(preserve_none) __attribute__((noinline)) __attribute__((visibility("hidden"))) Term
#define WL_JMP(F)  __attribute__((musttail)) return WL_##F(WL_ALL)
#define WL_DYN(F)  __attribute__((musttail)) return wl_tab[F](WL_ALL)

#define WL_SIG Env e, DEV Term* sp, u32 seq, u32 rn, Term r0, Term r1, Term r2, Term r3, Term r4, Term r5, Term rp, Term r6, Term r7, Term r8, Term r9, Term r10, Term r11, Term r12, Term r13, Term r14, Term r15, Term r16, Term r17, Term r18, Term r19, Term r20, Term r21, Term r22, Term r23, Term r24, Term r25, Term r26, Term r27, Term r28, Term r29, Term r30, Term r31, Term r32, Term r33, Term r34, Term r35, Term r36, Term r37, Term r38, Term r39, Term r40
#define WL_ALL e, sp, seq, rn, r0, r1, r2, r3, r4, r5, rp, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, r16, r17, r18, r19, r20, r21, r22, r23, r24, r25, r26, r27, r28, r29, r30, r31, r32, r33, r34, r35, r36, r37, r38, r39, r40

typedef Term (PRESERVE(preserve_none) *WlFn)(WL_SIG);

enum { FID_START = 0, FID_MID = 1, FID_DONE = 2, FID_COUNT = 3 };

struct RuntimeState { u64 transitions; };
extern struct RuntimeState runtime_state __attribute__((visibility("hidden")));
extern const WlFn wl_tab[FID_COUNT] __attribute__((visibility("hidden")));

WL_FN WL_FID_START(WL_SIG);
WL_FN WL_FID_MID(WL_SIG);
WL_FN WL_FID_DONE(WL_SIG);

#endif
