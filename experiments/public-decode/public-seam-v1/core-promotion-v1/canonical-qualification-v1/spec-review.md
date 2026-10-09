# Canonical source adoption — independent Spec review

Reviewed `git diff b2ef9608...b9c7f63a -- src/ecs` (33 added modules), commit range, AGENTS/workflow, SPEC, parity index and live OPEN issues #43/#46/#58 (2026-10-09). Source/evidence inspection only; no checker/backend replay. Reference order remains Rust Bevy, Bend constraints, then TS inventory; pins are `.references/sources.json`.

**Source adoption blockers: none found for this tested bounded slice.** No wrong implementation or scope creep established. Ordinary declaration identity joins query/Family/save recipes; affine payloads remain Type; explicit projections produce detached Data rather than shared aliases. Save requires complete schema eligibility; plain leaves propagate False, transient leaves omit without consuming owners. Trusted schema constructors/lenses do not prove callback purity or language-wide secrecy. Decode/Local completion preserves the existing transaction, owner-recovery and deferred-barrier contracts; relation readers retain independent domains and structural publication boundaries.

The suggested SignedInteger overflow edge is not an executable adoption blocker: `numeric` converts magnitude/2^32 to U32, but pinned Bend `comp.ts` checks ordinary Nat arithmetic against 2^48−1 (207–208, 349–358, 448–453); JS host Nat admission is <=2^53 (455–461). Neither reaches the proposed >=2^64 truncation. This is source reasoning, not a new runtime test or permission for unchecked host inputs.

**Still-open acceptance gates:**

- #46 asks applications to “construct components/resources from typed raw input” and explicitly retains “Standard Schema adapter compatibility.” Closed projectors/installers are a verified admission slice, not a universal Raw-to-arbitrary-Type constructor. Generic declaration-bound construction/resource validation and inventoried host compatibility remain incomplete.
- #58 requires “Publish the exact snapshot contract and explicit difference between world save and runtime checkpoint.” Basic detached export is implemented; broader generic constructor/save coverage, public contract delivery and prerequisite #38/#46 acceptance remain open. Restore/identity/capture/Type-event policies are not selected.
- All three issues require “equivalent complete feature-specific TS/JS/Native observations and timing/scaling evidence.” Canonical decode archive1104b77b, JS/C review6f4a727b, adapter review4e9f141d, relation actual4c23c0dc/review23192e3a and actual-src snapshot review support their finite cohorts. They do not finish broader performance or proof obligations.

The unchanged #28 receipt at `/tmp/bendvy-canonical-delivery-regression-b9c7f63a-bound-refs/receipt.json` reports NO_CONFIRMED_REGRESSION for Workshop only. Adoption must retain those exact evidence joins and independent Standards review. No issue closure is justified by this review.
