# Public Compose through the selected optimized owner route

Governing issue: #30. Status: public provider implemented; delivery gates pending.

Selected source is concrete-v3 closure
`a4672d110446195e3ac92911c6f41166b62025811df8816878356d0eafd08a55`.
The retained archive and per-module recipe are verified by the task-local freeze
command. Neither the direct-ID nor compiler-flag variants replace this selection.

The actual selected interface has two levels. Generic query handoff evacuates
`Array<Maybe<M>>` owners into ascending affine `HandoffCon{id,owner,rest}` nodes
by descending physical traversal; recovery returns every owner and ordered IDs.
The concrete Motion/Health route expands specific private MainSlot payloads into
nominal nodes. Its faster carrier is not a generic caller-defined Store provider.
Auxiliary columns, metadata, pending commands, ledger and mode remain owned by
the returned World. These records are trusted provisioning, not callback grants.

Public Compose currently uses arbitrary family lenses over one caller-defined
Store and a public World transaction journal. The selected route uses a different
World type, Main/Aux/Flag storage and specialized flat inverse journals. An import
or renamed wrapper cannot bridge those representations. Transporting the entire
public World as a single fake Main row would execute an irrelevant handoff and
does not satisfy optimized owner storage integration.

The compatible expansion adds a Prepared variant to the existing schema/family
Column type. Closed schema declarations prepare each accessed/selected family
once for the query, independently of heterogeneous Ops arity. The original
constructor, family lenses and gameplay declarations remain usable. Extracted
owners form the selected ascending affine row chain. An active current owner
supports repeated aliases without Array transport; ascending access moves prior
owners to owned history. Reverse access recovers every owner before ordinary
fallback. Growth similarly recovers before the original capacity expansion.

The public World still owns its heterogeneous Store and complete inverse,
command/event owners. Existing setters journal the complete previous affine
payload and authoritative stamps. Transaction finish executes inverse recovery
while the prepared provider remains accessible, then the additive executor
recovers current, past and remaining columns in the returned World on success
or failure. Deferred command application remains an explicit later barrier.

The Required/all-live producer is source partial evaluation of the selected
generic route: descending guarded physical indices, ownership-consuming swap,
None skipping and ascending HandoffCon nodes remain. Synthetic Aux/live/flag/
stamp arrays are eliminated because their fixed values had no selection effect.
Finite original-versus-specialized JS/Native controls retain three complete Type
Array payloads, a hole and ascending IDs. This is not a universal refinement proof.

Preparation stays cohesive with each copied Workshop plan: no family for the
empty-ID plan, Enabled only for contradictory selection, Stock for aliases,
four families for the lifecycle reader, and all five for work/retry. Gameplay,
structural membership, output and the frozen regression fixture are unchanged.
Confinement is still rank-2 abstract H; public trusted Column/Plan constructors
are not an authority secrecy theorem. No Data-only or fixed-Main/Aux restriction.

Fresh complete observations, intended negatives, compiling reached mutation,
source-bound transport diagnostics and no-confirmed-slowdown timing are distinct
delivery gates. Historical route evidence does not pass these integration gates.
The five-second checker remains binding; full matrix/production selection are
independent of this bounded source-compatible provider.
