# Independent complete schedule observation oracle

Private #56 preparation for source `8a9c53c5e` and its frozen runtime clones.
No runtime outputs were read or used to derive expectations. Existing author
source5 receipts and current complete pin guards were verified; no extra checker,
backend or performance run was started here. SOURCE-BASIS.json and ORACLES.json
bind source, compiler printing rules, complete expected outputs and baselines.

Both nominal schemas create scoped factory namespace1. Before descriptions:
counter0, one deferred add100, debugFalse, two actual registrations with cursor0.
Disabled snapshot returns None. Enabling and repeated descriptions preserve World,
original Plan, executable schedule/requirements and actual affine owners. The
original ordered Plan retains Resource7 and then duplicate Resource7 requirements;
the executable provisioning union is [Resource7].

Actual Sch.run evaluates condition1 (+1/true), invokes registered runner1 (+10),
applies the pending barrier (+100), evaluates condition2 (+1/false), and skips
runner2 (+20). Final counter112 and pending0 are included in complete State,
with ordered Entered/ Ran/ Applied/ Skipped observations and post-run description.
Resource observations preserve clock0; both actual registry cursors remain0.
Whole live/resource trees, store, events, registration metadata, names, accesses,
operational Plan, steps, requirements and enabled flag are retained in the model.

The reached description mutant changes only planned Entry projection to omit all
per-step requirements. Enabled/repeated/post-run descriptions change; original
State Plan, union, World/owners, operational steps and execution result remain
identical. description-source.patch records the exact source difference. Generation
does not establish executed projection reach or successful mutation detection.

The clone entry directory changes imported Core constructor printing namespaces.
The mutant baseline is therefore a separately rendered normal-shaped complete
output in that same namespace. A byte-exact unchanged normal source clone at the
same directory depth positively checks that baseline through the actual consumer.
Raw normal output is not used to attribute namespace-only rejection to mutation.

This selected two-owner fixture does not qualify a general heterogeneous App,
arbitrary provisioning, SP.run availability validation, scheduler failure policy,
foreign raw owner construction, debug overhead or full #56 acceptance. Finite
refusal transports and raw constructors are fixture administration. The actual
resource owner is affine Array<U32>, but this slice does not introduce new payload,
capture or finalizer contracts. Runtime/backend checks remain coordinator-owned.
