# Aligned Readers reference for #20

`readers-reference.mjs` fixes the #19 comparison asymmetry: actual Spawn, Update and Dispose descriptors are constructed once before timing, matching the retained Bend workload's preregistration. Their callbacks still read the actual current iteration/transient handle and execute the same 64 spawn/barrier → update/Fast/(Slow every fourth iteration) → remove/despawn/barrier sequence. Fast and Slow remain the same actual descriptor objects throughout. TS still creates its private runtime slot lazily on first actual invocation; no extra setup invocation, frame or registration tick is introduced.

The adapter retains all Main/Aux/Flag fields, ordered queries and lifecycle identities, Ping deliveries, final ledger, read audit, debug outcomes/frame/tick/missed diagnostics and actual reservation range. The timed interval still excludes setup, initial priming, final drain, output validation and serialization. One fresh warmup precedes one fresh sample. Actual descriptor construction is recorded by the wrapper that calls `G.System`; all seven descriptor records are outside timing. No timing-window instrumentation is added to the passing body.

All six Motion/Health × 64/256/1024 cases pass fresh comparison with unchanged `s-integrate/measurement-reference.mjs`. Both warmup and sample are checked, covering 475,968 complete row observations. Ten compiling controls are detected across the two schemas: re-created Update inside the loop, wrong Main slot3, wrong Ping payload, Slow every iteration and missing Slow diagnostics. The first control isolates construction alignment even when the ECS trace remains equivalent; the others protect the actual trace. Finite controls are not new approved ECS laws or universal proofs.

Replay:

```sh
python3 experiments/s-perf/readers-verify.py
```

The runner pins CPU5 and Node/reference/validator/source hashes, freshly runs the authoritative reference before each case, checks all fields using the existing full comparator and records complete validation outcomes in `readers-evidence.json`. Each Node syntax or runtime child retains the five-second limit. It reports no RSS measurement and no seven-sample performance ratio. The authoritative sources, old aligned/unmatched limitations, raw timing ratios, failures and memory evidence under `s-integrate` are unchanged.

Candidate sampler interface: `node experiments/s-perf/readers-reference.mjs Motion 64` (or Health, 256/1024) returns `{warmup,sample}` with the existing complete actual observations plus `descriptorAudit`. Python `readers-verify.py:validate(text,schema,count,fresh_reference)` checks both worlds and construction alignment. A future candidate seven-sample run must first pass a fresh complete Native/JS/aligned-TS gate for each exact source closure/case, then validate every repetition and rotate backend order. Do not combine historical Bend times with this new TS adapter or claim a corrected ratio from these six verification executions. Short timer resolution needs the ticket's separately frozen common batch/work amendment before any replacement samples; no such amendment is made here.

Physical logs, holder sets, stored cursor positions, staged/pending command occupancy and post-drain physical retention are explicitly unavailable in this adapter. The previous synthetic final-unread summary and process self-RSS field are not carried forward. Actual callback deliveries remain present. `occupancy-method.md` specifies the owner-preserving instrumentation boundaries, retention/lag distinctions, controls and independently tested clean-launcher RSS protocol for the later frozen overlay. That document is a contract, not completed instrumentation or memory evidence.
