# Component read restoration: actual JS mechanism

Source-only finding, not a selected speedup or core patch. The named-loop current simulation's complete106-source stage and actual JS are retained, not recompiled. TX-GET-SOURCE-JOINS.json binds exact source/artifact bytes; TX-GET-GENERATED-EXCERPT.txt preserves the reached functions with original line numbers. Generated JS SHA `d339445bf8e6ccff2041e117f10b0ef0d931cef2b5fa6a5b930fd7b36d669777`. Staged component hash6e38590e maps to canonical input0e41557c through stage.json's import relocation.

## Reached path and concrete allocations

Movement.body calls Cap.get, then velocity Cap.read through opaque declared grants. Compose.get invokes Component.tx_get and read_join. The same full component projection is also used by selector family_match; do not collapse selector and body reads.

| Actual JS site | Work |
|---|---|
| compose.read_join1260,8220 | consumes Tx/Access Tuple; constructs final Frame and Frame/Access Tuple |
| component.tx_get1260,8226 | destructures Tx and calls get, then tx_get_join; no new closure here |
| component.tx_get_join1260,8636 | consumes intermediate World/Access Tuple; constructs final Tx and Tx/Access Tuple |
| component.get1260,8642 | retains all World fields; namespace/id/liveness checks before store read |
| component.get_live_owned1260,9096 | invalid: reconstructs World plus MissingEntity plus Tuple; valid: calls get_store then world.with_store_finish |
| component.get_store1260,9486 | consumes take's Rest/Column Tuple, invokes actual Col.view |
| storage.take_position1260,9492 | constructs PositionRest and Tuple |
| component.get_projected1260,9938 | invokes put and Access conversion; constructs Store/Access Tuple |
| storage.put_position1260,10419 | reconstructs Store with returned column and unchanged other owners |

The exact with_store_finish1262 location is recorded in the joined excerpt. It reconstructs one World and returns a World/Access Tuple. That Tuple is immediately destructured by tx_get_join. These object literals exist in actual emitted code; this does not establish how many survive V8 escape analysis or how much allocation/time they consume.

## Smallest same-contract fusion

An internal transaction-specific completion path can carry undo/commands/events to the validated read's completion, constructing the final World→Tx→Tuple directly. This removes the **intermediate World/Access Tuple**, while preserving tx_get's public result and all final owner containers. Merely combining tx_get/get restoration cannot remove the final World or Tx: they are still fields of the required result. The earlier broad suggestion that this one fusion removes World/Tuple/Tx churn overstates its direct syntactic effect.

The valid path must still invoke take once, Col.view once, project exactly as that view currently does, and put once using the returned column. An absent component invokes no payload projector. Invalid namespace/ID/dead handle returns MissingEntity without take/project/put. All four column representations remain handled by Col.view, including prepared/indexed owner restoration. Projection may return a changed affine C; retaining the old store or merely returning a cached detached view would lose that owner.

Carry transaction undo/commands/events unchanged; preserve world clock/stamps/registrations/depth/pending/resource/live/identity fields exactly and keep per-read authority validation. Use static specialized helpers, not a runtime callback capturing the transaction. No closure currently exists in this subchain to eliminate. A new callback could add run_clo/run_tail work and defeat the narrow goal.

Removing the Store/Access Tuple would require deeper transaction-specific store completion. That is an additional fusion scope, not automatically provided by the outer fusion. Removing Tx/Access Tuple belongs to Compose's consuming boundary and cannot be claimed while preserving standalone tx_get ABI. Neither change is implemented or qualified here.

## Evidence does not establish priority

Earlier coarse profiles attributed1.660ms to a tx_get specialization. The finer209-sample profile did not confirm a dominant read cost: consumer-start.created1260 at line349 accounts for5.107ms, but is a branch into Readers.register and can reflect lazy compilation/cold startup. The current named-loop249-sample profile's run_tail3.292ms includes a single3.034ms interval through Cap.get→movement.body→selection; this is not a per-read computation estimate. Allocation samples include loader/output and do not count total timed-region allocations.

Current20-pair complete simulation compares JS/TS median3.344503 and Native/TS0.060014. It is a fresh-lifecycle workload, not a steady-state ECS loop. Those measurements cannot supply a speedup for an unimplemented read fusion or identify initialization as a proven algorithmic bottleneck.

Conclusion for the existing #63 optimization queue: there is a concrete removable intermediate Tuple, so the hypothesis is not rejected as allocation-free. Reject the stronger claim that this is a demonstrated major hotspot or that a shallow fusion eliminates World/Tx/closures. A bounded candidate would need generated-code confirmation of that exact removed packaging, full arbitrary-owner/absent/foreign/error/rollback controls and the unchanged complete workload before an existing admitted comparative run. No alternative major core rewrite is justified by these retained profiles. No sourcevariant matrix, dependency, ownership contract, new threshold or runtime execution was added.
