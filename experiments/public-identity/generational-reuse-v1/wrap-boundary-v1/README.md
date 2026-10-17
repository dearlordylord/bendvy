# Generation wrap boundary

Explicit trusted admin setup seeds the generation of one actual ordinary-spawned
live slot to U32 max, replacing only its generation, logical-order key and returned
current handle. The original actual generation-zero handle remains retained.
Ordinary typed cleanup then wraps the free slot to zero. Ordinary Batch spawn
reuses it; the retained ancient handle aliases this new same-world occupant, as
approved. An actual independently IO-created World's same-index/generation handle
still refuses. Ancient-handle despawn clears the new occupant; the next generation
one reuse rejects the ancient zero handle again.

Fourteen complete checkpoints retain both actual Worlds, physical allocator and
component arrays, stamps, free/order lists, all affine returned payloads, events,
queues, resources, registration metadata and clock. Observation and ordinary
operations import the immutable first consumer without modifying it. No source
models, expected output or backend execution are authored here.

Pinned CPU6 five-second check reports only the four actual IO foreign-dependent
definitions; no parser, type or affine error. Independent oracle and execution
remain pending.
