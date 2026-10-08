import Base
import ./events.bend as Events
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import ./geometry.bend as Geometry

type DamageArgs is Data: DamageArgs{goal: U32,damage: U32}
type DamageError is Data:
  DamageMissingPosition{}
  DamageMissingHealth{}
type DamageOps<-S: Data,-H: Type> is Type:
  DamageOps{position: Cap.Read<H,Geometry.Cell>,health: Cap.Write<H,Array<U32>,Geometry.Cell>,handle: Cap.ValueRead<H,W.Handle<S>>,events: Cap.Send<H,Events.SimulationEvent>,despawn: Cap.Action<H>}
def Ops(~S: Data,H: Type) -> Type: DamageOps<S,H>
def position_cap(~S: Data,~H: Type,ops: DamageOps<S,H>) -> Cap.Read<H,Geometry.Cell>:
  match ops:
    case DamageOps{position,_,_,_,_}: position
def health_cap(~S: Data,~H: Type,ops: DamageOps<S,H>) -> Cap.Write<H,Array<U32>,Geometry.Cell>:
  match ops:
    case DamageOps{_,health,_,_,_}: health
def handle_cap(~S: Data,~H: Type,ops: DamageOps<S,H>) -> Cap.ValueRead<H,W.Handle<S>>:
  match ops:
    case DamageOps{_,_,handle,_,_}: handle
def events_cap(~S: Data,~H: Type,ops: DamageOps<S,H>) -> Cap.Send<H,Events.SimulationEvent>:
  match ops:
    case DamageOps{_,_,_,events,_}: events
def despawn_cap(~S: Data,~H: Type,ops: DamageOps<S,H>) -> Cap.Action<H>:
  match ops:
    case DamageOps{_,_,_,_,despawn}: despawn
def died(~S: Data,~H: Type,~ops: DamageOps<S,H>,dead: Bool,id: U32,ctx: H) -> H:
  match dead:
    case False{}: ctx
    case True{}: Cap.action(~H,~despawn_cap(~S,~H,ops),Cap.send(~H,~Events.SimulationEvent,~events_cap(~S,~H,ops),ctx,Events.SimulationDeath{id}))
def hit_health(~S: Data,~H: Type,~ops: DamageOps<S,H>,damage: U32,+id: U32,ctx: H,health: Geometry.Cell) -> H & (T.Outcome<DamageError> & Geometry.Cell):
  match health:
    case Geometry.Cell{+value,sentinel}:
      (died(~S,~H,~ops,U32.is_eq(value,0),id,Cap.send(~H,~Events.SimulationEvent,~events_cap(~S,~H,ops),ctx,Events.SimulationHit{id,damage})),(T.Success{},Geometry.Cell{value,sentinel}))
def hit(~S: Data,~H: Type,~ops: DamageOps<S,H>,damage: U32,health: Geometry.Cell,observed: H & W.Handle<S>) -> H & (T.Outcome<DamageError> & Geometry.Cell):
  match observed:
    case (ctx,W.Handle{_,id}): hit_health(~S,~H,~ops,damage,id,ctx,health)
def damaged(~S: Data,~H: Type,~ops: DamageOps<S,H>,+damage: U32,observed: H & C.Access<Geometry.Cell>) -> H & (T.Outcome<DamageError> & Geometry.Cell):
  match observed:
    case (ctx,C.Found{Geometry.Cell{value,+sentinel}}):
      +next = (value - damage : U32)
      hit(~S,~H,~ops,damage,Geometry.Cell{next,sentinel},Cap.value_read(~H,~W.Handle<S>,~handle_cap(~S,~H,ops),Cap.set(~H,~Array<U32>,~Geometry.Cell,~health_cap(~S,~H,ops),ctx,ANode{ALeaf{next},ALeaf{sentinel}})))
    case (ctx,_): (ctx,(T.Failure{DamageMissingHealth{}},Geometry.Cell{0,0}))
def eligible(~S: Data,~H: Type,~ops: DamageOps<S,H>,accepted: Bool,damage: U32,ctx: H) -> H & (T.Outcome<DamageError> & Geometry.Cell):
  match accepted:
    case False{}: (ctx,(T.Success{},Geometry.Cell{0,0}))
    case True{}: damaged(~S,~H,~ops,damage,Cap.get(~H,~Array<U32>,~Geometry.Cell,~health_cap(~S,~H,ops),ctx))
def positioned_result(~S: Data,~H: Type,~ops: DamageOps<S,H>,goal: U32,damage: U32,observed: H & C.Access<Geometry.Cell>) -> H & (T.Outcome<DamageError> & Geometry.Cell):
  match observed:
    case (ctx,C.Found{Geometry.Cell{position,_}}): eligible(~S,~H,~ops,U32.is_le(goal,position),damage,ctx)
    case (ctx,_): (ctx,(T.Failure{DamageMissingPosition{}},Geometry.Cell{0,0}))
def positioned(~S: Data,~H: Type,~ops: DamageOps<S,H>,args: DamageArgs,observed: H & C.Access<Geometry.Cell>) -> H & (T.Outcome<DamageError> & Geometry.Cell):
  match args:
    case DamageArgs{goal,damage}: positioned_result(~S,~H,~ops,goal,damage,observed)
def body(~S: Data,~H: Type,~ops: DamageOps<S,H>,args: DamageArgs,ctx: H) -> H & (T.Outcome<DamageError> & Geometry.Cell):
  positioned(~S,~H,~ops,args,Cap.read(~H,~Geometry.Cell,~position_cap(~S,~H,ops),ctx))
