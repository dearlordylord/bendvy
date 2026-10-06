# Direct Array.peek call product split

Bounded generated-JavaScript causal probe only. No Bend/compiler/kernel/reference/oracle/dependency/law/proof edit, mutable global/alias rewrite, adoption, universal refinement, qualification or canonical cap reset. The preceding local-only hypothesis found no local literal sites; this separately authorized probe examines concrete call boundaries.

## Feasibility before rewrite

In `/tmp/bendvy-cache-box-js-build/baseline.js`, Array.peek is already lowered to a plain literal as the last argument of a named helper:

```
receiver(previousArgs, {$:"Tuple",fst:array,snd:array[index % array.length]})
```

The matched receiver only reads its pair parameter's fst/snd properties. Acorn found 23 supported direct edges and 23 distinct receivers; seven edges executed in the prior baseline phase. Prior site counts predict **786,944 fewer Tuple constructions**: six per 131,072 point callbacks plus 512 capture-cell reads. The feasibility receipt was sent before implementing the rewrite. No tiny producer was inlined because the actual producer is already this exact literal expression.

## Transformation and limits

`rewrite.cjs INPUT FRESH_OUTPUT` requires one of the frozen input SHA256 values and an absent output. It accepts only exact ordered plain Tuple fields and the array-identity/modulo-length peek expression above, as the final argument with exact receiver arity. The receiver must be a uniquely declared top-level named function, without reassigned or shadowed bindings. Binding-pattern analysis conservatively collects all local/parameter/catch/import names; any matching name excludes that edge globally. Duplicate receiver binders, nested functions, pair escape/write/delete/identity/tag test, arguments/eval/this-sensitive constructs and uncertain pair references are refused. Every pair reference must be a direct nonoptional fst/snd projection. No arbitrary unknown producer or function parameter is treated as monomorphic.

The specific call changes to a derived receiver with the final pair parameter replaced by fresh scalar parameters. Existing preceding arguments evaluate in their original order, then fst and snd evaluate once in their original order at the old construction point. Scalar parameters retain these exact values; repeated receiver reads cannot re-read or recompute a field. The receiver body retains every operation, branch and mutation of its original field owners, replacing only pair projections. Original function signatures remain for other edges. Derived bodies retain the same eligible static calls with the same split, so helper chains avoid reintroducing their eliminated products. No new per-call closure, wrapper tuple or continuation is introduced. Twenty-three static function declarations add 12,998 bytes (320,245 -> 333,243 JS bytes); fixed code/startup cost remains a tradeoff.

Removing allocation changes resource exhaustion behavior and function names/stack traces; this is not a general JavaScript observational-equivalence theorem. The frozen workload observes authored ECS outputs, not allocation identity or generated stack names. No direct alias mutation is introduced: raw arrays and all field identities remain exactly the values passed by the original literal.

## Verified finite results

CPU9 quiet diagnostic, per-runtime cap5: normal and counted rewritten Motion builds each pass nine complete worlds against a freshly executed TS adapter. Existing shared `js-profile/run.py --cpu 9 --no-gc` supplies phase-only CPU profiles and complete validators; runner/instrumenter hashes are archived. Full outputs are retained. No additional physical heap sampler or stable speed comparison was run.

Exact Tuple executions: **2,502,144 -> 1,715,200**, delta **-786,944**, matching the pre-rewrite prediction. Arrow/FunctionExpression closures and all other tagged constructors are unchanged. Candidate total tracked construction expressions are 9,300,032. The prior baseline receipt totals 10,086,977 and includes one additional diagnostic marker object because its instrumentation was inserted after marker injection; candidate instrumentation preceded marker injection. The raw total difference is therefore -786,945; after that one marker object, the program-construction delta is exactly -786,944. Counts are executed construction expressions, not physical allocations/bytes or speed acceptance.

All eight supplied cached/raw transaction fixtures, including actual suppressed-owner Motion/Health variants, were rewritten and executed. Every full observed checkpoint line matches the original byte for byte: 72 per fixture, 576 total. Normal fixtures use stored `.js.jsonl`; suppressed fixtures have no stored transcript and compare against fresh original execution. Actual mutant effects remain present; no original mutation gate is silently asserted authoritative for derived generated helpers. Source inverse/read/access functions are unchanged, but no Bend source gate or universal alias theorem is claimed from this generated-code comparison.

The separate order control retains all four old fields, writes through the same raw owner, and verifies old/new scalar values, remaining fields and exact effect sequence. A preceding argument exception occurs before the peek; a throwing element read occurs after the preceding argument and before receiver entry. Original/rewritten outputs equal independently specified expected lines. Five controls (pair escape, pair write, nested capture, shadow, reassigned callee) refuse without creating output.

## Reproduce and follow-ups

```
node --expose-internals experiments/s-prep/js-call-product-elision/rewrite.cjs INPUT FRESH_JS
python3 /workspace/formal-proofs/bendvy/experiments/s-prep/js-profile/run.py --cpu 9 --no-gc --generated-js FRESH_JS --output FRESH_PROFILE
python3 experiments/s-prep/js-call-product-elision/run-scope-controls.py --output FRESH_CONTROLS
python3 experiments/s-prep/js-call-product-elision/run-tx-controls.py --baseline /tmp/bendvy-direct-raw-tx-baseline --output FRESH_TX
```

Derived full64 candidate `/tmp/bendvy-js-call-product-final.js`; normal profile `/tmp/bendvy-js-call-product-profile`; counted profile `/tmp/bendvy-js-call-product-counted-profile`. Frozen evidence includes input/output JS, matched catalog/prior counts, current kind counts, complete outputs/profiles, eight original generated controller inputs, transaction output transcripts and scope controls. Archive hashes describe uncompressed bytes. Source pin values label provenance, not a general accepted input grammar.

Physical heap attribution, a fresh adjacent quiet performance comparison, compiler-side implementation/design, extended schema/workload controls and canonical acceptance remain follow-ups. The source query CPS failure (14 closures/ID) is not adopted here: this diagnostic uses static emitted receiver declarations and no curried callback transport.
