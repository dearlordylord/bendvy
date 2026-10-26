# Lifecycle notices in World administration

The coordinator selected candidate B after comparing
`execution-lifecycle-notice-candidate.md` and the independent separate-owner
candidate. The cross-judgment is retained at
`/tmp/bendvy-gh85-notice-design-judge.md`. This document records the selected
implementation contract. It does not assert that the implementation or evidence
is complete.

World owns a separate affine `Notice.Journal<S>`. Its user `events:List<E>` field
and event APIs keep their meaning. The journal contains per-channel sequence
numbers, previous/current maintenance generations, dropped-through floors and
active reader registrations. Scope carries only a reusable detached view;
Administration retains the actual journal. Reassembly ignores the returned view
and takes the authoritative journal exclusively from Administration.

The World constructor appends `lifecycle` after `clock`. Administration appends
the journal; Scope appends its view after `prior`. Root splits and query adapters
preserve the immutable view while moving actual component/resource owners.
A newly separated group captures a new snapshot after any preceding publication
barrier. Readers share snapshots; they never share one affine reader token.

Closed removed/despawned builder primitives derive capability, canonical stream
identity and SharedView/ReadOnly LifecycleAccess metadata together. Removal
capabilities and tokens carry the full nominal selected Layout origin and schema.
LifecycleAccess is a built-in snapshot access, not a physical component/resource
requirement or a caller-authored catalog entry. It remains in planner access uses
while physical schema requirements omit it. Reader registration and retirement
remain administrative operations on the actual World, outside running scopes.

Publication occurs inside the existing automatic command interpreter. A remove
of an actually present owner emits one family notice; a missing remove, refused
operation or insert/replacement emits none. Successful despawn emits one removal
notice for each actually present family and one despawn notice for the old full
entity identity. The actual arbitrary Type owners remain in their existing
structural receipts. Presence extraction never invokes a refresher or discards
an owner to inspect it. Full namespace and allocator generation admission remain
before mutation. Stale repeated despawn therefore emits no duplicate notice.
The identity DTO carries nominal S, actual namespace and complete entity-key;
it imports entity-key rather than World and provides no live-handle constructor.

Each channel starts at next sequence 1 and dropped-through floor 0. Reader
Retained starts at the floor; Future starts at next-1. Dropping a nonempty previous
generation advances the floor to its final sequence. A valid read reports
max(floor-cursor,0), clamps the cursor once, then yields the next retained row if
present. Both Item and Empty return the clamped token; refusal returns the actual
unchanged token. Unrelated families cannot increase a reader's missed count.
Every yield updates the returned token immediately, so a subsequent body or
condition error retains consumed progress in that owner's actual Local.
Registration IDs never reuse retired values and refuse exhaustion before mutation.
Namespace, active ID and selector are checked before retirement mutates the journal.

Maintenance runs exactly once after a Finished ordinary public App update, after
its selected final-deferred policy, including errors handled with Continue.
Invalid, Stopped and genuine exceptional exits do not pretend to complete an
update and do not rotate. An empty Finished update still rotates. A Finished
update with final application suppressed can rotate retained notices but never
publishes or flushes its pending commands. Bare system, group and Scope helpers
never perform maintenance themselves.

This placement follows pinned Bevy ad678262 `bevy_app/src/sub_app.rs` update then
clear_trackers, `bevy_ecs/src/world/mod.rs` clear_trackers updating removed
components, and `bevy_ecs/src/lifecycle.rs` per-component message maintenance.
Previous/current generations bound retention in completed updates, not item
count, memory bytes, channel count or active-reader count. No hard item limit is
introduced or claimed.

The journal change must migrate every actual World constructor, Administration,
command Remainder, Scope adapter and root split/join. Runtime journal/readers are
not silently added to detached serialization; GH91 owns that contract. Existing
user events and raw trusted provisioning remain explicit boundaries. Required
ordinary evidence includes unlike schemas/families, actual owner receipts,
fast/slow readers and lag, per-yield errors, conditions, refusal, retirement,
foreign/stale handles, generation reuse, deferred visibility/suppression,
invalid preservation, both parallel paths and JS/native execution. No new law or
universal runtime preservation theorem is asserted by this design.
