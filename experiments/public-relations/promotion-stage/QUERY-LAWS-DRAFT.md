# Relation Query candidates — unapproved

These candidates are source-backed statements for falsification and review. They are not approved ECS laws or proofs.

- For a supported live World and a declared component family, relation row selection is the conjunction of actual core component selection and every declared relation requirement. A component-absent entity may occur in an inverse snapshot without becoming a required-component row.
- Selected rows retain ascending live entity ID order. Incoming handles retain graph inverse arrival order; absence is Query `Missing`, including an empty inverse, while direct lookup may return successful `[]`.
- Required rejects absence, Optional retains it as Missing, Present accepts only presence, and Absent accepts only absence. With/without filters do not add projected cells. Projected cells retain declaration order and descriptor/schema identity.
- A read-row callback gets an abstract affine owner and only a ValueRead capability for its immutable snapshot. It returns exactly one owner; opaque component owners and all unrelated World/transaction fields survive the scan. This is a closed provisioned-client boundary, not universal authority of exported raw constructors or arbitrary trusted selectors.
- A retained Data snapshot remains unchanged after later deferred graph mutation; queueing alone does not change the graph before a barrier. These lifetime/phase candidates still require their own actual executable witnesses.

The current finite falsification slice covers two nominal schemas, four affine payload array depths, one ownerless live entity, two ordinary relation descriptors, ten composed specs, and reached empty-inverse/order/cell/conjunction mutants. It does not establish all Worlds, descriptor counts, lifecycle phases, cleanup or performance acceptance.
