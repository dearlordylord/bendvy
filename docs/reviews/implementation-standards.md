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

Summary for #17: 0 hard findings; 0 actionable heuristic findings. Later #12/#16
packages are not reviewed here until their integrated commits are available.
