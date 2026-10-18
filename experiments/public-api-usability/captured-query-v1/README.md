# Executable ordinary App captured query (#73)

This independent consumer uses existing `Component.add` followed by the new
`ordinary-app-capture-query.add`. Both registrations derive executable App
composition. The consumer supplies no dispatch implementation, numeric-ID plan,
manual cursor adapter, availability provider, or metadata projection. Its
schema-indexed function aliases select library-generated types/functions in the
same form as existing Component consumers; they implement no dispatch logic.

The new helper retains the actual `ordinary-capture-query.Owner` as its affine
invocation token. It derives registration fields, plan, invoke, heterogeneous
error/dispatch/fold/provision composition internally. Fields refresh from the
returned actual owner after execution. Its failure continuation returns both
the original prior App and incoming affine capture. Args/Out/Error remain Data;
capture remains arbitrary Type. Typed errors compose through existing Choice;
complete successful Out lists stay in the invocation and have an owner-returning
accessor. Failure clears partial outputs, matching Component.add policy.

Prior Rows/observer are retained, with the actual captured declaration's debug
binding added. No detached value inspector for arbitrary Type capture is
invented. Execution preserves its incoming trace context; detailed operation
tracing is not expanded beyond the existing capture-query runner.

Each nominal Workshop/Garden schema owns two real four-cell Array components
and a separate two-array captured pack. A read-only component callback executes
before the captured Write+Changed query. The captured callback writes twice,
reads the actual intermediate/final state, and fails on the second row. The
complete typed failure payload, successful output lists, returned App statuses,
scheduler observations, full physical World, component stamps, capture arrays,
actual inner cursor and refreshed metadata fields are observed. Same-owner
retry succeeds; the next Changed query enters no rows, testing cursor advance.
Failure preserves captured changes while rolling back World payloads/stamps;
World.clock remains advanced, as required by existing semantics.

Pure checks and expected IO-dependent diagnostics are retained under checks.
The independently authored Python operation model reads no generated artifact
or subject output. Source/gold are sealed before backend execution. First run
is Workshop JS/Native; Garden reuses those exact generated artifacts after both
first subjects pass. Queue/events remain empty: no staged publication coverage,
full22, performance ratio, universal refinement or new contract/law is claimed.
