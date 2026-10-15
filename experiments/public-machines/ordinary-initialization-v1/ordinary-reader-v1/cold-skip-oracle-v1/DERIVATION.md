Independent source-only cold first-use skip oracle, producer15eb2dab8. All38
literal Bend imports were independently traversed and compared to the producer
COLD-SKIP-SOURCE.json before immutable copying. C/JS namespace allocator bodies,
Base, both print effects and pinned Bevy message_cursor.rs are separately pinned.
No candidate runtime/generated output was consulted; no backend was run.

Bevy MessageCursor::default (message_cursor.rs59-65) starts last_message_count at
0, so a reader that has never read is not moved forward merely by existing or
not running. Bend public Reader.skip returns the actual reader and World
unchanged. St.open observes a missing position with cursor0 and then activates
that reader at cursor0; its registeredAt field affects loss reporting, not the
value cutoff. Therefore the still-retained Initial A publication is read exactly
once after cold skip. No new contract or core change is needed. This finite
fixture contains no frame/expiry/clear and makes no arbitrary retention claim.

The actual scenario is registered-before-open, cold-skip-before-first-open,
first-read-after-cold-skip, first-repeat, accepted first disposal, swap to the
independent survivor, survivor read, accepted survivor disposal, final World
images. Seven checkpoints plus final images execute for each nominal schema.
The existing full physical World/registry/owner serializers are reused exactly;
model state/render reuse comes from the source-derived initialization oracle.

Each schema makes two sequential real WI.create calls; main sequences SchemaA
before SchemaB then prints both strings once. Thus fresh host namespaces are1/2
and3/4, from the pinned shared atomic/global allocator. Both initialized Worlds
have clock1, InitialA at tick1, revision1/default-effects1. Local registrations
are first1 and survivor2; nextSystemId remains3 through disposal. Foreign Worlds
have no registrations/positions and nextSystemId1. There is no marker or callback
world mutation. Registered/cold-skip snapshots have no positions and both owner
cursors0. First success changes first cursor/position to1, repeat is empty. Local
disposal removes only first registry/position. Survivor still reads InitialA,
then its own disposal removes the final registry/position. Publication remains.

Strings are concatenated without checkpoint separators. Each scenario final
image ends in LF; IO.print appends a further LF after concatenation. Every raw
byte, complete arrays, metadata, payload and terminal LF is retained. Source
pins and substantive nonactivation/backlog/independence/disposal invariants pass.
This is a complete finite executable Data projection, not affine-owner cloning,
backend acceptance or a universal proof.
