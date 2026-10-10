# First core seeded run: capacity mismatch

The first actual core seeded-A JS run rejected the original 3018-byte model
with a 2908-byte observation. Existing expected bytes, source pins, plans and
failure receipt stay unchanged. Five snapshots differ only in column storage:
expected two Some(Unit) leaves, actual one Some(Unit) leaf.

Independent source inspection explains the gap. `seed.cell` calls `Col.swap`
directly. `column.swap_sized` accepts only `0 < id <= Array.size`; it does not
grow the column. The empty column is a single leaf, so ID one succeeds and ID
two is rejected. `seed.swapped` deliberately returns the column from either
outcome, hiding that fixture rejection. Entity reservation and activation still
produce two live entities.

The independent model mistakenly assumed direct swap would grow storage.
Explicit `Col.ensure` before the fixture swap would exercise the intended two
component cells without changing the ECS contract. That requires a new exact
source freeze and source capture; the existing failure is historical evidence.
Alternatively modeling the current one-cell fixture would require an explicit
scenario decision. No expected bytes have been silently changed here.

Provisioning reuses this seed, so the same source gap affects its anticipated
Before/After column state before any provisioning backend run. Resource writes,
affine siblings, registration identity, clock, cursor and pending callback
expectations have no discrepancy established by this first run.
