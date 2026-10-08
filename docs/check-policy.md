# Check policy for evidence runners

## Development before acceptance

Before preparing a full cohort, run the cheapest real consumer with the complete
oracle: typecheck alone cannot catch observer execution or observation order.
For the public constructor gate:

```sh
python3 experiments/public-bundles/production-candidate/transactions/invalid-constructor-v1/run.py --development-only
```

This executes the TS fixture, Bend fixture and expected proof-boundary refusal,
with five-second limits. `scripts/check_preflight.py` retains raw stdout/stderr
and an INCOMPLETE receipt on failure. Only exact complete observations can produce
PREFLIGHT_PASS. This status grants no full delivery or proof acceptance.

The full constructor runner automatically runs this preflight before library
discovery; `--consumer-preflight RECEIPT` instead verifies an existing receipt.
It checks source bytes, core membership, declared input directory membership,
tool binaries, helper implementations, command plan, environment and raw logs.
Missing, failed or stale evidence blocks preparation. Reuse requires the same
complete environment; a new shell may change incidental environment variables,
in which case rerun the cheap preflight or launch both phases with one fixed env. Inputs must include every
consumer dependency and oracle; undeclared inputs are not automatically inferred.
After failure, reproduce the exact failed stage before repeating full preparation.
After two attempts without new evidence, change the experiment.

Name CLI evidence by the actual runtime path. In the pinned Bend source,
`book_run` uses `term_snf` for a pure main, but routes `IO` mains through
`Comp.io_run`, which emits JS and evaluates it in-process. An IO CLI pass is
a generated-JS IO consumer, not independent pure-interpreter coverage. Retain
historical receipt labels and qualify their scope in the current report;
standalone emitted JS and Native artifacts retain their separate gates.

## Preparing a focused runner

Before freezing a delivery capsule, run `python3 scripts/check-python-source.py`
with its exact selected Python paths, including new untracked candidates. This
uses the same entrypoint execution policy as the commit hook. Check selected
live text for whitespace before archiving; run the configured staged checks on
the exact delivery selection before committing. Exclude generated caches from
the selection. If qualified bytes already exist, preserve them and record any
live-source correction separately rather than modifying historical evidence.

When reusing a delivered reference, select the comparator from its delivery
manifest before freezing the plan. Use `selected_reference.binding(root,
manifest, entry)` and freeze both returned files; verify that binding at stage
boundaries. This rejects historical failed adapters such as #49's unselected
`reference.mjs`; the selected `reference-v3.mjs` has the successful receipt.
The manifest selects bytes, while the linked full receipt establishes behavior.

New wrappers use [GuardBoundary and ReceiptBoundary](../scripts/evidence_boundary.py)
for post-command checks and final receipt publication. `GuardBoundary` takes
named checks and attempts every check while preserving the primary exception.
`ReceiptBoundary(receipt, path, checks)` writes a JSON receipt after all final
checks; child or guard failure records INCOMPLETE and propagates the failure.
Set the cohort success status inside this boundary only after complete oracle
validation. Register raw outputs with the planned log owner; keep derived
outputs outside that log namespace. Freeze this helper as a command input.
Reference adapters print the complete observed DTO and required raw diagnostics
before asserting equality, so a failed comparison retains the actual result.
The commit hook injects child, guard, write and cancellation failures into these
boundaries. Previously frozen wrappers retain their reviewed bytes.

Start from the guard composition in the [constructor runner](../experiments/public-bundles/production-candidate/transactions/invalid-constructor-v1/run.py), adapting the consumer and command plan. Before requesting execution review, prepare the concrete wrapper, source/helper inventories, ordinary installed-tool snapshot, environment binding, ancestor configuration presence states, generated-output guards and full oracle. Completion means the reviewer can trace every planned command through central `Runner` and the same before/after guards. A list of planned commands is preparation evidence only.

Use `owned-tool-pins.py` snapshot/verify for the ordinary path. Historical binary hashes alone do not establish current resource membership, resolver or configuration state. Preserve the original failed or unadmitted plan when preparing its replacement. Reuse retained positive evidence when sources and its scope still match; concentrate new commands on changed behavior and missing controls.

## Portable evidence verification

Portable capsule verifiers check each source, JS and Native cohort against its
literal admitted plan: exact terminal status, command count and labels, raw log
membership and receipt digests, and archived probe membership (JSON, stdout and
stderr for every probe). Apply these checks equally to prerequisite cohorts.
An archive hash or a positive output length does not replace exact raw joins or
the expected output bytes. Preserve historical helpers when strengthening a live
verifier; do not rewrite original receipts or archives.

## Immutable dependency stages

`owned-tool-pins.py:verify` retains its complete discovery behavior. Use the
optional `PinnedTools` session only with a reviewed, closed resolver inventory:

```python
session = tools['PinnedTools'](resolver_inputs=resolver_inputs, **tool_config)
frozen = session.expected
session.check()       # before and after each command: bytes and membership
session.boundary()    # full discovery at stage boundary, against frozen baseline
```

Declare loader/cache/preload/config inputs and all search directories reachable
through RPATH, RUNPATH, environment and wrappers. Declare absent optional config
paths too. Directory contents and symlink targets are checked; external directory
symlinks require explicit target coverage. No timestamp cache substitutes for
bytes. An incomplete inventory is unsafe: retain ordinary `verify` instead.

The constructor runner accepts repeated `--resolver-input PATH` arguments to opt
in to this mode. It records the declared resolver inventory and initial discovery,
checks before/after commands, and rediscovers at preparation and terminal stage
boundaries. With no arguments, the existing full discovery remains active.
A change refuses the stage; it never silently freezes a new baseline. Start a new
cohort only after investigating and deliberately accepting changed inputs.

Intermediate `check()` returns the original discovery evidence, not fresh probes.
The controlled test performs twenty intermediate checks with one initial probe
and one boundary probe. This proves probe elimination, not elapsed-time savings:
hashing a large resolver namespace can itself be costly.

## Adoption by #48

The #48 followup runner was untracked main-thread work when this PR was prepared;
it is deliberately outside this branch. After pulling, integrate the same helper
before its expensive tool snapshot. Bind its own TS/Bend fixtures, full oracles,
source closure, metadata, reference trees, tools and environment. Verify the
receipt again immediately before freezing the full stage.

For its command wrapper, replace repeated `tools.verify` with `session.check`
only after reviewing its complete resolver inventory; use `session.boundary` at
stage transitions and completion. Do not claim the existing 336 probes have been
removed until that integration and an actual #48 receipt demonstrate it.

Full semantic, backend, raw-log, timeout, law and performance gates remain
unchanged. A passing preflight cannot bypass them. No new dependencies or
numerical acceptance thresholds are introduced.

### Explicit shallow loader search directories

`PinnedTools(..., loader_search_directories=[...], resolver_inputs=[...])`
optionally inventories loader search directories shallowly. Each selected root's
resolved directory identity and symlink chain, and every immediate entry's name,
kind, resolved identity or file bytes are pinned. Filenames are unrestricted.
Nested directories, including directory aliases, are metadata-only: their
contents are neither traversed nor adopted as search scope. Declare searched
hwcap and other nested directories separately. Broken or cyclic links refuse the
stage. Non-link absent search paths are retained, including ancestor aliases.

Selected root aliases and file candidate symlink targets require explicit target
coverage by the declared recursive resolver inputs or shallow search namespaces;
no parent directory is implicitly trusted. Relevant intermediate links are
retained, so equal final bytes cannot hide alias changes. Child directory aliases
are recorded without granting target coverage. Directory identity uses device and
inode rather than timestamps; irrelevant nested documentation edits are ignored.

The default recursive resolver inventory and recursive resource inventory are
unchanged. Continue declaring loader/cache/preload/config and absent optional
inputs through `resolver_inputs`, and freeze the complete environment. Initial
and terminal discovery remain mandatory; intermediate checks launch no probes.
This API does not establish a closed host-specific list: actual loader defaults,
hwcaps, RPATH/RUNPATH, DT_NEEDED paths, cache, configuration and environment require
call-site review before adoption. No aarch64 inventory or collector is approved
by these mock tests, and no backend or performance gate is waived.
