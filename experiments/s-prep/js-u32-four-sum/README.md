# Exact closed Four/U32 sum cast probe

This final small generated-JS causal probe applies to the unused-read descending **firststage** outputs. It excludes nested Tuple, constant-swap and state reuse. It changes only the exact authored `prototype-static-client.sum` (batches) and protected `gate-callbacks.sum` (controllers), independently pinned by complete program, source29/extra/producer and body hashes. It is not a generic arithmetic optimizer.

The source declares `Four is Data` with four U32 fields. Both exact source helpers match `def sum(value:T.Four) -> U32` and `U32.add(U32.add(a,b),U32.add(c,d))`. The emitted body first reads a,b,c,d in order, then computes `(a+b)>>>0`, `(c+d)>>>0`, and `(x0+x1)>>>0`. Only the two inner casts are removed; the local bindings, read/addition order, and final unsigned wrap remain.

For the admitted U32 domain, each field is an integer0..2^32−1. The two pair sums are at most2^33−2 and the total at most2^34−4 =17,179,869,180, below2^53. JavaScript Number additions are therefore exact. Dropping the two intermediate reductions does not change the final reduction modulo2^32. This is an explicit bounded numeric argument, not an ECS law proof, source/compiler modification, or legality claim for unknown Number/BigInt/FFI values. All existing raw affine Type domains are preserved.

Source closure `b0fdd6c41be12b34efc79e45edc98225c1b0158a51976b432a1646bfcae9e8f0`. Actual input catalog has two batch and eight fresh protected/suppressed source variants. Unknown programs, changed source facts, fields/operators/shifts/helper bodies/provenance, or occupied outputs refuse. The recipe preserves every other byte of the generated program. No new source dependency, compiler/runtime-original/kernel/reference/law/proof change occurs.

Fresh bothschema full65 fields, before/after nine-world comparisons and all576 actual controller records pass. Literal/closure counts are unchanged. BigInt oracle controls pass2,320 U32 edge/seeded quartets (including0, maxuint and both signed edges), plus five field-read/exception-order comparisons and four malformed/unknown-input refusals. The getter-based order fixture is instrumentation only, not admission of foreign getter-backed/unknown numeric objects. The initial negative test changed an unrelated same-named field local; the corrected test targets the exact pinned sum helper. That harness failure is retained.

Motion `/tmp/bendvy-u32-sum-motion.js`, SHA256 `177aceb39757ee0c34d0b61fc6b25f703817e2c12c358ce2729b8f1e29e32109`.
Health `/tmp/bendvy-u32-sum-health.js`, SHA256 `91c3cd2a8e349d186b85ebeaf051f5fc36b280a0fabce3b26ab24014b1f0c8e4`.

```
node --expose-internals rewrite.cjs EXACT_PINNED_INPUT.js FRESH_OUTPUT.js
python3 controls.py --output FRESH_DIRECTORY
node --expose-internals edge-controls.cjs EXACT_PINNED_INPUT.js EXACT_CANDIDATE.js FRESH_DIRECTORY
```

All semantic runtime children use CPU7 and the unchanged five-second descendant supervisor. Complete command/source/recipe/catalog/output receipts are archived. Root owns elapsed comparison; two removed casts are not evidence of a speed or heap benefit. No canonical reset/qualification/adoption or universal refinement is claimed.
