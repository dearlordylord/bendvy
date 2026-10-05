# Owned selected-row write capability — bounded prototype

This is a finite capability experiment, not candidate integration or a performance
benchmark. Main and Ledger remain genuine Type owners in `Held`. The remaining
World contains their temporary absence; closed rank-2 application callbacks see
only opaque Owner and token-specific operations. Both original Dense callback
families are copied from the protected measurement source; run.py verifies every
function byte and SHA256 before compiling. Each callback runs twice through the
original get/set/ledger/setledger interface, followed by three interleaved writes.

Every successful write records the original old scalar in actual X.Inverse and
prepends its mark immediately. Seven inverses remain in exact operation order;
there is no write coalescing or initial-snapshot rollback shortcut. Full four-field
Main/Ledger payloads and Type Aux owners survive. Both schemas have distinct
non-first fields and owner metadata.

Trusted selected-handle lookup checks namespace and ID against the held binding;
matching lookup sees the latest Main99 without consulting the empty physical slot.
Foreign matching-ID lookup returns Missing. The actual full snapshot joins held
Main/Ledger observations with actual O.world's remaining-row/metadata observations;
it reports no artificial MainNone/LedgerNone hole and returns every owner intact.
This fixture's snapshot splice is explicitly fixed to selected ID1, not a general
production query implementation.

After these observations, Main/Ledger reintegrate once into World. Success runs
actual X.tx_finish_success and X.storage_commit at tick9: two staged commands
publish FIFO (Flag2group9, then Despawn2), pings publish11,12 and actual staged marks
change only selected row's changed tick. Commands remain pending at the existing
commit boundary; no implicit applyDeferred is introduced. Failure runs actual
X.unwind in original inverse order and commits Reverted: original Main10/Ledger100
return, staged commands/pings disappear and ticks remain unchanged. The queues are
trusted pre-staged fixture input threaded through the unchanged application body;
this does not implement a new application staging capability.

The runner compares NativeO3 and JS's28 complete lines, fresh pinned bevy-ts Main/
Aux/Flag/Ledger fields, actual published events and independent inverse observations.
Bend namespace/high-water/mode/pending FIFO/added/changed metadata are independently
checked exactly. TS runtime epochs differ; equal TS tick/authority observations
are not invented. Four intended compiler controls reject undeclared/schema token,
owner reconstruction, affine duplication and a concrete setter on opaque read
Owner. These are closed polymorphic capability controls, not a universal safety
proof. Four compiling mutants (wrong reintegration slot, lost owner, inverse
ordering and foreign lookup bypass) must differ on both Native and JS.

Replay from a clean worktree with existing references/tools:

```sh
BENDVY_CPU=5 BENDVY_HELD_ARTIFACT=/tmp/fresh-owned-write-query python3 experiments/s-prep/owned-write-query/run.py
```

The runner materializes the real candidate overlay and actual original transaction/
observation modules. Limits remain checker/runtime5s, codegen30s, clang120s. No new
dependencies, compiler flags, laws/proofs or timing loops. Compiler2.0.35 is explicit;
prior2.0.34 evidence is not substituted. Failed development attempts are retained:
an extended lookup's high-live-register pattern triggered clang14 ARM64 register
scavenging failure. Splitting safe selected-handle extraction/comparison into
separate helpers recovered standard O3; a packed Type snapshot state preserves
owners. No failed compiler attempt counts as a mutation kill.

## Exclusions and required follow-ups

General cross-entity access, arbitrary opaque World callbacks, arbitrary selected
ID snapshot splice, optional Ledger/Main opening, provider staging, destructive
payload restoration, reader registries/stamps and actual applyDeferred remain
unimplemented here. Existing original measurement callback compatibility is shown
only for the two copied closed Dense bodies, not all system callbacks. Selected
owners are trusted fixture inputs; extracting a checked live selected row from
actual traversal requires a new integrated provider gate. Full query/provider/API
access controls and independent reviews must be rerun when integrating it. No ECS
architecture, product performance acceptance or measured improvement is claimed.
