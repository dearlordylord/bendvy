# Constant Array.swap product diagnostic

The exact composed Motion program has eight eligible direct-call swap edges into seven receivers. Each eligible execution removes its constant-arrow closure and the runtime Tuple construction. The eight-world timed phase falls from 7,333,952 to 6,809,664 counted constructions: 262,144 fewer `Tuple` objects and 262,144 fewer arrows, two of each per point callback. Every other counted kind is unchanged. These are executed construction-site counts; instrumentation changes JIT escape optimization, so they are not physical allocation bytes or a speed result.

The same result holds independently after the store-elision pass. Both inputs passed nine full Motion worlds against fresh TypeScript normally and with counters. Their eight cached/raw/suppressed-owner Motion/Health controllers passed all 576 checkpoints each, 1,152 total, byte-for-byte against freshly executed inputs. No Bend source, compiler, reference, proof, law, dependency or shared runner changed. This is a closed generated-program causal probe, not general JavaScript optimization legality or universal affine alias refinement.

## Exact transformation and limits

`rewrite.cjs` requires a pinned input and all 29 actual source hashes for production inputs. It matches the exact existing `array_rmw` runtime, which computes `i % a.length`, reads the old slot, calls the function, writes the replacement, and returns `Tuple{fst:a,snd:old}`. Only its occurrence as the final argument of an immutable, uniquely named, unshadowed receiver call is eligible. The receiver's final parameter must be used exclusively through read projections of `fst` and `snd`; escapes, identity tests, writes, reflection and uncertain nested functions reject the edge. Original functions remain for other callers.

The arrow must have no parameters and return a unique, dominating local `const` identifier. Array, index and replacement names must resolve to unique local/parameter bindings; explicit object index initializers are refused. Getters, setters, proxies and reflection constructs are refused. These pinned closed Bend-generated programs use ordinary arrays and numeric U32 indexes; there is no arbitrary external array ingress at the selected edge. That closed-program fact is a scope condition, not a generic JavaScript claim.

The call evaluates all previous arguments once and in their original order, then passes the array, index and immutable replacement value to a new static receiver bridge. The bridge computes modulo, reads the true old value, writes the replacement, then executes the original receiver body with scalar array/old parameters. Reading the already initialized immutable replacement identifier early adds no observable effect in this scope. There is no new per-call closure, mutable global, object alias mutation or CPS chain. Both `struct_idx_selected→struct_idx_main` instantiations qualify. The `struct_idx_main→struct_idx_aux` edges retain their original code because their receivers contain nested callback closures outside this conservative scope.

## Controls and reproduction

The finite witness preserves a full four-cell/stamp Type payload, a retained immutable Data snapshot, array identity, true old contents, non-power-of-two modulo, the empty-array NaN property behavior, prior-argument mutation order, and a prior-argument exception that leaves the swap untouched. Fourteen refusal controls cover an impure arrow, unknown receiver, pair escape/write/identity/capture, getter, proxy, shadowed/reassigned receiver, mutable replacement, object index, changed runtime, and a const that does not dominate the call. An initial witness expectation mistakenly overlooked the prior argument extending the empty array; originals and candidate already matched. The corrected witness and the diagnostic are retained.

```sh
python3 experiments/s-prep/js-array-swap-elision/run-cases.py --output /tmp/swap-cases-fresh
python3 experiments/s-prep/js-array-swap-elision/run-scope-controls.py --output /tmp/swap-controls-fresh
python3 experiments/s-prep/js-profile/run.py --cpu 9 --no-gc --generated-js /tmp/swap-cases-fresh/baseline.js --output /tmp/swap-nine-fresh
```

Outputs must be absent. Controller/control children use the existing owned-descendant supervisor, CPU9 and five-second limits. The unchanged shared profiler checks a warmup and eight complete fresh Motion worlds. The pinned inputs and output programs, controller observations, profiles, counter catalogs, source overlay, command receipts and runner hashes are archived in `evidence/`.

Full64 candidates for the root's separate fresh65 comparison:

| Input | Candidate path | SHA256 |
| --- | --- | --- |
| Composed `a9e530c4…` | `/tmp/bendvy-swap-elision-combined-verified/baseline.js` | `119b3225a6cf9230c49a69a29d1e2ec72cf1e0919bf6c6b5fe189968481d9bdc` |
| Store-elided `177539ce…` | `/tmp/bendvy-swap-elision-combined-verified/store-baseline.js` | `41010049c0cc1fe45e3a1a198bb1183e673819f97b1cc3e9ec771115fdcd4f4d` |

Both are also frozen as compressed JS artifacts. Read-wrapper composition needs separate explicit intermediate input pins and unchanged guards. This task does not claim that composition, independent Health batch coverage, Native improvement, physical heap reduction, source mutation gates, canonical keep/full22 or performance acceptance.
