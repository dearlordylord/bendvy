# Public resource backend qualification

Preparation owns only this directory and the sibling `rollback-control`. The public module, normal consumer, observer and authority controls remain unchanged. The normal consuming graph uses `src/ecs/ordinary-resource-system.bend` through its ordinary public imports. The rollback control copies that public module with canonical imports relocated and the already-qualified Failure-only omitted-undo mutation; its consumer differs only in import paths. `rollback-control/SOURCE-JOIN.json` and the patches verify exact body joins and inverses.

Fresh normal and rollback source5 checks passed on their exact current 31-file consuming closures. All captured source bytes, receipts, raw streams and post-input guards are retained in `source-controls01` through a shared content-addressed gzip store. These development checks do not claim mathematical verdict or portable #28 qualification.

The independently authored complete String/Report models cover empty and two-entity Worlds, one registered resource-only invocation per call, affine Counter/Output, success, typed failure, rollback and retry. No runtime output is used to author them. Primitive presentation contains no imported nominal constructors, so the reused normal baseline is namespace matched.

Execution reuses the unchanged detached-v2 collector and the resource profile's tools, environment, commands, caps, lock and guard chain. Only preparation, public source inputs and independently joined oracles differ. Order: normal JS, rollback-control JS, normal Native, rollback-control Native. Each later cohort requires actual complete preceding PASS; the control must also reject the complete normal baseline. Stop on failure, deadline or guard drift; no retry. CPU11, source5, emit30, Clang120, runtime5, Clang19, Native one thread and GPU off remain selected. No contention or performance claim follows from affinity.

This finite public-module qualification does not provide automatic App/debug integration, schedule coverage, universal proof, full #56 acceptance or a new public contract.
