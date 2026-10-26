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
consumer, condition false/error observations, declared resource conflicts, full
scheduled backend oracle, concurrency evidence, migration, applicable laws, normal
CI and independent review remain required for issue 83. The lifecycle consumer
checks the source closure at this branch's integration baseline plus the two owned
capture/lifecycle modules; it does not qualify later scheduler or composer changes.
This directory does not yet add a runnable `main.bend` to normal CI while those
ordinary-entry gates are unfinished.
