# Static provider dispatch prototype

**Incomplete architecture probe. No performance keep, full22-gate pass, production API or universal refinement.** Governing issue: [#23](https://github.com/dearlordylord/bendvy/issues/23). The primary route uses erased provider binders in the callback type. Next scope is [a discussion draft](../../design/static-provider-dispatch-plan.md).

## Observed results

The old live Motion/Health callback constructs ten curried `run_clo` values per row. The new static-client/static-row chain uses direct saturated calls; its generated callback functions contain no provider closure construction. Remaining dispatcher/IO closures and owner/cache allocation are outside that count.

The initial two-module named route and a positive concrete invocation passed checking under five seconds. Five specific negative controls rejected cross-schema setters, write-provider substitution with a reader, wrong ledger authority, owner destructuring, and public concrete setters applied to an abstract owner. The rejection must be the intended type diagnostic, not a timeout.

Dense256/64-tick final records matched actual pinned bevy-ts output for Motion/Health on JS and Native. Native was re-executed with `--threads 1 --gpu off`, using O3. The existing validator checked every complete final row and authored checksum/ledger results. This is one world per schema/backend, not a repeated performance sample or every intermediate full world.

For selected handle ID0, two schema runs matched the original dynamic Bend path across dynamic JS, static JS and static Native: six complete records, each after16,384 missing-row callback attempts. All fields except the raw clock were compared. This is a missing-ID fallback observation, not a foreign-world identity test.

The full measurement-entry `--check-only` calls exceeded the five-second limit. Successful individual module checks, code generation and finite execution do not pass that missing gate. The complete22 connected gates and noise-qualified comparative measurements remain untested for this route.

## Language constraints verified

- Closed runtime closures remain affine; reusing one was rejected. A provider bundle cannot become reusable just because it captures no component.
- Closed template arguments produce direct calls while retaining a Type owner. Capturing a local owner in a template was rejected; duplicating a Type owner was rejected.
- Both erased and template Owner parameters rejected concrete owner pattern matching in the tested definitions.
- A `~client` parameter accepts the template callback when its type marks the provider binders erased (`@-get`, `@-set`, etc.), and its body uses ordinary call syntax. Runtime-provider types and `~` call syntax failed in earlier controls. The corrected example dispatched two independent callbacks and returned85. A captured runtime provider was rejected as a non-closed template argument.
- The real corrected adapter retained every existing body and changed eight callback type headers. Four further Motion/Health JS/Native final records matched the actual TS reference. This supports the bounded registration mechanism; a production registration API and universal authority proof remain open.

These controls establish bounded evidence in Bend2.0.35. They are not newly approved ECS laws or mathematical proofs. Original six opaque callback blocks remain byte-identical in the copied measurement module, but the new route executes separately declared template callbacks. It changes the execution contract and cannot be silently substituted into the old13-path measured session.

## Reproduction

Sources are archived as text so this direct probe does not add new runtime/check dependencies to the existing frozen session. The preparer verifies both existing28-module parent closures and produces29 actual modules per backend for the corrected callback type. `--named-route` reproduces the initial30-module named-row probe. It deliberately omits the parents' obsolete overlay/cache manifests and writes a prototype manifest that grants no gate authority.

```sh
python3 docs/research/static-provider-dispatch/prepare.py.txt \
  --repo /workspace/formal-proofs/bendvy \
  --sources /workspace/formal-proofs/bendvy/docs/research/static-provider-dispatch \
  --output /tmp/bendvy-static-probe
timeout -k 1s 5s bend /tmp/bendvy-static-probe/JS/experiments/s-integrate/prototype-static-client.bend --check-only
timeout -k 1s 5s bend /tmp/bendvy-static-probe/JS/experiments/s-integrate/held-adapter.bend --check-only
timeout -k 1s 5s bend /tmp/bendvy-static-probe/controls/positive.bend --check-only
```

`positive-registration.bend` must also exit0. All remaining `controls/*.bend` must exit1 with their specific type error inside five seconds. Exit124/137 is failed execution. Add `--missing-id-zero` when preparing the fallback fixture. Run `bend version` and `bend guide` before any extension. Codegen is capped at30seconds, clang at120seconds and runtime at5seconds.

Runtime commands used after codegen:

```sh
timeout -k 1s 5s node measurement-static.js 0 0 256
timeout -k 1s 5s node measurement-static.js 1 0 256
timeout -k 1s 5s measurement-static-native --threads 1 --gpu off 0 0 256
timeout -k 1s 5s measurement-static-native --threads 1 --gpu off 1 0 256
```

The Node reference was derived by unchanged `prepare-ts.py --schema Motion|Health --batch 1` from the pinned source adapter, then actually executed under Node24.20.0. The existing `measurement-bend-run.py.validate/normalized` functions checked the dense records. The fallback comparison removed only `milliseconds`. Raw clock fields were not selected as metrics or used for an improvement claim. Initial named-route receipts are in [evidence.json](evidence.json); the corrected registered route is in [registration-evidence.json](registration-evidence.json).
