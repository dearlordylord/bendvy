# Foreign disposal refusal / local retry / survivor

Source-only draft for interface/import/oracle review. No child commands yet.

Existing caller bodies copied from root followup/foreign-core.bend with only relative imports plus new foreign-disposal and surviving-reader route. Source proposal pins current read-only root dependencies; worker lacks later root followup files, so a fresh immutable reviewed stage must copy those exact current files before checks. No existing src or fixture is edited.

Independent model and expected.json were written before caller-core.bend. Each nominal schema has two real worlds: world A has nine full rows (local cleanup then survivor checkpoint), world B nine full rows (survivor then local cleanup); eleven instance/delivery records. Every existing physical field, owner token, registration/cursor/batch and unchanged payload remains exact. Both JS and Native historical seven-row scenes remain supplemental, globally INCOMPLETE; new rows receive no old runtime credit.

Cleanup rejection must retain A registry and both reader owners plus untouched B world. The same returned instance retries in A; accepted Sys.dispose alone allows removal of A's two positions. B's real same retained registry/reader then reads empty after prior successful consumption, ticking its world from6 to7 and advancing only its positions. A stays tick6 with removed positions; B cleanup consumes its instance afterward. There is no disposal argument owner: that API takes registry/world; surviving read uses actual Data Input. Do not fabricate an affine argument contract or repeated call on consumed owner.

Review source/import/full model before affected source5. Runtime plans and API-negative/mutant plans require separate review and immutable closure/tool/config/env/raw boundaries; no backend is granted by this draft. Proposed targeted defect removes stream positions on rejected disposal; complete foreign-refusal checkpoint must expose it while all unaffected fields match the independently authored variant. No new public API, law, later-key choice, FIFO adoption, timing or root core writes.
