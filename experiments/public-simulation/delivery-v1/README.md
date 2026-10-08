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
