# Successor source freeze: logical component IDs

Agent `/root/recovery52_independent_app`; branch `parity52/independent-application`.
Owned successor scope is `experiments/public-recovery/independent-app-v1/successor-v2/`.
The first freeze is commit `c74f6b8535d91ad9f176125f6b829bae86bdd681`, based on
`d38025142`. Its source and check records remain unchanged. The coordinator
retains its actual failed JS attempt separately.

The first backend run exposed my fixture indexing error: component columns map
logical ID `id` to physical array index `id - 1`. The first fixture seeded the
original owner in physical slot 1, making logical target ID 1 absent. Its row
observer also used invalid logical ID 0 and stopped before logical ID 4. That
source did not establish the required present-removal path.

This preserved successor moves the target payload to physical slot 0 and sibling
to physical slot 1 in both columns, leaving physical slots 2 and 3 empty. The
observer enumerates logical IDs 1, 2, 3, 4, so every physical slot is observed
exactly once with its logical lifecycle stamp. Stamp entries remain keyed by
logical IDs 1 and 2. World live bits use `live[id]` rather than `live[id - 1]`;
therefore `[False, True, True, False]` correctly represents live logical IDs 1
and 2 and remains unchanged.

The narrowly relevant source semantics were inspected after the coordinator
reported the mismatch: `column.bend` `swap_checked`, `plain_view_checked`, and
`plain_view_sized`; `lifecycle.bend` `get`; `world.bend` live access. This does
not introduce an operation-body dependency on private recovery algorithms.
No prior application bodies, observers, or oracles were inspected.

Application operations are unchanged: remove the actually present target with
canonical `component_replace(..., None{})`, write resource, write capture, and
fail semantically; repeat against the restored world and commit. All declarations,
System calls, independent observer preservation/release behavior, arbitrary
affine nested payloads, output and typed recovery observations follow the first
freeze. Imports gain one parent segment for the successor directory.

The complete observation format is documented in the first freeze's README,
with one correction: component row labels now run **row1 through row4**, mapping
to physical slots 0 through 3. All target, sibling, second-column, resource,
capture, current/returned owners, lifecycle stamps, world and registry fields
are recorded; no checksums or selected-element summaries are used. Three lines
are emitted: `initial:`, `rollback:`, `commit:`. Exceptional constructors retain
their explicit complete-observation branches.

This directory supplies source only. A fresh independent oracle must be authored
after this successor freeze; the coordinator runs the unchanged collector. This
author has launched no backend and supplies no expected output. The parent
README's intended behavior is not evidence that the first freeze met it.
