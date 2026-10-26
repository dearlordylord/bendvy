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
static void __attribute__((constructor)) bendvy_namespace_use(void) {
  io_eff(CID(fresh), bendvy_namespace_fresh, 0);
}
