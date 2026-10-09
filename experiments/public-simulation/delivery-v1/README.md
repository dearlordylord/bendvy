# Fixed-step simulation relocation

This package prepares the complete two-schema public ECS consumer in a chosen
empty directory. It does not depend on expanded `bend-v1/development` files or
the original execution worktree. Run from any checkout location:

```sh
python3 experiments/public-simulation/delivery-v1/prepare.py /tmp/bendvy-simulation-stage
python3 experiments/public-simulation/delivery-v1/compare.py
```

Preparation validates all 226 regular members of the immutable development
archive and all 106 current consumer/reader/core sources against executed pins.
The only accepted source difference is the separately recorded one-LF geometry
EOF correction. Absolute core imports and relative imports are converted to
stage-relative imports; source bodies remain unchanged. Every imported Bend
file must belong to the frozen source closure. Base remains the installed Base:
its compiler/tool/config identity must be frozen by the eventual execution
cohort. No historical receipt is rewritten or assigned to relocated execution.

The comparison command reads the archive directly, checks the strict report
parser's whole-text roundtrip, and compares every field of the actual historical
JS report against the independently authored complete oracle. Thirty-two
literal constructor paths are explicitly joined to neutral source names.
Historical Native stdout must equal the complete JS bytes. This is historical
development evidence, not a new backend run or a full delivery receipt audit.

A future relocated run's **whole stdout** can be compared using:

```sh
python3 experiments/public-simulation/delivery-v1/compare.py --stage /tmp/bendvy-simulation-stage --stdout /tmp/simulation.stdout
```

This recomputes the exact 106-file import-only relocation from pinned current
sources, checks its manifest, bytes and Bend membership, refuses symlinks, and
validates each non-Base constructor's actual
source declaration, then compares all fields without projection or defaults.
It does not launch children or authorize an unguarded backend run. The frozen
runner must own outputs, tools, environment and before/after/final guards under
`docs/check-policy.md`, locking only the actual heavy child.

## Evidence and remaining gates

`source5-v1` retains the actual single relocated development source check:
unchanged five-second checker, telemetry disabled, all 106 staged sources
validated immediately before and after the shared-lock child; exit 0, compiler success
stdout and empty stderr. The stage manifest joins input bytes to transformed bytes. The lightweight
receipt records the command, terminal exit, duration and stage hash; it does not
retain a frozen environment or machine-verifiable pre/post guard records. Those
are required in the future delivery cohort; this receipt is development evidence.
Current root source bytes were checked independently against the same executed
pins, with only the recorded EOF correction. No compiler/runtime performance
comparison is implied by this check.

Still required for #63: frozen source/tool/environment/output delivery cohort,
complete relocated JS and Native observations and observed TS receipt joins,
source-current applicable negative/mutation admission, unchanged #28 regression
receipt and feature-specific equivalent-work timing/scaling. Retained existing
positive and controls evidence should be reused only where its exact scope and
source bindings remain valid. Timing remains deferred during CPU contention.
Proof and full-core performance prerequisites remain explicit; this simulation
does not close full parity. No new law, dependency or numerical gate is added.

## Current preparation boundary and exact unqualified inventory

Preparation now reads index/archive/correction/current source inputs through a no-follow regular descriptor; same-byte leaf symlinks and special files are refused. `test-preparation-inputs.py` exercises this boundary without tool discovery or backend children. This does not pin ancestor directory aliases or substitute for the eventual complete source/tool guard.

The current root `installed-config.py` is preparation configuration, not resolver admission. `RESOURCE_ROOTS` covers installed Base/private Clang/Z3 resources; `LINK_INPUTS`, `HEADER_SEARCH` and `LINK_SEARCH` are observed inputs/search candidates, not closed compiler resolution. Still missing: reviewed loader search roots and explicit hwcap variants; loader config includes/cache/preload/absence and environment/RPATH/RUNPATH closure; complete header candidates/absence and consumed include files; GCC selection, linker candidate/script/default-script closure; generated Native ELF/runtime resolution. Do not recursively treat `/lib` or `/usr/lib` as an approved resolver inventory. Existing snapshot/verify remains the ordinary helper; PinnedTools requires a separately reviewed closed namespace. No discovery was run by this repair.

Delivery also still needs guarded complete relocated JS/Native/observed TS receipt joins, source-current negative/reached mutation binding, unchanged #28 and equivalent-work timing/scaling. Historical full observations remain reusable only with exact source/subject joins. CPU contention defers timing, not semantic preparation; no #63 closure or new numerical criterion is claimed.

### Narrow current metadata recipe

`prepare-metadata.py` freezes exact readelf `-l -d` commands for preserved Bend, Node, private Clang, shell/bash, env, taskset, linker and loader, plus loader `--help`. It reads only selected binary/config bytes and recursively expands explicit ld.so.conf include patterns, retaining unmatched patterns and cache/preload presence. No loader search directory is scanned. `prepared-metadata-plan.json` binds argv, CPU5/cap5, explicit configuration environment, helper/tool bytes, alias spellings and exclusively absent output root. It is prepared metadata, not execution admission; collection must implement the specified pre/acquired/post/final and unconditional receipt boundaries using existing helpers before any child.

`resolver-candidate-input.json` preserves the earlier unadmitted path-only lead; `resolver-plan.py` separates recursive selected files/config from shallow loader search roots and refuses broad recursive `/lib`/`/usr/lib` or falsely closed status. Its deterministic output is not a tool snapshot. The five no-child controls cover these refusals and cyclic recursive include expansion with an absent pattern. Current loader metadata is the next bounded review subject, not a substitute for compiler/header/linker or generated-runtime namespaces.

`collect-metadata.py PLAN SHA256` is now the narrow runnable collector: before importing helpers it verifies the exact supplied plan, current Python, its own bytes and all transitive helper pins. Each metadata command receives the shared child lock, raw exclusive regular files, pre/acquired/post guards and an unconditional final receipt using existing `task_runner` / `evidence_boundary`. Nonzero output is retained before refusal. Fresh v2 preserves the original unexecuted v1 plan. The namespace guard follows actual intermediate symlink targets and filesystem `..`, re-expands recursive config includes and retains cache/preload absence. Four no-child collector controls cover preimport drift, interpreter drift, failed raw/receipt preservation and an intermediate-target/`..` alias trap. No metadata child has yet run; v2 requires exact independent launch admission.
