# Existing collector binding recipe — no backend admission

The existing `adoption-v1/qualification-v1/spine-report-v1/development-run.py` now accepts optional `--assembly-binding ABS_JSON --assembly-binding-sha256 SHA256`. With no flags it retains the historical entry, oracle commit/hash and ca88 whole oracle. No historical oracle is rewritten. Existing `--execute --plan-sha256` admission remains mandatory.

The binding has exactly these fields:

```json
{
  "mode": "registered-decode-assembly-v1",
  "entry": {"path": "ABS/spine.bend", "sha256": "64hex"},
  "sourcePins": {"ABS_EVERY_TRANSITIVE_BEND_IMPORT_INCLUDING_BASE": "64hex"},
  "oracle": {
    "commit": "40hex independent author commit",
    "expected": {"path": "ABS/expected.json", "sha256": "64hex"},
    "whole": {"path": "ABS/whole-expected.json", "sha256": "64hex"},
    "basis": {"path": "ABS/source-basis.json", "sha256": "64hex"},
    "authoring": [{"path": "ABS/expected.py", "sha256": "64hex"}, {"path": "ABS/REVIEW.md", "sha256": "64hex"}]
  }
}
```

All paths are canonical absolute regular files. Source pins must match the exact recursively imported source closure, not a subset. Independent basis retains the established `{ "sources": { "ABS": "SHA256" } }` format. Candidate and each mutant need separate explicit source bindings and output directories. Their oracle is the independently authored correct candidate oracle; mutant output must disagree, never receive a mutant-authored expected result.

After the independent oracle is committed: pin its source basis and authoring files, generate the complete manifest, and prepare using the existing collector without `--execute`. Preparation emits no child. Review the exact returned plan/digest, frozen inputs/tools/environment and unchanged CPU5/caps, then parent admits execution. `--native` currently means the existing installed **C-emission** development cohort; this change does not extend it to Native compile/run qualification.

Transport opts into the new full DTO inventory only with explicit assembly binding. It retains complete Mail, Local recovery, declaration codec/completion, registrations, before/after/barrier snapshots and all original cases. It never fills absent fields or drops an unrecognized constructor. `check-collector-bindings.py` checks historical roundtrip + ca88 preservation, synthetic full declaration/recovery roundtrip, missing recovery rejection, exact closure and binding/source/oracle drift rejection. Synthetic controls are not a semantic oracle or backend acceptance.
