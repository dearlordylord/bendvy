# Completion adapter contract mapping

`decode-local.bend` adds no outcome type or cleanup policy. It returns existing `Local.Outcome` and uses existing Commands.tx_finish, Request.finish/Batch.Finished and Journal.abort.

| Original consuming path | Generic replacement | Preserved observation |
| --- | --- | --- |
| both public fixtures: manual Batch/T.begin/Frame | begin_frame | same descriptor, transaction, zero cursor/handle and empty receipts/Pending |
| both public fixtures: success/committed | traversal/committed + committed_state | commits only empty prepared/Pending; retains Local; publishes args/rows only on success |
| both public fixtures: abort/recovered | abort/recovered + retained | true interleaved undo; owners then prepared originals; existing Pending then new Pending; same error and Local recovery order |
| defensive prepared/Pending success | traversal rejected branch | same UserError Unit and owner-preserving abort |
| deferred invoked/finished | finish_deferred + retained | same actual Request.finish callbacks/outcome; accepted packets and outputs retained in Local on failure; successful output unchanged |
| recovery counterexamples aborted/commit_result | recovered/committed | same during snapshot, owner/Pending order, errors and Unit outcome |
| four fixture registrations | registered | same runner erased identity, namespace/name/access, state and registration refusal |

Opaque-H gameplay bodies, original case arguments/order, query selectors/providers, installers/projectors/lenses, Mail delivery sinks, physical observations and owner boundary conversions are untouched. Skip still calls existing Local.skip without invoking the runner. No-match traverses the same empty set and commits the same transaction. Recovered Pending is observable and remains incomplete; no extra retry or cleanup is introduced.

Model reuse: independent generic15 expected SHA a0b2037dba1943acb7deb49f58007a72ff5d62821559744a8d1f9823c0a3e349; deferred8 expected SHA 8095a1eb678fcf3f9cf985ce33d9e779108f6041fbecdd7ac67cf8f94a2bac42. All23 scenarios remain in the two source-current list-spine consumers; no projection, omission or oracle change. Source checks establish type/authority binding, not new emitted-backend qualification. Independent review must confirm the mapping before new backend admission.
