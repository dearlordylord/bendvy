# Implementation review — Standards axis

Standards: `AGENTS.md`, `docs/agents/issue-tracker.md`, Bend LDD and the
code-review skill's Fowler smell baseline. Repository and Bend ownership/DAG
rules override generic refactoring heuristics. This report does not review Spec
acceptance or independently execute the experiments.

## #17 — capture/restoration

Reviewed fixed comparison `git diff 484fb88...00f4407`; both refs resolve and the
diff is nonempty. Commits: `96bd5d9` (tracker workflow), `400f4dc` (affine state
and restoration experiment), `00f4407` (independent coordinator rerun). Inspected the committed runner, Bend/TS modules,
controls, candidate hypotheses, trace, evidence manifest and research report.

**Hard violations: none found.** The runner verifies reference commits and
compiler/Base hashes, runs version/guide, and reuses the explicit five-second
checker/runtime process bounds. Code generation and clang have separately
identified build bounds. No dependencies or ECS proofs were introduced.

`Local`, payload, transaction and schedule owners remain affine Type values.
Observations return owners alongside Data projections; rollback retains the
array and journals numeric inverses rather than cloning a Type owner. Repeated
execution recreates a once-only closure from its returned owner. Positive and
negative controls test intended abstract access, read/write, nominal schema,
snapshot, consumed closure and destructive-transfer diagnostics. Mutants pass
checking and run on both backends before being counted as detected.

The report distinguishes the finite 39-checkpoint comparison from general
proof/refinement, records destructive-restoration and integrated-runtime gaps,
and leaves Local policy, arbitrary captures and performance acceptance open.
Diagnostic host strings and structural-command projections are explicitly
limited; neither is represented as integrated external effects or command
application.

**Heuristic smells: none requiring action.** Numerous small destructuring and
owner-return helpers are required by Bend's single-head-match, declaration DAG
and affine constraints. The separate TS scenario is an independent reference,
so extracting its transitions into shared implementation would weaken evidence.

Summary for #17: 0 hard findings; 0 actionable heuristic findings.

## #16 — indexed storage

Reviewed full comparison `git diff 484fb88...276a71c`, focusing on new commit
`276a71c` via `git diff df22bf2...276a71c`. Refs resolve, focused diff is nonempty
and whitespace checking passes. Read runners, indexed/owned/relocation/identity
modules, generated control sources and diagnostics, raw results and report.

**Hard violations: none found.** Existing five-second checker wrappers precede
code generation; semantic runtime and timed benchmark deadlines are separately
identified. No dependency or ECS proof is added. Type arrays/cells are threaded
through get/swap/set/projection operations; failed numeric writes unwind retained
inverses, with no Type clone. Access bounds precede array access. Closed generic
providers preserve nominal schema boundaries, and ten newly generated positive/
negative controls exercise both schemas, including fabrication/reconstruction.

The 18 measured Data cases retain five randomized samples for each of five
backends; every exact input/sample checks final IDs/values and relevant actual
own-read/removal counts. Ten compiling mutants inspect meaningful decision
paths. Separate owned Type measurements avoid representing Data rows as the
full payload capability. Reusing actual T08 transitions/readers is documented;
fresh indexed comparisons and selected-reader mutants supply this task's own
evidence. Reference/compiler/Base/source pins are recorded.

The report preserves dense and JS regressions, unresolved millisecond values,
shared-host dispersion and whole-child RSS limitations. Favorable head churn is
identified, relocation is explicitly untimed, and the fixed reversed mapping is
not represented as measured dynamic compaction. General affine destructive
restoration, integrated providers/readers and performance acceptance stay open.
Candidate statements remain unapproved hypotheses, with no invented law-first
history or threshold approval.

**Heuristic smells: none requiring action.** Small match/continuation helpers
follow Bend ownership/DAG constraints. Owned linked-list measurements deliberately
share Cell operations while independent TS remains separate; this is evidence
design rather than speculative abstraction.

Summary for #16: 0 hard findings; 0 actionable heuristic findings. #12 remains
unreviewed until its integrated commit is available.
