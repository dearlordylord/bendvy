# S-INTEGRATE runtime modules — Standards

## First frozen module checkpoint — `2972e98`, `68c71a8`, `8bb389e` (2026-10-04)

Reviewed actual storage/identity/transaction/payload modules in detached worktree
`8bb389e`, against the reviewed join contracts and #19. All four module checker
runs independently passed the existing hard five-second wrapper. No runtime
integration or full capability acceptance follows.

**Hard violations: none found in the delivered module boundary.** Actual Main,
Aux, resource and queued payload owners remain Type. Main extraction/reinsertion
threads returned payload owners, preserves optional Aux/Flag and row metadata,
and distinguishes absent entity from absent Main. Namespace validation precedes
Main access. Sequential factory creation increments actual lineage state; ID
reservation advances world state independently of publication. Public constructors
and independently bootstrapped roots are explicitly trusted/admitted boundaries,
not fictitious privacy or global unforgeable-authority guarantees. Unique IDs,
valid array shape and bounds remain stated adapter premises.

Transaction setters automatically record returned old scalars in a newest-first
numeric inverse journal; reverse unwinding preserves the allocator field because
allocator restoration is absent. Failed finish drops staged Type commands/pings/
marks; success transfers them. Concrete Tx/restore capabilities must remain outside
rank-2 callbacks in the eventual provisioning join: module comments correctly do
not make public constructors private. Full payload getters return actual owners,
read all four slots and metadata, while scalar swaps preserve non-target fields.

**Required join follow-up:** Tx command staging is chronological; storage pending
lists are reverse chronological. No direct handoff exists yet. The forthcoming
bridge must reverse exactly once or otherwise reconcile conventions, with an
actual same-Tx noncommuting FIFO control. Passing the raw Tx list directly would
reverse intended order. This is a join gate, not a delivered integrated defect.

Frozen transaction canary evidence is scalar/Type-array-only: its allocator starts
at6 rather than exercising actual failed reservation, and full metadata/reader/
provisioning behavior is not established. My standalone normalization replay
printed expected `20:101:6` but failed exit0 within five seconds; it is not counted
as passing evidence. Compiled backend canary results were inspected, not independently
rerun here. Payload runtime runner changes outside the frozen commit were excluded.

**Heuristic findings: none actionable.** Small helpers reflect Bend affine/match
constraints. Actual command/query/Tx/factory joins, authority/access negatives,
full traces, readers/captures and performance remain open.
