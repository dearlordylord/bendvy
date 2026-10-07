# WorldIO promotion checklist — unapplied, root coordinated

The additive `world-io.patch` creates exactly four core files: world-io.bend, world-namespace.bend, world-namespace.c and world-namespace.js. No existing core file is edited. manifest.json pins the current World dependency, the four prospective files, copied candidate inputs and patch bytes. The C/JS effect bytes are unchanged from the independently reviewed45-command candidate. Bend changes are only relative core imports, effect filenames and a candidate comment.

## Entry point and unchanged semantics

Advertise WorldIO.create as the application creator, returning Created with an arbitrary-Type World or Refused with the original arbitrary-Type Resource. It uses actual W.create_checked and the admitted one-module IO namespace allocator. The exact existing successful range is1 through4294967294;0 is exhaustion/refusal and4294967295 is reserved. Shared Native atomic compare/exchange and JS module counter saturate, never wrap or reuse disposal IDs. No failed-reservation cancellation, stale-handle, clock, allocation/reuse or cleanup policy changes are part of this patch.

Raw World/Handle constructors, W.create_checked, legacy W.Factory/W.factory/W.create and WorldIO's convert/with_namespace helpers remain source-accessible trusted setup operations. They can bypass canonical provenance. Document that explicitly; do not advertise language-wide constructor confinement. The one emitted-program canonical module guarantee is not separate-program/bundle/realm/worker/process uniqueness or a concurrent uniqueness theorem. The effect is foreign IO, not a proved ECS law.

## Freeze release and source adoption

1. Root confirms #34 publication and #42/profile freezes have ended and coordinates one combined core freeze. Do not apply the patch while a receipt/measurement depends on the old source.
2. Require all four target paths absent and the actual current World hash matching manifest.json. If another approved World change lands first (including the separately prepared tail scan), create a fresh manifest and fresh owner replays; do not credit the old source receipt as current.
3. Run `git apply --check experiments/public-identity/production-candidate/promotion/world-io.patch`, inspect the exact four-file addition, then apply only that approved patch. No legacy helper or constructor is removed, no pure proof module imports IO, and no existing consumer is silently migrated.
4. Root updates the application API documentation/index and selected canonical example imports explicitly. The pure Factory path remains labeled trusted setup/compatibility. Keep the raw authority caveat and foreign proof-only diagnostic visible. These documentation/consumer edits are root-owned and need their own reviewed diff.

## Required current creator owner receipt

The `promotion/validate.py` harness stages the patch at its actual core target paths and rebinds four authored fixture imports to actual src/ecs/world-io.bend. It binds the exact stage addition plus mapped fixture hashes, complete source/tool/Base/TS inventories, expected outputs/diagnostics, planned mutant hashes and generated inputs. It supports `--native` after independent inspection. This staged replay catches import/effect CID relocation issues, but does not replace post-adoption live current-source verification.

After application to shared core, prepare a fresh source-bound replay against the live WorldIO module and retain a new receipt for all these cases:

- Two actual same-schema canonical Worlds, complete Stock/Recipe/Queue Arrays and markers, foreign typed lookup MissingEntity, actual gameplay queue refusal, complete World/Tx before/after ownership including staged command, inverse journal and event.
- Successful commit/barrier executing the captured Bundle; separate live-component rollback executing the inverse and restoring the original complete Stock Array. Preserve authoritative existing clock observation and avoid a new failed-reservation policy.
- Ordinary namespace sequence1–4, declared near-maximum namespace input, two maximum valid creations and repeated refusal returning complete original four-cell Array Resources.
- Reached compiling collision and creator range mutants on both JS/Native at the new actual core files; complete output rows, not a metadata-only checksum.
- Four exact intended negative diagnostics: Created/Refused owner duplication, nominal cross-schema handle, write through abstract read, undeclared World access. Foreign proof-only failure is classified separately from successful live IO checking and runtime.
- Actual pinned TS same-schema numeric collision/foreign lookup/despawn output; approved Bend foreign MissingEntity difference remains explicit. No new reference policy is inferred.

Use the unchanged checker/live/runtime5s, emission30s, private Clang120s and Native1 thread/GPUoff limits. Retain complete outputs, source/input sets, copied stages, intended mutations and generated JS/C/native hashes. Reconfirm actual Base/TS/reference commits and tool resource/library sets. Independently review the final live source receipt before delivery.

## Affected owner and consumer replays

Replay scope follows actual executable dependency changes, not blanket retesting after a four-file addition. Adding WorldIO does not change the existing pure World implementation or any legacy consumer import graph. Existing unrelated feature receipts remain historical/current according to their own exact pinned inputs; do not pretend they were rerun or force unrelated correctness/build cohorts solely because unimported new files exist.

Required after adoption: the direct canonical creator owner/refusal/rollback/exhaustion/mutation/negative controls listed above, actual foreign effect relocation on both backends, any consumer explicitly migrated to WorldIO, and the unchanged default #28 inventory/gate. For an affected migrated consumer, rerun its complete own harness and preserve every authored owner/checkpoint/error/cursor control; do not replace it with the creator fixture. If the actual query Workshop or user-system application is migrated, use its complete22 TS-equal plus approved foreign checkpoint workload and relevant registered/rollback/Type-owner negatives.

The separately proposed World.handles tail patch is not part of this four-file promotion. If root adopts it or changes a shared executable dependency in the same final freeze, root must identify its affected operations/consumers and schedule their exact current-owner replays under that separate scope. Retain original high-water faults and the actual pending/Resource/FIFO scan controls; do not silently substitute the experiment-only wrapper. Schedule/provision/readers/component-state/bundles/relations/registration/fragments/decoder/constructor feature suites are required only where their executable dependencies or migrated consumers actually change, not automatically for this additive IO module.

Bind each affected actual recursive dependency DAG and fixtures/helpers/reference inputs. The full-core freeze belongs to the final default gate; it does not turn every unrelated feature receipt into this task's acceptance.

## Unchanged default #28 gate

After current semantic owner/control receipts pass and root establishes an observed suitable host window, run the default gate from benchmarks/README.md with a fresh output directory and an allowed coordinated CPU:

```sh
python3 benchmarks/test-statistics.py
python3 benchmarks/run.py --output .artifacts/creator-regression-FRESH --cpu ALLOWED_CPU
```

Replace the literal placeholders with a fresh unique path and an observed available CPU; do not reuse receipts. Keep baseline327bec49, archived Workshop work, ten complete applications/process,22 TS-equal checkpoints, randomized balanced20 adjacent pairs/backend, zero-allowance paired sign test/Holm0.05 and all existing caps unchanged. No provider override, baseline advancement, threshold amendment, outlier removal or reduced checksum work is part of this adoption.

Ensure the final frozen input inventory includes new foreign C/JS effect bytes as well as Bend source. The default Workshop gate protects its existing workload; it does not exercise WorldIO if the archived application still uses pure Factory, so creator-specific complete equivalent-work timing/scaling remains a separate task and cannot be claimed from that gate. Contention/timeouts/source drift are inconclusive, not acceptance. No new per-feature numerical criterion is proposed.

Root owns final independent Spec/Standards review, delivery report, commit/push and issue closure after the governing gates. This checklist authorizes none of those by itself and changes no policy/law/dependency.
