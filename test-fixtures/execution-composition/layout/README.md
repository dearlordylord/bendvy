> Verification policy override (2026-10-27): semantic verification uses Bend laws only. The new non-law models, reference tests, golden outputs and check scripts have been retired at the user's direction. References below to those checks describe historical work, not current acceptance. Historical receipts remain outside the source tree; the five approved Bend helper laws do not prove the whole ECS.

# Closed layout ownership probe

This focused probe allocates the component layout and mutates the right resource
through a library-interpreted route. Both resource payloads have the same affine
`Array<U32>` type. The right route derives the `secret` key from the same layout
that determines physical extraction. Its initial value 22 becomes 99; the left
`public` resource remains 11.

The layout owns its payload-type terms. Closed template layouts may be interpreted
again without duplicating an application payload. Actual leaf owners include the
layout key in their type. `wrong-key.bend` attempts to transport a public slot to
a same-payload secret slot through the equality boundary. It must be rejected for
the differing `ResourceSlot` keys.

Use the existing source and example commands from the repository root.

```bash
scripts/bend-check test-fixtures/execution-composition/layout/main.bend
scripts/bend-check test-fixtures/execution-composition/layout/wrong-key.bend
export BEND=/home/node/.bend/bin/bend-2.0.35
source examples/common.sh
example_emit test-fixtures/execution-composition/layout/main.bend /tmp/gh88-layout.js
example_node /tmp/gh88-layout.js > /tmp/gh88-layout.stdout
cmp test-fixtures/execution-composition/layout/expected.stdout /tmp/gh88-layout.stdout
```

The second source check is an intended failure. This probe establishes a concrete
layout operation and its type boundary. Ordinary builder migration, composed
feature execution, services, backend qualification, and issue #88 remain pending.

`owned-result.bend` exercises the ordinary resource grant's writable `own` method.
Its callback may return an affine result while retaining the actual resource.
The mailbox already owns token 901, so publication returns the incoming array.
The first returned array changes 202 to 203. A second run returns that same local
owner, changes 203 to 204, and reports a body error. Mailbox token 101 and its
retained payload 901 remain present. This finite probe does not establish general
event semantics or cleanup.

The method quantifies over an erased result type. It preserves the existing Data
view and mutation methods. Read-only grants do not expose it. The controls
`read-only-owned-result.bend`, `owned-result-escape.bend`, and
`duplicate-owned-result.bend` must respectively reject writable authority through
read-only access, duplicate use of the hidden scope, and duplication of an actual
affine result.
