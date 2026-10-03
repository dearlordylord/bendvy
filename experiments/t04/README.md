# T04 owned-array payload experiment

Issue [#5](https://github.com/dearlordylord/bendvy/issues/5), parent [#1](https://github.com/dearlordylord/bendvy/issues/1), [SPEC](../../docs/SPEC.md). Base: `d31870ed0808afd93dc5bc7afe2b4953227d858c`. Date: 2026-10-03. Read GitHub title/body with `gh issue view {5,1} --repo dearlordylord/bendvy --json title,body`, repository instructions, SPEC, [R-A](../ra-provider/README.md), [R-C1](../rc1-query/README.md) and F05. Initial non-JSON gh calls failed because its default projectCards field is deprecated; explicit JSON calls succeeded. Applied `/home/node/.codex/skills/bend-ldd/SKILL.md`; ran `bend version` and `bend guide` before writing Bend.

**Research report complete; bounded Type-owned-array read/update gate passes the recorded inputs.** A Data record containing an owned Array is rejected for its intended kind mismatch. This is not a Data-only scope decision, production API approval, unrestricted affine-payload acceptance, rollback acceptance or performance acceptance. T03's failed exported-constructor design remains failed; this extends the subsequent R-C1 abstract-handle experiment.

## Storage kind versus value kind

| Case | Storage kind | Component value / element kind | Fresh result |
|---|---|---|---|
| R-C1 row with Payload{Array<U32>} | World/Row/List<Cell> are Type | Payload and Array are Type; U32 is Data | Native/JS/actual TS trace matches |
| DataPayload{Array<U32>} | No valid storage constructed | Claimed Data record contains Type field | Checker rejects `expected : Data / observed : Type`, Location DataPayload |
| DataPayload{List<&2,U32>} | Independent local control | Record/list/elements are Data | Duplicate reads print `7,8:7,8` on native/JS |
| Owned{Array<Box>} | Independent local control, not ECS traversal | Owned/Array/Box are Type; Box's U32 field is Data | Swap updates and ownership-preserving traversal repeat on native/JS |

The Data-array rejection is a language kind boundary, not an ECS restriction. Merely storing Data values inside affine world storage does not make those values affine, and wrapping U32 in an explicitly Type Box does not make it duplicable. The Data-list control is an alternative representation, not a silent substitution for the failed Data-array fixture. No casts, unsafe definitions, foreign authority stubs, dependency additions or import restrictions are used.

## API and observations

[payload.bend](payload.bend) imports the existing R-C1 API, uses its actual World/Row/Cell representation, and stores Type Payload as its auxiliary component. Its `get : Payload -> Payload & String` projects all four U32 slots, returning the same owned payload. The R-C1 `query` checks [system.bend](system.bend)'s read callback for arbitrary affine P/M, instantiates M with Payload in trusted provisioning and restores the returned handles into the original world. Position remains 0/10 throughout. `has` returns the owned handle and True; both rows have this required payload.

The new writable traversal accepts a closed callback of type:

```text
@-M: Type -> (M -> Token -> U32 -> M) -> M -> M
```

It supplies only the declared Items update operation, which reads slot 1, adds delta 3 and returns the payload. The callback is checked for arbitrary M, receives no concrete array or whole world, and returns M. Traversal rebuilds the original ordered row list. All constructors and operations are public. Detached public Payload construction/get/update is allowed but cannot replace M. Each invocation specializes the same closed step template with fresh affine setter functions; no closure is duplicated. The experiment supplies a narrow slot update operation, not arbitrary user code over raw owned arrays.

[main.bend](main.bend) runs setup observation, a repeated read, three identical step invocations followed by reads, and a final repeated read. Both rows start with four equal entries (10 for a, 20 for b). The six complete ordered observations are in [observed.txt](observed.txt): a's slot 1 becomes 13,16,19; b's becomes 23,26,29; all other entries remain 10/20. The world is threaded back through every call, allowing later updates and reads. No result is inferred from source descriptions alone.

[reference.mjs](reference.mjs) freshly runs the pinned bevy-ts public core with the same logical input, ordered queries, three invocations of one Schedule(Step,Read), and repeated reads. Labels are mapped from public reservation IDs, not guessed. Its updater uses `slice` to construct a new array rather than mutating an alias. Spawn/deferred identity and rollback behavior are not compared here: Bend uses explicit setup, while TS uses Spawn/applyDeferred. The comparison covers post-setup reads and updates only.

## Swap, take, traversal and read limits

[alternatives.bend](alternatives.bend) is an independent ownership canary, not a second ECS acceptance claim. It stores two affine Box elements, starts [10,20], and swaps slot 1 with an explicit Box{0} placeholder. The returned original Box is consumed once, incremented and placed back; three repetitions produce [10,23], [10,26], [10,29]. Structural traversal consumes each node/Box once and reconstructs it beside a String projection. It requires no cloned Box, Array.get or Data-element constraint. A whole-payload take returns the array beside Owned containing a supplied replacement. The caller discards that placeholder owner and continues to traverse the extracted array; this is destructive transfer, not a retained read-only borrow. These seven exact output lines, including controls, are in [alternatives.txt](alternatives.txt).

The paired affine-get rejection confirms `Array.get(Box,...)` is unavailable because Base requires a Data element. `Array.swap` is accepted for the same Box. Base `Array.to_list` consumes the array and accepts Type elements, while Base `Array.map` requires Data source/target elements; neither is a general ownership-preserving read-only API. Custom structural traversal demonstrates a possible Type-element path without relying on Array.map.

Returning `(Payload{a},a)` from a retained read attempts to duplicate the owned Array and is rejected (`+a` requires Data). Swap/take safely transfer ownership but would let the recipient mutate the extracted array. They therefore cannot simply be exposed through a read capability. A projected read is expressible and observed here; arbitrary borrowed whole-payload reads and user-defined affine transformations under a read-only facade have not been established. Closure and IO-handle payloads are untested; this example does not imply support for them.

**Bounded design decision for the user, before fixing the production API:** retain Type payloads in scope and investigate provider-owned projection/traversal plus declared write transformations; do not promise `get : Cell -> Cell & OwnedArray` as a retained no-copy read. If that exact API is required, the delivered duplication rejection is a support boundary requiring redesign, not grounds to remove affine payloads. Specific read contracts and rollback laws require approval after falsification. No approval is inferred here and no ECS proof is written. Dependent production implementation/proofs needing unrestricted payload reads or rollback remain blocked; the bounded array experiment can inform their probes.

## Reproduction and controls

Run `./experiments/t04/run.sh`. Requires existing Bend 2.0.34, Node v24.20.0, clang 14.0.6, timeout, rg and the absolute read-only checkouts. The runner freshly executes R-C1 and R-A, including their controls, compiler/Base identity and all three reference HEAD checks against [.references/sources.json](../../.references/sources.json). Pins: bevy-ts `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`, bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60`, bend2 `a950fd683c0d76f09794078e6174fe98a1492876`; Base SHA256 `c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661`. Baseline results are prerequisite reproduction, not this task's acceptance.

Each checker/build invocation uses the unchanged five-second [bend-check](../t01/bend-check); each runtime/reference invocation has a five-second kill limit. Native uses one worker, GPU off; JS uses Node. Temporary binaries/logs are removed. Any unexpected status, timeout, unrelated diagnostic, missing verdict or output difference fails. [controls.json](controls.json) and [controls.mjs](controls.mjs) require seven negative fixtures to exit 1 with exact expected/observed/location lines, and each paired positive to exit 0 with ALL PROOFS CHECK: Data-array kind, affine-element get, write-through-read, undeclared getter, foreign token, concrete reconstruction and owned-array duplication. The real runtime exercises allowed query/get/set paths. Existing baseline schema/capability fixtures are also re-executed.

The compiling [mutant.bend](mutant.bend) invokes the identity callback instead of the updater. Native/JS agree, preserve all six checkpoints and setup, but slot 1 stays 10/20. [compare-mutant.mjs](compare-mutant.mjs) requires this exact unchanged-storage behavior and detects the first step divergence. This falsifies draft statement 2 at the recorded input, not a universal law or a proof. Initial has/destructuring and multi-pair-match syntax failures were corrected before final verification; neither was counted as a capability rejection. ALL PROOFS CHECK for these safe definitions is a type-check verdict, not an ECS proof.

## F05 result and return conditions

**Concrete F05 evidence:** Type-owned numeric arrays work through abstract R-C1 read traversal and a declared update traversal; Data-owned arrays reject; affine-element swap/take/structural traversal are expressible locally. F05 remains open until scalable layout, general Type write/read semantics and rollback are resolved. No timing, memory or final performance acceptance was measured. Native substantial speedup and JS comparability remain mandatory.

- Numeric projected reads do not call Array.clone. Base source recursively rebuilds/traverses nodes for get/set; generated native and JS may lower indexed arrays differently. Do not infer physical costs from source alone. Structural Box traversal reconstructs array and Box nodes and formats observations; it is not a benchmark workload.
- Explicit Array.clone requires Data elements. Its observed control clones [10,10], changes one copy's first slot to 99 and reads 99/10 independently. Base recursively clones the array structure; measure allocation/copy costs at realistic sizes. General Box/closure/IO-handle cloning is unavailable through this Data clone interface.
- The TS updater explicitly slices four elements per update. Before benchmarking, choose equivalent ownership and rollback work, report whether copying/setup/formatting are included, vary array lengths and entity counts, measure compiled steady-state runtime and memory, and repeat samples. Comparing a copying TS transaction with a non-rollback Bend mutation would not establish equivalent work.
- Return to F05/#7 transaction work with affine payload failure after a successful earlier update, read-your-writes, restoration and retry observations. Swap/take alone provide no rollback journal or abort guarantee. Resolve consumable affine closures/IO effects separately; host IO remains outside ECS rollback.
- Replace the fixed required two-row fixture and fixed slot updater with scalable sparse/dense/churn storage and approved read/write contracts before selecting a production API. Broader law falsification, law-specific approval and proof/mutation evidence remain prerequisites to proofs. Finite trace comparisons do not establish universal runtime refinement.

No master, push, issue, Dalph claims/state, reference, DALPH.md or original jev/dalph changes. No new dependency. The coordinator owns delivery. One executor command containing `rm -f` was rejected by the command guard; it made no changes and was replaced with explicit temporary-file deletion and guarded directory cleanup. No task capability evidence is based on that rejected command.
