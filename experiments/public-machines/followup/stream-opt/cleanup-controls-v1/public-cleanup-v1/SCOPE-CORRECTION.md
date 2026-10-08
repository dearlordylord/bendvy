# Consumed cleanup scope correction

The preserved commit 5668359f and its original selection/receipts qualify the previous cleanup implementation with copied current core dependencies. They do not qualify execution of the generic adapter. The generic two/three-port typing caller does consume the adapter; both runtime callers do not.

The immutable post entry consumes its own cleanup-controls-v1/caller-core.bend; the failed-batch entry calls the same module through B.cleanup. That function directly calls Sys.dispose. The patched followup/foreign-core.bend is not transitively consumed, so its duplicate G alias supplies no compiler namespace acceptance evidence. CONSUMED-CLOSURE-AUDIT.json records literal imports, source hashes and complete owned entry closures.

All raw outputs, original status labels, the complete 36+22 and 32+16 independent models, source refusal histories, and Native deadline remain unchanged. The Native post attempt emitted baseline cleanup C and timed out during compilation; the second Native plan remains unexecuted. No generic runtime/adoption claim is retained.

The next source candidate replaces the actually called caller-core.cleanup with a uniquely named GC adapter bridge. Complete models stay unchanged. A separately reviewed mutation in the actual adapter function must yield both-schema survivor witnesses before claiming reached generic execution. Fresh affected source and JS qualification require exact plan admission; no unchanged baseline replay or Native retry is proposed.
