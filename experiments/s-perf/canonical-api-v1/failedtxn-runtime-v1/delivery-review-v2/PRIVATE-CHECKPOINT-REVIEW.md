# Private FailedTxn checkpoint review

Verdict: PASS for integrating this bounded private consumer preparation. This is not production API/layout adoption, a deadline repair, numerical performance acceptance, or completion of issue #21. Ordinary Motion256 remains UNMET at the unchanged five-second consumer limit.

Reviewed source `68cd0c7971125173c2d9d8b8beb1cd9f6cc6f50f`, frozen source inventory SHA256 `d5f1b3200cbe3d1b5e33feba8b74942625dd878d4bf2d19341331cc495f78e47`, and packet commit `e981bc61ef38ee6d449711e235229596e787adb8`. Packet: `runtime-v1/motion64/known-length-checkpoint01`; RETENTION SHA256 `622e0ae44aa019f887cbfcb0c8f4b59960ec183359284585bf080c256b79cb3c`.

## Independence and criteria

This review applies CODING_STANDARDS.md, docs/SPEC.md, the governing #21 story, agent-workflow delivery rules and check-policy evidence boundaries. I authored none of this FailedTxn adaptation, independent model or known-length change. I did author ancestor Readers Doc/piece-buffer ideas reused here; this is an independent review of the FailedTxn delta, source applicability and evidence, not an independent re-review of that ancestor design. Executable controls and the coordinator's generated-code inspection supply separate evidence for the reused machinery. No new law, universal proof or cleanup/IO guarantee is claimed.

## Source findings

No blocking field, ownership, chronology or wire defect found in the reviewed finite scope.

- Generic physical observation threads and reconstructs actual affine payload owners. Data Docs contain detached observed text, not affine payloads. Physical trees, allocator slots/generations/free/order, column metadata/stamps, event/command/trace state and full payload fields remain represented. Actual logical rows are queried once at their original boundary; observation does not replay gameplay or substitute synthesized rows.
- Transaction facts are captured before finish from the actual transaction. Registered-only boundary rendering avoids recursively embedding the growing frame; the full frame and all retained boundaries are still emitted in the final report. Failure/retry/FIFO/disposal order, A/B schedule behavior, reader and Local state, reservations and stale handles retain their original callsites and order.
- Ledger inverses remain field-specific. Actual Audit request/effect Strings remain full observations and retain the established nonjournalled-effect semantics. Affine signatures do not imply automatic destruction or arbitrary external-effect rollback.
- Character length and traversal work are separate. Text lengths come from actual String.length; joins add lengths; PhysicalNode adds exactly seven grammar characters. Traversal work counts the actual punctuation stack entries. There is no fixed traversal cutoff or large-Doc flattening path; inconsistent work is an explicit error.
- Reached known-length inputs form a closed private boundary: Doc Text uses its derived length, punctuation uses exact literal lengths, and the control uses actual String.length or matching empty/single-character literals. This is not a universally refined public constructor: forged private counts are outside this qualification.
- Buffered pieces preserve character order and the 4096-character chunk budget. The writer retains chunks, so bounded chunk size does not establish bounded total memory. Empty, Unicode, 4095/4096/4097, long-text and tiny-piece controls supply finite executable credit.
- Warmup writing completes through IO.bind before creation of the fresh measured World. Both actual reports remain present; no fresh-world state is fabricated and no IO side effect is claimed rollback-safe.

I independently verified all 119 reached Bend modules plus two sidecars and 270 source pins, including exact entry import closure. Public ECS sources are unchanged by this private checkpoint.

## Actual and portable evidence

Read-only receipt/plan/guard checks confirmed actual source/tool/artifact bindings, exit statuses, empty ordinary stderr, complete equality for passing roles and exact-prefix status for incomplete output. The sealed packet verifier was run offline on CPU9:

```
taskset -c 9 python3 <packet>/verify.py <packet>
objects/members PASS 6903 4953
portable plan/source/tool/resource/guard joins PASS 224 full independent comparisons 6
ordinary64/control4PASS; ordinary2562INCOMPLETE; fuller15diagnostic2FULL only; no5squalification
```

Ordinary Motion64 JS and Native pass all 38,459,780 independent bytes; the known-length control passes all 122,320 bytes on both. Ordinary Motion256 JS and Native both remain INCOMPLETE at five seconds (JS zero output; Native 59,305,984-byte exact prefix). The separate fifteen-second full-coverage diagnostics complete both 118,614,122-byte independent reports. They are DIAGNOSTIC_ONLY: they do not satisfy ordinary acceptance, establish a speed ratio or authorize changed limits. Historical invalid control construction, failed candidates, profiles, incomplete prefixes and unexecuted attempts remain status-aware; they are not promoted into successful ordinary evidence.

## Integration boundary and remaining gates

The workflow permits delivery of a clearly named bounded slice with outstanding obligations visible. Integrating this private fixture/evidence checkpoint is therefore acceptable while ordinary256, corresponding Health/larger-size correctness, full equivalent-work scaling and final numerical #21 qualification remain open. It must not select a new performance baseline or production storage layout.

Reuse of the existing #28 capsule applies only to its unchanged protected default workload. Before integration the coordinator must verify all 351 protected source hashes and absence of these private modules from the frozen workload import closure. This review does not transfer that gate into FailedTxn/canonical numeric performance credit. Actual integration hooks, push and CI remain coordinator delivery steps. No subject, compiler, model regeneration or benchmark was rerun for this review.
