# Complete decoder candidate review

Read-only Spec/Standards review of decode.bend, size.bend, controls.bend,
bounded-controls.bend, negative-owner.bend, check-observation.py and
 development-run.py against CODING_STANDARDS.md and docs/parity/validation.md.

No blocker found for integrating this development candidate. Full #46 delivery
is not established. The executable seam is controls.main → run →
Complete.decode_owner → project(owner) exactly once → decode_projected →
Size.budget → D.owned/D.normalized. It returns the original arbitrary Type owner;
no Raw-to-owner inverse, owner duplication or second projection is introduced.
The affine sentinel fixture checks returned owner contents on both failure and
success. The negative-owner source attempts actual owner reuse; its intended
checker rejection still needs a retained source-current diagnostic receipt.

Automatic budget is structural Nat arithmetic, not a fixed depth/item bound.
codec_size counts each nullable/array wrapper and each struct declaration/child;
raw_size counts scalar leaves and array/object cells plus terminators. Their
product covers repeated schema traversal per input occurrence, including schema
fields absent from Raw. Nullable null stops; nonnull advances into its inner
codec. Missing required fields fail rather than materialize partial success.
Scalar literal alternatives do not add fuel work nodes; their equality/alternative
walks remain existing decoder operations. Canonical recursion consumes one
successor for `1n++more`, whose +more is reusable. The factor-four bound is a
conservative source argument, not a mechanically proved universal refinement.
No finite comparison is presented as such a proof.

Whole constructor joins preserve original Raw, every returned sentinel cell,
complete checked values/errors, list ordering and unknown-field removal. Actual
complete eight-case JS evidence reaches the new wrapper; fixed128 sibling differs
at the three long-array controls. That is a reached behavioral comparator, not
an independently planted complete-wrapper semantic mutation. Old bounded c1d52
oracle and failed comparison remain explicit; corrected v2 has exact64 struct
fields. No accepted canonical truncation claim survives the syntax correction.

Native receipt is terminal DEVELOPMENT_PASS: emit/build/run all exit0. This is
only the eight-case candidate scope. No backend was launched by this reviewer.

Remaining full46 gates: production/public callsite adoption; source-current two
schema ECS spawn/insert/resource observations and queue/world rollback; complete
negative authority/type controls; reached semantic mutant through the adopted
candidate; full immutable delivery tool/source/command qualification; governing
paired regression and equivalent-work feature performance evidence. Existing
numeric/UTF16/handle/descriptor adapters are not requalified by this small cohort.
Standard Schema host compatibility remains an inventoried obligation. A computed
budget removes caller fixed fuel but does not prove unlimited host stack/memory
capacity. No new laws, ownership contracts, dependencies or numerical gates were
accepted in this review.
