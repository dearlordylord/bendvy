# Source query owner transport probe

The pinned frozen-provider source returns two nested products from a query client. This diagnostic adds a separate generic `PrototypeOwnerResult<P,U,O>` with three fields and routes only the two handle-query registrations through a new private helper family. Arbitrary affine `P` and `U`, general owner-returning getters, abstract schema handles, all selection checks, indexed swaps/restoration, observation order and all original callback algorithms remain. Public `Q.each`, `Q.lookup`, every original query definition, the original handle client and the Held entry/signatures are retained. Only `query.bend` and `measurement-bend.bend` change.

This is a finite source experiment, not a production API, a proof or performance acceptance. The independently run Native attribution found **zero allocation/RFC delta** for this source representation. JavaScript performance remains open; fewer source products do not establish speed.

Baseline source29 closure: `409d87045a832f021c7d7a1aa880ebfd16ff8d2b9eb5035883d96f781a49daad`. Selected flat source29 closure: `ac8de957a37d85cb473168d43c89c589e418fd32685f5269a225d11d68dac31a`. `baseline-source29.tar.gz` preserves the exact baseline; `overlay-flat-v1` contains the selected source with matching embedded/standalone cache provenance. `flat-receipt.json` pins evidence. No emitted-JS rewrite implements this candidate.

Fresh executed gates:

- Motion and Health, Native and JS: 65 complete worlds each equal independently executed pinned TS. Validation includes every observed field, warmup and all 64 measured worlds.
- Two schemas and both backends: 160 independent literal query/command checkpoints, plus eight compiling order/flag-membership mutants detected at intended checkpoints.
- Nonidentity trusted getters: eight public-versus-flat source/backend subjects, 40 complete observations each. Getters return changed affine scalar owners with unchanged array payloads and old String observations; both protocols install the returned owners identically. This does not authorize a new write-through-read API.
- New flat contract: one positive and six intended affine/access/schema rejections. Existing frozen contract: two positives and three intended access/schema rejections. Actual static-provider contract: two positives and six intended rejections.
- Actual factory lineage: sixteen backend/schema/client/observer subjects, eight complete records each, including two live worlds sharing local ID 1.
- Actual direct Tx: eight original and eight suppressed-setter programs, 72 complete records each; protected independent cached/raw, true-old, journal, marks, rollback and failure oracles pass. These fixtures reach unchanged direct callback paths; the new private query helper is reached by full65 and general-getter subjects. No old-source receipt is transferred.

Commands (from repository root; keep CPU8 checks serialized):

```sh
python3 experiments/s-prep/source-query-owner-fusion/materialize.py --input /tmp/bendvy-query-frozen-provider-native-v3 --output experiments/s-prep/source-query-owner-fusion/reproduced-flat
python3 experiments/s-prep/source-query-owner-fusion/build.py --overlay experiments/s-prep/source-query-owner-fusion/reproduced-flat --schema motion --output /tmp/source-query-motion
python3 experiments/s-prep/source-query-owner-fusion/build.py --overlay experiments/s-prep/source-query-owner-fusion/reproduced-flat --schema health --output /tmp/source-query-health
python3 experiments/s-prep/source-query-owner-fusion/validate-full-fields.py --schema Motion --js /tmp/source-query-motion/batch.js --native /tmp/source-query-motion/batch.native --output /tmp/source-query-motion-fields
python3 experiments/s-prep/source-query-owner-fusion/validate-full-fields.py --schema Health --js /tmp/source-query-health/batch.js --native /tmp/source-query-health/batch.native --output /tmp/source-query-health-fields
python3 experiments/s-prep/source-query-owner-fusion/authority-run.py --overlay experiments/s-prep/source-query-owner-fusion/reproduced-flat --output /tmp/source-query-authority
python3 experiments/s-prep/source-query-owner-fusion/provider-run.py --overlay experiments/s-prep/source-query-owner-fusion/reproduced-flat --output /tmp/source-query-provider.json
python3 experiments/s-prep/source-query-owner-fusion/frozen-authority/run.py --overlay experiments/s-prep/source-query-owner-fusion/reproduced-flat --output /tmp/source-query-frozen-authority.json
python3 experiments/s-prep/source-query-owner-fusion/protected-run.py --kind tx --overlay experiments/s-prep/source-query-owner-fusion/reproduced-flat --output /tmp/source-query-tx
python3 experiments/s-prep/source-query-owner-fusion/protected-run.py --kind factory --overlay experiments/s-prep/source-query-owner-fusion/reproduced-flat --output /tmp/source-query-factory
python3 experiments/s-prep/source-query-owner-fusion/owner-threading-run.py --overlay experiments/s-prep/source-query-owner-fusion/reproduced-flat --output /tmp/source-query-threading
```

The literal getter runner takes the same overlay staged beneath `JS/experiments/s-integrate` and `Native/experiments/s-integrate`; run it with `BENDVY_CHECKER_SECONDS=15`. The protected adapter changes only the explicit approved Clang19 executable and process-local checker diagnostic limit, retaining fixture/oracle bytes. The historical stock access fixture uses pre-frozen runtime getter headers and is unsupported for this inherited baseline; exact frozen authority fixtures are separately rerun instead.

Limits: default proof/checker 5 seconds; explicitly authorized executable checker diagnostics 15; emission 30; Clang 120; runtime 5. Existing approved wrapper `/tmp/bendvy-clang19-diagnostic/clang19` uses process-local `BENDVY_CLANG19_ROOT`; no dependency/global toolchain change. `bend version` reported 2.0.35 and `bend guide` was read first.

Failures remain in evidence: initial Motion C emission exceeded 30 seconds; exact unchanged-source retry passed within 6.23 seconds. One TS run exceeded 5 seconds while a same-CPU build ran concurrently; a fresh serialized run passed the unchanged limit. Abandoned context-record v1 failed materialization before provenance update; v2 checked but introduced seven-array context transport and was not selected. Their exact sources are compressed in `probes/abandoned-context-source.tar.gz`.

Follow-up: measure exact candidate JS and Native work, then investigate a separately pinned frozen continuation passing independent opaque context slots directly. Do not join the Held overlay until both source closures are independently verified. Full core capability, universal refinement, ECS laws/proofs and numerical performance acceptance remain open.
