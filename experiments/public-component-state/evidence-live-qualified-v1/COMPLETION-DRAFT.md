# #47 completion report — integration draft

**The finite public component-state acceptance criteria are implemented and source-current verified; final independent review, commit/push and issue delivery remain pending.** Generic typed state operations are available in `src/ecs/state.bend`, with consumer-defined vocabularies, equality, legal move endpoints and checked write requests. This is entity-component state, not a global scheduled state machine.

## Acceptance evidence

- Actual pinned TS execution observes 54 Descriptor.State checkpoints covering defaults, legal values, matching, construction and invalid inputs. Three constructor observations are compared across TS/JS/Native. No default is fabricated.
- The complete 62-row public application exercises independent Phase/Mode state families in two nominal schemas, heterogeneous queries, replacements and changed readers, a deferred barrier and failed-write rollback. Four-cell affine Array neighbors are fully materialized and preserved. Six independent same-schema foreign-world rows, five access rows, five raw boundary rows and seven clock rows preserve exact refusals and returned owners.
- Eight intended type/location controls reject illegal state/edge/raw type, undeclared access, owner duplication, write-through-read, read-as-write-request and cross-schema use. Five compiling semantic mutants reach actual divergence on both JS and Native, including the wrong-state endpoint mutation; no compiled-but-unexecuted mutant receives credit.
- Fresh actual-live replay is `PASS_FINITE_SLICE`, 87 commands: [receipt](receipt.json.gz), decompressed SHA256 `1219a8ef1bb3c0d5e3eaee56b1c8c577a695afbf3af00ed9f092973005bb4183`. All 61 consumed-source pins remain current, including the adopted exact string equality/lazy registration World. [Terminal verification](terminal-source-check.json) and complete logs are retained.

## Performance evidence and remaining qualification

Complete feature-specific TS/JS/Native timing retains all 120 balanced pairs at 1/2/4 complete lifecycles, with full outputs inside the timer. Latest qualified staged observations: JS/TS **2.8922 / 2.8217 / 2.7233**; Native/TS **0.05104 / 0.06079 / 0.07476** (about 19.59/16.45/13.38× faster). [Complete retained timing](../world-equality-promotion/lazy-registration/evidence-timing-observations-v2/RESULT.md) and all samples remain available; no outliers were dropped. This subject's exact World/helper bytes were adopted, then fresh live semantics and default regression were run. Comparative measurements were not repeated solely for adoption.

Before/after CPU and collected-allocation profiles use the same complete workload. Exact equality removed generic ordering/reconstruction; lazy predicates avoid string work after an ID mismatch and stop after an exact registration match. Sampled JS allocation traffic at scales 1/4 declined from 3,518,184/11,547,664 bytes to 2,307,584/7,089,632 bytes (34.4%/38.6%). These are weighted sampled allocations, not physical/RSS memory reductions or a causal speedup guarantee. [Initial findings](../profiling/findings.md) and [qualified profiles](../world-equality-promotion/lazy-registration/evidence-profiles-v2/RESULT.md) retain full outputs/profile hashes. Short CPU samples and contextual host load limit attribution.

The unchanged default #28 gate is `NO_CONFIRMED_REGRESSION`, 43 source pins and exact 38-module inventory; affected reader replay also passes 99 commands. [Batch regression evidence](../../../docs/reports/feature-world-batch-regression.md) retains current receipts. This named workload is distinct from full-feature qualification.

**Full-feature JS parity remains unmet:** the complete state application is approximately 2.72–2.89× slower than TS. Existing performance qualification stays open under **#21/#23/#24**; the observed Native results do not erase that deficit. No new numerical threshold, tolerance, baseline or acceptance waiver is inferred.

## Trusted boundaries and verification limits

Consumer equality, legal-move endpoints, decoder and provider implementations remain author contracts. The public adapter propagates exact decoder errors and actual checked write statuses; a local accepted write does not imply surrounding transaction commit. Live absent-family upsert remains legal; foreign handles retain the approved MissingEntity divergence from TS numeric-ID collisions. Attempted legacy helpers are outside the public surface. General unknown decoding/host serialization belongs to #46.

These are finite executable comparisons and reached defects, not universal graph/ownership/runtime refinement. State and equality laws remain unapproved drafts; no ECS proof was written. Runtime-supported String representation is preserved, including the documented JS/Native lone-surrogate discrepancy; no compiler/domain policy was changed.

Bend 2.0.35, Node 24.20.0 and approved separate Clang 19.1.7; current replay CPU 11, Native one thread/GPU off. Caps checker/emission/compilation/runtime 5/30/120/5 seconds. Receipts bind source/stage/mutant inventories, tools/config/libraries, reference HEADs and logs; descendant supervision retains timeout boundaries. References: bevy-ts 3040a3b2a3f28fa8554d856f9ccb6bf5433fa334; Bevy ad678262ce53b5d142fe49ee5e08caff6f00ab60; Bend2 a950fd683c0d76f09794078e6174fe98a1492876.

Integrator must complete independent Spec/Standards review, master commit/push and governing-issue report before closure. This draft grants no closure approval.
