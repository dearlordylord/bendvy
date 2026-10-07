# Real-runtime foreign-handle observation

Actual public TS execution: `observations/1791377930138080322/receipt.json`, twelve complete records across Workshop and Other. Each pair contains two independently created runtime instances of the same schema, each with actual spawned IDs 1–5. After the local barrier, the command using the peer runtime's ID 1 relates local entity 2 to local entity 1. The seeded local entity 3 relation also applies; the peer runtime's graph and owners remain unchanged. No relation failure is published.

This numeric-ID aliasing is comparator evidence, not a Bend requirement. The approved #19 identity contract rejects a foreign namespace with MissingEntity and preserves the queue and affine owners, including colliding numeric IDs.

The next Bend control uses one threaded owned World.Factory to create two same-schema worlds, actual reserved handles, a seeded pending local operation, full physical component arrays and metadata, and all descriptor/query observations before and after the barrier. Its observer must retain the peer namespace rather than normalize it to 1. No independently rooted factory uniqueness, backend execution, or full #42 acceptance is claimed by this TS receipt.
