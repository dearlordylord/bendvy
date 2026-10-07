#include <inttypes.h>
static bool public_trace_begun = false;
Term io_public_trace_begin_run(Env e, Term *f, IoWork *w) {
  if (public_trace_begun) { fputs("Duplicate trace Begin\n",stderr); exit(2); }
  public_trace_begun = true;
  fputs("{\"boundary\":\"begin\"}\n",stderr);
  return term_pak(CID(Unit),0);
}
Term io_public_trace_complete_run(Env e, Term *f, IoWork *w) {
  if (!public_trace_begun) { fputs("Completion before Begin\n",stderr); exit(2); }
  fprintf(stderr,"{\"boundary\":\"complete-trace-forced\",\"nodes\":%" PRIu32 ",\"characters\":%" PRIu32 ",\"sum\":%" PRIu32 "}\n",(uint32_t)f[0],(uint32_t)f[1],(uint32_t)f[2]);
  return term_pak(CID(Unit),0);
}
static void __attribute__((constructor)) io_public_trace_use(void) {
  io_eff(CID(begin),io_public_trace_begin_run,0);
  io_eff(CID(complete),io_public_trace_complete_run,0);
}
