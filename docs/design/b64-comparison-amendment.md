# B64 / global-cap20 method amendment — proposal for approval

Two complete B16 packets passed all full-record semantics but failed the existing10% Health TS MAD/drift gates, once on the candidate and once on the fixed reference. Neither emitted a usable metric. Four of the approved eight global packets have been consumed, including two earlier crashes.

Propose only these changes:

- One bracket covers64 fresh worlds instead of16. Each world still executes the same64 original dispatcher ticks. Preserve one warmup world and every full record:65 records per child, compared independently against fresh TS.
- Version the method as `fresh64-one-bracket-v2`. Both fixed initial reference and candidate use this method; no comparison across B16/B64 results.
- Increase the global maximum from8 to20 packets; four already consumed,16 remain. Canonical segment configuration starts with16 remaining packets. The deadline remains2026-10-05T12:22:50Z; no time reset.

Everything else stays fixed: two schemas/Dense256, exact authored callbacks, original immutable initial source, thirteen editable implementation paths, all eleven gates per backend and their applicable mutants, exact-source gate reuse, unknown noise/qualification2,10% MAD/drift rules, bootstrap seed23/10000resamples, endpoint correction, strict keep rules, JS/TS<=1 and Native/TS<=0.5. Full product/matrix remains open. B64 may improve timing resolution; this preparation makes no claim that it passes the noise gates or reaches either performance target.

Timer-free feasibility passed both schemas on NativeO3/one thread/GPUoff and JS, with CPU11 and unchanged checker5s/runtime5s/codegen30s/clang120s limits. All65 full records matched fresh pinned TS. Derived fixture clocks were replaced with constant0, including the warmup; no performance timestamps or ratios were selected. Four raw integrity controls rejected lost-world, dropped-cell, tampered-reference and wrong-batch observations. `feasibility.json` binds the retained source/artifact/receipt evidence. The runner explicitly passes batch64; generator/validator default-only edits during preparation are documented rather than claiming an unchanged helper directory for the entire fixture.

Source-only proposed boundaries, actual candidate capture and root exact-source gate reuse also passed. Reused derived control maps remain JS93/Native94; the extra measurement drivers remain outside the gate overlays. Concrete proposal protocol, evaluator/check commands and config are at `/tmp/bendvy-batch64-method-proposal/{protocol.proposed.json,commands.proposed.json,config.proposed.json}`. The protocol is unaccepted and no measured packet/session/setup was launched.

Reproduce the timer-free fixture once into a new external directory:

```sh
/usr/bin/python3.11 experiments/s-prep/batch64-amendment/run.py --js-core /workspace/formal-proofs/bendvy-worktrees/fivehour-loop/experiments/fivehour-candidate/JS/experiments/s-integrate --native-core /workspace/formal-proofs/bendvy-worktrees/fivehour-loop/experiments/fivehour-candidate/Native/experiments/s-integrate --batch 64 --output /tmp/bendvy-batch64-timer-free-replay
```

After explicit approval, merge the seven method files, regenerate boundary/protocol hashes in the authoritative loop and configure a new canonical segment with16 remaining packets and floored remaining wall time. Log the prior four packets globally. Start with unchanged initial-source qualification; later implementation candidates require their existing source-bound gates. The integrator must rebind actual loop paths/hashes; isolated proposal hashes do not authorize execution.
