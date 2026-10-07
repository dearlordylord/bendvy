# #39 schema fragments — completion

The executable fragment slice meets its functional and delivery evidence
criteria. Implementation and reviewed controls are committed on master in
`439aa496`. Full product parity and performance qualification remain open under
#1/#21/#23/#24; these parents are not closed by this slice.

`src/ecs/schema-fragments.bend` composes recursively authored affine owner packs,
validates each fragment before the combined registry, and checks initializer
requirements before consuming owners. Validation is kind-local, preserving the
observed key/name and public-construction error priority. Rejection returns both
actual owner packs. Closed manifests, lenses and initializers are trusted setup;
gameplay uses the existing abstract public capability boundary.

| Required behavior | Direct evidence |
| --- | --- |
| Empty, repeated, key/name and priority behavior in two schemas | Actual Node TS reference and full JS/Native cases in the worker and independent root receipts |
| Public component/resource/event/service application and explicit barriers | Complete before/after physical owner, service-call, event and queue observations in both nominal applications |
| Invalid composition before application effects, retained owners | Literal refusal observations, full owner return and reached name/collision omission controls |
| Cross-schema, undeclared access and affine misuse | Intended source-current compiler negatives; key/name/priority/barrier mutants compile and are detected |

The [final independent Spec/Standards review](../reviews/public-schema-fragments-final.md)
reconciles both 69-command, 22-case receipts and all 31 current project source pins.
Their complete portable artifacts and hashes are retained in
`experiments/public-schema-fragments/evidence/archive-index.json`; the independent
root archive is `1791351743039031911.tar.gz`.

The unchanged [default paired regression](parity-current-regression.md) passes
`NO_CONFIRMED_REGRESSION`; all 37 recorded core source hashes match. Complete
feature observations are retained in `benchmarks/parity-features/evidence/paired-v10/`.
Across one/two/four complete fragment lifecycles, descriptive JS/TS paired medians
are 1.246/1.352/1.489 and Native/TS 0.0260/0.0285/0.0313. Corresponding JS region
medians are 5.56/7.27/9.89 ms, versus TS 4.49/5.36/6.78 ms. All balanced pairs,
output bytes and source-stage inputs are retained; these small initialization
regions establish neither hot-path nor full-product qualification. No new
per-feature threshold, tolerated slowdown or baseline amendment is introduced.
The v10 nested-command mismatch concerns #34, not these fragment observations.

Bend 2.0.35, Node 24.20.0 and private Clang 19.1.7 were used with checker/emission/
Clang/runtime limits of 5/30/120/5 seconds. Reference commits match
`.references/sources.json`. [Three draft metadata laws](../laws/schema-fragments-draft/README.md)
have 245 finite instances and five reached defects, but remain unapproved;
no ECS proofs or universal owner/authority refinement are claimed. Approval and
later proof obligations belong to #62; general feature builders belong to #40.
