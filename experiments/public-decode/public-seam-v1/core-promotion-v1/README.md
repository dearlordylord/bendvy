# Public core promotion candidate — review required

This is an import-only proposal, not a claim that master delivers #46. `core-import-only.patch` adds 18 modules under `src/ecs`; root owns application of the patch and shared integration. Every candidate Bend body equals its qualified source after removing import lines (`import-only-map.json`). Historical source and executed cohorts remain untouched.

## Public surface and dependencies

| Module | Typed surface / purpose |
| --- | --- |
| decode-requests | `Owner<S,C,R,E,P,identity,project>`, `Input<S,P>`, `Output<S,P>`; retained declaration admission, exact refused P; `finish` uses caller attempt/recover callbacks |
| decode-frame | trusted frame/provider assembly; arbitrary P/Q owners, actual transaction, external receipts; bodies receive opaque H |
| decode-traversal | affine args/state threading over current transaction-selected rows; committed-only Data observations |
| decode-declaration | ordinary query-derived `Ops<S,P,R,V,H>`, owned request/write/spawn/resource grants, read-only grant; `Cap.invoke_owned` body |
| decode-owned-component | same-family/lens owned replacement and exact owner refusal |
| decode-immediate | validated reserve/activate/reversible-install carrier; original owner retained on refusal |
| decode-owned-journal | external receipt unwind at actual ordinary undo counts; equal-position LIFO; Pending is incomplete recovery |

These seven modules depend on the **single canonical nominal** snapshot/Codec cohort: ordinary-declaration, persistence-declaration, declared-family, decode-data, decode, decode-size, decode-utf16, decode-capabilities, snapshot-leaf, snapshot-gate. `ordinary-query-declaration` consumes that same cohort. The remaining dependencies are existing core modules (world, transaction, capabilities, compose, component/column, resource, commands, bundle batch/install/construction). The patch includes the eleven dependency modules only as a coherent proposed integration cohort; do not install duplicate declarations alongside the separately proposed snapshot/Inspector promotions. Exact destinations are in `promotion-targets.json`.

## Ordinary application binding

`consumers/.../generic-assembly-v1/{public-fixture,first-public-fixture,recovery-fixture}.bend` uses ordinary query declarations, two distinct affine component/resource schemas and `Local.register`; opaque-H bodies exercise actual owned mutation, immediate spawn and approved Local recovery. `consumers/.../deferred-assembly-v1/fixture.bend` registers deferred owner-pack admission and canonical-barrier delivery. Both complete list-spine entries import the candidate library, preserving all 15 + 8 cases and original whole-model observations.

Deferred `Mail<R,P>` and its selective resource-value journal stay application code. They are an explicit recovery destination, not a global activation/cleanup policy or required public World resource representation. `Request.finish` already accepts application-selected attempt/recover functions. Installer/projector/lenses and Local state codec are ordinary typed application declarations; trusted provider code alone sees the frame/world.

## Exact delivery boundary

No contract decision blocks these bindings. Registration is usable through existing `Local.register`, but the success/error transaction-finalization adapter is still application code; there is no single generic `System` registration constructor that automatically joins this receipt/batch carrier. Root must decide integration shape under existing contracts before claiming that ergonomic API. This patch provides a finite read/write/decode/spawn/resource capability assembly, not a variadic replacement for every query clause or a new system-failure output contract.

Shared promotion must reconcile snapshot and Inspector nominal imports once, then run relevant public import/source checks and the established combined regression gates. Historical JS/Native evidence qualifies unchanged gameplay source, not the newly relocated nominal cohort's emitted artifacts. No performance or proof claim is added here.

## Checks

`python3 check-bindings.py`: PASS import-only closure; both complete source consumers; eight actual body negatives (undeclared grant, read-only write, cross-schema owner, affine duplication). CPU5/shared lock, 5 seconds per source check; no backend replay. `source-checks.json` preserves results. Reuse the independent generic15/deferred8 models and the archived successful list-spine JS/Native full observations; original models remain unchanged.
