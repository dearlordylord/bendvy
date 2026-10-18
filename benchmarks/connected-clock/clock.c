#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

static bool connected_clock_active = false;
static struct timespec connected_clock_start;
static const uint64_t connected_clock_limit = (UINT64_C(1) << 48) - 1;

static void connected_clock_require(bool valid, const char *message) {
  if (!valid) {
    fprintf(stderr, "connected clock: %s\n", message);
    exit(2);
  }
}
Term io_connected_clock_begin_run(Env e, Term *f, IoWork *w) {
  connected_clock_require(!connected_clock_active, "begin while active");
  connected_clock_require(clock_gettime(CLOCK_MONOTONIC, &connected_clock_start) == 0, "clock_gettime failed");
  connected_clock_active = true;
  return (Term)0;
}
Term io_connected_clock_end_run(Env e, Term *f, IoWork *w) {
  connected_clock_require(connected_clock_active, "end without begin");
  struct timespec stop;
  connected_clock_require(clock_gettime(CLOCK_MONOTONIC, &stop) == 0, "clock_gettime failed");
  connected_clock_require(stop.tv_sec >= connected_clock_start.tv_sec, "clock moved backwards");
  uint64_t seconds = (uint64_t)stop.tv_sec - (uint64_t)connected_clock_start.tv_sec;
  connected_clock_require(seconds <= connected_clock_limit / UINT64_C(1000000000) + 1, "elapsed exceeds Nat range");
  int64_t elapsed = (int64_t)(seconds * UINT64_C(1000000000)) + stop.tv_nsec - connected_clock_start.tv_nsec;
  connected_clock_require(elapsed >= 0 && (uint64_t)elapsed <= connected_clock_limit, "elapsed exceeds Nat range");
  connected_clock_active = false;
  return (Term)(uint64_t)elapsed;
}
static void __attribute__((constructor)) io_connected_clock_use(void) {
  io_eff(CID(begin), io_connected_clock_begin_run, 0);
  io_eff(CID(end), io_connected_clock_end_run, 0);
}
