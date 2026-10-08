# Resource declaration binding: architecture for review

Status: source-only proposal. The committed trusted wrapper remains unchanged; no new implementation, allocator, callback, law or contract is selected here.

Pinned TS derives Inspector metadata from the same System access declaration that constructs its read context (Inspector.make91–128; System.collectSystemRequirements1018–1031). Resource descriptor constructors intern their keys by kind/name (Descriptor212/222/240), and Requirement.collect49–68 preserves the first occurrence of each key. Query access contributes no requirement. Runtime availability does not alter reflection; direct Inspector projection has no Schedule availability preflight. The existing Bend resource token identity is nominal schema plus resource ID (schedule-provision.same), with canonical token/name association authored in trusted schema setup. The TS fixture labels those actual keys with IDs; those labels are not an additional public TS field.

The smallest coupling seam is a schema-authored resource declaration indexed by the same closed projection used by the actual read grant, following component.Family's existing erased-lens pattern:

```text
ResourceDeclaration<S,R,V,Token,project> : Data
    canonical existing resource token + canonical display name
project : R -> R & V                 # existing trusted closed lens
BoundRead<S,H,V> : Type
    reflected resource metadata + actual Cap.ValueRead<H,V>
```

The schema exports closed canonical declarations. Repeated aliases reuse the same declaration; they cannot rename its token by supplying another display name to the builder. Existing authoring establishes the kind/name-to-token association once, outside gameplay. This proposal does not introduce a runtime symbol interner, ID allocator, global name registry or arbitrary descriptor-validation rule. Distinct IDs with the same name in the generic trusted wrapper remain outside the TS joined declaration seam. A general allocator/interner would need separate review and is not required for this fixed canonical seam.

A closed grant helper consumes the selected declaration and constructs both its metadata and I.read_resource(...,project) from that same declaration index. It never accepts a second requirements list or a second independently supplied projection. Metadata observes the actual authored declaration that produced the grant; no code introspects an opaque Plan or pretends supplied metadata establishes its truth. The declaration is Data because its lens is the existing erased closed schema parameter, not an affine captured owner. A captured or runtime-owned projection is excluded from this seam and would be a different ownership question.

For the first implementation, explicit schema Ops remains a fixed resource-only struct (score, scoreAlias, bonus), not a heterogeneous erased dictionary or permissive Ops<I.Frame>. The fixed builder constructs every grant and folds metadata in that same field order, using existing resource-token normalization and canonical first-name retention. An alias adds a read field but only one reflected requirement. Unpacking BoundRead moves its Cap.ValueRead exactly once and retains its Data metadata. Plan construction consumes the typed grants once; metadata reads only thread the entire opaque completed Plan owner back. An arbitrary Extra:Type owner, including two Arrays, may be carried alongside that Plan and must also return unchanged. Neither metadata assembly nor metadata read invokes the projection or owns a World.

This is narrower than a general 'metadata for any Plan' API. The existing generic wrapper continues to accept trusted supplied metadata and arbitrary affine Plan owners with its documented limitation. Only the declaration-built variant can claim coupling to its actual closed declaration fields. It cannot claim that every public Plan constructor or arbitrary user-built Ops has a declaration inventory.

Affected qualification for the narrow seam, to freeze before execution:

- Two nominal schemas with existing closed Array-preserving resource lenses; aliases reuse canonical declarations. Actual declaration order is Bonus2, BonusAlias2, Score1, and complete metadata must retain2 then1. Same-name constructor aliases map to canonical token3 twice and reflect one3. No name-based numeric-token allocation is inferred.
- Construction and repeated metadata reads preserve both Arrays and arbitrary Extra:Type plus the completed actual typed Plan. The full diagnostic reports every Array cell; a matched generic source witness additionally threads an opaque unknown Extra, so an Array-only shortcut cannot qualify ownership.
- After metadata reads, an independently authored actual Inspector consumer uses every produced read field and reports each complete resource projection alongside canonical requirement identity/name/order. Reuse the existing universally quantified opaque-H read boundary and existing closed projections; any new executable body must be reviewed before child execution. Do not substitute expected literals or a manually constructed Frame/cursor for real Inspector execution.
- Metadata-only absent/present declarations remain identical, with no availability effect. Any actual missing-resource projection result must follow the already agreed resource-view type and be tested separately; neither a manual branch nor reflected requirements is Schedule rejection.
- Matched source controls reject cross-schema declarations, mismatched indexed lenses, write authority/undeclared fields, owner duplication and opaque owner escape. Exact raw single-location diagnostic review remains separate from source exit codes. Existing generic-wrapper refusals are retained, not relabeled as declaration-coupling tests.
- A compiling binding mutation must swap the actual Score/Bonus projection while preserving metadata; the full actual projection oracle must reject it. A separately reached ordering/dedup mutation must preserve resource/owner observations and differ only in the intended reflected fields. Neither timeout nor framing-only output counts as a semantic kill.

Expected first gate is one pure source5 closed declaration-builder/opaque-owner witness. Actual pinned TS source-pinned cases and complete independent Bend literal outputs must be frozen before any consumer. Focused JS emit30/run5 precedes Native preparation/emission/Clang120/run5 with the usual complete joins and guards. Retained unaffected source/Node/JS/Native metadata and earlier retention capsules should be reused exactly, with affected seam evidence additive. No #54 closure, shared core adoption, proof or new policy follows merely from this proposal.

Open review point: canonical declarations currently belong to trusted schema setup, as existing Family lenses do. The reviewer must confirm the exact narrow constructor surface and typed declaration index before implementation. This draft does not select new public capture, service, held-view, foreign-Inspector or global identity policy. Root remains the sole src/ecs writer.
