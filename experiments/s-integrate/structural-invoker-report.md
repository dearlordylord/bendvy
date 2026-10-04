# Actual Cleanup / Inserts / Dispose joins

`structural-invoker.bend` supplies the concrete transaction/typed-command hooks
for the dispatcher-owned E6–E9 Host. It does not own the Host, clocks, reader
completion or explicit barriers. Cleanup binds the actual p/a/b handles and
instantiates a closed callback over arbitrary opaque Tx with fresh nominal
slot-zero setter, remove-a, despawn-b and Ping operations. The actual setter
captures its inverse internally; success commits p51, marks and Ping3 and stages
RemoveMain(a),Despawn(b). The callback receives no world or journal authority.
Cleanup's trusted handle parameters must be actual same-world trace bindings;
this helper does not establish a general foreign-command/root API.

Inserts accepts five genuine Main Type payload owners and calls public typed
`commands.insert_main` in p71,a80,c30,a81,b90 order. Dispose calls public
remove_main(c),despawn(a),despawn(p),despawn(r),despawn(c). `Batch{world,rejected}`
retains every actual payload rejected by the public command operation. No helper
flushes and no rejected result is fabricated as accepted. The stale b command
is scoped to this world, stages successfully, and is ignored when no live row
exists at apply. SpawnS remains in the dispatcher-owned closed systems module.

Run `python3 experiments/s-integrate/structural-invoker-run.py`. The independent
fixture actually creates a factory/world and reserves/spawns a,b,c,p,r with full
owned payload arrays and metadata; q consumes an actual reservation ID but never
publishes a spawn. Initial values are explicit chosen structural inputs matching
the full A/B payload forms, not evidence that this fixture dispatched A/B:
a[11,11,12,13], b[50,21,22,23], p[50,51,52,53], r[60,61,62,63],
Ledger[201,101,102,103], actual Aux/Flag fields. Their initial marks follow this
fixture's real setup barrier. The full dispatched trace separately supplies the
actual earlier A/B world to these same helpers.

Every complete pending/live world, all four cells and metadata, rejected counts,
Ping batch and exact ordered lifecycle change records are compared on Native
and JavaScript against independent finite operation expectations. Cleanup commit
leaves structural changes pending; explicit apply removes a.Main and b. Inserts
retains all five payloads before apply; a ends with81, c30, p71, and stale b90
never resurrects b. Dispose leaves all live payloads intact until its barrier,
then removes/despawns all remaining rows while retaining Ledger. Compiling wrong
Cleanup target, swapped noncommuting insert order and omitted r disposal mutants
must differ at their intended checkpoints.

The initial operation oracle incorrectly retained historical marks on a after
RemoveMain. Actual `commands.edit_row` explicitly reconstructs that row with
Main=None, added=0, changed=0. The first full original output exposed this detail;
the independently written finite oracle was corrected to that pinned source
behavior, preserving all operation inputs and public lifecycle outputs. That
initial run is not a PASS. The target mutant also explicitly marks its reused
Data handle parameter copyable so it remains a valid compiling semantic mutant.

Checker and runtimes retain five-second limits; code generation and clang use
the existing separate t05 bounds. No dependencies/tooling/proofs added. This is
fresh actual typed-operation evidence, not full TS parity, Host registration/
capture/readers, E11 retention, performance acceptance, general destructive
restoration, production layout or globally unforgeable root authority.
