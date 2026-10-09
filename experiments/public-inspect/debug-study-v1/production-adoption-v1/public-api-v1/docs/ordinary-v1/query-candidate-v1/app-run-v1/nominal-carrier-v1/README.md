# Concrete owner-carrier candidate (source only)

The existing actual-App Plain emit deadline remains immutable. This candidate does not change that entry or any expected observation.

`owners.bend` introduces three closed, non-generic affine `Type` carriers. Each has exactly the five existing typed registered system owners and the existing Trace. Pack/unpack explicitly transport every field; arbitrary-owner roundtrip functions source-check all three category types. This is not an executable full-scenario qualification.

Minimal integration delta, subject to review:

1. After ordinary App.add has collected its existing nested five-owner product, pack it plus Trace into the appropriate nominal carrier. Keep the public ordinary declaration and registration path unchanged.
2. Instantiate actual App/SP/Sch H with the closed carrier, not the nested product paired with Trace. Supply a closed dispatcher whose selected actual Execution continuation reconstructs that carrier with the returned selected owner and all four untouched owners. Body failure and registration refusal must reconstruct the same carrier too.
3. Unpack only at existing complete Driver observation and ordinary App rebuild boundaries; repack the returned actual owners immediately. Preserve original and foreign worlds, removed registration records, detached component owners, every skip/failure/retry/barrier, Enabled/Disabled descriptions, and the unchanged entire 60-phase oracle.
4. The current generic Delivery/Observed types assume `H & Trace`; a separate carrier-specific application/observation adapter must avoid reintroducing this nested product into scheduler H. This is the concrete remaining seam, not an alias-only rename.

Reference hypothesis: root `experiments/public-inspect/boxed-scan-reconciliation-v1/README.md:11` and `.references/bend2/bend2/comp.ts:908–925` describe nominal ADT argument traversal without expanding fields in that reference branch. Existing `client/multi-registered.bend:69` uses a closed Owners type. These references do not establish the installed compiler algorithm or timeout cause, nor a speedup.

Development check: existing scripts/bend-check main.bend, five-second cap, exited 0 (PTY session 29356). Tool output retained as a transcription below; no backend was launched. Source consumers accept arbitrary real typed owners; main returns Unit and does not execute a scenario.

```text
ALL PROOFS CHECK
Use --verdict for mathematical validity.
bend 2.0.36 is available: run bend update
```

No public ownership/failure policy, law, dependency, compiler cap, phase, or acceptance criterion changes are proposed. Backend admission and full independent source/transport/oracle review remain required before executing a carrier variant.
