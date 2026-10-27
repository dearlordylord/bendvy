> Verification policy override (2026-10-27): semantic verification uses Bend laws only. The new non-law models, reference tests, golden outputs and check scripts have been retired at the user's direction. References below to those checks describe historical work, not current acceptance. Historical receipts remain outside the source tree; the five approved Bend helper laws do not prove the whole ECS.

# Captured execution owners

`execution-capture` binds closed callback code to an actual affine context. Each
invocation consumes that context and retains the context returned by the callback.
The code is a closed template. No affine function or context is copied to make
repeated calls possible. `Local<State,Capture>` keeps independent Local and capture
owners in the same system-owned state.

The development `capture-owner.bend` consumer invokes two unlike callbacks twice.
One callback owns an Array of identity and count. The other owns separate identity
and String Arrays. The expected output follows from `0 + 2 + 3` and `a + x + y`.
It demonstrates actual retained nested owners, not the full ordinary schedule.

From the repository root, use the existing shared execution commands.

```bash
export BEND=/tmp/bendvy21-bend2035-lifecycle-pin/bin/bend-2.0.35
source examples/common.sh
example_emit examples/parallel-captures/capture-owner.bend /tmp/capture-owner.js
example_node /tmp/capture-owner.js > /tmp/capture-owner.stdout
cmp examples/parallel-captures/capture-owner.expected.stdout /tmp/capture-owner.stdout
```

`execution-system-lifecycle` retires only an exact namespace, ID, name and access
registration. It returns the detached actual System owner. Restoration validates
that namespace, the previously allocated ID, absence of an ID collision, and the
access derived from its closed declaration Program. It retains the original ID,
cursor and Local and does not allocate another ID. Release returns the actual
Local owner with detached identity observations. It does not run an IO finalizer.

`lifecycle.bend` runs an actual ordinary system twice. Its body returns an error
on the second invocation after advancing both affine arrays to four. Retirement
removes its registration. A subsequent ordinary run refuses without invoking the
callback. Restoration into a second World, created using the actual advanced
Factory returned by the first creation, refuses. Restoration into the original
World keeps namespace 1, ID 1, name `captured`, and cursor `0:2`; the next execution
advances the cursor to `0:3` and both retained arrays to six. Final retirement and
release return the actual Local and capture owners. An attempted restore while
the original registration is still present also refuses. The final World has zero
registrations and retains `nextSystemId = 2`.

The expected output is derived from three actual invocations adding two, with no
invocation on either registration refusal. The fixture observes the retained Local
identity 101 and capture identity 201 separately. JS, native one-worker and native
four-worker stdout match the complete expected line. These checks use the existing
`examples/common.sh` emitter and qualified 2.0.35 lifecycle bundle; they do not
establish native worker use. Source checks use the repository's pinned checker.

```bash
example_emit examples/parallel-captures/lifecycle.bend /tmp/capture-lifecycle.js
example_node /tmp/capture-lifecycle.js > /tmp/capture-lifecycle.stdout
cmp examples/parallel-captures/lifecycle.expected.stdout /tmp/capture-lifecycle.stdout
```

These modules are provisional. The ordinary parallel captured-system and condition
concurrency evidence, applicable laws, normal CI execution and independent review
remain required for issue 83. The lifecycle consumer
checks the source closure at this branch's integration baseline plus the two owned
capture/lifecycle modules; it does not qualify later scheduler or composer changes.
`main.bend` and `check.sh` now provide the normal CI entry. The new wrapper awaits
independent launch review before execution.

## Ordinary RootSchedule consumers

`scheduled.bend` registers two left systems sharing the same Counter resource and
one right system using an independent Score resource. Closed Builder declarations
supply both grants and conflict metadata. The RootSchedule partitions the actual
World. It serializes the two Counter writers and may execute the independent Score
writer alongside a Counter writer. Both serial and native entries run three times
under two nominal schemas. No custom World dispatcher is provided.

Each left Local owns a mutable identity/count Array and a separate captured
identity/count Array. The right Local owns its own mutable Array and a capture
context containing separate identity and String Arrays. The closed body template
invokes each actual capture owner and retains the returned owner. Local identities
are 501, 601 and 801. Capture identities are 201, 202 and 203.

The full expected observations were written before backend capture. For each of
three runs, both Counter writers add ten and the Score writer adds three. Each
left capture adds two, while each right capture appends `x` to `a`. Thus the final
resources are 60 and 9, left captures are six, and the right capture is `axxx`.
Both left bodies return an ordinary error on their second run after their writes
and capture updates. The handler continues and records two errors. Admission order
assigns final cursors 7, 8 and 9 to left, right and other. Three registrations leave
`nextSystemId = 4`. There are no entity operations, events or deferred commands.
The complete oracle includes allocator state, resource identities and canonical
cached views, registrations, namespace, clock, cursors, Local and capture owners.

`guarded.bend` uses the same systems with a captured condition bound to the right
system. Dependency edges from both Counter writers to the right system ensure the
condition observes values 20, 40 and 60. Its own Local Array identity is 901. Its
capture owns counter Array identity 902 and a String Array retaining the observed
value. Calls return false, an ordinary error, then true. Each call first advances
both its Local and capture state. Consequently the Score writer runs once, its
capture becomes `ax`, both left captures reach six, and the condition retains
`901:3/902:3/seen=301:60`. The handler records three errors, including the two left
body errors. At the three-run prefix, cursors are left 7, other 8, guard 9 and right 10, with
clock 10 and `nextSystemId = 5`.

Both complete four-line oracles pass on JavaScript using Node 24.20 and native
execution with one and four configured workers. Native output contains calls to
the ordinary `run_native` entry. Configured workers and matching output do not
establish participation by multiple native workers. The source-current generic
column observation helper is reused for complete administrative observations.

The guarded consumer then retires the actual right owner returned by the schedule,
rebuilds the same application from returned World and owners, and runs again.
The right system refuses admission. Its Local stays at one, its capture stays
`ax`, and its cursor stays ten. Both Counter writers and the condition continue
from their actual owners. Restoration reuses the same right ID and cursor without
allocating another ID. Immediate observations after retirement and restoration
both retain `1:2:right:[score]:0:10`, before a subsequent execution can update the
cursor. A fifth schedule run advances the right Local to two and
its capture to `axx`. Counter reaches 100, Score reaches six, and the condition
retains its fifth observation `301:100`. Cursors become 14, 17, 15 and 16 for left,
right, other and guard. Final retirement removes right registration 2, and explicit
release returns its actual Local and identity `1:2:right:[score]` for observation.
The World still has `nextSystemId = 5`. No IO finalizer is run or claimed.

The five-run oracle was written before backend capture. Exact source checks and
intended refusal diagnostics pass. Its backend comparison and the normal wrapper
are pending the coordinated execution window and launch review. The earlier
three-run guarded and independent consumers passed all three backends before this
lifecycle extension. `main.bend` selects ordinary native RootSchedule entries for
both consumers under both nominal schemas and compares one complete four-line
observation. Separate lifecycle checks retain genuine foreign-World provenance
from the actual advanced Factory.

The negative controls reject duplicate capture and Local owners, a system owner
from another nominal schema, escape from abstract scope, a Score operation through
a Counter capability, and writes through a shared resource read. The resource
payloads and captured contexts contain actual affine Arrays. These are intended
affinity and authority errors, not parser or missing-symbol failures.

Report observations retain every scheduler event. They use the pinned Base stable
sort by numeric system ID, preserving duplicate events and unknown IDs. Every
event variant renders all its fields. Stopped reports retain their error, and
invalid plans render the reason variant and its fields. `report-probe.bend` checks
duplicate ID 1, unknown IDs, every event variant, stopped error and every invalid
plan reason against an independently written expected observation. The normal
main entry checks this pure probe before running the real systems. Successful
probe validation adds no line to the ordinary output. Its complete four-line
oracle remains unchanged.
