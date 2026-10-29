#include <stdatomic.h>
#include <stdint.h>

// Saturate rather than wrapping or reusing a disposed world's namespace.
static _Atomic uint32_t bendvy_namespace_next = 1;
static Term bendvy_namespace_fresh(Env e, Term* f, IoWork* w) {
  uint32_t old = atomic_load_explicit(&bendvy_namespace_next, memory_order_relaxed);
  while (old < UINT32_MAX) {
    if (atomic_compare_exchange_weak_explicit(&bendvy_namespace_next, &old,
        old + 1, memory_order_relaxed, memory_order_relaxed)) return (Term)old;
  }
  return (Term)0;
}
// Bend 2.0.35 passes an allocation need; newer native runtimes infer it.
// Select the actual registration signature without casting either ABI.
static void bendvy_namespace_register_two(void (*register_effect)(u32, Effect)) {
  register_effect(CID(fresh), bendvy_namespace_fresh);
}
static void bendvy_namespace_register_three(void (*register_effect)(u32, Effect, u32)) {
  register_effect(CID(fresh), bendvy_namespace_fresh, 0);
}
static void __attribute__((constructor)) bendvy_namespace_use(void) {
  _Generic(&io_eff,
      void (*)(u32, Effect): bendvy_namespace_register_two,
      void (*)(u32, Effect, u32): bendvy_namespace_register_three)(&io_eff);
}
