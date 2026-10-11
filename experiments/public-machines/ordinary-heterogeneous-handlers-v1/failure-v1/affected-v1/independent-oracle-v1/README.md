# Independent finite Exit and Enter failure expectations

Two full eleven-item expectations derive from the existing source-defined rollback/commit boundaries. The same ten physical snapshots and final Factory retain both typed bundles and global Reader registries, the complete World, six Local Arrays, resource and column Arrays, streams, pending callbacks, Pulses and statuses. No runtime output is an input.

Exit failure leaves owned head11 with the failed callback's Local touch retained, no Pulse/command publication, old Cold with Warm requeued. The early reader succeeds without a transition. Retry executes Exit/Transition/Enter, so final Local counts are `[2,1,1,1,1,1]`, owned head113 and applied7. The later explicit First marker publishes Warm→Settled.

Enter failure occurs after Exit and Transition commit: owned head34, published Cold→Warm at tick1, two successful deferred commands, previous Cold and current Warm. The failed Enter's resource/trace rollback leaves its Local count1 but queues no Settled. The early reader consumes that committed transition. The next marker drains the successful commands, advances the resource frame tick, and has no pending machine transition; it invokes no Enter callback. Later markers remain idle. Final head100, applied6, all six Local counts1. Both cases preserve reader registeredAt1 while the later read advances cursor2.

The model's finite sequencing assertions are examples, not laws/proofs. Present-state fixture only; no initialization, event expiration, generalized cleanup, new rollback policy or full #49 qualification. All output constructors are explicitly rendered to String, preventing QName-sensitive serialization.
