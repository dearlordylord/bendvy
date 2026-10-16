# Repeated public schedules, collision and unregister recovery (#50)

This additive consumer retains the first ordinary fixture unchanged. It uses the
same ordinary declaration and authored gameplay. Six actual `Schedule.run_with_skip`
executions per schema cover two registered instances, repeated calls, a false
condition, failure and retry. Each call builds a validated plan from the actual
instance ID and World namespace; the returned instance is passed to the next
schedule. It does not claim a heterogeneous schedule-builder API (#51).

The complete returned plan namespace/name/steps, arguments and scheduler
observations are printed. Nine complete World/instance checkpoints per schema
also include a genuine foreign run and foreign unregister refusal. The foreign
World has its own valid registration with the same ID, name and access as the
attempted instance, and retains a distinct two-array pack. Its initial owner and
complete final recovered pack are printed; it is never passed to gameplay.

Final unregister returns both original World instances plus the foreign twin.
Every returned capture cell and both final Worlds are observed. No mandatory
finalizer or external cleanup is claimed. `foreign-unregister-refused` uses the
existing snapshot `Skipped` tag to denote no callback entry; the separate
`unregister=Refused` line records the actual unregister result.

Only new fixture modules are added. Existing Local, Schedule and first ordinary
capture sources stay unchanged. Pure schedule check passes; IO main reports only
six foreign-dependent definitions. Full output requires independent oracle and
stock backend execution; source checking does not establish runtime acceptance.

## Qualified slice and remaining #50 work

Both normal backends now match the complete 6169-byte source-derived oracle.
The isolated unregister-removal omission also executes on both backends, matching
its complete 6277-byte counter and rejecting the normal trace. The sibling
`authority-v1` retains one positive and five intended compiler refusals. Existing
actual TS capture/schedule observations are a shared-behavior comparison, not a
claim that TS exposes Bevy's unregister API or that its wire trace is identical.

This delivers resource-declared capture lifecycle, repeated scheduler execution,
colliding foreign refusal and owner recovery. It does not complete ordinary
component-query captures: the existing query traversal accepted only Data args
and row outputs. An additive affine accumulator/query declaration adapter is now
being implemented under #50; this obligation is not transferred to #51. Full #50
closure and literal mutation-criterion reconciliation remain for final review.
