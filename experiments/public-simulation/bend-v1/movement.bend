import Base
import ./events.bend as Events
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import ./geometry.bend as Geometry
import ./storage.bend as Storage
import ./schema.bend as Schema
import ./step.bend as Step
import ./movement-transaction.bend as MovementTransaction

type MovementError is Data: MovementMissingPosition{} MovementMissingVelocity{}
type MovementOps<-H: Type> is Type:
  MovementOps{position: Cap.Write<H,Array<U32>,Geometry.Cell>,velocity: Cap.Read<H,Geometry.Cell>}
def Ops(H: Type) -> Type: MovementOps<H>
def position_cap(~H: Type,ops: MovementOps<H>) -> Cap.Write<H,Array<U32>,Geometry.Cell>:
  match ops:
    case MovementOps{position,_}: position
def velocity_cap(~H: Type,ops: MovementOps<H>) -> Cap.Read<H,Geometry.Cell>:
  match ops:
    case MovementOps{_,velocity}: velocity
def moved_result(~H: Type,~ops: MovementOps<H>,fixed_step: U32,value: U32,+sentinel: U32,observed: H & C.Access<Geometry.Cell>) -> H & (T.Outcome<MovementError> & Geometry.Cell):
  match observed:
    case (ctx,C.Found{Geometry.Cell{velocity,_}}):
      +next = (value + velocity * fixed_step : U32)
      (Cap.set(~H,~Array<U32>,~Geometry.Cell,~position_cap(~H,ops),ctx,ANode{ALeaf{next},ALeaf{sentinel}}),(T.Success{},Geometry.Cell{next,sentinel}))
    case (ctx,_): (ctx,(T.Failure{MovementMissingVelocity{}},Geometry.Cell{value,sentinel}))
def moved(~H: Type,~ops: MovementOps<H>,fixed_step: U32,position: Geometry.Cell,observed: H & C.Access<Geometry.Cell>) -> H & (T.Outcome<MovementError> & Geometry.Cell):
  match position:
    case Geometry.Cell{value,sentinel}: moved_result(~H,~ops,fixed_step,value,sentinel,observed)
def positioned(~H: Type,~ops: MovementOps<H>,fixed_step: U32,observed: H & C.Access<Geometry.Cell>) -> H & (T.Outcome<MovementError> & Geometry.Cell):
  match observed:
    case (ctx,C.Found{position}): moved(~H,~ops,fixed_step,position,Cap.read(~H,~Geometry.Cell,~velocity_cap(~H,ops),ctx))
    case (ctx,_): (ctx,(T.Failure{MovementMissingPosition{}},Geometry.Cell{0,0}))
def body(~H: Type,~ops: MovementOps<H>,fixed_step: U32,ctx: H) -> H & (T.Outcome<MovementError> & Geometry.Cell):
  positioned(~H,~ops,fixed_step,Cap.get(~H,~Array<U32>,~Geometry.Cell,~position_cap(~H,ops),ctx))
def Frame(~S: Data) -> Type: Q.Frame<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>
def selected_position(~S: Data,frame: Frame(~S)) -> Frame(~S) & Bool:
  Q.family_match(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~Storage.PositionRest<S>,~Array<U32>,~Geometry.Cell,~Storage.PositionToken<S>,~Storage.take_position(~S),~Storage.put_position(~S),~Geometry.project,~Schema.position(~S),~Q.Required{},frame)
def selected_velocity(~S: Data,frame: Frame(~S)) -> Frame(~S) & Bool:
  Q.family_match(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~Storage.VelocityRest<S>,~Array<U32>,~Geometry.Cell,~Storage.VelocityToken<S>,~Storage.take_velocity(~S),~Storage.put_velocity(~S),~Geometry.project,~Schema.velocity(~S),~Q.Required{},frame)
def selected(~S: Data,frame: Frame(~S)) -> Frame(~S) & Bool:
  Q.both(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~selected_position(~S),~selected_velocity(~S),frame)
def plan(~S: Data) -> Q.Plan<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent,Ops>:
  Q.Plan{MovementOps{Q.write_family(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~Storage.PositionRest<S>,~Array<U32>,~Geometry.Cell,~Storage.PositionToken<S>,~Storage.take_position(~S),~Storage.put_position(~S),~Geometry.project,~Schema.position(~S)),Q.read_family(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~Storage.VelocityRest<S>,~Array<U32>,~Geometry.Cell,~Storage.VelocityToken<S>,~Storage.take_velocity(~S),~Storage.put_velocity(~S),~Geometry.project,~Schema.velocity(~S))},selected(~S)}
def execute(~S: Data,fixed_step: U32,world: Step.World(~S)) -> Q.Executed<Step.World(~S),Q.Error<MovementError>,Geometry.Cell>:
  MovementTransaction.execute(~S,~Ops,~U32,~MovementError,~Geometry.Cell,~plan(~S),~body,fixed_step,world)
