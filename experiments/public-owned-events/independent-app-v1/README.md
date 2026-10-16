# Independent ordinary cargo manifest application

This is one independently authored finite public consumer for #53. It is not a
proof or feature acceptance receipt. The coordinator owns backend execution and
an independent author owns the whole-output oracle.

Entry: `main.bend`. It creates a real IO-namespaced world through `WI.create`,
with Unit component store, a four-slot owned sentinel resource, one schema-owned
manifest log, and the ordinary publisher and two declared reader systems.
Gameplay receives opaque publisher/read grants. Only the trusted administrative
observer sees concrete World and runtime constructors; it threads all owners
back unchanged.

The frozen sequence is written directly in `app.scenario`: created; commit A;
abort B and inspect/discard recovered owner; fast reader failure; fast retry;
frame; commit C; fast C; slow first read; frame; frame; commit D; shutdown drain.
There are thirteen full state snapshots. Publication and reader completions and
retirement receipts appear between the relevant snapshots. Capacity is eight.
Readers use the approved existing cursor/retention rules. No new rule is claimed.

`model.bend` defines four-slot affine manifest Arrays and a Unit request returning
all payload values as detached Data. Reader Args are affine and retain an owned
scratch Array whose first slot becomes the latest observed manifest code. All
attempted projections are preserved in each reader's Data history, including the
failed attempt; returned private Args are distinct from ECS cursor rollback.
Retry explicitly clears only the application's failure flag.

`observe.bend` preserves the complete physical Array tree, payload rows and log
counter; all World scalar fields, live bits, resource sentinel, Data publications,
registration metadata and pending-command count; and all runtime metadata,
batches and reader positions. `app.snapshot` additionally preserves both affine
reader handles, all publisher/reader registry fields, and complete actual reader
Args. The Unit store/output/error values have no further content. Opaque command
closures are threaded and counted; this consumer stages no commands.

Source-only checks use the current master `scripts/bend-check` five-second
wrapper. `check-app-05.txt` passes the complete pure app and dependencies.
`check-main-01.txt` has no syntax, type or affine diagnostic; it reports only the
expected foreign trust chain `world-namespace.fresh`, `world-io.create`, and
`main`. This is recorded as a foreign-boundary checker rejection, not a passing
proof. No backend compilation or execution has occurred in this worktree.
Earlier failed source diagnostics are retained unchanged. No output oracle or
expected whole-output text has been authored here.

`source-manifest.json` freezes every transitive Bend source used by the entry.
The five untracked owned-event dependency files are copied from the source
owner's checked overlay without inspecting their bodies. They are not owned or
committed by this application author. Integrate against matching hashes.
`AUTHORSHIP.md` records the actual author, public guidance and documentary reuse.
