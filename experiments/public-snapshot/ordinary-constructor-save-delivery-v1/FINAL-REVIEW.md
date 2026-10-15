# #58 ordinary constructor/save review

**Verdict: PASS for the retained, bounded basic-save slice.** Reviewed commit
65ae2b23cae7cd41d67f03c13479527cc1c66dfd in
`/workspace/formal-proofs/bendvy-worktrees/snapshot58-ordinary-constructor-save`.
The 37 committed paths exactly match `/tmp/bendvy58-final-owned.json`; no production
core paths are part of the commit.

I read the #58 acceptance criteria, `docs/parity/snapshot-export.md`, and
`CODING_STANDARDS.md`. The retained source follows a real IO-created Workshop
world through the ordinary declaration preparation and constructor path, admission
into the column, retained declaration, and `Save.save`. It observes two nominal
schemas and actual affine owners; each save is retained while the live component and
resource are mutated, then a later save is observed. The generic save result carries
the live World alongside a separate Snapshot. This is finite executable evidence,
not a universal ownership proof or a public import/restore boundary.

The offline retained verifier passes: **208 archive members, four roles, ten
malformed-receipt controls, and four independently reproduced source models**. The
normal JS and stock Native O3 roles match the complete 9,605-byte two-schema oracle.
The reached admission-bypass JS control matches its 9,286-byte counter and rejects
the normal report. For the included-transient role, the original receipt remains
INCOMPLETE; the corrected source-derived v2 matches the retained 10,217-byte output
posthoc and rejects the normal report. That v2 is explicitly not a fresh execution.
The verifier also validates all 16 exact root-relative source-body inverses and the
single-source mutation reversals.

I independently checked the current root dependencies recorded in the source map:
all 31 canonical core files and both namespace C/JS sidecars match their frozen
hashes and development copies. The repository-relative `root-input-v1` sources
have exact import-only inverses and passed the recorded five-second source check;
the backend receipts remain bound to the qualified producer inputs, with no backend
replay claimed after import relocation. Historical TS evidence is limited to its
existing run: 33 source dependencies, reference entry, and Node match, and six shared
snapshots agree; it is not a fresh TS run or complete physical-report parity.

The two current documentation edits accurately leave feature timing/scaling and
full #58 acceptance open, and adopt no restore, checkpoint, identity, law, or
dependency policy. One wording refinement would make
`docs/parity/snapshot-export.md`'s “passes … on JS and stock Native O3” sentence
say “the qualified producer source passes”: the linked delivery explains that the
repository-relative import-rebased copy was source-checked but not backend-replayed.
This is a clarity note, not a blocker, because the delivery states the scope precisely.

Validation performed: `python3 experiments/public-snapshot/ordinary-constructor-save-delivery-v1/verify.py`
passed offline. No compiler or backend was run for this review. Full #58 acceptance
remains open.
