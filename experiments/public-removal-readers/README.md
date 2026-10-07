# Public removal and despawn readers (#32)

`python3 experiments/public-removal-readers/verify.py --output <fresh-directory>`
runs correctness without timing. Add `--timing` to collect the five raw
equivalent-work samples for each backend. Output directories must be fresh;
without `--output`, the runner creates a unique `.artifacts` directory and prints
its path. Existing receipts are never overwritten. The runner uses checker5, JS/C
emission30, approved private Clang19 build120 and runtime5. No package installation
is needed. `evidence/receipt.json` records exact source hashes, commands, exit
status, complete outputs, intended negative diagnostics and optional five raw whole-child
samples per backend. It records tool versions, manifest/all reference HEAD checks,
reference source inventory, verifier/oracle/fixture hashes and final drift guards. Source changes require a fresh run.

The independently authored pinned TS reference uses actual public commands,
barriers and registered systems. The Bend counterpart uses public structural
insert, observed removal and observed despawn entry points, two independent
registered readers and two affine `Array<U32>` component families. It compares
all twelve read outcomes in order plus the complete surviving payload slots.
Pending invisibility, discarded failed removal while present, successful removal,
repeat/absent removal, duplicate queued despawn, independent slow-reader backlog,
skip preservation and failed-reader retry are exercised. A separate Bend-only
observation checks actual first/last registration disposal and log release.

The runner must observe intended rejection for duplicate reader ownership,
wrong family, cross-schema record use and writes through a metadata read. A
compiling JS/Native mutant advances a failed reader cursor and must lose the retry's
records; merely failing to compile is not detection.

Feature timing includes process startup/output and five raw samples; it does not
qualify hot-path or JS/Native product targets. The unchanged #28 paired Workshop
gate is a separate delivery requirement for root integration. No new law/proof,
dependency, compiler/kernel change or canonical application edit is made.
