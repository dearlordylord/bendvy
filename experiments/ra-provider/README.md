# R-A abstract capability provider experiment

Issue [#14](https://github.com/dearlordylord/bendvy/issues/14), parent [#1](https://github.com/dearlordylord/bendvy/issues/1), [SPEC](../../docs/SPEC.md), [T12 decision](../../docs/t12-redesign-decision.md), [T03 negative evidence](../t03/README.md). Base: `3e8f0210e8f471017fa257d3691c23004770ba70`. Read GitHub #14 and #1 via `gh issue view --repo dearlordylord/bendvy --json title,body`, repository instructions and linked documents. Applied `/home/node/.codex/skills/bend-ldd/SKILL.md`; ran `bend version` and `bend guide` before Bend work. Date: 2026-10-03.

**Outcome: bounded safe provider result for the tested closed callbacks.** This permits preparation of the next integration experiment; it does not choose a production API or close the original T03 capability gate. No language-wide safety theorem is claimed. A reproducible counterexample would overturn this result; timeout, unrelated diagnostics or unavailable prerequisites make the runner fail rather than count as rejection.

## Boundary and provisioning

`api.bend` is trusted orchestration; `system.bend` and the generic fixture functions model application systems. All symbols are public, including PositionCell, VelocityCell, Motion constructors, position_read/write, velocity_read, restore/restore_read, step, readonly, observe and both token constructors. No import prohibition or module privacy is assumed.

Authority comes from universally quantified affine handle types, not constructor secrecy. `step` accepts a closed callback whose type starts `@-P: Type -> @-V: Type -> ...`. The checker validates the callback for arbitrary P and V before trusted orchestration instantiates them with PositionCell and VelocityCell. The callback receives Position read/write operations, Velocity read, and one handle of each abstract type. It never receives Motion storage, and cannot identify P/V with a public concrete type. The read-only provider supplies only the Position read operation and abstract P. Repeating the closed template creates fresh affine operation arguments, rather than copying an affine closure. `move` is user callback code, not a checked action representation.

A concrete cell created by an application represents detached storage. It cannot replace the abstract handle of the currently executing callback. Calling public provisioning/restore paths on newly fabricated concrete cells likewise returns concrete types, not P. Raw setters cannot consume P. A callback can synthesize an identity function shaped like an updater, but that gives it no operation that changes provider-owned storage. We do not claim that arbitrary functions or detached cells are unconstructible.

Trusted provisioning is filled safe Bend code: step owns Motion, splits it into two affine cells, supplies the concrete operations at abstract types, invokes the callback and restores Motion from its returned pair. A successful three-step native/JS run demonstrates legitimate writes and ownership return. provision-control also checks constructor, raw setter and read-only provisioning together. No unsafe/foreign authority constructor, backend stub, unfilled declaration or ECS proof is present. Base IO prints observations; it is not an authority source. Application code calling its own provider on its own storage is allowed; it cannot acquire the caller's original abstract handle this way.

## Reproduce and observed evidence

Run `experiments/ra-provider/run.sh`. Observed exit 0. Requires existing Bend 2.0.34, Node v24.20.0, Debian clang 14.0.6, timeout, rg and read-only reference checkouts. No new dependencies. Every checker/build uses the existing [five-second wrapper](../t01/bend-check); compiled runtime and reference execution also have five-second limits. Temporary build outputs are removed. Native: one CPU worker, GPU off; JS: Node event loop. Guide is read on each run. Base SHA256: `c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661`.

Runner checks the tracked [.references/sources.json](../../.references/sources.json) against all three absolute reference HEADs at `/workspace/formal-proofs/bendvy/.references/`:

- bevy-ts: `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`
- bevy: `ad678262ce53b5d142fe49ee5e08caff6f00ab60`
- bend2: `a950fd683c0d76f09794078e6174fe98a1492876`

Inputs: one Motion row, Position=0, Velocity=2; three invocations of the same move callback. Native, JS and newly executed Node-only reference adapter output exactly:

```text
2
4
6
```

The adapter imports the pinned bevy-ts core directly with Node, spawns one entity, applies the explicit deferred barrier, runs the same Step system three times and executes a public read-only query after each step. Bend explicitly initializes storage; comparison covers the component-update checkpoints, not spawn/barrier parity or full R2. Every observation in Bend returns Motion ownership for the next step.

Every negative has its paired `*-control.bend`, checked with rc=0 and ALL PROOFS CHECK. Negatives require rc=1, SOME PROOFS FAIL, exact expected/observed types and the named failing function:

| Fixture | Intended mismatch | Location |
|---|---|---|
| read-write | expected A.PositionCell, observed P at concrete setter | bad |
| undeclared | expected A.VelocityCell, observed P at undeclared Velocity read | bad |
| cross-schema | expected A.MotionToken, observed A.OtherToken | bad |
| reconstruct | expected P, observed A.PositionCell reconstructed from read output | forge |
| fabricate-setter | expected P, observed A.PositionCell from public constructor + setter | bad |
| fabricate-provider | expected P, observed A.Motion from nested legitimate provisioning | bad |
| fabricate-restored | expected P, observed A.Motion from public restore | bad |

OtherToken/OtherPosition are a distinct second schema token, with no second complete world. The fixture controls successfully use the supplied declared read operation; provision-control separately demonstrates the concrete paths are usable by their legitimate owner. The tests target public construction/provisioning paths in this candidate, not just T03's former MotionWrite name.

The compiled no-update mutant passes checking and produces 0,0,0 on both backends. The runner requires those outputs and verifies they differ from the reference trace. [Candidate statements and falsification results](CANDIDATE-LAWS.md) were recorded before any proof work. ALL PROOFS CHECK here is ordinary checker wording: no ECS law or proof has been written.

## Limits and return conditions

- Closed callbacks and affine operation arguments are the experimental simplification. Captured state, callback errors, dropping handles, nesting across application schemas and general schedules remain open; investigate them before choosing System/Schedule APIs.
- Only U32 payloads and one explicit row are used. Data-only components are not approved. Return with affine Type payload access, storage layout, ownership-preserving updates and rollback experiments.
- Full R2 is open: optional/tag membership, multiple ordered entities, lookup mismatch and read-your-writes need the next two compositionally distinct schema integration experiment. This token-only second schema does not satisfy that future gate.
- No model proof, executable-function proof or universal runtime refinement exists. Finite trace agreement is the only semantic comparison here. Exact laws need separate human approval before proof work; this experiment approval does not approve them.
- Native substantial speedup and JS comparability remain mandatory and unmeasured. Return with equivalent representative workloads, variability, memory/scaling and separately approved numerical thresholds. This runner measures no timing acceptance.
- If broader provider evidence fails, return to human review to discuss R-B. No checked-action replacement, compiler change or callback/core scope reduction is approved by this result.

No changes to master, references, DALPH.md, Dalph claims/state, original jev/dalph or dependencies. No Dalph-specific execution problem observed. Coordinator/integrator owns delivery.
