# Independent completion-adapter review

Reviewed immutable b8218bd39cc062ecf5c16510cc4c956ba3f39240 (master dcd2cb1d), source only. No backend, checker or model execution was performed.

**Source/Standards PASS; no implementation blocker found.** This does not qualify the new reached adapter on emitted backends or accept public delivery.

- `library/decode-local.bend::registered` delegates unchanged to canonical Local.register, including typed runner identity, namespace/name/access and rejected Local ownership. Each actual fixture now calls this adapter.
- `begin_owner/begin_frame` reproduce the previous transaction, retained constructed descriptor, zero handle/cursor and empty prepared/receipt/Pending fields. Owner, payload, Local, arguments and output remain arbitrary Type; only observations/error/event parameters retain their existing Data bounds.
- `traversal` commits only when prepared packets and Pending are both empty. It calls existing Commands.tx_finish; only successful completion invokes the success callback. User failure preserves its exact error; defensive success with unresolved work uses the existing fixture-selected rejection and abort path.
- `abort/recovered` use existing Journal.abort, preserving interleaved ordinary and owned inverses. Recovered owners precede prepared originals; pre-existing Pending precedes newly recovered Pending. Fixture `retained` callbacks retain codec, previous recovery history, arguments and returned owners. No owner extraction into an undo-overwritten resource, implicit retry, finalizer or cloning is introduced.
- `deferred/finish_deferred` use existing Request.finish/Batch.Finished. Commit returns output once; failure moves output and returned packets into fixture Local, returns the same error and publishes no output. Delivery recovery remains an explicit trusted application callback.
- Recovery-fixture callbacks preserve their previous during snapshot/errors and empty initial recovery lists. Their discardable Unit arguments/rows do not hide affine owner loss. Local.skip and disposal paths are unchanged; adapter failure returns the mutated/recovered Local, consistent with the approved Local-on-error direction.

The unchanged list-spine entries still execute all generic15 and deferred8 cases. Comparison of all four fixture diffs found only registration/initialization/completion factoring and equivalent state callbacks; gameplay, query grants, installer/projector/lenses, physical observers and case lists remain unchanged. Reuse of complete expected models a0b2037d… (15) and 8095a1eb… (8) is source-supported; no field projection or new error/cleanup policy was selected.

Evidence limitation: `source-checks.json` was last committed by 43fcd604, before this adapter change. Those retained source checks and earlier list-spine JS/Native observations must not be relabeled as execution of b8218bd3. Current adapter source checks, exact constructor/import joins, reached completion mutation and full emitted-model comparison remain qualification work. `binding-deltas.json` pins the changed fixture bytes but is not execution evidence. The README's reuse statement is historical model/evidence reuse only.

Checked boundaries: decode-local; canonical src/ecs/local; decode-owned-journal; decode-requests; all four changed fixtures; complete generic/deferred list-spine entries; COMPLETION-MAPPING, binding-deltas, README and source-check provenance. Shared source and governing contracts were not changed by this review.
