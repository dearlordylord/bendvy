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
