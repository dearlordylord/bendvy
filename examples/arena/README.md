# ECS swarm example

![Bendvy ECS swarm gameplay](arena.gif)

A playable browser ECS example: enemies, pickups, bolts, area pulses and chains.
Movement, targeting, damage and cleanup run through the ECS.
WASD/arrows move, Space pauses, and R restarts. Keyboard required.

From the repository root:

```sh
examples/arena/build.sh
python3 -m http.server 8000 --directory examples/arena
```

Open <http://localhost:8000>. No npm packages or external assets are needed.
`dist/` is generated and ignored. The build is checked with Bend 2.0.36.

## Components and entities

These are excerpts from [game.bend](game.bend), with its existing imports and
helpers. `Body` is the demo's compound component; `Store` owns its typed column.

```bend
type Schema is Data: Schema{}
type Body is Data: Body{x: F32,y: F32,kind: U32,seed: U32,hp: U32,speed: F32,target: U32,visited: List<&2,U32>,age: U32}
type Token is Data: Token{}
type Store is Type: Store{bodies: Col.Column<Schema,Body>}
```

An entity is a world-scoped `W.Handle<Schema>`. Spawn accepts a component value
and queues a structural command; the explicit barrier makes it visible.

```bend
def spawn(world: World(),body: Body) -> World():
  spawn_finish(Cmd.tx_spawn(~Schema,~Store,~Unit,~Unit,~Body,~populate,T.Tx{world,[],[],[]},body))
```

The [populate helper](game.bend) installs `Body` on the reserved entity. Despawn
clears its column through `clear` at the post-query barrier.

## System and query

The system receives declared capabilities: read/write `Body` and queue despawn.
Its callback works with abstract `H`, rather than accessing storage directly.

```bend
type Ops<-H: Type> is Type: Ops{body: Cap.Write<H,Body,Body>,despawn: Cap.Action<H>}
def OpsType(H: Type) -> Type: Ops<H>
def body_cap(~H: Type,ops: Ops<H>) -> Cap.Write<H,Body,Body>:
  match ops:
    case Ops{body,_}: body
def despawn_cap(~H: Type,ops: Ops<H>) -> Cap.Action<H>:
  match ops:
    case Ops{_,despawn}: despawn
```

The required query binds those capabilities to the world and runs the callback:

```bend
def body_system(~H: Type,~ops: Ops<H>,args: Args,ctx: H) -> H & (T.Outcome<Error> & Row):
  observed(~H,~ops,args,Cap.get(~H,~Body,~Body,~body_cap(~H,ops),ctx))
def Frame() -> Type: Q.Frame<Schema,Store,Unit,Unit>
def selected(frame: Frame()) -> Frame() & Bool:
  Q.family_match(~Schema,~Store,~Unit,~Unit,~Unit,~Body,~Body,~Token,~take,~put,~project,~family(),~Q.Required{},frame)
def plan() -> Q.Plan<Schema,Store,Unit,Unit,OpsType>:
  Q.Plan{Ops{Q.write_family(~Schema,~Store,~Unit,~Unit,~Unit,~Body,~Body,~Token,~take,~put,~project,~family()),Q.command_despawn(~Schema,~Store,~Unit,~Unit,~clear)},selected}
def execute(world: World(),args: Args) -> Q.Executed<World(),Q.Error<Error>,Row>:
  Q.each(~Schema,~Store,~Unit,~Unit,~OpsType,~Args,~Error,~Row,~plan(),~body_system,args,world)
```

`observed` reads the component, calls `update`, and writes the result through
`Cap.set`; `dispose_dead` queues removal through `Cap.action`. The gameplay
functions remain in [game.bend](game.bend).

This demo uses direct `Compose.each` orchestration. Registered systems and
schedules are covered by other examples; this one demonstrates component
storage, entity commands, declared query access and transactional updates.
`browser.mjs` supplies input, the fixed-step clock and rendering.

Run focused checks (also builds the finite controlled scenarios):

```sh
examples/arena/check.sh
```

These are finite gameplay/host checks, not mathematical proofs. Optional real
browser smoke with an already installed Playwright:

```sh
node examples/arena/browser-smoke.mjs
```

Set `PLAYWRIGHT_MODULE` to its module path if installed elsewhere. Pass a
screenshot filename as the first argument to save a preview. Current evidence
and the Chromium environment limitation are in [CHECKS.md](CHECKS.md).
