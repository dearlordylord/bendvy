# Lifecycle filter example check plan

Status: new normal example wrapper, authored but not launched. Independent code
and launch review must approve this wrapper before execution. The three existing
consumers already passed their full ordinary development observations at the
source commits recorded in README.md; those runs do not admit this new wrapper.

The wrapper reuses `examples/common.sh`, its single heavy-lock owner and the
ordinary `BEND`, `NODE`, `CLANG`, `BENDVY_EXAMPLE_CPU` and
`BENDVY_EXAMPLE_NATIVE` environment. It performs no tool discovery, installation,
collector, instrumentation or reference execution. The source lock includes the
actual uid and selected CPU. Source checks have a 15-second deadline; emit and
Node retain the common 30-second deadline; native compilation has 120 seconds,
and each native observation has five seconds. Native mode runs one and four
workers. The configured CI compiler remains selectable through `BEND`; private
2.0.35 tool/resource bindings belong to the existing development receipts, not
to a hard-coded compiler path in this portable wrapper.

Before backends, check the three concrete lifecycle consumers and the existing
closed output-query positive control. Reuse five unchanged authority controls
from `parallel-query`: output cross-schema handles, affine output duplication,
escaping the output owner, undeclared command output, and writes through a read
capability. Each must exit exactly 1 and contain expected/observed diagnostics
and both intended type fragments. A timeout or unrelated diagnostic fails.
These controls retain their existing boundary statements; they introduce no new
lifecycle-reader claim.

For each consumer, regenerate its independent Python model and compare it with
the committed complete expected file before emission. Then compare the complete
JavaScript observation, and optionally both native observations, with that
model; consumer stderr must be empty. `filters` has four lines / 9,282 bytes,
`history` six / 14,066 bytes and `scheduled` six / 9,391 bytes. Models reuse
explicit fixture initialization and observation formatting, not Bend execution
or captured output. Source/oracle bindings and raw receipt retention for an
admitted execution belong to the existing outer evidence workflow; this normal
wrapper adds no receipt or qualification collector.

Scope is the captured execution window, actual affine query payloads, Added and
Changed selection, historical/wrap/dormant cases, retained writes after returned
errors, and actual scheduled command publication/final suppression. Full GH85
removal/despawn readers, journal maintenance, intended reader authority controls,
actual native-worker participation and final integrated implementation review
remain pending. Neither this wrapper nor native output equality establishes
those gates, a new law or issue completion.
