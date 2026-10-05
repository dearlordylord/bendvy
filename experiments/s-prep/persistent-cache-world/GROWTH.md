# Finite cached-owner structural probe

Input commit: f3eb7a95efd101530fc6782c8510a68b2021173d. Receipt: growth-evidence.json. Historical two-tick evidence is unchanged.

Replay from this worktree/repository:
```
BENDVY_GROWTH_ARTIFACT=/tmp/bendvy-growth-fresh python3 experiments/s-prep/persistent-cache-world/growth-run.py
```
A task may additionally assign `BENDVY_BUILD_CUTOFF_UTC` (ISO8601 with timezone). Omission has no historical deadline. The executed run explicitly assigned 2026-10-05T01:48:00Z. Pure controls reject an expired explicit cutoff before a build and accept omission. Existing run.py now uses the same optional assignment; its historical runner SHA remains in historical evidence.json.

Observed: actual generic Rows growth from capacity1 to8 carries Cache<Raw,View> as the Main owner. Both Motion and Health preserve all four raw/cached fields, Aux, flags, epochs, namespace, next, mode and absent Ledger. Eight full world checkpoints compare cached snapshots against independent original uncached getters AND independently constructed Python expected worlds. Main is initially absent on entity2, replaced on1, inserted on2, removed on1; staged Flag8 and Despawn2 remain pending until actual apply_checked, then execute in FIFO order. Actual point lookups reject zero/out-of-range/foreign handles. Actual foreign flag staging returns Missing with the original flag payload and leaves the queue unchanged.

Native O3 and JS output agree. A compiling mutant reverses the existing/empty Main tree association in actual storage.rows_grow; both backends compile and the full-field oracle rejects its output. Raw outputs and compiler/Base/source hashes are recorded. No old two-tick probe was rerun.

Domain remains the private cached World with explicitly wrapped trusted cached constructors and original index0 writers. This extends the finite structural gate; it does not supply a public raw-command/factory adapter, general transform invalidation, every command/optional-state branch, production API, universal invariant proof or performance acceptance. Existing callback bodies and two-tick prototypes are unchanged. Follow-ups: production constructor/staging boundaries must construct/refresh cached owners; arbitrary raw mutation must invalidate/refresh; all optional combinations and query provider integration need their own checks.
