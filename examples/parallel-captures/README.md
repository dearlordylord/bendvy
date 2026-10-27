# Captured execution owners

`execution-capture` binds closed callback code to an actual affine context. Each
invocation consumes that context and retains the context returned by the callback.
`Capture.Local<State,Capture>` keeps the Local and capture owners together. Neither
owner is copied to make repeated calls possible.

## Retained nodes and lifecycle

[guarded.bend](guarded.bend) is the current retained-node consumer.
[guarded-nodes.bend](guarded-nodes.bend) supplies its typed declarations and bodies.
The application retains two Counter writers, a Score writer, and a captured
condition for the Score writer. Counter writers conflict with each other. The
condition runs after both writers and sees their actual Counter value.

The resource-query bodies use `Sys.Body` with the abstract `Permit` and scope `H`.
Their `ResourceAccess.Writer<H,Payload,V>` capabilities return actual scope owners
and explicit edit results. Unsupported or unchanged edits return `BodyError` with
the actual Local, capture, and scope. Capture updates made before an error remain
owned by the returned node.

`execution-resource-query-lifecycle` provides the retained-node lifecycle API:

- `retire` removes an exact registration and returns the actual detached node.
  Refusal returns the original World and node.
- `release` returns a typed `Released` capsule with the actual compilation,
  admission evidence, prepared permits or inventory, identity, and Local.
- `rebuild` reconstructs that node from the returned capsule and Local.
- `reregister` checks namespace, allocated ID, absence of a registration collision,
  access, and support using the retained compilation. It preserves the original
  identity and cursor. Refusal returns the actual World and capsule.

Successful re-registration consumes the old admission cache through
`registered_binding` and returns an `Uninspected` node. The next ordinary schedule
inspection validates that node against the current World. Re-registration does
not make old admission evidence valid forever, recompile the declaration, or
allocate a new system ID. Final release returns the actual Local and identity.
There is no IO finalizer.

The capsule covers all four retained-node states: `Uninspected`, `Inspected`,
prepared ready, and prepared inventory. It preserves their actual owners through
detachment and refused re-registration.

## Serial and default execution

`Group.run_retained` keeps the default `Task.Parallel` policy.
`Group.run_retained_with_policy` accepts an explicit policy, and
`Group.run_retained_serial` selects `Task.Serial`.

Serial policy applies to the whole Task invocation, including nested composite
and body forks. The existing interpreter lowers each encountered `TFork` to the
existing left-then-right `TBind` sequence before advancing or servicing branches.
The Frame retains the policy on every interpreter round. The default Parallel
branch retains the existing fork behavior and safety classification.

The guarded entry prints `A-serial`, `A-native`, `B-serial`, and `B-native` for two
nominal schemas. Here `native` selects the default policy. The label alone does
not establish that multiple native workers participated.

## Independent scheduled execution

[scheduled.bend](scheduled.bend) retains one World across three public Schedule
runs per phase. Its main selects serial and default Parallel policies for each
of two nominal schemas.
Both component stores are `Unit`, so this consumer exercises resource ownership.
The left and other systems both write Counter and must execute sequentially.
The independent right system writes Score. Schedule splits and reassembles the
actual World inside the library; the application does not manually split it.

Each resource and Local owns an actual Array, and each system retains its capture.
After three runs, Counter retains token 301 with value 60, and Score retains token
401 with value 9.
Both Counter writers return `BodyError` on run two after their writes and capture
updates. The handler retains two errors, and the third public run reuses the
returned World, Local, and capture owners.

`execution-parallel-rootcut.trusted_execute` wraps each actual invocation in
`TRun` before `paired_tasks` constructs the fork. This defers body work until the
interpreter services that branch. Evaluating the fork's arguments must not run
the body before the fork exists.

The complete four-line output is 2,304 bytes. An expectation derived from source
before reading the outputs matched JavaScript and Bend 2.0.37 native execution
with both one and two workers. Temporary derivation and comparison helpers were
deleted after use.

Symbol breakpoints on the unmodified two-worker native binary observed Counter
operations on the main OS worker and Score operations on a second OS worker
within each single-World native phase. All observed operations in serial phases
ran on the main worker. This establishes worker participation for this consumer.
It does not establish temporal overlap, speedup, or universal worker placement.
The observation does not cover native component storage, and it measures neither
memory management nor heap allocation.

## Run the guarded consumer

From the repository root, emit and run the existing entry directly with Bend
2.0.35 and Node:

```bash
	BEND=/tmp/bendvy21-bend2035-lifecycle-pin/bin/bend-2.0.35
	"$BEND" examples/parallel-captures/guarded.bend -o /tmp/captures-guarded.js
	node /tmp/captures-guarded.js
```

To preserve the generated C and run the ordinary native product:

```bash
	"$BEND" examples/parallel-captures/guarded.bend -o /tmp/captures-guarded.c
	clang -std=c11 -O3 /tmp/captures-guarded.c -lpthread -lm -o /tmp/captures-guarded
	/tmp/captures-guarded --threads 2 --gpu off
```

Each of the four output lines includes five schedule runs. The first condition
call disables the Score writer. The second returns a condition error after
updating its capture. Both Counter bodies also return errors on their second run,
after their writes and capture updates. The third run executes the Score writer.

The application then retires that actual Score node and runs again. Admission
refuses the unregistered node without invoking its body. Re-registration preserves
`1:2:right:[score]:0:10`. The fifth run executes the restored node. Final release
returns its Local and capture owners. The observation includes the World,
registrations, clock, resources and cached views, cursors, handler, allocator,
events, deferred state, and every Local and capture owner.

At the end, Counter is 100 and Score is 6. Both Counter captures are 10, the Score
capture is `axx`, and the captured condition retains `301:100`. Final cursors are
14, 17, 15, and 16 for left, right, other, and condition. The World retains
`nextSystemId = 5`, and final retirement removes right registration 2.

On 2026-10-27, source `b5161af4d912217e85fee535c9ddae073f494539` emitted and ran
through the unchanged qualified 2.0.35 JS and native paths. Their complete four-line
outputs matched at 3440 bytes. This is a finite observation of this consumer.
It is not a proof of the whole ECS or evidence of worker participation. Semantic
verification uses the five approved Bend helper laws within their stated limits.

## Other existing consumers and historical evidence

[capture-owner.bend](capture-owner.bend) invokes two unlike captured callbacks twice.
One owns an identity/count Array. The other owns identity and String Arrays. This
small consumer demonstrates retained nested owners independently of scheduling.

[lifecycle.bend](lifecycle.bend) contains the earlier raw `Sys.Owner` lifecycle
consumer. Its historical observations include refusal in a second World and
preservation of the original identity, cursor, Local, and capture. That raw-owner
path does not establish retained-node cache preservation.

[main.bend](main.bend) imports the scheduled consumer as `Independent`. The
aggregate sequences Independent A/B followed by Guarded A/B before printing,
each selecting its native Task policy. At historical source `5ef841663`, the
aggregate compiled and ran with the pinned 2.0.35 JS and native routes. Its four
complete output lines matched at 2,884 bytes. That historical receipt includes
the retained captured-condition path and establishes no multiple-worker claim.

Golden files and `check.sh` were retired on 2026-10-27 at the user's direction.
Historical comparisons against those files are not current acceptance steps.
`report-probe.bend` remains source imported by the aggregate entry, but it is not
part of the direct guarded execution receipt. No probe result establishes the
retained-node lifecycle or Task policy behavior.

## Existing authority controls

The files in [controls](controls) contain intended affinity and authority refusals.
`duplicate-capture.bend` and `duplicate-local.bend` use the actual affine context
and Local types. Other controls still refer to the earlier scheduled-owner,
concrete-scope, or `execution-access` capability API. They require migration to the
current retained-node and resource-access boundary before their diagnostics can
qualify that boundary. No current diagnostic result is claimed for those controls.
