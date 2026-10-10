# Check policy for evidence runners

## Development before acceptance

Run the cheapest actual consumer against its complete oracle before preparing
full delivery. Reuse an existing successful receipt only when source, inputs,
tools, environment and checked scope still match. After a failed stage, repair
and rerun that stage; after two attempts without new evidence, change the experiment.
A preflight or typecheck does not establish backend, proof or full delivery acceptance.

## Preparing a focused runner

Use an existing runner. Freeze the source closure, full oracle, command plan,
tools/configuration/environment and required outputs. Retain pre/post guards,
raw success/failure logs and unconditional terminal receipts through
[GuardBoundary/ReceiptBoundary](../scripts/evidence_boundary.py).
Guard generated artifacts before consumption; use one heavy-lock owner. Use the
runner's existing lock when present; an outer lock on the same file can deadlock
its independently acquired child lock.

Routine feature execution through an unchanged reviewed runner is authorized
by the assigned issue and existing gates; one independent final Spec/Standards
review covers code and evidence. Obtain independent launch review for new or
changed runners/guards, compiler experiments and comparative performance plans.
Batch the entire planned sequence into that review. A source repair within the
same agreed contract uses affected checks and final review; changes to an admitted
frozen plan require a preserved successor and review of the changed portion.
Launch approval binds the reviewed source, plan and prerequisite conditions.
After a commit, verify those bindings and prerequisites; unchanged bindings retain
the existing approval without another review or admission report.

Select reused TS references with the delivery-manifest binding. Check selected
Python sources with `scripts/check-python-source.py` and run configured staged
checks. Preserve historical attempts unchanged. Run required feature gates and
the unchanged #28 regression on the combined executable integration; reuse
matching evidence rather than rerunning planning/documentation commits.

When authoring or changing a runner, reference binding, admission control or
archive verifier, read the applicable [runner details](reference/evidence-runner-details.md).
Existing declared gates remain binding; this shorter policy adds no tolerance.

## Portable evidence verification

Use existing verifiers for exact plan/receipt/source/raw-output joins and complete
oracle equality. Deliver one evidence package and final review per capability or
integrated slice; receipts retain intermediate stages without separate manual reports.
See [verification details](reference/evidence-runner-details.md#portable-evidence-verification)
when changing a verifier.

## Immutable dependency stages

An optional reviewed closed resolver inventory can reuse `PinnedTools` checks.
The ordinary installed-tool path remains sufficient. Read the
[session details](reference/evidence-runner-details.md#immutable-dependency-stages)
only when adopting or changing this optimization.

## Parity compiler identity

Use the preserved `bend-2.0.35` selected by
[installed configuration](../experiments/public-simulation/delivery-v1/installed-config.py),
with its existing Base/resource inventory. The changing `bend` alias is not an
identity pin. Read [identity details](reference/evidence-runner-details.md#parity-compiler-identity)
when changing tool selection.
