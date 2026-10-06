# Packed Motion finite controls

Independent controls for immutable Motion source closure `52b505c4d7c3a0b304659b48b0a892e6d0db973a3637bc033e03282792d52c6e`. Input `/tmp/bendvy-packed-main-slot-motion-v4-receipt-v2` has all 29 Bend files byte-identical to original v4. Original preflight refused its stale cache specialization digest; that failure and both metadata versions are retained. No guard waiver.

Actual private `CP.PrototypeMotionMainSlot`, `HA.PrototypePackedMotionRowOwner`, rank2 `prototype_packed_row_invoke`, packed fold and packed Host/Raw ingress are exercised. Literal oracles deliberately distinguish raw from cached values and frames. Arrays of lengths 1, 2, 4 and 8 preserve every cell; two setter calls must return true-old 100 then 500, patch raw cell 0/cache-a only, and preserve all other raw/cache/ledger metadata and retained Data.

Fresh JS and Native observations:

| Subject | Checkpoints per backend | Receipt |
|---|---:|---|
| Actual opaque row/get/set/journal/marks | 4 | row-controls-v2 |
| Actual Slot get/two swaps | 4 | value-controls-v1 |
| Actual rollback, complete physical World/context | 4 | rollback-v4 |
| Actual Host retained Snapshot, reached private fold and rollback | 2 | host-ingress-v1 |
| Foreign command rejection returns all raw cells/frame | 8 | foreign-return-v2 |
| Actual packed factory success/exhaustion | 2 | factory-v1 |
| Same-world hole queues, application consumes pending and leaves rows unchanged | 2 | hole-queue-apply-v1 |

Four intended checker negatives pass: cloning abstract Owner, undeclared concrete-slot access, cross-schema token, writes through a getter-only read registration. `negatives-v2` contains genuine repeated-owner consumption; v1's clone was rejected for wrong return type and is excluded from that claim.

Eight compiling runtime mutant cases are detected: lost raw update, damage to another raw cell, stale cached-a and wrong true-old journal, each on JS and Native. First six are in `row-mutants-v1`; corrected wrong-old pair is in `row-mutants-wrong-old-v2`. The first wrong-old source failed affine checking before execution and remains a failure.

`missing-return-v1` is a failed invented rejection oracle, not a product regression: original `commands.queue_owned` checks namespace only. SPEC's immediate rejection concerns foreign-world handles. A same-world hole is queued, then missing-target application emits no changes; the independent `hole-queue-apply-v1` observation records that actual policy. Production command-policy clarification remains a follow-up. Earlier rollback/foreign checker failures and the weaker rollback-v3 observation are retained; only v4 covers exact Aux/live/flag shape.

Reproduce using `fixture-run.py --fixture NAME.bend --expected NAME-expected.txt --output FRESH`, `negative-run.py --help`, and `row-mutants.py --help`. Default fixture input is the corrected metadata overlay. Runners pin all29/cache maps and use CPU10, executable diagnostic checker15, emission30, approved Clang19 O3 compilation120 and runtime5; proof/default checker5 is untouched. Bend version/guide were read before this scope. Evidence archive retains exact C/JS/Bend, source manifests, commands, outputs and failure receipts; native binaries are excluded.

These are finite source-bound Motion controls, not full22, universal authority/refinement, ECS proofs, production API or performance acceptance. Packed+paired and Health variants require fresh controls; no passing gate transfers to their different closures. No core/compiler/reference/kernel/dependency or canonical-defense edits.
