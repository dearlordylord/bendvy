# Candidate statements, unapproved

Recorded before implementation. No ECS proofs are authorized or written.

1. Sequential nesting preserves leaf order; failure stops later leaves and retains the leaf's typed identity and error. Test Begin -> nested Notify,Fail -> After, twice; After must never run. A skip-nested mutant must differ.
2. Provisioning requires the declared resource and host service types; runtime absence is a typed provisioning failure before any leaf effect. Test missing resource and missing service separately.
3. Application callbacks receive abstract affine handles and declared operations only. Test raw writes through read, undeclared service reads and foreign schema tokens, with positive controls.
4. Closed template callbacks can run repeatedly with returned owned state; an ordinary affine closure cannot be invoked twice. This is an expressibility boundary, not approval of captured-state restrictions.

Finite tests falsify candidate statements, not universal laws. Exact quantified laws, proofs and mutation proof gates require human approval later.
