# Retirement-loss candidate

Source-only falsifier preparation for experimental #53. The sole source delta is `fixture.retirement_done`: after actual canonical `Ev.frame` and owned-log reconciliation, return the tail of the nonempty retirement owners instead of every owner. All runtime metadata, retained log owners and complete consumer observations remain unchanged. Main, log, observation and direct controls are byte-identical copies, with the mutant entry namespace bound separately.

Source5 `evidence/source-1` passes. No backend has run. Independent complete baseline/counterfactual observations must be frozen and reviewed before execution. This checks experimental owner conservation; it approves no disposal/finalizer/public signature policy.
