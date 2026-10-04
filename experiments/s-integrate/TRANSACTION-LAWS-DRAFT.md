# Transaction subject obligations — preimplementation draft

No integrated subject is implemented here and no general proof is requested. Exact
shared interface freeze and executable falsification remain pending. This file
states the proposed observation subjects for discussion; successful historical
probes are not integrated acceptance.

## Trusted joins

Storage owns `with_main(W,H,Main -> Main & O) -> W & Access<O>` and
`with_ledger(W,Ledger -> Ledger & O) -> W & Maybe<O>` with Data O. It checks actual
handle namespace and membership before calling the fresh affine transform, then
immediately reinserts its actual returned Type owner. Missing/mismatch returns W
without invoking the transform. Ledger absence is preserved, not manufactured.
`transaction-contracts.bend` checks these abstract owner/result shapes and a
rank-2 client using fresh declared setters. ProbeAccess is local canary vocabulary;
final Access/result declarations belong to the shared-type owner.

Private Tx holds the actual world, private LIFO numeric inverse journal, staged
Type commands, Data messages/marks and selected-reader snapshot. Main setter
extracts slot0 through Array.get, retains the returned full owner, writes the new
slot0, immediately reinserts it and records `MainInverse{handle,old}` only on Found.
Ledger setter analogously records old slot0. An observation is never an inverse
owner. All four array cells and every schema metadata field remain in real owners.
Callback parameters expose read/set/stage/reserve only: no Tx constructor,
journal, restore, extraction or finish authority. A separate successful structural
barrier owns disposal; arbitrary destructive callback recovery is not claimed.

## Proposed exact observation equations and falsification cases

| ID | Subject/domain | Required observation; targeted compiling mutant |
|---|---|---|
| TX-MAIN | Real live b with Main V20, both schemas; setter30 then setter50, both return actual Tx | Between read=[30,21,22,23], after=[50,21,22,23]; frame7 or reserve9/class2 retained. Failure applies inverses50→30→20. FIFO inverse replay must fail final observation. |
| TX-LEDGER | Retained Ledger after earlier A commit101 | B writes201; failure restores[101,101,102,103],epoch4; omitted Ledger inverse must fail. |
| TX-EARLIER | A finishSuccess then B finishFailure | a=[11,11,12,13], prior Ping1 and A pending spawn/remove remain; rollback-to-pre-A snapshot must fail. |
| TX-STAGED | B accepts genuine Type spawn q, command, Ping9 and marks, then fails | No q publication/live payload, no failed Ping9/changed/removal/despawn marks. All staged owners dropped once. Commit-on-failure must fail; separate positive success transfers Type payload into pending, not immediate live. |
| TX-RESERVE | Actual reserve within B then fail; next actual reserve afterward | Escaped q missing; counter consumed and next handle differs. Counter rewind/reissue mutant must fail raw-ID observations. |
| TX-READER | Real registered B boundary, other Fast boundary; failure then sameinstance retry | B's observable retained messages/lifecycle tuple and lag repeat, Fast preserved; failed reader advancement must fail. Reader module owns exact boundary implementation. |
| TX-CAPTURE | Actual separately owned B capture in returned Invocation | Count survives failure and retry; ECS undo must not rewind capture or Audit external effects. Dispatcher owns this evidence. |
| TX-MISSING | Foreign/dead/mismatch actual handles; missing Ledger | Never invoke transform; preserve world and any rejected Type payload. Wrong-target mutation must fail full unchanged observations. |

All equations concern actual operations over generated valid worlds and real
handles, not caller-supplied success flags. Full E2/E3/E4 checkpoints compare both
schemas, all fields, pending visibility and raw reservations against fresh TS,
Native and JS execution. Positive controls accompany every negative, including
successful setter/staging/retry and missing-access owner retention. Each checker
invocation remains <=5 seconds. No proposed equation has been falsified against
an integrated implementation yet; implementations and mutable decision-path
mutants begin only after coordinator freeze. Approval of exact general laws remains
separate. No allocator reuse/exhaustion, production layout, arbitrary Type fan-out
or global factory authority policy is introduced.

## Signature probe evidence

Before integrated bodies, installed `bend version` reported2.0.34 and `bend guide`
was read. `timeout --kill-after=1s 5s bend transaction-contracts.bend --check-only`
passed in an isolated temporary directory containing an exact copy of the shared
vocabulary candidate (subsequently committed061cb2e), SHA256
`4dcaa0998c00f4a02e6a971ba5b95a98e7e0e6f13c5bc2a816bd68383a328eda`.
The source file imports `./types.bend`; reproduce after integrating that committed
shared file, or copy both files into one temporary directory. This checks signatures
only: no kernel/ECS proof, numeric journal algorithm or integrated behavior is
claimed. Fresh historical t06/read-control and s-capture/read-control checker probes
also passed within5seconds, solely as prior rank-2 signature evidence.

Executable draft `transaction-predicates.bend` returns True{} for both schemas'
valid full-field E3 observations and rejection controls for wrong reverse undo,
untouched array tail corruption, wrong Ledger rollback, failed publication leak,
reservation reissue and erased earlier A write. Main/Aux/Ledger arrays and metadata
are all checked. These are planted validator inputs, NOT actual runtime outputs
or integrated falsification. Ping/pending/mark fields are provisional summaries;
full command identities/owners and actual public reader traces remain fresh runtime
gates. Failed namespace/access/reader behavior is not represented by these inputs.

Planned actual operation subjects are `tx_begin`, `tx_read_main`, `tx_set_main0`,
`tx_read_ledger`, `tx_set_ledger0`, `tx_stage_command`, `tx_stage_ping`,
`tx_reserve`, `tx_finish_success` and `tx_finish_failure`; shared freeze will bind
these names to the real store hooks, private retained actual handle and publication
records. Fixture IDs5/6 validate comparison only; actual runtime must obtain
handles through reservation and report raw consumed IDs. Reproduce like the
signature probe by copying the committed shared types and this file into one
temporary directory; `timeout --kill-after=1s 5s bend transaction-predicates.bend`
printed True{} under installed2.0.34. No law was proved.
