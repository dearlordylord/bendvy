# ECS, reducers and Bendvy: research and audit

Subject revision: Bendvy `2e3be6904`. Reference revisions are the pinned checkouts in
[`.references/sources.json`](.references/sources.json): Bevy `ad678262` (bevy_ecs
0.20.0-dev), bevy-ts `3040a3b2`, Bend `a950fd68`. Cross-checks against the current
bevy-ts line use [Ritmo](https://github.com/typeonce-dev/ritmo) (`typeonce-dev/ritmo`,
the repository that hosts bevy-ts) at `bec76226`.

Evidence scope: source reading and the repository's recorded measurements. No code was
executed or profiled for this document. Where the cause of a performance gap is
inferred from code structure rather than a profile, it is marked as a hypothesis.

## 1. Summary

- An ECS is a special case of a reducer: the state is a relational store
  (one table per component type), and the step function is a composition of query-driven
  transforms. The OOPSLA 2025 Core ECS calculus defines a program step literally as
  `z(c) = c ↓ (c ⇓ z)`: compute a mutation from the state, then apply it.
- Bevy's mutation model has two parts: in-place `&mut T` writes, and a deferred, opaque
  command queue for structural changes. Both exist because of Rust's aliasing and
  borrowing rules.
- Bendvy is structurally a pure reducer (`World -> World`) with typed, capability-checked
  footprints. That is the right foundation. It also carries mechanisms whose rationale is
  specific to Rust (pointer-style access, opaque commands) or to TypeScript (undo journal,
  observable iteration order). In Bend these mechanisms cost allocation and
  sequentialization and give back none of the benefits ECS exists for.
- Two findings are correctness defects: the change clock advances on every component
  write and saturates, after which all writes are rejected (section 6.1); and save/restore
  silently drops structural work queued after the last barrier (section 6.9).
- Cross-checking Ritmo, the bevy-ts line: the clock, query and read-typing findings
  (6.1, 6.2, 6.6) depart from Ritmo as well as from Bevy. The journal and ordered
  iteration (6.5, 6.7) are TypeScript-motivated choices in Ritmo whose rationale does not
  carry over to Bend. Ritmo shares the save/restore defect (6.9).
- Recorded performance (section 6.0) misses the targets: Native/TS 2.00–3.95, JS/TS
  4.29–6.61, against a goal of Native ≤ 0.5 × TS and JS ≤ TS.

## 2. Origins of ECS

| Year | Milestone | Source |
| --- | --- | --- |
| 1998 | *Thief: The Dark Project* (Dark Engine) is the earliest publicly known ECS-like engine; technical details were published much later | [Wikipedia: Entity component system](https://en.wikipedia.org/wiki/Entity_component_system) |
| 2002 | Scott Bilas, GDC, "A Data-Driven Game Object System" (*Dungeon Siege*): composition from data-driven components instead of class hierarchies. Motivation was authoring flexibility, not cache performance. Components still carry behavior. Core ECS cites this as the earliest reference it knows | [slides](https://www.gamedevs.org/uploads/data-driven-gameobject-system.pdf), [video](https://www.youtube.com/watch?v=Eb4-0M2a9xE) |
| 2007 | Mick West, "Evolve Your Hierarchy" (Neversoft); Adam Martin's T-Machine series fixes the strict form: entity = id, component = data only, system = all logic | [T-Machine part 1](http://t-machine.org/index.php/2007/09/03/entity-systems-are-the-future-of-mmog-development-part-1/) |
| 2010s–2020s | Data-oriented turn: archetype and SoA storage (Unity DOTS, Bevy, Flecs); ECS becomes primarily associated with performance | [Sander Mertens, ECS FAQ](https://github.com/SanderMertens/ecs-faq) |

## 3. Formal state of the art

A search of [pldb](https://pldb.kirancodes.me/?q=%22entity+component%22) (33,580 papers
from POPL, PLDI, ICFP, OOPSLA and other PL venues, 1973 onward) returns two ECS papers. A
third appeared at SAC, which pldb does not index. Formal treatment of ECS dates from
2025–2026; before that, ECS existed as game-development practice.

### 3.1 Core ECS (OOPSLA 2025)

Redmond, Castello, Calderón Trilla, Kuper. "Exploring the Theory and Practice of
Concurrency in the Entity-Component-System Pattern."
[arXiv:2508.15264](https://arxiv.org/abs/2508.15264),
[ACM DOI 10.1145/3763050](https://dl.acm.org/doi/10.1145/3763050),
[draft PDF](https://users.soe.ucsc.edu/~lkuper/papers/core-ecs-draft.pdf).

Denotational semantics:

- **State:** `c = { c_i : E ⇀ K_i }`, an indexed family of partial maps from entities to
  component values (a set of binary relations).
- **Queries:** `incl_i | excl_i | anyway_i | q ∧ q'`, which the authors relate to a fragment
  of conjunctive queries (selection, projection, join). A query vector is a cartesian
  product, used for interactions between entities.
- **System:** a pair (query vector, function from matches to a mutation).
- **Mutations:** a monoid `attach_i(e,k) | detach_i(e) | m • m' | ν(fresh) | nil`. The
  authors began with freer monads and moved to a monoid as the simpler representation.
- **Production:** `conc` (every match observes one snapshot) and `seq` (each match
  observes earlier mutations; defined by `roll`, which the paper notes is a fold-left).
- **Schedules:** `conc(s) | seq(s) | z ∥ z' | z ⨟ z'`.
- **Step:** `z(c) = c ↓ (c ⇓ z)`.
- **Results:** Theorem 4.5 (a safe schedule is deterministic); Lemma 4.6 (mutations with
  disjoint influence commute); Corollary 4.9 (a system with a singleton query vector that
  does not derive entities from component values is deterministic under `conc`). The
  surveyed frameworks (Bevy, EnTT, Flecs, Specs, apecs) leave deterministic concurrency
  unexploited; in particular none can attach a component concurrently with another
  mutation. An executable Haskell model is on Zenodo.
- **Scope:** the model has no external input. A step is `State → State`, the system
  function is pure, and the only external choice is fresh entity generation. The
  executable model's main loop applies the schedule a fixed number of times.

### 3.2 The Essence of Entity Component System (SAC 2026)

Tasnim, Zhao. [arXiv:2606.14919](https://arxiv.org/abs/2606.14919).

- Operational semantics of archetype ECS. Heap `ArchetypeType → {Entity} ∪ Entity → (C → Component)`;
  state `(Heap, Frame, EventQueue)`.
- Structural changes are staged (queued, applied at `sync`) or immediate.
- Two conflict kinds: concurrent (parallel access to one archetype table) and residual
  (reading an archetype dirtied by staged events before `sync`).
- A type-and-effect system derives a read/write set `(R, W)` per system. Progress,
  preservation and soundness are stated; proofs are omitted (short paper). Half of the
  paper is a Tower Defense benchmark.

### 3.3 Other

- Dahl, Harris, "An Argument for the Practicality of Entity Component Systems as the
  Primary Data Structure for an Interpreter or Compiler," Onward! 2025,
  [DOI 10.1145/3759429.3762622](https://doi.org/10.1145/3759429.3762622). Not a
  formalization. ECS eases optimization passes and serialization, at a memory cost.

### 3.4 Open questions in the literature

Typed invariants over component combinations, external input, and partially overlapping
footprints are not covered by either formalization. Both target concurrency and memory
layout.

## 4. ECS and reducers

### 4.1 Mapping

| ECS | Reducer |
| --- | --- |
| World (component tables, resources) | State |
| Tick, input, event | Action |
| System `(World, Input) → World` over a query | Reducer over a slice/query |
| Schedule | Composition of reducers |
| Command buffer | Reducer returning a patch applied later |
| Query | Selector (a conjunctive query over normalized tables) |

ECS → reducer always holds. Reducer → ECS is trivial (one entity, one component, one
system) unless the state is normalized and the reducer decomposes into transitions with
declared read/write sets.

Prior informal mappings:
[ryohey, "Similarity between Entity Component System and Redux"](https://dev.to/ryohey/similarity-between-entity-component-system-and-redux--5cpa),
[vincentdesmares/redux-ecs](https://github.com/vincentdesmares/redux-ecs),
[yos.io, ECS in Elixir](https://yos.io/2016/09/17/entity-component-systems/) (systems with
`dispatch(state, action) → state`),
[Maxim Zaks, Entitas for Flutter](https://mzaks.medium.com/entitas-for-flutter-e1ea063a123c),
[HN discussion "ECS, Finally"](https://news.ycombinator.com/item?id=38821208).

ECS as a relational database:
[Mertens, "Why it is time to start thinking of games as databases"](https://ajmmertens.medium.com/why-it-is-time-to-start-thinking-of-games-as-databases-e7971da33ac3),
[AFIT thesis on ECS data storage](https://scholar.afit.edu/cgi/viewcontent.cgi?article=6355&context=etd).
Typed functional ECS: [apecs](https://github.com/jonascarpay/apecs) (`cmap :: (cx -> cy) -> System w ()`).

### 4.2 Concepts

- **Conjunctive queries:** `SELECT … FROM … WHERE` with only AND of equalities: joins,
  filters, projection; no OR, NOT, aggregation or recursion. As Datalog:
  `Moving(e,p,v) :- Pos(e,p), Vel(e,v).` Bevy's `Query<(&Pos, &Vel)>` is a join on entity
  id. The class is well studied: containment is decidable, and incremental maintenance
  and caching are known techniques, which is why per-archetype query caching works.
  `Without<C>` (`excl`) is negation and lies outside pure conjunctive queries.
- **Layout:** how component data sits in memory.
  - Archetype tables (Bevy default, Flecs, DOTS): one table per component set, one column
    per component. This is a columnar store partitioned by archetype; adding or removing a
    component migrates the row between tables.
  - Sparse sets (EnTT; Bevy `StorageType::SparseSet`): per-component storage keyed by
    entity; cheap insert and remove, slower joins.
- **Read/write sets vs mutations as data:** read/write sets are a static declaration of
  what a system may read or write, known before it runs (Bevy `Access`/`FilteredAccess`,
  derived from parameter types; the query vector in Core ECS). Mutations as data are the
  concrete changes produced at run time (the Core ECS mutation monoid; Bevy `Commands`).
  A read/write set over-approximates a mutation's actual footprint (its influence in
  Core ECS).
- **Determinism from read/write sets:** if `W_A ∩ (R_B ∪ W_B) = ∅` and `W_B ∩ R_A = ∅`,
  neither system observes the other's writes, so any interleaving equals sequential
  execution. A scheduler that only enforces disjointness guarantees freedom from data
  races, not determinism; conflicting systems additionally need an explicit order. Bevy
  offers ambiguity detection for unordered conflicting pairs.
- **External input:** in the pattern, input is written into the world before a tick
  (Bevy `ButtonInput`, `Events<T>`). Adding input to Core ECS yields
  `step(c, i) = z(c ↓ inject(i))`, which is exactly `(State, Action) → State`. The
  determinism theorem still holds because input arrives between steps, but the model has
  no typed channel for which inputs are legal in a given state.

### 4.3 Bevy's mutation model (pinned source)

- Component values: in-place `&mut T` through queries and `ResMut<T>`, made safe by the
  borrow checker. Systems with conflicting access cannot run concurrently.
- Structural changes: `Commands` push to a queue applied at sync points, because "each
  command requires exclusive access to the `World`"
  ([commands/mod.rs:43](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/system/commands/mod.rs#L43)).
  A command is any `FnOnce(&mut World)`
  ([commands/mod.rs:74-86](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/system/commands/mod.rs#L74-L86)).
  Sync points are auto-inserted between dependent systems, and deferred buffers are
  applied at the end of a schedule by default
  ([executor/mod.rs:134-149](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/executor/mod.rs#L134-L149),
  [schedule.rs:585](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/schedule.rs#L585)).
- The queue is a free monoid of opaque closures: commands are not normalized, merged or
  checked for commutation.
- Exclusive systems (`&mut World`) mutate without restriction and block all others.
- Change detection: the world tick advances once per system run
  ([function_system.rs:822](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/system/function_system.rs#L822),
  [:851](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/system/function_system.rs#L851)).
  Comparison is wraparound-safe
  ([tick.rs:58-67](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/change_detection/tick.rs#L58-L67)),
  with a periodic clamp
  ([world/mod.rs:3391](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/world/mod.rs#L3391)).
  Ticks are stored as arrays beside column data
  ([table/column.rs:29-30](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/storage/table/column.rs#L29-L30)).
- Queries cache matched archetypes and storages
  ([query/state.rs:85-95](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/query/state.rs#L85-L95)).
  "Iteration order is not guaranteed"
  ([system/query.rs:655](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/system/query.rs#L655)).
- Fallible systems return `Result` to an error handler (panic, log, ignore). Writes made
  before the error are not rolled back
  ([error/mod.rs](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/error/mod.rs)).
- Core ECS on Bevy (§5): concurrency safety is "shallowly embedded into the borrow
  checker". In-place mutation forbids concurrent access to a store; structural changes are
  serialized through the queue.

### 4.4 Takeaways

1. ECS is a reducer over a relational store. The real question is whether a relational
   state shape and a system scheduler are needed.
2. ECS value has three separable parts: layout (cache performance), scheduler with
   read/write sets (deterministic parallelism), and open component composition (authoring
   flexibility). Without any of them, ECS adds nothing as an execution model.
3. Footprints matter without parallelism, as explicit connascence of what a procedure
   touches.
4. Making mutations data (the Core ECS monoid) exposes concurrency that Bevy, Flecs and
   Specs miss.
5. Open component sets conflict with "make invalid states unrepresentable"; typed
   archetypes or bundles restore it.
6. Classic ECS is a closed, tick-driven simulation. Event-driven systems with legality
   that depends on state fit a reducer with an explicit action parameter better.

## 5. Bendvy: what it gets right

- **Footprints as types.** A system body receives an abstract `H` and only the granted
  capabilities (`Cap.Read`, `Cap.Write`). Parametricity prevents undeclared access. This is
  the type-and-effect approach of section 3.2 in a stronger form.
- **One declaration produces both the typed capability and the runtime clause**
  ([ordinary-query-declaration.bend:13](src/ecs/ordinary-query-declaration.bend#L13)), so
  type and metadata cannot drift.
- **Input arrives as system arguments** (`args` in `Q.each`; `browser.mjs` in
  [examples/arena](examples/arena/README.md)): `(State, Action) → State`.
- **The schedule is an explicit ordered list**
  ([schedule.bend:7](src/ecs/schedule.bend#L7)): deterministic, with no ambiguity.
- **The parallelism limitation is recognized**:
  [bend2-ecs-port.md:72](docs/bend2-ecs-port.md#L72) notes that access metadata without
  ownership separation is insufficient.
- Deferred structural semantics with explicit barriers, and generational ids over arrays,
  are reasonable adaptations.

## 6. Bendvy: findings

Classification:

- **A:** a mechanism whose rationale is specific to Rust, carried into Bend where the
  rationale does not hold.
- **B:** a mechanism taken from bevy-ts (TypeScript, mutable arrays); a departure from
  Bevy.
- **C:** a departure from Bevy explained neither by Rust nor by Bend.

### 6.0 Recorded performance

From [delivery-process-expectations.md](docs/reports/delivery-process-expectations.md),
2026-10-19 seven-case raw comparison (medians, ms; ratio = Bend / TS; the decision rule is
pending):

| Case | JS | Native | TS | JS/TS | Native/TS |
| --- | ---: | ---: | ---: | ---: | ---: |
| Dense-motion-256 | 94.945 | 36.668 | 18.061 | 5.257 | 2.030 |
| Sparse-motion-256 | 152.191 | 70.006 | 31.130 | 4.889 | 2.249 |
| Lifecycle-motion-256 | 6482.301 | 4189.695 | 1061.095 | 6.109 | 3.948 |
| FailedTxn-motion-64 | 2193.990 | 1241.147 | 462.847 | 4.740 | 2.682 |
| Readers-motion-64 | 639.156 | 396.050 | 115.412 | 5.538 | 3.432 |
| Dense-health-64 | 29.786 | 9.011 | 4.506 | 6.611 | 2.000 |
| FailedTxn-health-64 | 2510.232 | 1705.209 | 584.750 | 4.293 | 2.916 |

The goals are JS ≤ TS and Native ≤ 0.5 × TS.

### 6.1 Change clock advances per write and saturates (C, correctness)

- Bendvy calls `advance_clock` on every component write
  ([component.bend:112](src/ecs/component.bend#L112)). The clock saturates at `4294967295`
  ([world.bend:255](src/ecs/world.bend#L255)), after which writes are rejected
  ([query-composition.md:87](docs/reports/query-composition.md#L87)).
- Bevy advances the tick once per system run and compares ticks with wraparound-safe
  arithmetic (section 4.3).
- Consequence: at 10,000 component writes per frame and 60 frames per second, the clock
  is exhausted in about two hours, after which the world rejects every component write.
  Bevy's scheme is plain arithmetic and ports directly.
- Ritmo also advances the tick per system run and per command flush
  ([internal/world.ts:179-182](https://github.com/typeonce-dev/ritmo/blob/bec762266bedbe9c04b4ce804d40d87f2ad442fa/packages/core/src/internal/world.ts#L179-L182),
  [:724](https://github.com/typeonce-dev/ritmo/blob/bec762266bedbe9c04b4ce804d40d87f2ad442fa/packages/core/src/internal/world.ts#L724)).
  Per-write advancement departs from both references.

### 6.2 Query is a full entity scan without matched-storage caching (C, performance)

- `each` snapshots every live handle and runs the selection predicate per handle
  ([compose.bend:173](src/ecs/compose.bend#L173)). Cost is O(live entities) per query, not
  O(matches). Multi-component queries become nested-loop filters over per-component sparse
  arrays ([column.bend:32](src/ecs/column.bend#L32)).
- Plain-column change stamps are an association list: `get` is O(n), `set` is O(n) clear
  plus prepend ([lifecycle.bend:21](src/ecs/lifecycle.bend#L21),
  [:42](src/ecs/lifecycle.bend#L42)). A system writing n rows is O(n²). The indexed variant
  uses arrays ([indexed-lifecycle.bend](src/ecs/indexed-lifecycle.bend)).
- Bevy caches matched storages per query and stores ticks as column arrays.
- Ritmo caches each query's ordered match set, refreshes it incrementally from
  membership versions, recomputes from the smallest required component set, and bounds
  `changed` candidates with per-component change logs
  ([internal/queries.ts:406-500](https://github.com/typeonce-dev/ritmo/blob/bec762266bedbe9c04b4ce804d40d87f2ad442fa/packages/core/src/internal/queries.ts#L406-L500)).
  Ticks are numeric slots in the entity record, not lists. The full scan departs from
  both references.
- Ritmo shows the cost of the ordered-iteration contract (6.7): incremental refresh copies
  the match arrays and splices each affected record, and the sparse `changed` path re-sorts
  candidates by id
  ([queries.ts:505](https://github.com/typeonce-dev/ritmo/blob/bec762266bedbe9c04b4ce804d40d87f2ad442fa/packages/core/src/internal/queries.ts#L505)).

### 6.3 Component access emulates a pointer (A, performance and parallelism)

- Each `get` or `set` destructures the nine-field `World` record, takes the column from the
  store, reads or writes, puts it back and rebuilds `World`
  ([component.bend:50-53](src/ecs/component.bend#L50-L53)). The whole transaction is
  threaded through every row ([compose.bend:155](src/ecs/compose.bend#L155)).
- In Rust, an `&mut T` from a query iterator is a free pointer. In affine Bend, the natural
  form is a column-level transform: take the column once, map the rows, put it back. That
  is `conc` production (section 3.1), which also enables parallel evaluation.
- Per-row bodies may write resources ([compose.bend:59](src/ecs/compose.bend#L59)), creating
  a shared accumulator across rows that makes `conc` impossible for such systems.

### 6.4 Commands are opaque closures (A, architecture)

- `Raw{apply: W -> W}` ([deferred-command.bend:5](src/ecs/deferred-command.bend#L5)), stored
  in `World.pending` ([world.bend:20](src/ecs/world.bend#L20)).
- Bevy defers commands because of exclusive `&mut World` access and represents them as
  `FnOnce(&mut World)` (section 4.3). Bend has no iterator to invalidate: handles are
  snapshotted and the world is affine. The deferred semantics (query membership stable
  until a barrier) is worth keeping. The closure representation is a Rust artifact.
- Consequences: commands cannot be inspected, merged, checked for commutation, serialized
  into snapshots, or joined after a fork. The plan in
  [bend2-ecs-port.md:113](docs/bend2-ecs-port.md#L113) ("deterministic merge of
  deltas/commands") cannot be implemented over opaque closures.

### 6.5 Rollback by an inverse-closure journal (B via A, performance)

- Bevy has no rollback. bevy-ts journals original values in three flat arrays because JS
  mutates in place
  ([bevy-ts internal/world.ts:221-229](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/src/internal/world.ts#L221-L229)).
- Ritmo journals each (record, component) pair once per transaction, guarded by a
  per-slot transaction mark
  ([internal/world.ts:380-395](https://github.com/typeonce-dev/ritmo/blob/bec762266bedbe9c04b4ce804d40d87f2ad442fa/packages/core/src/internal/world.ts#L380-L395)).
  The journal stores references to old values, so it is correct only while values are
  never mutated in place; Ritmo enforces that through readonly types alone. In Bend,
  values are immutable by construction, which removes the hazard the journal guards
  against and leaves only its cost.
- Bendvy records a `W -> W` inverse closure per write
  ([transaction.bend:20](src/ecs/transaction.bend#L20), rollback at
  [:39](src/ecs/transaction.bend#L39)): one allocation per write.
- In a pure language, "compute the mutation, then apply it" is the natural form: writes
  accumulate in an overlay or patch, a failure discards it at no cost, and success applies
  it. Read-your-writes is served by reading through the overlay.
- Both FailedTxn workloads run 2.7–2.9× slower than TS on Native (section 6.0).

### 6.6 Required-query access admits absence (C, typing)

- `Access<V> = Found | ComponentAbsent | MissingEntity`
  ([component.bend:16](src/ecs/component.bend#L16)) is returned even when the query
  requires the component. Bodies must handle unreachable branches, and the README example
  invents `D.Health{0.0}` to satisfy the result type.
- Ritmo's `ReadCell<T>.get()` returns `ReadonlyValue<T>` with no absence variants
  ([Query.ts:568-573](https://github.com/typeonce-dev/ritmo/blob/bec762266bedbe9c04b4ce804d40d87f2ad442fa/packages/core/src/Query.ts#L568-L573)).
  The widened type departs from both references.
- Bevy's `Query<&T>` yields `&T`; absence is expressed only through `Option<&T>`. The query
  proves presence, and the type should carry that narrowing.

### 6.7 Observable iteration order and no final flush (B, contract)

- Bendvy makes query iteration order a contract
  ([identity.md:216](docs/parity/identity.md#L216)) and has no implicit flush at schedule
  end ([SPEC.md:28](docs/SPEC.md#L28)). Both follow bevy-ts
  ([Runtime.ts:709-713](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/src/Runtime.ts#L709-L713));
  the audit at
  [laws-source-research.md:28](docs/archive/recovered/reviews/laws-source-research.md#L28)
  explicitly declines Bevy's default.
- Bevy does not guarantee iteration order and applies deferred buffers at schedule end by
  default (section 4.3).
- This conflicts with the SPEC precedence (Rust Bevy first, bevy-ts third). A fixed
  iteration order also rules out the unordered `conc` evaluation that Corollary 4.9 makes
  deterministic.

### 6.8 Registration metadata compared as strings on every run (minor)

- Each system run scans `registrations` and compares id, name and an ordered
  `List<String>` of access entries ([world.bend:175](src/ecs/world.bend#L175),
  [system.bend:50](src/ecs/system.bend#L50)).
- The same value is stored in `Registry` and in `World` so the two copies can be compared:
  connascence of value on the hot path. `namespace + id` suffices to reject a foreign
  registry.

### 6.9 Save and restore drop pending structural work (A + B, correctness)

- Without a final flush (6.7), commands queued after the last barrier persist across
  schedule runs. Because commands are opaque closures (6.4), a save cannot serialize them.
- Bendvy's snapshot export does not read `pending`
  ([snapshot-data.bend:17](src/ecs/snapshot-data.bend#L17)), and restore discards it:
  "Pending commands are discarded, never invoked"
  ([restore-world.bend:6-10](src/ecs/restore-world.bend#L6-L10);
  contract in [restore-basic.md:77](docs/parity/restore-basic.md#L77)). Save does not
  refuse when `pending` is non-empty.
- Scenario: a system queues a spawn, no barrier follows before the tick ends, the player
  saves. After load the entity does not exist, and nothing reports the loss.
- Ritmo has the same combination: `snapshot()` rejects only calls made during a tick and
  omits `pendingCommands` and `pendingMachines`; restore clears them
  ([Runtime.ts:2441-2467](https://github.com/typeonce-dev/ritmo/blob/bec762266bedbe9c04b4ce804d40d87f2ad442fa/packages/core/src/Runtime.ts#L2441-L2467),
  [:2581-2583](https://github.com/typeonce-dev/ritmo/blob/bec762266bedbe9c04b4ce804d40d87f2ad442fa/packages/core/src/Runtime.ts#L2581-L2583),
  [Snapshot.ts:27](https://github.com/typeonce-dev/ritmo/blob/bec762266bedbe9c04b4ce804d40d87f2ad442fa/packages/core/src/Snapshot.ts#L27)).
- Bevy's default final flush means queued commands do not outlive a schedule run.

### 6.10 Relation to the formal models

The formal models are descriptive, so Bendvy does not violate them. Several choices take
it outside the region where their theorems apply:

| Bendvy choice | Relation to the models |
| --- | --- |
| `W -> W` commands | Outside the Core ECS mutation monoid; Lemma 4.6 and the determinism theorem do not apply |
| Row fold with shared `Tx` and resource writes | Valid `seq` production; influences overlap, so `conc` is not safe |
| Fixed iteration order | Fixes an order the model leaves unspecified; forgoes Corollary 4.9 |
| Undo journal | Outside the model, which has no rollback |
| Deferred commands and barrier | Matches staged events and `sync` in Essence |
| Typed read/write capabilities | Matches the Essence type-and-effect approach, with stronger enforcement |
| Visibility before barrier | Defined behavior (Bevy-like), where Essence treats it as a residual conflict |

## 7. Recommendations (priority order)

1. **Correctness (6.1, 6.9).**
   - Change clock: advance the tick per system run and adopt Bevy's wraparound-safe
     comparison and periodic clamp.
   - Pending work across save: refuse a save while `pending` is non-empty (an explicit
     result, not silent omission), or serialize built-in commands as data (see 3), or
     adopt Bevy's final flush (see 4).
2. **Query and stamp storage (6.2).** Maintain per-query membership (the analogue of
   `matched_storage_ids`) instead of scanning all handles; replace list-backed stamps with
   arrays on every column variant.
3. **Mutation as data (6.3–6.5).**
   - Express system effects as a patch: column-level transforms for value writes; built-in
     structural commands (spawn, insert, remove, despawn) as a data enum, with `Raw` kept
     only for custom commands.
   - Apply the patch on success and discard it on failure, replacing the inverse-closure
     journal; serve read-your-writes from the overlay.
   - Restrict resource writes from per-row bodies, or make them explicit reductions, so
     row evaluation can be `conc`.
4. **Typing and contracts (6.6–6.8).**
   - Give required queries a narrowed access type.
   - Decide explicitly, against the SPEC precedence, whether to keep the bevy-ts iteration
     order and no-final-flush contracts.
   - Reduce registration matching to `namespace + id`.

## 8. Verification plan

- 6.1: a test that starts the clock near `4294967295` and performs writes across several
  system runs; expected (Bevy semantics) is continued acceptance and correct
  `Added`/`Changed` observation.
- 6.9: a save taken after a system queues a spawn with no following barrier, then a
  restore; expected is either a refused save or the spawned entity after the next
  barrier.
- 6.2–6.5: Native CPU profiles of Dense-motion and Lifecycle-motion attributing time to
  `W.handles` plus the predicate, `L.get`/`L.set`, the `World` record rebuild and undo
  closures.
- 6.3–6.5: a prototype `each` in `conc` mode (rows read a snapshot and return data
  mutations; one apply) compared with the current `seq` route on Dense-motion, using the
  existing equivalent-work protocol.
