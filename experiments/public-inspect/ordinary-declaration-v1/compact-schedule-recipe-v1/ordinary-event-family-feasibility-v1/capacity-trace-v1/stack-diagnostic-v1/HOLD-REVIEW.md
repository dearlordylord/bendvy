# Event capacity stack-only diagnostic — independent launch review

**HOLD: frozen plan is incompatible with its pinned collector.** No execution or mock/control was performed. Reviewed plan SHA256 `a8ee2b0c1ffa9671eba72c6144e4b8ef042e97ff71f2cc672b1025fb4fe7d3d0`.

Literal artifact checks pass. Original emitted JS SHA256 `637328921bc116104f760e5961a959f97e816f79888cdebdd68ff2b4bded9e8d` matches the original successful emit receipt. Modified JS SHA256 `79e351d50052fb42190c830644e9cd75baea55213fb5a492480b865f636a4dbd` differs at exactly one unique `io_exit` catch call: `io_errs(String(e))` becomes `io_errs(String(e.stack ?? e))`. Reconstructing the inverse restores the original bytes exactly. The workload, runtime entry, values and Node options otherwise remain identical. Original receipt records emit0, then consumer1/failureNone; no successful capacity qualification is inferred.

All 103 frozen plan file pins are current, including original and modified artifacts. Full independent gzip oracle is unchanged at 8663368 bytes SHA256 `945df50f7ca9874f77a0f040e9fb5d19f2a11c84cb103fcc5f01550868eee8b5`. Consumer argv names taskset CPU11, exact pinned Node and modified JS, with cap5. Diagnostic output/receipt/raw files are absent.

Concrete blockers:

- executionReuse metadata claims collector SHA256 `d6bca6f968ea52ed186a8d0890884ac054287417ce07a1a75b53a4646190d144`, whereas its actual body and plan pin are `fa765d72b5be47d61b157dba3fd992858deea48f4ab1d4f464bd2c43e68efefa`.
- That current `canonical-adoption-v1/detached-v2/development.py` invokes the pinned development-plan-guard before any child. The guard requires JS stages exactly `[emit,consumer]`, generated path `plan_path.parent/scenario.js`, native path `plan_path.parent/scenario.native`, generated/native outputs absent and nonaliasing inputs, and an existing stage directory. The proposed plan instead has only consumer, already-pinned scenario-stack.js, an old runtime native path and an absent stage. Consequently it is rejected before execution. The collector's output directory is actual plan_path.parent, not the plan stage field.

The current collector does provide acquired/pre/post/final source/import/resource/raw guards, unconditional receipt boundaries and lock release around actual children; the issue is unsupported preparation shape, not an excuse to weaken those guards. Bind a genuinely existing supported consumer-only guarded runner/configuration, or obtain a focused subject adapter authorization and exact review; do not modify the shared collector/guard silently, re-emit, erase the artifact pin or claim this plan already supports diagnostic execution.

Scope remains ONE diagnostic failure stack, not production generated-code adoption, stock capacity qualification, performance credit or cap escalation. Original failed capacity attempt and held Native remain unchanged. No source, generated artifact, runner or plan was edited during review.
