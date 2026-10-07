# Unapproved equality law drafts and literal falsification

LAWS.bend declares three proposed exact pure-value statements; they are unapproved and have no definitions or PROOF.bend. This is not a checked proof or universal runtime refinement. Logical String equality does not assert common JS/Native IO acceptance of malformed scalars.

| Draft | Retained finite subjects | Reached defect |
|---|---|---|
| exact_string_equality |324 actual old String.eq/new equal pairs;128 long-prefix pair;7 Native-only surrogate representation pairs| always-true: `a` vs `b` yields true:false; equal-prefix: empty vs `a` yields true:false, in JS and Native|
| exact_ordered_access_equality |9 literal registration rows include equal access, extra entry, reordered access and unequal prefix-family; original ordered-list characterization is source-backed| always-true makes reordered [`read-phase`,`write-mode`] vs [`write-mode`,`read-phase`] accept at row327; prefix defect accepts `read-phase` vs `read-phases` at row328|
| exact_registration_characterization |9 literal ID/name/access cases include mismatching ID, name, access order/length, supplementary names| always-true accepts `😀runner` vs `😃runner` at row331; prefix defect accepts `runner` vs `runner2` at row325|

Rows are zero-based. law-literal-mutations.json extracts exact observed normal/mutant differences from existing controls-v2 complete logs, both backends; extraction introduces no new backend execution. String-pair rows execute original and candidate together. The9 registration rows execute the candidate against literal source-backed characterization goldens; they are not a newly executed W.registration_meta_matches pair oracle. Current patched full87 application owner/foreign/refusal evidence is separate finite integration coverage, not proof of these quantified laws.

Known gaps: not exhaustive over strings/lists/registrations; long controls do not cover every shape or establish complexity bounds; backend-specific surrogate observations do not repair compiler/runtime domain differences. Human approval and actual proof remain absent. No law was weakened or silently accepted.
