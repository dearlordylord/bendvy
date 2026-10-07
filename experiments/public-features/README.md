# #40 feature reference observations

Preparation for #40; #34 delivery and the full #40 implementation remain open.

`timeout 5 node experiments/public-features/reference.mjs` executes the pinned
public Feature API without new dependencies. Eight complete records are retained
in `evidence/reference/`, with source hashes, reference commits and tool version.

For two distinct roots, actual builders, bootstrap and update callbacks follow
selected `[Combat, Core, Empty]` order even when Combat requires Core. Empty
outputs normalize to empty schedule arrays, retaining extra output fields.
Duplicate and missing names reject before builder effects; duplicate-name
validation precedes missing-dependency validation.

This Node run strips types. It does **not** qualify compile-time dependency
visibility, undeclared access or foreign-root rejection, nor Bend ownership,
performance or universal laws. Those remain actual #40 implementation gates;
the reference is a starting comparator, not ticket completion.
