# Actual #57 skip, defect and recovery reference

The corrected full five-phase TS development consumer passed once under the existing five-second Node cap on CPU 5. Complete cumulative trace events, complete tick results and whole world dumps match the preauthored oracle. Stderr is empty. Original pre-execution STATUS remains historical.

A false Check condition skips the body and does not advance the system tick. A thrown string defect reports attempted resource writes and queued command tags, rolls back those writes and discards commands, and is rethrown. The pinned TS trace has no schedule.end event for this thrown defect because traceSchedule exits through its finally before emitting the end event. A subsequent successful schedule verifies restored schedule-path state and normal execution. These are observed TS reference properties, not newly approved Bend behavior.

The original run failed at two allocator IDs in the recovery oracle. ORACLE-CORRECTION.md explains the independent pinned-source basis for changing only those IDs; all original inputs, failed receipt and raw diagnostics are preserved. The corrected receipt does not relabel that failure as passing.

This is retained nonportable development evidence. It does not qualify Bend/Native behavior, stream-discard/retention participation, callback exceptions or mutation, relation/transition/restore traces, noninterference, performance or full #57. Only finite nonnegative ms is normalized; ordinary JSON omission of undefined remains explicit. No new capture/ownership contract is selected.
