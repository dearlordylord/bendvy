#include <inttypes.h>
#include <time.h>
static struct timespec public_trace_start;
static bool public_trace_begun = false;
Term io_public_trace_begin_run(Env e, Term *f, IoWork *w) {
  if (public_trace_begun) { fputs("Duplicate trace Begin\n",stderr); exit(2); }
  public_trace_begun = true;
  fputs("{\"boundary\":\"begin\"}\n",stderr);
  if (clock_gettime(CLOCK_MONOTONIC,&public_trace_start)) { perror("clock_gettime Begin"); exit(2); }
  return term_pak(CID(Unit),0);
}
Term io_public_trace_complete_run(Env e, Term *f, IoWork *w) {
  if (!public_trace_begun) { fputs("Completion before Begin\n",stderr); exit(2); }
  volatile uint32_t nodes=(uint32_t)f[0], characters=(uint32_t)f[1], sum=(uint32_t)f[2];
  struct timespec end;
  if (clock_gettime(CLOCK_MONOTONIC,&end)) { perror("clock_gettime Complete"); exit(2); }
  int64_t elapsed=(int64_t)(end.tv_sec-public_trace_start.tv_sec)*INT64_C(1000000000)+(int64_t)end.tv_nsec-(int64_t)public_trace_start.tv_nsec;
  if (elapsed<0) { fputs("Negative monotonic duration\n",stderr); exit(2); }
  fprintf(stderr,"{\"boundary\":\"complete-trace-forced\",\"nodes\":%" PRIu32 ",\"characters\":%" PRIu32 ",\"sum\":%" PRIu32 ",\"region\":\"whole-feature-setup-operations-full-trace\",\"elapsedNs\":\"%" PRId64 "\"}\n",nodes,characters,sum,elapsed);
  return term_pak(CID(Unit),0);
}
static void __attribute__((constructor)) io_public_trace_use(void) {
  io_eff(CID(begin),io_public_trace_begin_run,0);
  io_eff(CID(complete),io_public_trace_complete_run,0);
}
