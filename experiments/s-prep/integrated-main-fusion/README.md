# Fused Main point hook — proposal and finite control attempt

Proposed local transformation: the trusted `hook_checked` path checks namespace,
nonzero ID, capacity, committed high-water and liveness once, then swaps the affine
Main owner, invokes the existing transform exactly once, and returns it to the same
slot. MainNone returns Mismatch; stale/foreign handles return Missing. Aux,
metadata (including flags/ticks), pending commands, ledger and mode remain intact.
Public signatures and existing helper bodies remain available unchanged. Actual
upstream transaction inverse/mark/publication code remains unchanged.

Source motivation: the existing path takes Main through `take_rows`, then calls
`put_rows`, repeating bounds and metadata reads and rebuilding intermediate
Rows/Taken/result wrappers. This proposal removes that second decision/read. It
still performs an affine Array.swap and Array.set; no speedup is presumed.

Attempted checks (checker/runtime5s, codegen30s, clang120s): storage checks;
actual integrated provider positive and eight intended negatives pass (see JSON).
Integrated E0–E10 first codegen exceeded30s. SerialCPU5 retry passes both
schemas on NativeO3 and JS, with full fields/effects equal to fresh TS; the old
failed attempt remains retained. See main-evidence.json.
The first explicitly version-adjusted owned replay reached clone rejection, then
the actual duplicate control exceeded5s. SerialCPU5 retry passed the unchanged
full-field NativeO3/JS oracle, all three intended checker negatives, all three
original compiling mutants and three added fused-path mutants: wrong leaf, dropped
Main owner and bypassed foreign namespace. Both backends detected every mutant.
Neither original timeout counts as a mutation kill.
The coordinator authorized the explicit version-only replay seam for ordinary
checks, with toolchain repin still PROPOSED for future loop acceptance. Installed
stdout says2.0.35, whereas the frozen harness expects2.0.34. No compiler was
installed or modified here. Basehash remainsc742fae9… .

The candidate must not be kept from these semantic observations alone. Required
return conditions: accepted toolchain resolution and the root’s complete protected
checks, reviewed contract and comparative measurement gates.
No laws/proofs, timing runs or production acceptance are claimed.

Replay: `python3 experiments/s-perf/overlay.py /tmp/fresh-overlay`; run Main
with `BENDVY_CPU=5 python3 experiments/s-perf/main-run.py --overlay /tmp/fresh-overlay
--build-dir /tmp/fresh-main`; run `BENDVY_CPU=5 python3
experiments/s-prep/integrated-main-fusion/owned-replay.py`. The latter preserves
the authoritative fixture/oracle and adds three compiling mutants; its only
version-guard amendment is explicitly2.0.35. Exact tool/source pins are in
signatures.json/access-evidence.json/main-evidence.json.
