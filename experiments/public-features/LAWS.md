# Feature composition law drafts

UNAPPROVED. No proofs or universal runtime refinement are claimed.

1. Selection names retain authored left-to-right order; dependencies never reorder builders or aggregated schedules.
2. The first repeated selected name rejects before missing dependency or schema validation and before any builder invocation.
3. With unique selected names, the first absent direct dependency rejects in selected-feature then authored-requirement order. Transitive visibility follows the actual authored dependency tree; runtime validation remains direct because every selected feature is checked.
4. Rejection returns the original arbitrary affine owner pack, with no builder effects. Metadata equality does not prove capability authority or inverse identity.
5. Visibility grants consist only of the feature's own descriptors plus recursively authored dependency descriptors; exact repeated descriptors collapse only in the grant set; conflicting descriptors remain errors. Repeated direct dependency references are permitted, while duplicate selected names reject. Concrete capability provisioning must check these grants and rank-2 gameplay must remain opaque.

Literal falsification will compare independently written ordered examples and detect reached duplicate-priority, omitted-dependency and reordered-builder mutants. These finite checks do not approve the laws. Cyclic raw metadata, structural sharing of arbitrary Type owners and post-builder failure cleanup are not inferred from the TS reference.
