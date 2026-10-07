# #42 → #43 existing failure carrier

No new snapshot store or reader API is proposed. `relation-commands.Notice<S,E>.RelationFailed` already contains the complete nominal `relation-types.Failure<S>`: descriptor key, relation name, inverse name and kind, operation, source ID, target ID and exact Error variant/fields.

`publish_relate` publishes only an actual failed command application, at its deferred FIFO/barrier position through `W.event_publish`. The reorder adapter publishes its own complete keyed `ReorderChildren` failures at the corresponding application position. Namespace-only frontend refusal leaves the transaction queue unchanged; it is distinct from a deferred missing/expired-entity failure. Failed systems discard staged effects before the barrier. Ordinary Original E events and component-removal notices remain separate variants.

#43 should adopt this carrier through guarded Event/reader-domain transport. The source is bound to its containing nominal World and World namespace; raw source/target U32 DTOs alone are not cross-world authority. Descriptor identity/key defines independent relation channels. A raw `W.events_view` snapshot is only publication evidence: it is not independent cursor, conditional-skip, failure/retry, lag, retention or compaction acceptance. Those actual reader behaviors belong to #43 and must use #35 runtime with fresh source-bound controls.

#42 still requires fresh relocated full-application failure/publication observations in its complete feature driver and equivalent-work timing. Historical V5 failure traces are retained evidence, not current-stage acceptance. No new policy, storage simplification, proof or per-feature performance threshold is introduced.
