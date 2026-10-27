# Retained command application

[generalized-root.bend](generalized-root.bend) runs one retained command author
beside a resource-query peer through the generalized Root. The author owns a
heterogeneous spawn bundle containing an affine Array with value `901`.

The application keeps its original schema-created Context in a Bound value.
It first attempts an update with the Context of a second, genuinely created
World of the same nominal schema. Root refuses before execution. The returned
application still has an empty queue, an unrun author, and clock `0:0`.
The program then deliberately restores its original Context to that same
returned application.

The first admitted update authors Spawn21 and returns a body error. Its error
handler escalates. The Stopped result retains the actual queued bundle and
author cursor `0:3`; it does not apply the command. The next update enables
final application and produces a Spawned21 receipt. The final update exercises
a condition error while the peer still runs. Terminal observation reads the
actual spawned Array and its cached view, both `901`, and the peer's retained
capture `200`. Intermediate command snapshots preserve each node's inspected
or prepared state, evidence, permits and provenance.

Run the ordinary application with Bend's JavaScript output:

```sh
bend examples/parallel-commands/generalized-root.bend -o /tmp/bendvy-commands.js
node /tmp/bendvy-commands.js
```

This is a finite application observation. It does not prove generic affine
preservation, native concurrency, or all exceptional exits. The default bound
entry uses lifecycle maintenance only. Framework callers that also maintain
protected relation streams can supply their closed whole-update callback to
`Root.run_bound_with_completion`; the same context preflight precedes it.
