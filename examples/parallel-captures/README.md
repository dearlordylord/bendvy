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

These modules are provisional. The ordinary parallel captured-system and condition
consumer, error/skip/refusal/disposal observations, full backend oracle, concurrency
evidence, migration, applicable laws, normal CI and independent review remain
required for issue 83. This directory does not yet add a runnable `main.bend` to
normal CI while those ordinary-entry gates are unfinished.
