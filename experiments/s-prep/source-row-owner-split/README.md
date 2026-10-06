# Source row owner split (bounded #21/#24 probe)

Draft experimental source candidate; not production adoption, a proof, full22 acceptance, or a performance cohort. This package changes only derived `held-adapter.bend` in the exact 29-module flat-Held baseline. Query/measurement/callback algorithms and public headers stay pinned. The independently verified flat-query source is not part of this closure.

`PrototypeRowOwner<Raw:Type,View:Data,L:Type,LV:Data,H:Data>` contains Main Raw/view, Ledger Raw/view, handle, undo and marks. World context, pending commands, transaction commands and pings remain outside the abstract callback owner as affine continuation arguments. Actual providers carry seven fields; final return consumes the callback's returned owner and restores the complete World/Tx once. No closure or new context container is introduced. Arbitrary affine Raw/L remain supported; immutable Data views are retained. Original invalid/missing fallback, true-old inverse ordering, mark ordering and callback algorithms remain unchanged.

Invariant mapping: supplied Main/Ledger providers cannot alter external context; original context is restored at return. The returned handle selects the original storage reinsertion slot under the existing confined-provider contract. Namespace/cursor, other rows/aux/metadata/capacity/depth/high, pending/mode, commands and pings remain explicit and complete. Journals and marks come from the returned owner. Experimental constructors are exported by Bend; the word private describes this probe's convention, not language-enforced secrecy. Universal constructor authority and production API approval remain follow-ups.

Reproduce from the exact baseline with `materialize.py --input /tmp/bendvy-held-flat-both-reproduced-v5 --output <fresh>`. It refuses mismatched 29 source pins, module changes, public-header changes and fuzzy patches. `derive.py` records the original source derivation; the materializer is the pinned repeatable recipe. Input closure `411467c393032950d49e203564ec6f68635065417562ea3864d5afabb173c233`; output `cb9fc60030d0d9ebe7f8192b6a343d2521896e5c00e116c019b255676202af8b`; changed module SHA `eba51d553139f559f8d479b9ca44bfe898c95514a6f9597714069c6acec6ac14`.

All source checks use explicit executable diagnostic15; default/proof5 is unchanged. Emission30, Clang120, runtime5; CPU10. Bend2.0.35 / Node24.20.0 / approved private Clang19.1.7. No compiler/reference/kernel/dependency/law/proof changes.

Verified finite evidence (receipts and source inputs are in `evidence/finite-source-evidence.tar.gz`, with per-file hashes in `evidence/manifest.json`):

| Gate | Current candidate result |
| --- | --- |
| Full64 builds | Motion+Health executable check, C, Clang19 and JS pass within caps |
| Full65 comparison | Both schemas; fresh TS, baseline/candidate Native+JS; all complete fields pass |
| Ordinary/count nine worlds | Both schemas; all fields pass; phase 9,300,544→8,907,328 constructions |
| Actual Tx/suppressed owner | Eight cached/raw schema programs; 576 complete records/backend pass |
| Lost-mark / inverse-order | Actual row-family compiling mutants;8 backend cases each detected |
| Affine generic owner | Owned arrays Native+JS return 50; cloning Raw rejects Data kind |
| Retained snapshots / returned owner | All four view kinds across writes, cached/raw, both backends; returned Main30/Ledger200 observed |
| Returned-owner omission | Actual final-return Raw discard compiles; exact complete-field counterexamples in both schemas/backends |
| Reached row confinement | Four positive / 12 intended negatives pass: abstract inspection, undeclared Ledger, read-write, cross-schema, concrete setter on abstract owner |
| Static/original getter clients | 16 backend subjects / 128 complete records pass |

The constructor delta is World, WorldRoot and None each −131,072; old/new owner counts cancel. Instrumentation adds one phase marker construction, recorded separately. Counts are not heap or speed acceptance. The explicit returned-owner mutant changes only the actual `_return` storage reinsertion Raw; callback/provider operations remain unchanged. The independent full-field oracle detects precisely the discarded Raw while unchanged context/journals/views remain checked.

No candidate timeout/failure or cap replay occurred. The known stock access9 fixture has an inherited frozen-header mismatch and is not rerun/credited here. This package does not include the independent flat-query source join. Production authority, universal refinement, full22 and numerical performance remain open.

Adjacent Native attribution belongs to `native-hotness-seed-followup` commit df05df7, not this task's gate: full65 fresh TS fields pass; World and RawWorldRoot requests each decrease 1/update and RFC 1/update (3 heap requests / 18 requested words saved per update). No clocks or qualified speed acceptance follow from these counts.
