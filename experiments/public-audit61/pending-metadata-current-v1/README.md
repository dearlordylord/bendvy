Independent complete AppA/AppB oracle successors for the actual pending-metadata #38 core change. This prefix contains no Bend consumer or core edits. It does not add a scenario, runner, contract or normalization.

The actual root entrypoints are unchanged:

- AppA `app-a-owned-handoff-v1/host.bend`: existing `IO.print(App.main())`, preserving the complete application string and terminal LF. The pure `main.bend` is not substituted for this qualified IO entry.
- AppB `app-b-current-v1/main.bend`: existing complete Report printer.

Each source freeze traverses literal imports from that actual entrypoint and pins installed Base, compiler, wrapper, taskset and model Python. Source checks run serially with the existing CPU5/default-five-second root wrapper; both pass. The root's four working core bodies are recorded by WORKING-CORE.json as uncommitted working source, not misattributed to tracked HEAD. Each reached application closure changes only world.bend and commands.bend; its other134/72 bodies match the previous current-source qualifier exactly.

| Subject | Closure / source pins | Full expected bytes | SHA256 |
| --- | --- | ---: | --- |
| AppA | 136 /205, plus4 tool pins | 47,464 | `230f07debdee0346c78b8619daa60d51ea437164858b7eaebd35878d3ad3498a` |
| AppB | 74 /143, plus4 tool pins | 13,475 | `925a17abe588fa504bec21cb44895fd298c032ae21f0897c1129cd85bbfd3a3f` |

These expectations are derived before runtime execution from retained independently authored models. Original models and expected outputs remain losslessly retained. Both historical model reproductions pass before deriving the successors; model.diff records every change. verify.py performs only offline source/hash/model/gzip/state checks and never reads a backend output.

World.create starts with the legacy single false leaf. Actual Cmd.tx_spawn marks a lazily allocated pending plane, while reserving/growing preserves both planes. AppA's committed pre-flush snapshot has visible[False,False]/pending[False,True]; its activation leaves visible[False,True]/pending[False,False]. AppB has capacity4, pending IDs1–3 before flush and three visible IDs after activation; the entire physical8-leaf Array remains observed afterward. All original World/resource/graph/clock/cursor/owner/notice/schedule observations remain in the full output.

Cmd.track_pending adds real transaction inverses, committed and dropped by these successful batches. The observed retained bundle-install receipt counts remain1 for AppA and3 for AppB; they are not the transaction undo list. No additional claim to observe that unprinted transaction list is made.

AppA adds only physical pending-plane output. AppB additionally derives literal constructor QNames from its actual root entry directory (rather than the previous /tmp entry); all strings remain intact. The smaller AppB byte count reflects those source-derived shorter names, not stripping or normalization. No runtime output or old captured actual output was used to calculate either expectation.

Full stock JS/Native qualification is root-owned and pending. These remain finite independent applications; wider #38 identity choices, #54/#57/#59/#60 and full #61 acceptance retain their existing scope.
