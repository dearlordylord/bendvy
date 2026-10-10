# Runtime record run source-only oracle

Frozen producer 0410950aa, intended source06 original60121. Full A0/2 trace includes seven complete World/Fields observations and six action-result lines per scenario, affine success output prior values, rollback, retry, skip, trusted metadata invalidation and actual rejected-Args True observation. No backend output was consulted.

Resource replacement and rollback preserve World clock; only seeded component replacement advances it. Successful run_tracked copies current clock to transported Registry cursor; failure/rejection preserve cursor. Resource operational Fields clauses remain empty and Resource:Write kind is retained. World events, component owners/stamps, pending queue, registrations and nextSystemId remain fully rendered.

This is a single resource-owner transport witness, not heterogeneous application dispatch, arbitrary registration length, general disposal/error behavior, full #56 or performance qualification. Array contents are observed only where the frozen consumer explicitly reads them; failed output is not printed. Root independently reviews this model before backend execution.
