# Astra review — remaining parity ticket breakdown

Requested by the user. Read-only review by `gpt-6-astra`, medium reasoning,
against SPEC, current public API, historical core map, #26/#27 evidence and #28
regression contract. This review does not approve laws, thresholds or publication.

## Decisions incorporated

- Use six bounded immediate slices: optimized public Compose integration, event
  readers, removal readers, schedule declaration/provisioning, conditional
  transactional execution, and explicit per-system Local ownership.
- Independent stream/schedule work must not wait for blanket closure of #21/#24.
  Optimized integration requires its exact owner/provider interface and source
  gates, but final performance qualification remains owned by existing tasks.
- D2 depends on D1 plus integrated event/removal readers. C need not depend on B;
  their skip semantics differ and shared infrastructure is optional.
- Local policy is unresolved and is not a discovered dedicated TS Local API.
  Closed registered callbacks are not runtime affine captures.
- #28 guards frozen existing work only. New features require observed equivalent
  reference/backend workloads, not a fabricated historical baseline. No small
  slowdown allowance is approved; full-matrix acceptance stays separate.
- Preserve later coverage for schema/features, relations/hierarchy/scopes,
  machines, validation/restore/tooling, allocator/authority, payload/captures,
  proofs, performance and the copied application. Keep query cardinality and
  exact lookup completeness explicit.

The updated parity overlay distinguishes current public integration from older
experimental receipts. User subsequently pre-approved publication. Eight issues #29–#36 separate query cardinality from storage integration and basic schedule execution from nested provisioning, as recommended in the final review. Parent #1 was not modified.

## Concrete eight-ticket review

Astra verified named query errors/count against pinned Query.ts and found no
impossible cardinality requirement or dependency correction. Two wording findings
were fixed in both local and live issues: #34 exercises nested provisioning
independently on two nominal schemas and rejects mixing; #36 explicitly uses a
documented equivalent-state TS adapter because upstream has no dedicated Local
API. No remaining actionable review findings were reported. UTC date corrected
to 2026-10-06. This is planning review, not executed feature acceptance.
