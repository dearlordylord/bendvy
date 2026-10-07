// Harness-only UTF-8/FNV-1a32 capture, actual effect sequencing, CLOCK_MONOTONIC.
#include <time.h>
#include <inttypes.h>
typedef struct FeatureChunk { char *text; uint64_t length; struct FeatureChunk *next; } FeatureChunk;
static FeatureChunk *feature_head = NULL, *feature_tail = NULL;
static struct timespec feature_start;
static bool feature_active = false;
static uint32_t feature_digest;
static uint64_t feature_bytes;
static void feature_require(bool ok) { if (!ok) { fputs("feature timer protocol failure\n", stderr); exit(2); } }
Term io_feature_begin_run(Env e, Term *f, IoWork *w) {
  feature_require(!feature_active && feature_head == NULL);
  feature_digest = UINT32_C(2166136261); feature_bytes = 0;
  feature_require(clock_gettime(CLOCK_MONOTONIC, &feature_start) == 0);
  feature_active = true;
  return term_pak(CID(Unit), 0);
}
Term io_feature_capture_run(Env e, Term *f, IoWork *w) {
  feature_require(feature_active);
  uint64_t length = 0;
  char *text = io_cstr(e, f[0], &length);
  FeatureChunk *chunk = malloc(sizeof(FeatureChunk)); feature_require(chunk != NULL);
  chunk->text = text; chunk->length = length; chunk->next = NULL;
  for (uint64_t i = 0; i < length; ++i) feature_digest = (feature_digest ^ (uint8_t)text[i]) * UINT32_C(16777619);
  feature_digest = (feature_digest ^ UINT32_C(10)) * UINT32_C(16777619);
  feature_bytes += length + 1;
  if (feature_tail) feature_tail->next = chunk; else feature_head = chunk;
  feature_tail = chunk;
  return term_pak(CID(Unit), 0);
}
Term io_feature_end_run(Env e, Term *f, IoWork *w) {
  feature_require(feature_active);
  struct timespec stop; feature_require(clock_gettime(CLOCK_MONOTONIC, &stop) == 0);
  int64_t elapsed = ((int64_t)stop.tv_sec - feature_start.tv_sec) * INT64_C(1000000000) + stop.tv_nsec - feature_start.tv_nsec;
  feature_require(elapsed >= 0); feature_active = false;
  fprintf(stderr, "{\"elapsedNs\":\"%" PRIi64 "\",\"bytes\":%" PRIu64 ",\"digest\":%" PRIu32 "}\n", elapsed, feature_bytes, feature_digest);
  while (feature_head) {
    FeatureChunk *chunk = feature_head; feature_head = chunk->next;
    io_out(stdout, chunk->text, chunk->length); io_out(stdout, "\n", 1);
    free(chunk->text); free(chunk);
  }
  feature_tail = NULL;
  return term_pak(CID(Unit), 0);
}
static void __attribute__((constructor)) io_feature_timer_use(void) {
  io_eff(CID(begin), io_feature_begin_run, 0);
  io_eff(CID(capture), io_feature_capture_run, 0);
  io_eff(CID(end), io_feature_end_run, 0);
}
