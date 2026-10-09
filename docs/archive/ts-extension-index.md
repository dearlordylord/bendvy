# Archived TS mechanisms and future tooling

Preservation tag: `archive/ts-port-inventory-2026-10-09`, commit `2661dda1`.
The tag retains the complete source tree before active TS-only experiments were removed.
This archive is reusable research/code, not approved Bendvy ECS scope or delivered libraries.

Transfer/removal approved by the user on 2026-10-09. Classify future reuse by
consumer purpose, not by the old parity ticket: TS facade, optional adapter,
wire/codec utility, test tooling, helper library, or reference research.
Native ECS capabilities stay under their existing owners.

For future tools offering a TypeScript interface, start with the TS facade row,
then reuse wire/codec material and facade test models. Add Standard Schema only
when that consumer needs it. Keep host adapters outside the Bend ECS core;
archived TS signatures do not override Rust Bevy semantics or Bend ownership.
The rows below distinguish reusable implementation from research and unfinished
checks so a future tooling project can establish its own acceptance evidence.

## Classification

| Future use | Preserved material | State and reuse boundary |
| --- | --- | --- |
| TS interface to Bend ECS | `standard-schema-v1/runtime-v1/host-wire.mjs`, `runtime-v2`, typed Raw DTOs and full observation encoding | Experimental JS/Native CLI bridge. Source checks only; no generated runtime interoperability qualification. A future TS facade should expose Bend-native ECS contracts. |
| Standard Schema adapter | `standard-schema-v1/adapter.mjs`, `fixture.mjs`, host comparison/controls and shared runner's former host branch | Host conversion work can become an optional integration library. User callbacks remain in JS; this does not add reflection to arbitrary Bend Type. |
| Raw wire/codec tools | `runtime-v1` and `runtime-v2`: token parser, serializer, bit/scalar/UTF16 representations | Two source-checked entries and six authority negatives. V2 fixes malformed embedded-count overflow; 20 positive and 9 malformed draft cases. Large-input/runtime behavior remains unqualified. |
| Testing a TS facade | `runtime-v1/oracle-v1`, V2 raw source-check attempts/receipts | Complete 28 host/ECS draft models, transport models and seven Python controls. Final source binding unfinished; no backend-output qualification. Reuse as test research, not acceptance receipts. |
| TS helper libraries | Historical `Fx`, `Result`, `Definition`, Inspector facade and schema mechanisms in the census | Inventory/research leads. Existing native rollback, Local, typed declarations and read-only inspection remain approved ECS work; standalone TS helper API parity is pending. |
| Porting/reference research | [23-module census](ts-port/core-export-inventory.json) and its lossless gzip payload | Pinned TS symbols/signatures/usages/errors, not a required-export checklist. See [capability classification](../parity/coverage.md#capability-scope-reconciliation--61-preparation) for native capability versus TS mechanism. |

All paths in the first four rows are relative to
`experiments/public-decode/public-seam-v1/construction-v1/` in the preservation tag.
The census and its embedded regeneration/source records remain in this archive.

## Recovery

Inspect a file without changing the checkout:

```sh
git show archive/ts-port-inventory-2026-10-09:experiments/public-decode/public-seam-v1/construction-v1/standard-schema-v1/runtime-v2/README.md
```

Recover the whole experiment in an isolated worktree:

```sh
git worktree add ../bendvy-ts-tooling archive/ts-port-inventory-2026-10-09
```

Preserved provenance: `e472657d` original candidate, `b569ffe3` V2 source/attempts,
`f50bf12b` incomplete oracle draft, `1376ed4b` native/host boundary findings.
The complete combined root snapshot is `2661dda1`; this is the recovery authority.

Cleanup commit `e9638d73` removes `standard-schema-v1/**` and the shared reference runner's
`--standard-schema-host` branch. The ordinary TS ECS reference runner remains.
Native validation/construction, UTF16 data representation, rollback, Local,
persistence and the six qualified canonical construction modules remain in core.
A separate tooling project needs its own scope, public API and runtime/performance qualification.
