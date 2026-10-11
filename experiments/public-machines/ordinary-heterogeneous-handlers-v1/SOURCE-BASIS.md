# Heterogeneous ordinary handler consumer

The entry calls existing public `ordinary-machine-handler-bundle.run` twice with distinct `FirstKey/First` and `SecondKey/Second` bundles, threading the returned same World. It then invokes both actual registered transition readers and executes the explicitly authored later marker sequence. No new adapter or core change is proposed.

Eight full snapshots retain both bundles, their actual Registry owners, typed readers, the sole World, component and resource Array trees, Local owners, actual published events, deferred callbacks, registration metadata, and statuses. First Enter queues only First.Settled; the second marker preserves this pending value until the authored later first marker. Present slots are provided by setup. Initialization, implicit cross-machine overwrite, arbitrary callback capture, failure recovery and cleanup policy remain outside this first consumer.

Governing references: docs/SPEC.md machine/handler stories; docs/parity/handlers.md current finite-handler coverage; Rust Bevy pinned ad678262ce53b5d142fe49ee5e08caff6f00ab60; Bend pinned a950fd683c0d76f09794078e6174fe98a1492876; TS third-priority inventory pinned 3040a3b2a3f28fa8554d856f9ccb6bf5433fa334. Existing public handler bundle, phases, system Registry and transition stream semantics remain unchanged. This source check is finite evidence, not a new law or universal proof.

SOURCE-HISTORY.zip retains all six exact source attempts. The selected source06 result uses pinned Bend 2.0.35, taskset CPU11 and the unchanged source-capture/task_runner with a five-second cap. Earlier failed parser/termination/affine diagnostics remain failed history. No backend output has been used as a model input.
