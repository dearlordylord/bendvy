#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

Term io_connected_clock_control_delay_run(Env e, Term *f, IoWork *w) {
  struct timespec remaining = { .tv_sec = 0, .tv_nsec = 20000000 };
  while (nanosleep(&remaining, &remaining) != 0) {
    if (errno != EINTR) {
      fprintf(stderr, "connected clock control: nanosleep failed\n");
      exit(2);
    }
  }
  return term_pak(CID(Unit), 0);
}
static void __attribute__((constructor)) io_connected_clock_control_delay_use(void) {
  io_eff(CID(wait), io_connected_clock_control_delay_run, 0);
}
