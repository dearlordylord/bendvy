# First-Ledger-write journal prototype

**Finite isolated prototype; generic Tx replacement rejected. No speed claim.** `original.bend` copies the actual transaction implementation unchanged except relative imports. `journal.bend` retains those definitions and adds `Journal{owner: Tx, ledger_saved: Bool}` and wrapper operations. A successful first Ledger write appends its inverse; later writes retain that inverse and update the live owner immediately. Absent writes leave the bit false. It performs no growing-list scan.

`fixture.bend` compares original/coalesced transactions using a Type world with affine Array owners. Each run interleaves three Main writes and three Ledger writes, reads Ledger immediately at 101 and 303, and stages a command and ping. Full four-cell Main and Ledger arrays, original Main marks, staged command and ping all match for success/failure and present/absent Ledger. Failed runs restore initial values and discard marks/commands/pings. The fixture uses scalar Main/command witnesses, not the complete ECS component schema or a production opaque adapter.

`reference.mjs` freshly executes the pinned bevy-ts public runtime for present-Ledger success/failure, preserving all Main payload cells and four Ledger cells. It independently checks immediate reads and complete final values. Absent Ledger behavior is checked between the two Bend implementations against explicit expected output; the TS system cannot declare a missing required write resource and still run that callback, so no absent-TS equivalence is claimed. Main marks are an internal Bend witness, not a claim that TS internally journals duplicate marks.

Native O3 (one worker, GPU off) and JS agree exactly. Three compiling mutants—wrong first old value, dropped Ledger inverse, and skipped Ledger restoration—are detected on both backends. The protected originals and production sources are unchanged. Exact commands, hashes, compiler version, outputs and raw artifact directory are in `evidence.json`. Limits remain checker/runtime 5 seconds, code generation 30 seconds, clang 120 seconds.

## Required restriction

Generic `tx_finish_failure` accepts arbitrary `W -> W` restoration callbacks. Their interleaving can matter. The executable negative fixture deliberately lets Main restoration read Ledger: original output Main `[6,204,3,4]`, coalesced output `[6,305,3,4]`. Therefore this policy is **not generically observationally equivalent**, and must not replace the generic transaction implementation.

A production path requires a concrete storage-specific policy whose Main and Ledger inverse operations are disjoint: current `storage_restore_main0` delegates to Main-only `S.with_main`, while `storage_restore_ledger0` delegates to `S.with_ledger` (`experiments/s-integrate/transaction.bend:79–84`). Those paths must preserve all other owner fields, callbacks/capabilities, readers, publication and pending behavior under the complete connected gates. Source separation and these finite fixtures do not constitute a universal commuting proof; draft assertions are unapproved in `LAWS-DRAFT.md` and no proof is written.

The wrapper demonstrates a state-layout proposal, not a performance layout. Production needs an explicit private Tx layout revision (or separate concrete transaction type); the extra outer wrapper here may add allocations. Public callback type signatures could remain abstract, but every trusted concrete Tx constructor/pattern must be migrated together. No approval of that scope transition is inferred.

Internal diagnostic updates must be versioned, never weakened silently: `tx-occupancy` inverse occupancy/path meters, `operation-counts` record_ledger entry counts versus actual inverse append counts, and fixture expected inverse peaks. First-write coalescing leaves setter entry counts unchanged while reducing physical Ledger inverse count. Existing failed-transaction full fields, immediate read observations, Main marks, command/event discard, provider access and cross-schema negatives remain binding. Dense with 256 Ledger writes per tick would retain one Ledger inverse, but no timing benefit has been measured.

Replay:

```sh
python3 experiments/s-prep/ledger-journal/run.py
```
