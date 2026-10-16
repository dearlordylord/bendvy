# AppA resource-failure oracle

Derived before execution from the existing complete AppA model and the approved
per-system rollback/cursor contract. The first Scalar transaction commits 15 at
clock3; the failed Counter replacement restores [10,11] and keeps cursor0.
Sibling, bundle receipts, lifecycle stamps and all other observed World state
remain intact. The schedule returns ResourceFailed before its second barrier.
Both repeated Inspector observations preserve that state.

`model.py` reuses the original independent model for unchanged representation and
initial operations. SOURCE-BASIS binds the inspected sources; ORACLES binds the
complete expected wire. This is a finite consumer oracle, not a universal proof
or full #61 acceptance. No runtime output was used to derive it.
