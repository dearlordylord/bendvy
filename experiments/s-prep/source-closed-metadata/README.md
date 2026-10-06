# Source-only metadata seed diagnostic

The private Bool-result eliminator removes the original Native wildcard seed in `storage.metadata_live`. It does **not** remove global wildcard hotness. Independent read-only compiler inspection finds the next first seed at `metadata_get_live` → `Array.get(Maybe<F>)`, before any wildcard was present. This is a verified partial source result, not a performance improvement or compiler refinement claim.

The public `metadata_live` header and every original generic definition/type header remain unchanged. The new helper accepts an affine runtime continuation and the Bool-array result; the continuation captures flags/added/changed once and reconstructs the exact original columns and Bool. Main/Aux remain arbitrary affine Type. Guard, journal, stamp, owner, handle and callback algorithms are untouched. One runtime continuation is introduced per reached `metadata_live` call; allocation and timing benefits are not established.

## Reproduction and boundaries

`materialize.py --input /tmp/bendvy-query-frozen-provider-native-v3 --output ABSENT_PATH` admits exactly the pinned 29-source closure, validates matching overlay/cache metadata, applies only `storage-cps.patch`, preserves original headers and refreshes every closure/source digest coherently. It refuses stale pins, mismatched caches, symlinks and an existing output. The reproduced overlay is `/tmp/bendvy-metadata-cps-reproduced`. The Motion static64 build and frozen executable are `/tmp/bendvy-metadata-cps-motion-build/{batch.bend,batch.c,batch.native}`; SHA pins are in `build-pins.json`.

Standalone storage and Motion executable checks pass within diagnostic15, C emission within30, and the already approved private Clang19 O3 build within120 on CPU9. The first Clang invocation omitted its required private-root environment and failed before compilation; the corrected receipt preserves that infrastructure failure. No proof/kernel changes were made. Checker success is executable validation, not approval or proof of ECS laws.

`validate-native.py` prepares and runs fresh TS64 and validates all65 complete Motion worlds against the actual Native output, each execution under5 seconds. All fields match. Emitted clock lines are not accepted measurements. The retained-metadata witness returns `(4, 9)`: marking changes the current stamp while the old Data snapshot remains4. The affine negative rejects using one Array owner twice. The separate affine component witness uses a Type containing an Array, rather than a Data-only payload. New API confinement/mutation gates and universal runtime refinement are not claimed.

## Independent seed observation

The inspector belongs to `native-construction-attribution`; compressed candidate receipts are archived here. It imports the pinned compiler read-only, uses Node's inspector and re-emits byte-identical C `0985682e9f9b4f6c829b9590dde6c7c88f383dc4742b8229503a6fc04c76dbbf`. The original `metadata_live` seed is absent. The next independent seed is erased F index2 resolving against the caller telescope's `added` domain during intrinsic Flag-array observation. Candidate2332 observed wildcard branches/169 distinct sites versus baseline2329/168 include post-wildcard consequences; they are not counts of independent causes.

## Frozen continuation limit

`live-context-probe.bend` tests the query worker's saturated, separately owned context technique with an open `-F` Flag. Its first attempt placed a template binder after a runtime binder and failed syntactically; correcting the ordering then failed substantively: “template applied to closed ~ arguments (F is a variable here, not comptime: pass it at run time).” The negative receipts are preserved. A frozen query has `~F`, while the original public generic metadata helper has `-F`; transporting Flag-dependent context types across that boundary cannot be treated as a closed instantiation. The compiling runtime-continuation candidate is preserved rather than silently weakening the public API.

Further work is a separately pinned private closed-Flag route from the two concrete schema registrations. It must account for reachable initialization, grow, remove and replacement dependencies before any global-hotness claim. This report does not adopt a source variant, reset a canonical allowance, qualify speed, approve new laws or transfer another experiment's gates.

## Later closed-frontier result

[zero-star.md](zero-star.md) records the separately pinned continuation through actual reservation/identity/reader initialization edges. Both exact static schema compilations observe zero conservative wildcard-add branches, and fresh JS/Native full65 fields plus affine finite controls pass. This later closed-program result does not turn the earlier generic CPS result into universal refinement or establish allocation/performance acceptance.
