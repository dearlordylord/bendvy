# Large actual added/changed filtering

Run `python3 experiments/s-integrate/host-mark-run.py`. Six Native/JS cases use
actual threaded creation/reservation/application, width-four Type payload reads,
the rank-2 query and full world observations at 1, 17 and 65,537 rows. Their mark
filter receives actual handles and row stamps; payload getters check every cell
and metadata before yielding the canary's Bool views. Both filter results retain
all those views/flags and ascending handles. Empty and boundary reads also pass.

The original 65,537-row filter failed: Native reached five seconds and JS
reported a machine-stack memory fault, for both schemas. The preserved
[baseline](host-mark-baseline.json) is failure evidence. Small original cases
and six independent sparse/mixed/boundary Data controls passed before the repair.

The implementation advances a sorted world-observation suffix instead of
rescanning it for every query row. Both loops are tail-recursive; filtered rows
accumulate in reverse and regain their original order once. The exact predicate
remains `since < stamp <= thisRun`, independently selecting added or changed.
Missing row IDs still yield stamp zero. Complete Data query rows are returned.

The independent small controls use distinct stamps, optional values and flags,
and include an Aux-only row plus an unmatched ID. Four compiling boundary,
mark-kind and order mutants differ on both backends. This establishes the bounded
filter prerequisite, not full dispatched E11, arbitrary authority or performance
acceptance. Large fields remain uniform; full Host/retention uses its own
nonuniform payload and comparison gates.
