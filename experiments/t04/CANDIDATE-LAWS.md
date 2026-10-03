# T04 draft statements (unapproved)

1. Ordered read traversal returns the same world and projects all four array values without granting the application an owned array or a setter. Repeating observation does not change values.
2. Three invocations of the same closed update callback increment slot 1 by 3, retaining slots 0, 2 and 3. Initial rows a=[10,10,10,10], b=[20,20,20,20]; checkpoints are a=[10,13,10,10], [10,16,10,10], [10,19,10,10], with b slot 1=23,26,29. Position remains 0/10.
3. A callback checked for arbitrary M cannot replace M with detached concrete payload storage or use a concrete setter on M. Foreign tokens and undeclared access are rejected.
4. A genuinely affine element can be removed by swap with a replacement and threaded through traversal, but cannot be read twice using Array.get's Data interface.

These are draft contract directions, not approved Bend laws. Finite runtime and checker controls falsify selected instances only. A no-update mutant must retain checkpoints and fail statement 2. No model or executable proof is written. General rollback and universal refinement remain open.
