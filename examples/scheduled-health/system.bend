import Base
import ../../src/ecs/change-tick.bend as Tick
import components.bend as D
import schema.bend as S
import ../../src/ecs/column.bend as Col
import ../../src/ecs/component.bend as C
import ../../src/ecs/compose.bend as Q
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/transaction.bend as T
import ../../src/ecs/ordinary-query-declaration.bend as Decl
import ../../src/ecs/ordinary-declaration.bend as Identity
import ../../src/ecs/ordinary-system.bend as Ordinary
import ../../src/ecs/system.bend as Registry

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


def HealthId() -> Identity.Declaration<S.Schema,D.Health>:Identity.component(~S.Schema,~D.Health,"health")
def DecayId() -> Identity.Declaration<S.Schema,D.HealthDecay>:Identity.component(~S.Schema,~D.HealthDecay,"decay")
def PairOps(H:Type) -> Type:Cap.Write<H,D.Health,D.Health> & Cap.Read<H,D.HealthDecay>
def Frame() -> Type:Q.Frame<S.Schema,S.Store,Unit,Unit>
def declaration() -> Decl.Declaration<S.Schema,Frame(),PairOps(Frame())>:
  Decl.pair(~S.Schema,~Frame(),~Cap.Write<Frame(),D.Health,D.Health>,~Cap.Read<Frame(),D.HealthDecay>,~Decl.write(~S.Schema,~D.Health,~S.Store,~Unit,~Unit,~Col.Column<S.Schema,D.HealthDecay>,~D.Health,~S.HealthToken,~HealthId(),~S.project_health,~S.take_health,~S.put_health),~Decl.read(~S.Schema,~D.HealthDecay,~S.Store,~Unit,~Unit,~Col.Column<S.Schema,D.Health>,~D.HealthDecay,~S.HealthDecayToken,~DecayId(),~S.project_decay,~S.take_decay,~S.put_decay))
def adapted(~H:Type,ops:PairOps(H)) -> Ops<H>:
  match ops:
    case (health,decay):Ops{health,decay}
def decay_body(~H:Type,~ops:PairOps(H),args:Unit,ctx:H) -> H & (T.Outcome<Error> & D.Health):
  apply_decay(~H,~adapted(~H,ops),args,ctx)
def Runner() -> S.World() -> (Unit & Maybe<&2,Tick.Tick>) -> Registry.Outcome<S.World(),Q.Error<Error>,List<&2,D.Health>>:
  Ordinary.runner(~S.Schema,~S.Store,~Unit,~Unit,~PairOps,~Unit,~Error,~D.Health,~declaration(),~decay_body)
def Owner() -> Type:
  Ordinary.Owner<S.Schema,Registry.Registry<S.Schema,S.Store,Unit,Unit,Unit & Maybe<&2,Tick.Tick>,Q.Error<Error>,List<&2,D.Health>,Runner()>>
def define(world:S.World()) -> Ordinary.Defined<S.Schema,S.World(),Registry.Registry<S.Schema,S.Store,Unit,Unit,Unit & Maybe<&2,Tick.Tick>,Q.Error<Error>,List<&2,D.Health>,Runner()>>:
  Ordinary.define(~S.Schema,~S.Store,~Unit,~Unit,~PairOps,~Unit,~Error,~D.Health,~declaration(),~decay_body,world,"Health decay","decay")
def tick(owner:Owner(),world:S.World()) -> Registry.RunResult<S.Schema,S.Store,Unit,Unit,Unit & Maybe<&2,Tick.Tick>,Q.Error<Error>,List<&2,D.Health>,Runner()> & (String & List<&2,Decl.Clause<S.Schema>>):
  Ordinary.run(~S.Schema,~S.Store,~Unit,~Unit,~PairOps,~Unit,~Error,~D.Health,~declaration(),~decay_body,owner,world,Unit{})
