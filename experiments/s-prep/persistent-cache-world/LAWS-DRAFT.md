# Unapproved persistent-cache invariant candidates

No law or proof is approved here. Finite observations do not establish universal
runtime refinement. Preconditions: raw Main/Ledger are original four-cell Type
owners; trusted Cache.init uses the complete original getter; all subsequent raw
writes are the four reviewed scalar index0 swaps with their matching complete-view
head patch; no raw owner escape, arbitrary transform or forged cache ingress.

1. At every cached observation, cached complete view equals the original uncached
   getter, including all four cells and frame/reserve/class/epoch; both return the
   same affine raw owner. Aux, flags and row metadata retain original semantics.
2. A scalar write returns exactly the original old0, changes raw and cached head0
   to the requested value, and preserves every other field. Record every actual
   inverse and Main mark at its original operation position; do not coalesce.
3. Global transaction unwind replays original inverses in reverse order through
   cache-aware original swaps; both raw and cached values return together. A failed
   later tick preserves the earlier tick's commit and drops failed publication;
   successful commands/pings/marks retain original commit order and barriers.

The unconditional statement “every public Cache getter always agrees with raw” is
false: public constructors permit raw head10 with cached head99. The unconditional
statement after arbitrary raw transformations is also false: mutating raw without
refreshing cached head makes the next cached getter stale. Execute both controls;
classify them as outside-domain counterexamples, not defeats of an approved law.
Cache-aware implementation mutants remain separate from these excluded inputs.
