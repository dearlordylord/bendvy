#include <stdint.h>
#include <assert.h>
#include <stdio.h>
typedef uint64_t u64;typedef uint32_t u32;typedef u64 Term;typedef struct{u64*mem;u64*alc;}Env;
#ifndef DEVICE
#define DEVICE 0
#endif
#define FAR static __attribute__((noinline))
static u64 fallback_calls;static u64 blk_loc(u64*H,Term a){(void)H;fallback_calls++;return 1000+a;}
#if DEVICE
#define WL_ARRAY_LOCATION(A, HS, QS, N, FALLBACK) (FALLBACK)
#else
FAR u64 array_location_lookup(Env e, Term a, const Term* hs, const u64* qs, u32 n) {
  for (u32 i = 0; i < n; ++i) {
    if (a == hs[i]) return qs[i];
  }
  return blk_loc(e.mem, a);
}
#define WL_ARRAY_LOCATION(A, HS, QS, N, FALLBACK) array_location_lookup(e, (A), (HS), (QS), (N))
#endif


static u64 test_0_0(Env e, Term v, Term r0, Term r1, Term r2, Term r3, u64 q0, u64 q1, u64 q2, u64 q3){Term h0=r0,h1=r1,h2=r2,h3=r3;return v == h3 ? q3 : v == h2 ? q2 : v == h0 ? q0 : blk_loc(e.mem, v);}
static u64 test_0_1(Env e, Term v, Term r0, Term r1, Term r2, Term r3, u64 q0, u64 q1, u64 q2, u64 q3){Term h0=r0,h1=r1,h2=r2,h3=r3;return WL_ARRAY_LOCATION(v, ((Term[]){h3, h2, h0}), ((u64[]){q3, q2, q0}), 3, (v == h3 ? q3 : v == h2 ? q2 : v == h0 ? q0 : blk_loc(e.mem, v)));}
static u64 test_1_0(Env e, Term v, Term r0, Term r1, Term r2, Term r3, u64 q0, u64 q1, u64 q2, u64 q3){Term h0=r0,h1=r1,h2=r2,h3=r3;return r2 == h2 ? q2 : blk_loc(e.mem, r2);}
static u64 test_1_1(Env e, Term v, Term r0, Term r1, Term r2, Term r3, u64 q0, u64 q1, u64 q2, u64 q3){Term h0=r0,h1=r1,h2=r2,h3=r3;return WL_ARRAY_LOCATION(r2, ((Term[]){h2}), ((u64[]){q2}), 1, (r2 == h2 ? q2 : blk_loc(e.mem, r2)));}
static u64 test_2_0(Env e, Term v, Term r0, Term r1, Term r2, Term r3, u64 q0, u64 q1, u64 q2, u64 q3){Term h0=r0,h1=r1,h2=r2,h3=r3;return blk_loc(e.mem, v);}
static u64 test_2_1(Env e, Term v, Term r0, Term r1, Term r2, Term r3, u64 q0, u64 q1, u64 q2, u64 q3){Term h0=r0,h1=r1,h2=r2,h3=r3;return blk_loc(e.mem, v);}
static u64 test_3_0(Env e, Term v, Term r0, Term r1, Term r2, Term r3, u64 q0, u64 q1, u64 q2, u64 q3){Term h0=r0,h1=r1,h2=r2,h3=r3;return blk_loc(e.mem, v);}
static u64 test_3_1(Env e, Term v, Term r0, Term r1, Term r2, Term r3, u64 q0, u64 q1, u64 q2, u64 q3){Term h0=r0,h1=r1,h2=r2,h3=r3;return blk_loc(e.mem, v);}
static u64 test_4_0(Env e, Term v, Term r0, Term r1, Term r2, Term r3, u64 q0, u64 q1, u64 q2, u64 q3){Term h0=r0,h1=r1,h2=r2,h3=r3;return blk_loc(e.mem, v);}
static u64 test_4_1(Env e, Term v, Term r0, Term r1, Term r2, Term r3, u64 q0, u64 q1, u64 q2, u64 q3){Term h0=r0,h1=r1,h2=r2,h3=r3;return blk_loc(e.mem, v);}
static u64 test_5_0(Env e, Term v, Term r0, Term r1, Term r2, Term r3, u64 q0, u64 q1, u64 q2, u64 q3){Term h0=r0,h1=r1,h2=r2,h3=r3;return v + 1 == h3 ? q3 : v + 1 == h2 ? q2 : v + 1 == h0 ? q0 : blk_loc(e.mem, v + 1);}
static u64 test_5_1(Env e, Term v, Term r0, Term r1, Term r2, Term r3, u64 q0, u64 q1, u64 q2, u64 q3){Term h0=r0,h1=r1,h2=r2,h3=r3;return v + 1 == h3 ? q3 : v + 1 == h2 ? q2 : v + 1 == h0 ? q0 : blk_loc(e.mem, v + 1);}
static u64 test_6_0(Env e, Term v, Term r0, Term r1, Term r2, Term r3, u64 q0, u64 q1, u64 q2, u64 q3){Term h0=r0,h1=r1,h2=r2,h3=r3;return v == h3 ? q3 : v == h2 ? q2 : v == h0 ? q0 : blk_loc(e.mem, v);}
static u64 test_6_1(Env e, Term v, Term r0, Term r1, Term r2, Term r3, u64 q0, u64 q1, u64 q2, u64 q3){Term h0=r0,h1=r1,h2=r2,h3=r3;return v == h3 ? q3 : v == h2 ? q2 : v == h0 ? q0 : blk_loc(e.mem, v);}

int main(void){Env e={0};u64 checks=0;
#if DEVICE
u64 metadata_evaluations=0;assert(WL_ARRAY_LOCATION(++metadata_evaluations, (++metadata_evaluations), (++metadata_evaluations), (++metadata_evaluations), 77)==77);assert(metadata_evaluations==0);checks++;
#endif
for(u64 v=0;v<6;v++){fallback_calls=0;u64 x=test_0_0(e,v,1,2,1,1,10,20,30,40);u64 expected=fallback_calls;fallback_calls=0;u64 y=test_0_1(e,v,1,2,1,1,10,20,30,40);assert(x==y&&fallback_calls==expected);checks++;}
for(u64 v=0;v<6;v++){fallback_calls=0;u64 x=test_1_0(e,v,1,2,1,1,10,20,30,40);u64 expected=fallback_calls;fallback_calls=0;u64 y=test_1_1(e,v,1,2,1,1,10,20,30,40);assert(x==y&&fallback_calls==expected);checks++;}
for(u64 v=0;v<6;v++){fallback_calls=0;u64 x=test_2_0(e,v,1,2,1,1,10,20,30,40);u64 expected=fallback_calls;fallback_calls=0;u64 y=test_2_1(e,v,1,2,1,1,10,20,30,40);assert(x==y&&fallback_calls==expected);checks++;}
for(u64 v=0;v<6;v++){fallback_calls=0;u64 x=test_3_0(e,v,1,2,1,1,10,20,30,40);u64 expected=fallback_calls;fallback_calls=0;u64 y=test_3_1(e,v,1,2,1,1,10,20,30,40);assert(x==y&&fallback_calls==expected);checks++;}
for(u64 v=0;v<6;v++){fallback_calls=0;u64 x=test_4_0(e,v,1,2,1,1,10,20,30,40);u64 expected=fallback_calls;fallback_calls=0;u64 y=test_4_1(e,v,1,2,1,1,10,20,30,40);assert(x==y&&fallback_calls==expected);checks++;}
for(u64 v=0;v<6;v++){fallback_calls=0;u64 x=test_5_0(e,v,1,2,1,1,10,20,30,40);u64 expected=fallback_calls;fallback_calls=0;u64 y=test_5_1(e,v,1,2,1,1,10,20,30,40);assert(x==y&&fallback_calls==expected);checks++;}
for(u64 v=0;v<6;v++){fallback_calls=0;u64 x=test_6_0(e,v,1,2,1,1,10,20,30,40);u64 expected=fallback_calls;fallback_calls=0;u64 y=test_6_1(e,v,1,2,1,1,10,20,30,40);assert(x==y&&fallback_calls==expected);checks++;}
fallback_calls=0;assert(test_0_1(e,1,1,2,1,1,10,20,30,40)==40);assert(fallback_calls==0);assert(test_0_1(e,1,1,2,1,1,10,20,30,99)==99);assert(test_0_1(e,1,1,2,1,3,10,20,30,99)==30);assert(test_0_1(e,5,1,2,1,3,10,20,30,99)==1005);assert(fallback_calls==1);fallback_calls=0;assert(test_0_1(e,1,1,2,1,1,10,20,30,0)==0);assert(fallback_calls==0);checks+=5;
#if !DEVICE
fallback_calls=0;assert(array_location_lookup(e,5,0,0,0)==1005);assert(fallback_calls==1);checks++;
#endif
printf("PASS %llu\n",(unsigned long long)checks);return 0;}
