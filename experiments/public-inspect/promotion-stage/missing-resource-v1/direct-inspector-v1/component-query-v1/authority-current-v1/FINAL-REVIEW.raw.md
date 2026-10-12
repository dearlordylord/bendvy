# authority-current-v1 final review

## Verdict

**Bounded acceptance as current-public source-authority evidence.** The packet provides one successful public-query source witness and five intentional, single-location source refusals at the claimed authority boundaries. It supports the stated finite generic-opaque-`H` classification for the current public `Inspector`/query surface. It does not establish runtime behavior, a universal policy, callback or foreign-`Inspector` policy, compiler-wide adoption, performance, or any broader #54 credit.

## Exact packet and joins

I reviewed producer commit `2d3c36947a4ea0d0c950c363f5dd535b2a5e851f` (`Retain current public query authority source controls`) in the observable-query-boundaries worktree. Its authority-current-v1 subtree contains exactly 70 committed paths and has no scoped working-tree changes. `DELIVERY.json` classifies it as `SIX_CURRENT_PUBLIC_AUTHORITY_SOURCE_CONTROLS`; its `CLASSIFICATION.json` member is SHA256 `e05ad4542e335b88655659287497ab91d6d82aebd3c97fe963a60bc040307b3c`. The 101-member `EVIDENCE.zip` is 262,588 bytes with declared SHA256 `4c6675e941de24df139ac1b36d48b36e65247ed9683acb866d0a75402c3b8829`. I checked all 101 names, sizes, and hashes: no missing, extra, or mismatched member. The six source, plan, receipt, stderr/stdout, and guard joins are exact.

`SOURCE-PINS.json` contains 54 exact live-input pins. Each role plan independently records one source entry, a 28-file source/import closure, 49 plan pins, three resource roots, four tools, and eight environment entries; the recorded live hashes matched. All six roles use the pinned Bend 2.0.35 binary, taskset CPU 3, a five-second source-check cap, split output capture, and the existing runner. No new runner or compiler change is present.

## Witness results

All six receipts are `COMPLETE_SOURCE_CONTROL_PASS`, with `failure: null`; each final guard records `unchanged: true`, and all 24 guard files hash correctly. Final guards carry 52 actual pins. The positive has expected/actual exit 0, 58-byte standard proof stdout, and empty stderr. Each negative has expected/actual exit 1, empty stdout, and `sourceControlPassed: true`; each diagnostic contains exactly the intended `Location: bad` witness location and the expected boundary text:

| witness | intended source boundary | recorded diagnostic |
|---|---|---|
| `positive` | current `Q.ReadQuery`/`Q.get` public query | pass |
| `write` | read query supplied to `Cap.set` | expected `Cap.Write`, observed `Q.ReadQuery` |
| `undeclared` | `Consumer.Reads` supplied to `I.lookup` | expected `I.Lookup`, observed `Consumer.Reads` |
| `owner-escape` | abstract owner returned as `String` | expected `String`, observed `bad~H` |
| `owner-duplicate` | owner consumed twice in `(owner, owner)` | `consumed more than once` |
| `check-lifecycle` | `I.Frame` predicate passed where `K.Frame` is required | expected `Selection.Predicate<K.Frame`, observed `Selection.Predicate<I.Frame` |

The five refusals are source-level compiler witnesses only; the receipts do not claim runtime or universal policy behavior. The source files import the current public `/workspace/formal-proofs/bendvy/src/ecs` modules and the current component-query `schema-families.bend`/`execution.bend` closure. No private or mutant `done-cursor` source appears in the six witnesses.

## Authority interpretation and limits

The current public query module declares `Q.ReadQuery`, `Q.Lookup`, `Q.get`, and `Cap.ValueRead`; the current component-query execution module defines `Execution.Reads` over `Q.ComposedReadQuery` and builds ordinary operations with `Q.grant_composed`, then dispatches through the public `I.run`. The positive witness directly exercises the public `Q.ReadQuery`/`Q.get` path while importing that current execution closure. The negative controls test write misuse, undeclared lookup, owner escape, duplicate consumption, and the `I.Frame`/`K.Frame` lifecycle distinction at their actual current source boundaries.

The classification explicitly limits historical private-core material to witness shape and supplies no new contract, borrowed-ownership, foreign-`Inspector`, or cross-schema fixture credit. This review therefore retains the packet only for its finite current-public authority claim. It is check-only evidence and does not add JS/Native, runtime, full-oracle, performance, compiler-adoption, universal, callback, foreign-policy, or #54-closure credit. Those claims remain outside this packet and must rely on their separately qualified evidence.

## Validation and residual risk

Validation was read-only: commit/tree/status inspection; JSON parsing; independent SHA/size checks for the 70-path subtree, 101 archive members, 54 source pins, six source/plan/receipt joins, all 24 guards, and all diagnostic witness substrings; and source inspection of the six controls plus current public query/Inspector/execution definitions. No compiler, hook, backend, or source mutation was run. Residual risk is limited to the declared finite opaque-`H` source-check scope and the absence of runtime/universal/foreign-policy proof; there is no packet-integrity or stated single-witness-location blocker.
