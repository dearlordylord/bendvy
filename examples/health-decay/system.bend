import Base
import components.bend as D
import schema.bend as S
import ../../src/ecs/column.bend as Col
import ../../src/ecs/component.bend as C
import ../../src/ecs/compose.bend as Q
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/transaction.bend as T

type Error is Data: MissingComponent{}
type Ops<-H: Type> is Type:
  Ops{health: Cap.Write<H,D.Health,D.Health>,decay: Cap.Read<H,D.HealthDecay>}
def OpsType(H: Type) -> Type: Ops<H>
def health_cap(~H: Type,ops: Ops<H>) -> Cap.Write<H,D.Health,D.Health>:
  match ops:
    case Ops{health,_}: health
def decay_cap(~H: Type,ops: Ops<H>) -> Cap.Read<H,D.HealthDecay>:
  match ops:
    case Ops{_,decay}: decay

def write_health(~H: Type,~ops: Ops<H>,factor: F32,result: H & C.Access<D.Health>) -> H & (T.Outcome<Error> & D.Health):
  match result:
    case (ctx,C.Found{D.Health{value}}):
      +next : D.Health = D.Health{(value * factor : F32)}
      (Cap.set(~H,~D.Health,~D.Health,~health_cap(~H,ops),ctx,next),(T.Success{},next))
    case (ctx,_): (ctx,(T.Failure{MissingComponent{}},D.Health{0.0}))
def read_decay(~H: Type,~ops: Ops<H>,result: H & C.Access<D.HealthDecay>) -> H & (T.Outcome<Error> & D.Health):
  match result:
    case (ctx,C.Found{D.HealthDecay{factor}}): write_health(~H,~ops,factor,Cap.get(~H,~D.Health,~D.Health,~health_cap(~H,ops),ctx))
    case (ctx,_): (ctx,(T.Failure{MissingComponent{}},D.Health{0.0}))
# Executed once per entity selected by the query below.
def apply_decay(~H: Type,~ops: Ops<H>,_: Unit,ctx: H) -> H & (T.Outcome<Error> & D.Health):
  read_decay(~H,~ops,Cap.read(~H,~D.HealthDecay,~decay_cap(~H,ops),ctx))
def Frame() -> Type: Q.Frame<S.Schema,S.Store,Unit,Unit>

def select_decay(result: Frame() & Bool) -> Frame() & Bool:
  match result:
    case (frame,False{}): (frame,False{})
    case (frame,True{}): Q.family_match(~S.Schema,~S.Store,~Unit,~Unit,~Col.Column<S.Schema,D.Health>,~D.HealthDecay,~D.HealthDecay,~S.HealthDecayToken,~S.take_decay,~S.put_decay,~S.project_decay,~S.decay_family(),~Q.Required{},frame)
def selected(frame: Frame()) -> Frame() & Bool:
  select_decay(Q.family_match(~S.Schema,~S.Store,~Unit,~Unit,~Col.Column<S.Schema,D.HealthDecay>,~D.Health,~D.Health,~S.HealthToken,~S.take_health,~S.put_health,~S.project_health,~S.health_family(),~Q.Required{},frame))
# Query: write Health, read HealthDecay; require both components.
def plan() -> Q.Plan<S.Schema,S.Store,Unit,Unit,OpsType>:
  Q.Plan{Ops{Q.write_family(~S.Schema,~S.Store,~Unit,~Unit,~Col.Column<S.Schema,D.HealthDecay>,~D.Health,~D.Health,~S.HealthToken,~S.take_health,~S.put_health,~S.project_health,~S.health_family()),Q.read_family(~S.Schema,~S.Store,~Unit,~Unit,~Col.Column<S.Schema,D.Health>,~D.HealthDecay,~D.HealthDecay,~S.HealthDecayToken,~S.take_decay,~S.put_decay,~S.project_decay,~S.decay_family())},selected}
def tick(world: S.World()) -> Q.Executed<S.World(),Q.Error<Error>,D.Health>:
  Q.each(~S.Schema,~S.Store,~Unit,~Unit,~OpsType,~Unit,~Error,~D.Health,~plan(),~apply_decay,Unit{},world)
