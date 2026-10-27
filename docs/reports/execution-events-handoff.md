> Verification policy override (2026-10-27): semantic verification uses Bend laws only. The new non-law models, reference tests, golden outputs and check scripts have been retired at the user's direction. References below to those checks describe historical work, not current acceptance. Historical receipts remain outside the source tree; the five approved Bend helper laws do not prove the whole ECS.

# GH84 ordinary event delivery handoff

GH84 remains incomplete pending final independent review, affected integrated
normal checks, the declared CI native cohort, and the parent execution gates.
The event implementation and its complete concrete consumer observations are
ready for that review. This report uses the issue-completion-report acceptance
ledger to distinguish implementation evidence from issue closure.

## Delivered source

The executed consumer source is commit
`39a8d4afc0785e29032fef2fededa358e3a7c091` on
`feature/gh84-events-complete`. This handoff changes documentation only.

- [Family](../../src/ecs/execution-event-family.bend) owns each arbitrary Type
  payload once, registers/removes affine reader tokens, publishes immediately,
  and returns actual refused, retired, or shutdown owners in typed outcomes.
- [View](../../src/ecs/execution-event-view.bend) refreshes the canonical Data
  cache during Writable operations. Its schema, payload type, and family key
  phantoms bind the read capability to its actual canonical family.
- [Operations](../../src/ecs/execution-event-ops.bend) wrap canonical builder
  grants. Ordinary reads use ResourceRead and modify only the actual token in
  System Local. Publisher/admin use ResourceWrite.own for Type outcomes.
- [Consumer](../../examples/parallel-events/README.md) runs actual registered
  publishers, independent readers, admin, condition, peer, and error-handler
  capture through the ordinary public root schedule. Overlapping family readers
  remain conservatively Exclusive/ReadOnly. No shared affine log view is claimed.
- [Host registration](../../src/ecs/world-namespace.c) selects the actual C
  registration function type with two correctly typed C11 helpers. It contains
  no function-pointer cast, version macro, compiler patch, or generated-C patch.

The pinned Bevy reference is `ad678262ce53b5d142fe49ee5e08caff6f00ab60`.
Source comments and the consumer contract link the actual immediate write,
retained/future cursor, per-yield progress, lag, and two-generation draining code.
No new law, generic affine preservation proof, host-identity theorem, or automatic
IO finalizer was approved or established by this delivery.

## Acceptance ledger

| Issue criterion | Evidence and remaining boundary |
| --- | --- |
| Data and arbitrary Type payloads, independent ordinary readers | Observed for U32 and actual affine Array<U32> under two unlike nominal schemas. Each complete concrete case preserves both serial and native schedule routes and the full five-pass state. |
| Actual family conflicts and dependency visibility | Metadata comes from the same closed canonical resource slot. Publisher/admin are Exclusive/Writable; readers are Exclusive/ReadOnly. Future-fast reads row 2=101 in the same pass after the publisher's handled error. No deferred structural command grant is involved. |
| Authored publication after body error | Both first-pass sends remain in the actual log. Their actual owners later appear once in admin retirement. The Future-fast case directly observes the first send after the error in that pass. |
| Retention, lag, creation/removal, skip, partial error and resume | Complete oracles cover retained/future creation, two skipped slow reads, per-yield progress before returned errors, resumed positions, missed counts, token removal, and shutdown. These are finite selected traces. |
| Typed admitted/refused/retired/shutdown ownership | Each actual returned Array owner is threaded through two later reads. Final observations list every retained retired/shutdown row, refused payload, token and cache. This does not establish arbitrary-provider preservation or effectful cleanup. |
| Parent #77 and both backends | Qualified private-cohort observations pass below. Existing root-cut implementation is reused; configured four workers and a native route do not independently establish actual concurrency. Source-current #80 reach/multiple-worker evidence remains a parent gate. Applicable ordinary system-admission refusal evidence also requires explicit current-source reuse; these event cases exercise publication, reader and admin refusals. |
| Access and ownership controls | Positive and repaired wrapper-construction controls were checked with qualified 2.0.35. Original eight intended diagnostics remain labelled development evidence. The coherent normal wrapper now includes all eleven negative controls; its full source-current execution awaits final launch review. |
| Current consumer, docs and normal checks/review | Consumer and ordinary event contract migrated. Round 1 found cache rebranding; the branded cache and three construction controls repair it. Round 2 and affected integrated normal CI remain required. |
| Runner/resource policy | Existing common.sh manual execution only. No new collector, instrumentation, performance campaign, GPU delivery, or dependency was launched. The changed normal wrapper remains unexecuted pending review. |

## Complete backend observations

[ORACLE.md](../../examples/parallel-events/ORACLE.md) was derived before capture.
The original aggregate oracle's metadata correction is explicitly recorded there.
The original pre-correction files retain their first frozen hashes:

- Expected stdout `a7c0205ce0977c85382245abe6135023a5f7a113eab435ca75d0fb2e9b3a8e46`.
- Oracle explanation `52c59b8d795877d27f5d0c0b2094bda4d9da9cf659d41ee6394179fb81021de8`.

Round 1's independent model matched all eight original complete lines and
11,275 bytes. Its accepted rebranding counterexample and qualified compiler
bindings remain in
`/home/node/.claude/orchestrate/bendvy-gh78-94/reviews/gh84-round1/`.
The repair controls reject canonical cache grants wrapped under another schema,
payload type, or family key. Diagnostics remain at
`/tmp/gh84-qualified35-wrapper-{schema,payload,family}.log`.

The concrete native entries avoid the aggregate entry's 30-second C emission
limit without reducing state or observations. Each independent process starts
its actual allocator anew. The original A-affine oracle remains 2816 bytes,
SHA256 `a4ad1b212c14f8a354d4c5e2a2ea2d700800ced807ada215017947e47317c476`.
Future-fast's separately derived oracle is SHA256
`95c64c6da960eedd179f5df7468742329cc2c4bdebe15ccbf2867d01a640a871`.

Actual handle `16543` terminated with exit 0. All five complete concrete cases
passed twice on Node and twice with each native worker count 1 and 4. Each
stdout contains both full serial/native schedule traces. All 30 stdout files
match their complete static oracle byte for byte. The product portable host
adapter is included in these successful native observations.

Artifacts and receipts are retained in `/tmp/gh84-concrete-39a8d4afc-r1/`:

- `before.json` binds the exact head, inputs, all five oracles, tools and all
  seventy private compiler resources before execution.
- JS, C and native artifacts have before-consumption hashes checked again after
  execution. Full stdout files and raw outer logs are retained.
- `after.json` records terminal exit 0 and successful unconditional postguards.
  Source head, clean worktree, input/tool hashes and all seventy resources match.

The tool cohort is private Bend 2.0.35, compiler SHA256
`f77417474ded314ad5d1a68fa3ebbe214c2124bf04d56a59b05bc17be6b0327a`,
with its matching verified seventy resources; Node 24.20.0 at
`/home/node/.local/share/mise/installs/node/24.20.0/bin/node`; and the existing
private Clang 19 wrapper/root at `/tmp/bendvy-clang19-diagnostic/`.
CPU affinity was 0-3. Existing limits remained 30 seconds for emission/Node,
120 seconds for native compilation at -O3, and 5 seconds per native execution,
with GPU off. No timing result is a performance claim.

The actual WorldIO scheduled-health consumer also passed its existing independent
six-tick model on Node/native, using the separately retained historical
35-only adapter commit. That receipt is
`/tmp/gh84-first-complete-backends.json`; it is not the final portable-adapter
receipt. Earlier installed-cohort development captures, the aggregate C timeout,
and the initial reached two/three-argument host ABI error remain historical
observations rather than qualified successful native evidence.

## Next exact gates

The unexecuted normal wrapper is
[check.sh](../../examples/parallel-events/check.sh), SHA256
`dc08e87a5aac27352b3a890f3fd77324b9e694329f052b0b5bd69e82d19e913e`.
Its changed eleven-control/five-concrete-case contract needs final independent
launch review before first execution or publication. Round 1 approved only the
older exact eight-control wrapper and does not approve this delta.

The declared infrastructure CI installs Bend 2.0.37 and enables native examples.
Actual type inspection supports the portable two-argument registration branch,
but local qualified native observations execute the 2.0.35 three-argument branch.
The CI cohort's native branch remains unverified until actual CI. Do not claim
37/39 qualification from binary strings or from successful 35 execution.

Apply any coordinator-owned Scope/World journal migration mechanically and run
the affected source checks before final integrated normal CI. The implementation
constructs no State.Scope values; its trusted final World observer must retain
any newly appended fields required by the current constructor shape. Full GH84
completion also retains the blocked-by #80 and parent #77 evidence gates.
