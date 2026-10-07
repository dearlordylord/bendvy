# P-INSPECT event-read exception/retry observation

This narrow #54/#37 reference extension observes actual pinned TS behavior, not a Bend API, proof, policy or feature completion. Existing public-inspect sources/evidence remain unchanged. The new adapter uses actual Game.Inspector, Game.System, Runtime.inspect/tick and event capabilities, with separately bound Workshop and Garden schemas and three independently created runtimes per schema.

Final receipt `.artifacts/public-inspect-retry-1791386727905887501/receipt.json` SHA256 `c475bd67f43a3a85c86150fd1f0fd02e917cae2abed88da6b30bb1f4c6b259ac` records `TS_INSPECT_EVENT_RETRY_OBSERVED`: five commands, ten complete raw streams and60 public observations (30 per schema). Node24.20.0 directly imports the pinned TS .ts entrypoint. Every command has the same five-second cap and CPU5 semantic affinity; no timing is claimed. Direct central Runner/Inputs/CommandLogs pins and guards the actual adapter/runner, shared helper bytes, full33-file TS source closure, package/manifest inputs and Node/git/taskset executable bytes, with raw streams and environment digest. Actual guide/compiler work was not needed or executed for this Node-only extension.

HEAD checks match all three tracked refs: TS3040a3b2a3f28fa8554d856f9ccb6bf5433fa334; Bevyad678262ce53b5d142fe49ee5e08caff6f00ab60; Bend2a950fd683c0d76f09794078e6174fe98a1492876. Bevy/Bend are reference identity pins, not executed semantics credit here. No dependency was installed.

## Complete observed sequences

The retained runtime registers an actual event-reading system before publication. An inspector reads the complete11/12 event then throws Error `after-event-read` twice. Successful retry returns that same complete event; immediate successful repetition is empty. After publication21/22 it reads and throws again. Two empty schedules pass before successful retry: it still returns21/22 without lag, because the registered system retains both events. That system then reads complete11/12 followed by21/22 without lag, despite the host's failed and successful inspections. A subsequent successful inspector read is empty. Thus inspector failure does not commit its cursor; success affects its own cursor only; inspection does not consume the system's visibility.

The late-slot inspector-only runtime publishes31/32 before this inspector's first evaluation. It reads that event then throws Error `alone-after-read`. Two empty schedules discard it. Successful retry is empty with lagged=false, and immediate repetition remains empty/false. The loss is real; the lag result has a registration-floor premise, not a hidden retaining reader.

The early-slot inspector-only runtime first evaluates and throws Error `warm-after-read` before publication, then reads41/42 and throws after publication. Two empty schedules discard the event. Successful retry returns empty with lagged=true; immediate successful repetition is empty/false. This contrast shows inspector slots, even failed ones, do not register retaining readers, and that lag is bounded by registration time.

The callback records each complete event/lag pair before deliberately throwing. These host captures are outside ECS rollback; recording them does not advance a reader. No fabricated internal cursor integer is presented as a public observation. Identical logical results were observed in both schemas; full ordered callback/error/success/system records are retained, not only counts.

## Source interpretation and limits

Runtime.ts1695–1704 resets since/streamSince from the prior successful positions, invokes the inspector read, and updates lastRun/streamLastRun with world.advanceTick only after return. A thrown projection leaves those successful positions unchanged. Runtime.ts1367–1375 constructs the slot with registeredAt=world.currentTick even on a first evaluation that later throws, and slotOf(...,false) does not register retention. internal/streams.ts129–131 reports lag only when droppedThrough>max(since,registeredAt). The late-slot false-lag and early-slot true-lag cases are observed manifestations of those existing predicates, not a new policy decision.

Arrays are ordinary TS values detached for host observations; this does not establish affine Type ownership, universal refinement or an exception contract for future Bend projections. A Bend implementation must preserve actual World/component/resource/event owners and expose declared safe projections, including explicit returned-owner/failure semantics, without JS aliases or substitute system reader registrations. No new law or production API is authored here.

## Retained evidence

The initial44-observation successful discovery run `.artifacts/public-inspect-retry-1791386690192696757` SHA256 `4f6a739f344bb6d550b2e2d707fbfcec4d867c85af739700dad395da5e32f08a` remains historical; the final adapter adds the early-slot contrast. Its original consumed adapter bytes and outputs are preserved rather than claimed current.

`evidence/index.json` maps both exact receipts, all20 raw streams and actual consumed project/TS sources to50 content-addressed objects in `objects.tar.gz` (119008 bytes, SHA256 `2335f78b8aafa47138641d0d9cd0f827c4f24fe50899d4099ce0193d23ae2cfe`). Tool binaries remain recorded hash pins, not packaged. Archive round-trip and `python3 evidence/verify.py` pass. Each index maps raw file names to exact blobs, so full original JSON stdout is recoverable without formatting/normalization.

Independent review is requested; no review acceptance is presumed. #54's actual Bend implementation, current authority/access negatives, reached reader-consumption mutant, both-backend equivalence and applicable regression/performance gates remain open. This extension supplies only the previously missing throw-after-event-read retry reference observations.
