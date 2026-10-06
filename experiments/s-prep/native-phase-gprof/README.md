# Native phase gprof diagnostic

Existing GNU gprof 2.40 and the separately approved private Clang 19.1.7 compile a private copy of frozen generated C with `-O3 -pg`. Profiling is disabled at main entry, enabled at clock 3 and disabled at clock 4. Pre-main records can remain. Runtime limit is five seconds; compilation is limited to 120 seconds. No compiler, runtime or original source is changed.

Both schemas pass comparison of all fields in 65 worlds against fresh pinned bevy-ts execution. Motion has 39 CPU samples; Health has 37. `term_drop` accounts for 10/39 and 11/37 samples, the Held row loop for 6/39 and 9/37, and `rfc_wrap` for 4 samples each. These sparse, instrumented histograms identify investigation targets; they do not establish causal costs, speed improvement or performance acceptance.

Run `python3 experiments/s-prep/native-phase-gprof/run.py --source GENERATED_C --reference REFERENCE_MJS --schema Motion --output NEW_DIRECTORY --cpu 7` (Health likewise). Private Clang path and root match the approved diagnostic installation. Evidence archives contain exact command receipts, raw outputs, generated diagnostic C, architecture-specific executable, gmon data and textual analysis. Gzip archives preserve content hashes in `archive.json`.

`gprof.txt.gz` preserves exact raw output; readable `gprof.txt` strips trailing spaces only. The manifest hash applies to the raw output.
