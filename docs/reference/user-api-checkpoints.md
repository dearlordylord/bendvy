# S-USER-API observed reference checkpoints

Frozen 23-checkpoint logical application oracle:
[scenario](../../examples/user-simulation/scenario.md),
[actual public-API adapter](../../examples/user-simulation/reference.mjs),
[observed golden](../../examples/user-simulation/expected.json).

Read-only reference HEADs match the tracked provenance in `docs/reference/report.md`:
bevy-ts `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`,
Bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60`,
Bend2 `a950fd683c0d76f09794078e6174fe98a1492876`.
Node v24.20.0 executes upstream TypeScript imports directly; no package installed.

Public API anchors: upstream `Schema.ts` binding/query/system/runtime/command
constructors; `Query.ts` PresentOptionalReadCell/AbsentOptionalReadCell;
`System.ts` LookupApi.getHandle; `Runtime.events.test.ts` per-reader publication;
`Runtime.stability.test.ts` expected failure rollback; `Runtime.lifecycle.test.ts`
explicit deferred membership and insert/remove. Native Rust source provides ECS
architectural context only, not a claimed executable Rust comparison.

Commands from isolated worktree `/tmp/bendvy-user-api-reference`:

```
node --version
timeout 5s node examples/user-simulation/reference.mjs > examples/user-simulation/expected.json
timeout 5s node examples/user-simulation/reference.mjs --verify
```

Final replay exited0: `{"status":"PASS","checkpoints":23}`. The initial adapter
attempt incorrectly returned command results from void callbacks; upstream
correctly rejected those as invalid Fx. A second attempt failed to narrow an
optional slot before cloning its absent sentinel; final adapter uses public
`present`. These authoring mistakes were corrected before freezing the golden;
no upstream source changed. This is observed TS evidence, not Bend acceptance.
