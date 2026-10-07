# #39 schema-fragment metadata laws — unapproved draft

**Human approval is still required for these exact three laws and their model before any ECS proof.** No `PROOF.bend` or paired proof definitions were written. [LAWS.bend](LAWS.bend) deliberately contains three open claims; its checker-only run fails with exactly three TODOs. The finite executable controls below are falsification evidence, not proofs or universal refinement.

## Proposed subjects, in priority order

| Draft subject | Exact claim and rationale | Literal instances / reached defects |
| --- | --- | --- |
| `collision_classification` | `check_one(seen,item)` equals independent kind-local key/name classification: any same-kind key collision returns that exact DuplicateKey; otherwise any same-kind name collision returns exact DuplicateName; otherwise Valid. Key wins when both collide. Prevents forbidden composition and accidental cross-kind rejection. |101 instances: all 25 kind pairs × 4 key/name combinations plus empty. Detected key omission, name omission and a component/resource kind-confusion defect. |
| `validation_priority` | `validate(entries)` equals a reference scan in Component→Resource→Event→Relation→Service order, then original declaration order within each kind; each duplicate entry checks key before name. Full error kind/key/name is preserved. Prevents correct rejection with the wrong observable error. |42 instances: empties/singletons/duplicates, every pair of conflicting kinds, and earlier-name versus later-key collision. Detected resource-before-component defect. |
| `declaration_membership` | `descriptor_present(entries,item)` is true exactly when some entry matches **kind, key and name together**. Prevents a declared key from authorizing a differently named descriptor. |102 instances: all 25 kind pairs × 4 field combinations, empty and a later matching entry. Detected name-equality omission. |

The laws quantify over Data metadata lists for one nominal phantom `M.Schema`, without length bounds. The tested literal domain is much smaller than those claims. `model.bend` supplies the reference functions: numeric kind equality independent from Core.same_kind; separate key/name scans; a priority validator scanning the original list rather than Core's pre-filtering; exact triple membership. Approve the reference functions as part of the law meaning, not just their names. Core helpers under review are [check_one](../../../src/ecs/schema-fragments.bend:58), [validate](../../../src/ecs/schema-fragments.bend:81) and [descriptor_present](../../../src/ecs/schema-fragments.bend:100).

These are **not** claims about affine owner packs, arbitrary component access, callback effects, successful initialization, actual descriptor-token identity, public authority or universal merge refinement. Raw constructor metadata is Data; arbitrary affine Type payloads remain supported by the production API and are neither copied nor restricted here. Left-fragment/right-fragment/combined merge validation precedence remains separate from the proposed `validate` law. Existing #39 application and ownership gates remain necessary.

## Primary source boundary

Pinned TS [internal/fragments.ts](../../../.references/bevy-ts/packages/core/src/internal/fragments.ts:10) defines kind order components/resources/events/relations and [mergeRegistry](../../../.references/bevy-ts/packages/core/src/internal/fragments.ts:23) checks key before name, accumulates descriptor names and returns left/right registry spread. [Schema.fragment](../../../.references/bevy-ts/packages/core/src/Schema.ts:231) validates construction before later merge/bind. Raw structurally authored TS input can bypass that boundary; do not infer a raw merge law from public construction traces. Bend Service is additional provisioning metadata, not a TS Schema registry parity claim. The source-backed choices above prioritize actual error/membership observations; they do not invent commutativity or global collision rules.

Reference HEADs checked: TS `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`, Bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60`, Bend `a950fd683c0d76f09794078e6174fe98a1492876`. TS fragments source SHA256 `4220e09fcc78e50cecd05ec373f57a278a5c33fbd51c53cbb2f7d57c6593ba68`; governed Core `83525f185b6099d48af4e3a14f30149cd94069ad5e29663c63e44a15a866cfe6`. Read AGENTS, next checkpoint, #39, SPEC, remaining-core spec and bend-ldd; ran Bend 2.0.35 version/guide. No dependencies, existing experiment/core modifications or performance measurements.

## Exact finite evidence

Executed `python3 docs/laws/schema-fragments-draft/falsify.py`. [Receipt](evidence/receipt.json) reports `PASS_LITERAL_FALSIFICATION_AND_REACHED_MUTANTS`:245 literal instances compare actual Core output **and** independent Bend reference output against an independently implemented Python oracle; all five planted source defects check, compile to JS and produce a reached literal mismatch while the independent reference retains the expected output. Every witness records its law subject, full input, expected and actual outcome, mutation hash and mismatch indices. For example:

- Key omission: existing Component(a,A), incoming Component(a,A): expected DuplicateKey(a), mutant Valid.
- Name omission: existing Component(a,A), incoming Component(b,A): expected DuplicateName(A), mutant Valid.
- Kind confusion: existing Resource(a,A), incoming Component(a,A): expected Valid, mutant DuplicateKey(a).
- Priority swap: earlier Component-name conflict X plus Resource-key conflict k: expected Component DuplicateName(X), mutant Resource DuplicateKey(k).
- Membership omission: declared Component(a,A), requested Component(a,B): expected false, mutant true.

Only new local `evidence/stage/core.bend` copies were mutated; original Core SHA is checked unchanged at completion, as are law/model/runner hashes. No law text/model was changed for the mutants. Outputs, inputs, expected full results, emitted JS and generated fixtures are retained (~836KB). CPU 11 pin, checker 5s with `--check-only`, JS emission 30s, Node runtime 5s. JS-only literal execution is explicit: no Native comparator, TS replay, verdict or approved-law proof gate is claimed. A timeout would be inconclusive, not a pass; none occurred here.

LAWS SHA256 `b4d16f96ee11a600a41435e1f9ba2c1a8c5b708be39535239acf8a7ea54d09a6`; model `6f31bb01332bbb8ce8027c72bf14431f995c8a4dcb60271e938a56f7c2ead5bf`; runner `7bd03b5c68cac2b4543b3c26badeb424bac00b0549b12fcbcd1ed5f6f8db1e4f`; receipt `090befc1ea4bdbb18e341e3ed475253aec14ef5c6a4f5c70fd33a51dd59ec241`. [Open-claim diagnostic](evidence/draft-open-claims.json) retains the expected three-TODO failure; it is not a passing proof.

Next step is review and explicit approval of these exact subjects/model. After approval, proof planning may proceed against the approved text, retaining each reached mutation as a subject-specific control. This package does not close #39, approve laws implicitly or substitute for its source-current application/owner/negative/performance/delivery gates.
