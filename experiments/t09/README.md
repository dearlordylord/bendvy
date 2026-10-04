# T09 nested schedule provisioning and typed failure

Issue [#10](https://github.com/dearlordylord/bendvy/issues/10), parent [#1](https://github.com/dearlordylord/bendvy/issues/1), [SPEC](../../docs/SPEC.md). Base `2c9fad2e4a3d48b9d23fcb13fbc765fc1e569063`. Date 2026-10-03. Read both live issues using `gh issue view --repo dearlordylord/bendvy --json title,body` (browser fetch unavailable), linked specification, AGENTS.md, R-A/R-C1 reports and `/home/node/.codex/skills/bend-ldd/SKILL.md`. Ran `bend version` and `bend guide` before implementation.

**Outcome: bounded nested resource/service composition works on the recorded inputs.** This is an experimental candidate, not a production Schedule API, full core completion, or approval of specific laws. The previous T03 constructor design remains failed; independently verified R-A/R-C1 permits this dependent probe.

## Public example and boundary

Run `./experiments/t09/run.sh` in this exact worktree. Observed exit 0. `main.bend` calls public `A.provision(~S.schedule, ...)`, reuses returned owned state for a second execution, then exercises missing resource and missing service. `api.bend` is trusted provisioning; `system.bend` contains application composition. All definitions and constructors remain public. No import prohibition or secret constructor is assumed.

The closed callback declares arbitrary affine resource R and service S, one `R -> Token -> R & U32` reader and one `S -> String -> IO(S)` emitter. Provisioning instantiates them with Cell and Service. The parent passes exactly those operations and owned handles to the nested child; the callback receives no World, concrete Cell, writer or other service. Concrete public constructors/setters cannot consume an abstract R. The service is a minimal real Base IO stdout emitter with an affine token, not a simulated external-effects log. Base IO is publicly available: this experiment confines access to provider-owned ECS storage/service handles, and does not claim to sandbox arbitrary host IO.

The parent runs Begin, nested Notify then Fail, and dispatches After only on Complete. Fail returns `SystemFailure{system:"Fail", error:Rejected{code:7}}` with both handles. The parent forwards that identity/error unchanged. Normal run, twice:

```text
Begin
Notify:42
failure:Fail:7
```

After never runs. The independent successful callback variant replaces only Fail's outcome with Complete; twice it observes Begin, Notify:42, After, complete. Both executions read the same resource value 42. No writes or ECS publications occur here, so transactional rollback is not implemented or accepted. Stdout emitted before failure remains observable; external effects are outside ECS rollback.

Runtime Maybe absence produces MissingResource or MissingService before Begin or any service interaction. The signature statically enforces provision types, but presence is dynamic. Both absent is not a tested case; the implementation prioritizes MissingResource rather than enumerating all missing needs. This is a deliberately fixed two-requirement composition, without a requirement registry/inference engine. The TS adapter checks actual MissingRuntimeRequirements payloads before normalization; it does not infer missing results from source descriptions.

## Evidence and falsification

Runner requires existing Bend 2.0.34, Node v24.20.0, Debian clang 14.0.6, timeout and rg. No dependencies installed. R-A is freshly re-executed for inherited confinement and environment validation, including Base SHA256 `c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661` and all absolute read-only reference HEADs against `.references/sources.json`: bevy-ts `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`, bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60`, bend2 `a950fd683c0d76f09794078e6174fe98a1492876`. R-A results are prerequisite reproduction, not T09 acceptance.

All checks/builds use the existing five-second `experiments/t01/bend-check`; runtimes/reference have five-second kill limits. Native uses one worker, GPU off; JS runs on Node. Temporary outputs are removed. Failures, timeouts, missing verdicts and unrelated diagnostic mismatches fail the runner. Each of main, success and skip-nested mutant is checked, built and executed on both backends; outputs must agree exactly with committed checkpoint files. Main and success concatenated must equal freshly executed `reference.mjs`. The Node-only adapter imports pinned public core, declares Counter and Logger, constructs an actual nested G.Schedule, runs the same schedule twice using tryTick, asserts typed identity/error and missing-requirement payloads, and executes success twice. This is finite reference trace comparison, not universal runtime refinement.

Six new negative fixtures each have a paired positive, and require rc=1, SOME PROOFS FAIL, exact expected/observed lines and Location: bad:

| Control | Expected | Observed |
|---|---|---|
| write through resource read via public setter | A.Cell | R |
| undeclared concrete service access | A.Service | R |
| foreign schema resource token | A.Token | A.OtherToken |
| incompatible supplied service | A.Service | A.Cell |
| replace abstract resource with fabricated cell | R | A.Cell |
| invoke ordinary affine callback twice | callback | callback (consumed more than once) |

Positive controls require rc=0 and ALL PROOFS CHECK. The last control calls the ordinary callback once. In contrast the public runtime calls the same closed template twice with freshly supplied affine operations and returned storage/service. This establishes the observed repeatability boundary; captured closures/state are not accepted or ruled out universally.

[Candidate statements](CANDIDATE-LAWS.md) were recorded before implementation. A compiling skip-nested mutant removes Notify but retains the Fail identity and missing controls. Both backends yield exactly `mutant.txt`, differing from the normal trace, falsifying the order/requirement execution statement on this input. The success variant tests the continuation arm rather than letting an always-stop implementation pass. No ECS law/proof is written; ordinary checker verdict wording is not proof approval. No model proof, executable-function proof or universal refinement exists.

## Limits and explicit follow-ups

- Fixed call composition and manually threaded requirements are a minimal expressibility slice. Return with fragments/features/phases/conditions, requirement unions, general nested failure types, dynamic provisioning registries and composition across schemas before a production API choice. Failure identity is an actual typed payload with a String label, not a statically unique system-ID type.
- Resource payload is U32; Cell and Service are affine Type. Data-only components are not approved. Return with affine payload/resource access and rollback integration using the T04 and transaction probes; no payload scope reduction is implied.
- Closed templates avoid copying affine closures. Captured per-system state, service lifecycle/host failure, multiple services and recovery/retry state need further experiments before accepting a general System abstraction. No behavior encountered here requires a redesign; an unexpressible mandatory extension must trigger a bounded decision, not an automatic restriction.
- No ECS write, command/event publication, reader cursor, lifecycle operation or rollback is tested. Integrate this path with T06 transaction evidence before claiming the full system failure contract. No unconditional whole-world callback is required by this probe.
- Performance remains mandatory and unmeasured here. Return in T10 with equivalent representative native/JS/reference workloads, variability, memory/scaling and approved numerical thresholds. No speed claim follows from successful compiled execution.
- Candidate quantified laws require separate approval and broader falsification before proofs. Finite negative controls do not establish universal capability confinement.

No master, push, issue closure, Dalph claim/state, DALPH.md, read-only reference, original jev/dalph or dependency change. The coordinator owns delivery. No Dalph-specific problem observed.
