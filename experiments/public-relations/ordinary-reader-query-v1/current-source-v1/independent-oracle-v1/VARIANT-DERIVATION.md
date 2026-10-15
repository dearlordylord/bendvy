# Current-source replacement and SystemFailure oracles

`variant_model.py` reuses the previously selected finite source models for the
replacement/unrelate and SystemFailure scenarios. Before rebinding either
model, it reproduces the exact earlier golden from the pinned legacy model.
It then checks the complete 37-row current-source freeze and verifies that each
current fixture and operation module matches the selected prior source after
import-only relocation. The consumer execution suffix beginning at
`def write_result` is byte-identical in both scenarios.

The current consumer exposes reader identity separately from system registry
identity. Registration order leaves `ParentWriter`, `ParentInverse`, and
`ParentFailures` at registry IDs 2, 3, and 4. The failure runtime starts its
reader allocator at 1; registration stores that value as `Reader.id` and
advances `nextReader` to 2. The model therefore keeps registry 4 in the nested
`FailureView.registry`, puts reader 1 in `FailureView.readerId`, uses reader 1
for active Domain membership and event Position, and includes `nextReader=2`
in each snapshot.

The replacement/unrelate expectation is 14,303 bytes with SHA-256
`0aeb7963538144904ec630f6031ae26e3f0732d6028ec6a08003b8001519b124`. The
SystemFailure expectation is 16,488 bytes with SHA-256
`287068cd850bf985a2ac21fde9c2e898c03f2d1480b08d222b2a0ea50eeab955`.
The adjacent `.gz` files are deterministic gzip representations. Run
`python3 variant_selftest.py` to recheck all current-source rows, old model and
golden pairs, import-relocated scenario bodies, complete unchanged consumer
suffixes, identity counts, and expected bytes.

The prior reached `clear-omitted` mutation removes the supplied `clear` callback
at the same operation site in the current replacement source, whose operation
body otherwise matches after import relocation. This establishes source-level
applicability only. These files do not derive a current-source mutant golden or
claim a current-source mutation kill. Although the SystemFailure operations
also contain that callback form, this packet does not claim a reached
SystemFailure mutant outcome.

No candidate/runtime stdout was read. These are finite source-model
expectations, not runtime passes, TypeScript reader-ID parity, universal proofs,
performance findings, or issue-level acceptance.
