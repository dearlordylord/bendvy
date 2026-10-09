#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
typedef unsigned long long u64;typedef int Term;typedef int Env;
#define MAIN_PURE 1
#define MAIN_FID 1
#define TERM_HOLE 0
#define H_ROOT_WORD 0
static char witness[256]="";static int calls=0;
static void mark(const char*s){strcat(witness,s);strcat(witness,",");}
static int witness_clock(clockid_t id, struct timespec*p){int r=clock_gettime(id,p);mark("clock");calls++;return r;}
#define clock_gettime witness_clock
static void err_fail(const char*s){fprintf(stderr,"%s",s);exit(2);}
static int task_node(Env e,int f,int hole,int a,int b){mark("task");return 0;}
static int term_tsk(int f,int n){return n;}
static Term corpus_eval(u64*H,Term t){mark("main");mark("late");H[0]=17;mark("teardown");return 0;}
static void show_val(Env e,int d,u64*H,int chain){mark("printer");printf("Complete{%llu}",H[0]);}
static void run(void){u64 H[1]={0};Env e=0;
  struct timespec simulationStart, simulationStop, transportStop;
  if (clock_gettime(CLOCK_MONOTONIC, &simulationStart)) err_fail("simulation clock failed");
  Term m = corpus_eval(H, term_tsk(MAIN_FID, task_node(e, MAIN_FID,
    TERM_HOLE, 0, 0)));
#if MAIN_PURE
  show_val(e, 0, H + H_ROOT_WORD, 0);
  putchar('\n');
  if (clock_gettime(CLOCK_MONOTONIC, &simulationStop)) err_fail("simulation clock failed");
  if (clock_gettime(CLOCK_MONOTONIC, &transportStop)) err_fail("simulation clock failed");
  fprintf(stderr, "{\"simulationNs\":\"%lld\",\"transportNs\":\"%lld\"}\n",
    (long long)(simulationStop.tv_sec-simulationStart.tv_sec)*1000000000LL+simulationStop.tv_nsec-simulationStart.tv_nsec,
    (long long)(transportStop.tv_sec-simulationStop.tv_sec)*1000000000LL+transportStop.tv_nsec-simulationStop.tv_nsec);
#endif
}
int main(void){run();if(strcmp(witness,"clock,task,main,late,teardown,clock,printer,clock,")){fprintf(stderr,"\nCONTROL_REFUSED:%s\n",witness);return 3;}fprintf(stderr,"CONTROL_PASS:%s\n",witness);return 0;}
