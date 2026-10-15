# #43 full-capacity array transport v2

This packet retains one full-capacity #43 consumer using stock Bend 2.0.35. The v2 transport groups the lifecycle and mixed observation pair into a singleton `Array<LifecycleMixed>` so the normal JS and Native output paths can print all 65,536 rows while preserving every report field. The independent source-derived oracle verifies the complete 252,206,150-byte wire, and its source-derived inverse recovers the previous complete 244,722,906-byte wire exactly.

Both current v2 backend roles are fresh `COMPLETE_CONSUMER_DEVELOPMENT_PASS` receipts. JS emitted and consumed the full oracle; Native emitted, built with the pinned Clang 19 O3 command, and consumed the same full oracle. Exact command order, argv, caps, all stdout/stderr path/size/hash records, generated artifacts, guard progression, and the 41-source closure are bound by `verify.py`. Tool binaries and compiler resources remain hash-only in the source plans. No tool, cap, or runner was changed.

The predecessor v1 JS pass and Native emitter arity failure are retained as history, alongside prior source-attempt logs. They are not relabeled as v2. The v2 source-check transcript is retained as provenance only: it prints `ALL PROOFS CHECK` and the compiler's update notice; it is not represented as a universal proof or a replacement for the full JS/Native consumer results.

The current #42 IO-origin packet is reused for the specific independently created same-schema foreign-operation boundary. At commit `54ce441e907038f499979ff4596b3ae55974c2ff`, its consumer calls `WI.create` for receiver and peer worlds, reserves and activates the returned handles, registers the relation writer and failure reader on the receiver, and sends actual peer-issued handles through the registered writer. The source route is `consumer.bend:own_lookup/write` → `mutation-composition-v1/consumer.bend:writer_registered/write` → `system.run_tracked` → `operations.bend:writer` → `relation-providers.invoke_write` → `relation-commands.queue_relate/queue_unrelate` → `queue_namespaced`. The four foreign requests return `MissingEntity`; complete receiver/peer, queue, owner, registry, cursor and failure-reader observations are retained. This is stronger for that exact foreign-operation boundary than the older #43 synthetic helper, which directly calls `A.queue` and reconstructs a peer handle from its namespace. The #42 packet is bounded reused evidence, not another #43 run or full #42 closure.

This packet qualifies the retained full-capacity ordinary JS/Native consumer output and the bounded foreign-operation reuse above. It does not close #43: complete #43 TS parity/timing, the unchanged #28 gate, whole-feature performance/scaling and remaining acceptance are still open. No universal proof/refinement, production adoption, timing result, or new authority/identity policy is claimed.

Run the portable checks from this directory:

```sh
python3 verify.py
python3 verify.py --selftest
```
