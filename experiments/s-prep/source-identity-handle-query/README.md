# Exact identity handle query: source mechanism probe

The selected private measurement query returns handles through an exact identity client: `prototype_cont_handle_client` only calls its continuation with unchanged Main/Aux owners and the handle. It never calls either getter. The general query/client/getter families and the authored client definition remain unchanged. This experiment adds a separate handle-only route and redirects only the two exact Motion/Health registrations. It does not assume identity for arbitrary clients.

The input is the frozen joined flatjournal/Health-ledger overlay `/tmp/bendvy-joined-flatjournal-ledger-v1`, closure `8cb83bc7467ca8e9b0192b8dadd89d3c143262d37e812079342289be1c0f6e26`. Only `query.bend` and two call expressions in `measurement-bend.bend` change. All29 modules/cache maps remain coherent. No payload restriction, compiler/kernel/reference/dependency/law/proof change occurs.

## Source mechanism and retained alternatives

The pinned public Base has no general owning Array.rmw callback API. Array.get requires Data; Array.swap/set support arbitrary Type. The compiler recognizes those Base references as point primitives. A manual Array constructor match is different: matching ANode lowers to two `blk_half` copies and rebuilding lowers to `blk_node`.

* **v1, negative:** a regular generic `-M:Type` Array tree presence walk retained opaque M, avoiding nominal Cache/Main decomposition. It checked and preserved Motion JS/Native65 and Health Native65, but introduced block copying. Native Motion requests increased by20,971,520 and requested words by2,126,512,128. This is a failed representation, not an optimization. Its source, recipe, patch, build receipts and small parser negatives are retained.
* **v2:** `prototype_identity_array_inspect/restore` use unchanged Array.swap to temporarily replace a selected slot with None; match only `Maybe<M>` inside an erased generic `-M:Type` helper; put the exact opaque owner back with Array.set; return Array+Bool. M never travels through the closed nominal getter/client telescope. No Cache fields or payload fields are inspected. Native allocation counts decrease, but JS adds one transport Tuple/update.
* **v3, current:** `prototype_identity_inspect_state/restore_state` keep the same regular erased Type boundary and intrinsic operations, while taking the existing remaining arrays/id/namespace/values as ordinary owned parameters and returning StructColsState directly. No captured continuation or additional closure is introduced. The closed query caller never receives the Array+Maybe<M> intermediate. This removes v2's extra JS Tuple without changing its Native counts.

The private family preserves original id/nonzero/capacity/high, live and flag-selection decisions, missing Main behavior, ascending handle order and every World/Rows/metadata/pending/ledger/mode field. Aux remains owned and untouched, exactly as with the selected no-Aux-read client. Raw Main ownership stays Type; the helpers match only its Maybe wrapper and never copy Main. Public generic bodies and headers remain available for actual nonidentity clients.

## Fresh source-specific results

Both v2 and v3 pass diagnostic checker15, JS/C emission30 and approved private Clang19 O3 build120 for both schemas. Each schema/backend independently matches all65 full reference states under runtime5. The checker message is not a new ECS proof or law approval.

Fresh quiet and counted nine-world JS comparisons pass every field. v2 adds131,072 Tuple objects and393,216 object property initialization expressions per schema. v3 has **zero constructor and property-expression delta** against the actual joined source baseline. These counts describe executed expressions, not physical heap bytes or elapsed acceptance.

Independent Native attribution in `native-identity-query`, commits `6d803c3`, `4cb356c`, `a3a5198`, `b634a70`, pins actual29/source/entry/C/build receipts and independently observes65 full states. v3's entire counter output is byte-identical to v2 separately for each schema:

| Schema | Requests | RFC cells | Requested words | Difference per update against joined input |
| --- | ---: | ---: | ---: | --- |
| Motion | 17,171,399 | 8,479,038 | 41,507,855 | −5 requests, −2 RFC, −14 words |
| Health | 17,171,399 | 8,479,038 | 43,605,007 | −5 requests, −2 RFC, −16 words |

The independent executed map attributes the eliminated triplet to query restoration: Main/View each decrease from2,097,152 to1,048,576; Cache decreases from2,121,728 to1,073,152. Fold-row restoration remains. This is a source/ABI allocation mechanism, not a universal node-reuse claim, alias mutation or removal of compiler sealing/global sharing.

## Frozen reproduction

`materialize.py` is v3; versioned v1/v2/v3 recipes and patches remain separate. Run:

```
python3 materialize.py --input /tmp/bendvy-joined-flatjournal-ledger-v1 --output /tmp/FRESH
python3 build.py --schema Motion --core /tmp/FRESH/experiments/s-integrate --output /tmp/FRESH_BUILD --receipt /tmp/FRESH_BUILD_RECEIPT.json
```

The recipe pins all29 input source hashes, refuses existing output or changed sources/cache maps, validates both embedded/standalone cache metadata and supplied digests, and refreshes full source/cache maps. The legacy input lacks the optional specialized digest: its full specialized map is still checked exactly, and an explicitly supplied stale digest is refused. That initially overstrict infrastructure rejection is retained. Corrected replay is byte-identical for all29 files and both manifests; four refusal controls pass.

Versioned source29 maps and schema artifact pins bind actual entry, JS, C and Native binary. Build receipts contain original commands/caps/exits, not fabricated standardized build manifests. `counts.py` uses the current v3 catalog; earlier v2 catalogs and completed receipts are archived separately. Its site-metadata extension generates byte-identical instrumented runtime JS to the existing root instrumenter, and independently validates all nine counted worlds against fresh TS. Compiler/Base/guide pins are included; no canonical cap reset occurs.

v2 closure: `31c4913910dd315fdaac8507364129c9957feacb91c9f4c7010a219a3cc1869f`.
v3 closure: `0b3339e7fde4dc1af610ec76b1656b2f9c39748a546ba5929766d7445a51fa43`.

Independent query/access/arbitrary-affine-Type controls are being run in a separate source-bound package. Their v2 passes do not transfer to v3. Transaction mutations, confinement, undeclared/cross-schema access, write-through-read, nonidentity clients and retained full-shape owners require their own current-source evidence before broader acceptance. No elapsed qualification, adoption, canonical keep, universal refinement or production API approval is claimed here.
