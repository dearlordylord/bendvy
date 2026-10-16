Source frozen at producer `05da8ceac`, prerequisite family `17f799e64`. Entry SHA256 `4e7043c87d298f6dc1e2a9224b50b6220476823d79f19f5d6960523261bcd82a`; SOURCE-FREEZE SHA256 `67b89b96143dbe04fd49dfcc9d6aa26b282ec5d5a938dcd6f573d067e9159fbc`. All44 Bend bodies, both namespace sidecars, the freeze and Base/print effects are directly checked (50 pins). Full stdout is13523 bytes SHA256 `43df3c5af10742128190fd7730583df2a43ba706d03912b1f7bb46f3fa6ad46f`.

The final grant-builder repair changes representation only: builder is an erased Declaration type index, specialized at the complete Recovery owner before executable grants are created; pair_grant composes the same left/right recovery paths, declaration access remains[Payload, Flags], and the same actual inverse/journal/body/call-chain operations produce this model. Pure scenario sourcecheck passes; main retains only six foreign-dependent definitions, not a mathematical safety proof.

Independent finite source-only model for the ordinary heterogeneous recovery consumer. No backend or generated output is an input. Final source pins are embedded in oracle.py; --write reproduces raw oracle.txt and deterministic oracle.txt.gz, while ordinary invocation verifies sources, both complete encodings and substantive state/owner invariants.

Two nominal schemas each create two actual Worlds through WI.create. Every World allocates/activates two actual handles, populates handle1 with Payload:Array<Array<U32>> and Flags:Array<U32>, and leaves handle2 live but both components absent. Primary starts Payload10..13 at1:1, Flags15..16 at2:2, clock2, capture1000..1003. Foreign starts900..903/905..906, capture9000..9003, same registry ID1/name/access but different namespace. Access is derived in declaration order [Payload, Flags]; capture contributes no World access key.

One actual shared journal processes six interleaved operations: Payload first; Flags first; capture replacement; Payload second; Flags second; capture element1 exchange. Journal actions execute newest first across all three owner types. Each typed recovery sink prepends its returned records, so its full rows retain that family's original operation order. The Python model uses a single tagged action sequence, independently tracking optional payloads/stamps, nested owner values, capture, World clock and registry cursor.

A callback performs four accepted component writes, advancing the shared World clock four times. Capture operations do not advance it. Failure restores both columns' exact pre-call optional values/stamps and opt-in capture while retaining the advanced World clock. Returned component records preserve the actual displaced value's pre-undo stamp. Success returns original/displaced owners and commits the registry cursor to the final clock. Assertions check every failure's full replacement values/stamps and capture replacements, not just final World equality.

| Completed phase | Clock | Cursor | Payload1 | Flags1 |
| --- | --- | --- | --- | --- |
| registered |2|0|10..13 @1:1|15..16 @2:2|
| commit100 |6|6|120..123 @1:5|130..131 @2:6|
| failed200 |10|6|120..123 @1:5|130..131 @2:6|
| retry-failed300 |14|6|120..123 @1:5|130..131 @2:6|
| retry-success400 |18|18|420..423 @1:17|430..431 @2:18|
| absent-failed600 |22|18|420..423 @1:17|430..431 @2:18|

Final capture is ((440,441),(450,451)). Absent-failed writes handle2 Payload at19:19 then19:21 and Flags at20:20 then20:22; rollback restores both None @0:0 and returns each replaced nested owner with those exact stamps. The foreign-world500 attempt validates the actual registry against the foreign World before body entry: all Args are returned intact, with no clock, stamp, capture or registry mutation. Foreign World remains clock2/cursor0 throughout. Both normal schemas execute the same reached call chain, using namespaces1/2 then3/4.

The full observer covers both columns' complete authored slots0..3, full live tree, allocator/namespace/high-water/capacity/depth, Unit resource, zero events/pending, full registration/nextSystem metadata, both actual owner cursors/captures, every argument, full Output and every typed recovery row. Events are empty throughout this actual trace; their observed count does not claim arbitrary event-payload coverage. Imported older fixture/observer modules supply helpers only, not extra consumer execution.

Formatting derives from observe.bend and the existing resource observer's tree/items/List.show helpers: all array nodes/leaves, Maybe, errors, stamps, labels and list terminators remain. Main sequences Workshop then Garden through IO.bind and calls IO.print once; both traces already endLF and print appends one furtherLF. This is a finite heterogeneous component/capture qualification, not full #52 acceptance, universal proof, arbitrary caller inverse support, external IO undo, physical finalizers or performance evidence. Source checker foreign IO exceptions remain separate from runtime qualification.
