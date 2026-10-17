Independent source review and finite oracle, before subject backend execution.

Technical recommendation: retain the four exact proposals for human review and
run the frozen normal/control sequence. No proof or law approval is granted.
The equations are meaningful exact characterizations of the four pure Data
helpers. They are not tautologies: the specification does not call production
key equality or position lookup/activation/update, and independent per-record
semantics determines this oracle. No premise excludes counterexamples or turns
an instance into Unit. Constant answers cannot satisfy the key cases or position
cases. All eight Stream fields participate in equality; the seventh preserved
field is dropped, not an omitted diagnostic. Arbitrary Data event values are
quantified in the law, though the finite fixture uses only U32 events.

The failure rule preserves existing cursors but activates an absent reader at
cursor 0 with registeredAt=max(tick−1,0). Success overwrites every matching raw
cursor with tick and preserves registration, multiplicity, order and nonmatches.
There is no monotonicity premise: backward ticks and duplicates are intentional
raw helper inputs. Registration authority, actual clock choice, namespace,
World preservation, affine payload lifetime, rollback/publication and retention
are outside these equations. Explicit advance is independently pinned because
its implementation does not call completed. A dropped-field mutation affects
completion only, and a failed-completion mutation does not affect advance.

Source anchors: entity-key.bend:13; event-stream.bend:32,47,51;
event-runtime.bend:101,107,113,122,184,189,192. The existing approved cursor
failure/retry distinction and its Bevy divergence are recorded in
parity/affine-events.md:70. Pinned Bevy Entity equality uses both index and
generation (entity/mod.rs:459); message cursors advance through iteration and
clear sets the current message count (message_cursor.rs:144). Those reference
operations do not establish Bend's transaction-completion policy. Bevy excludes
MAX as an EntityIndex, whereas the Bend raw Key domain includes it. This
fixture's MAX case is therefore not a public Bevy-constructible entity claim.

Finite coverage limits: the 16 rows do not test an empty position list or absent
reader at tick 0. The existing-reader tick-0 rows show overwrite to zero, not
saturating creation at zero. No fixture can establish the unbounded list/Nat or
all-Data-type quantification. Four planted defects demonstrate four particular
sensitivities, not exhaustive mutation coverage or failed universal proofs.
The separate 22 legacy support candidates and 11 metadata drafts retain their
unapproved/deferred status; this packet supplies no coverage for them.

Reproduce bytes from the repository root with:

    python3 docs/laws/current-reader-key-draft/oracle-v1/model.py normal

Replace normal with generation-omission, failed-reader-advance,
dropped-metadata-loss or explicit-advance-zero for the four counteroracles.
Each corresponding .stdout file is the complete expected stdout; MANIFEST.json
binds hashes, byte counts and exact mismatching row IDs. All five contain 16
nonempty lines and end in two newlines: each pair adds one and IO.print adds
another. Pinned Bend Base Bool.show, List.show and effs/print.{c,js} establish
capitalized booleans, comma-space list separation and that final newline.

The model contains manually transcribed fixture inputs and semantic rules; it
reads no Bend files, subject outputs or author-generated expected values and
runs no backend. The right side always remains the independent normal contract.
Mutants change only their specified left-side behavior. Normal differs from
every mutant; explicit-advance-zero intentionally agrees on max-zero.
Python source checker passed; all saved outputs were reproduced from this model
and validated for 16 rows, normal equality, mutant inequality and output hashes.
Backend acceptance and final runner-plan binding remain the coordinator's work.
