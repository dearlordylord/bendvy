# Transaction and event simulation

This is an advanced regression example covering movement, damage, deferred
commands, events and failed-system retry. For the application starting point
with declaration-derived access and a registered schedule, use
[Scheduled health](../scheduled-health/README.md).

This example intentionally exposes `system.register`, query/provider lowering
and explicit access lists. These are lower-level APIs, not the recommended
registration pattern for a new application. Its fixed checkpoints are shared
with historical reference and performance evidence; changing its orchestration
requires checking that evidence rather than silently relabeling it as a new API
example.

From the repository root:

```sh
bend examples/user-simulation/main.bend -o /tmp/bendvy-user-simulation.js
node /tmp/bendvy-user-simulation.js > /tmp/bendvy-user-simulation.json
python3 examples/user-simulation/verify.py /tmp/bendvy-user-simulation.json
```

The verifier checks all 23 external checkpoints, including the approved
foreign-world handle rejection. See [scenario.md](scenario.md) for the exact
story and the intentional difference from the TS reference. A successful source
check alone does not establish these runtime results.

Current-source JS replay checked on 2026-10-17 with Bend 2.0.35 and Node
24.20.0: all 23 checkpoints pass (22 reference matches and one approved
foreign-world divergence). Native and comparative performance were not rerun
for this documentation update.
