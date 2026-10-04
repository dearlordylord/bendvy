# Contextual Overflow guard instantiation probe

Baseline dc273b8. Read installed Bend2.0.34 guide/version/Base and committed member-safety/Word-context definitions; no dependency changes. Own only this probe, never edit the schedule worker package. Goal is exact row_safe(Overflow,Row{toNat(id),toNat(value),tag}) equality to actual U32 below-MAX guard, preserving source predicate and domain.

Before tests: factor describe(Any,Some(row))=Found(row) under an arbitrary erased Lookup->Bool observer, then instantiate the observer at actual S.no_overflow_lookup. If needed use an arbitrary erased bound descriptor predicate to delay normalization. Reuse proved bump_guard_agrees only after exact guard transport. All checker/kernel <=5sec. Record failed probes and residual, not a weakened guard or assumed proof.
