# Preparation history

No source child timed out or failed infrastructure. All nine source attempts are retained unchanged. No Bend source repair was needed.

Before children, generic collector discovery used an incorrect path supplied by the coordinator. The coordinator corrected it to the existing canonical-adoption-v1/detached-v2/check-source.py source capture; no runner was invented or modified. The private preparation adapter calls its unchanged prepare_attempt/capture functions and the existing central executor/scripts/bend-check.

Hook-fixture preparation initially attempted to load the fixture registry without its scripts import path (ModuleNotFoundError: task_runner), then queried CONTROL_SETS in this older readiness branch (KeyError: CONTROL_SETS). Neither attempt ran a source child or hook. Inspection established the actual readiness baseline hook uses the older DEPENDENCIES registry and all required script/benchmark fixture files are materialized. No missing-fixture commit retries were attempted.

The initial git add refused newly authored files outside the focused sparse definition; the following commit had no staged files and ran no checks. The private authority-refresh-v1 path was then added to sparse checkout before staging. This was a checkout-selection repair, not a source/compiler repair.

All configured staged Python/helper suites passed on the first hook attempt. Final git whitespace check rejected the byte-identical retained owner-handoff.bend source snapshot (historical extra blank line at EOF). Preserve exact source bytes in source-stage.zip instead of stripping compiler-input whitespace; the unpacked source tree remains private on the installed host and is reproducible from the archive. No compiler/source child was rerun.
