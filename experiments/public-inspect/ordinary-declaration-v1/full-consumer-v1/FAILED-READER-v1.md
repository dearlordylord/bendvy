# Reader countermodel failure: source dependency

Actual evidence is immutable commit `12ad1a8b`: normal JS session 51867 passed the entire 5,077,477-byte baseline; reader JS session 12984 returned exit 0 from both compiler and consumer, but the collector rejected its whole output against independent model `3f15bf71`. The actual reader output is 5,057,139 bytes, SHA256 `ea9857a0afe61387ecf5948fb11e1f6f7f099263057b963b06ca105ed1640a5b`. Both stock Native plans remain unattempted. No replay, model replacement, or consuming-source change accompanies this note.

The source basis is `118923c8`. The mutation in `mutant-reader/families.bend` still evaluates the original component `C.get` and returns its actual World, but substitutes `ComponentAbsent` for the detached Inspector result. That local preservation does not imply unchanged downstream diagnostic or scheduling observations.

The reached dependency is explicit:

1. `stage/phase-driver.bend` retains each Inspector-produced record in `P.State.records`. `stage/gate-phase.bend:45` scans the first nine records; `next` at line 32 passes each record to `G.run`.
2. `stage/gates.bend:89` passes that record to `Instrument.preload`. `stage/gate-instrumentation.bend:13` stores it in the World resource's diagnostic state, retaining the other resource owners.
3. `stage/gate-instrumentation.bend:38` supplies this stored record as `QueryCheck.Args`. The unchanged Check consumer reads actual component values. `stage/check-execution.bend:35` requires both nonempty rows and exact equality between its formatted snapshot and the supplied Inspector record. Inspector projection omission therefore can change the condition even though the Check implementation and physical component values are unchanged.
4. `stage/gate-instrumentation.bend:22` records the resulting allowed flag and before/after World snapshots in the actual diagnostic resource. `src/ecs/schedule.bend:57` maps a false condition to `Skipped`, retaining owners; a true condition dispatches. `stage/gates.bend:14` increments `Args.ran` only in the dispatched body. Subsequent observations consequently include different schedule outcomes, actual argument state and diagnostic resource contents.

The first observed mismatch (zero-based output line 76) is precisely `observations|[Ran:2]` in the frozen prediction versus `observations|[Skipped:2]` in the retained actual; the later argument observation has `ran=0` instead of `ran=1`. These observations corroborate the source dependency; they are not used here to author an expected model. The original model's assumption that all non-query lines remain unchanged omitted this dependency. The independent model owner must derive the complete counterfactual from the frozen source and have it reviewed separately.

Normal finite JS qualification remains valid. Reader mutation qualification is incomplete. This evidence gives no stock Native, performance, general public delivery, foreign/held-policy or new-contract acceptance.
