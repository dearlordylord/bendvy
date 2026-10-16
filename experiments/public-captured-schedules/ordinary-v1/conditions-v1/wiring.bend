import Base
import ./conditions.bend as Cnd
import ../../../../src/ecs/captured-schedule-condition.bend as Guarded
import ../../../../src/ecs/ordinary-condition-composition.bend as Cond
import ./state.bend as St
import ./fixture.bend as F
import ./resource.bend as R
import ../../../public-captures/ordinary-owner-v1/payload.bend as P
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/compose.bend as Q
import ../../../../src/ecs/ordinary-app-local-fields.bend as Ord
import ../../../../src/ecs/captured-schedule-composition.bend as Comp
import ../../../../src/ecs/captured-schedule.bend as Run
import ../../../../src/ecs/captured-schedule-query.bend as QLeaf
import ../../../../src/ecs/captured-schedule-local.bend as RLeaf
import ../../../../src/ecs/schedule.bend as Sch
import ../../../../src/ecs/schedule-provision.bend as SP
def Owners(~S:Data) -> Type:
  QLeaf.Leaf<S,Col.Column<S,U32>,St.Resources<S>,Unit,P.Pack,F.Ops,F.Args,F.Error,U32,F.query(~S),F.body> & RLeaf.Leaf<S,Col.Column<S,U32>,St.Resources<S>,Unit,Array<U32>,R.Args,R.Error,Unit,Ord.runner(~S,~Col.Column<S,U32>,~St.Resources<S>,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~R.Ops(~S),~R.declaration(~S),~R.body(~S))>
def catalog(~S:Data,owners:Owners(~S)) -> Owners(~S) & List<&2,Comp.Identity>:
  Comp.pair_catalog(~QLeaf.Leaf<S,Col.Column<S,U32>,St.Resources<S>,Unit,P.Pack,F.Ops,F.Args,F.Error,U32,F.query(~S),F.body>,~RLeaf.Leaf<S,Col.Column<S,U32>,St.Resources<S>,Unit,Array<U32>,R.Args,R.Error,Unit,Ord.runner(~S,~Col.Column<S,U32>,~St.Resources<S>,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~R.Ops(~S),~R.declaration(~S),~R.body(~S))>,~QLeaf.catalog(~S,~Col.Column<S,U32>,~St.Resources<S>,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body),~RLeaf.catalog(~S,~Col.Column<S,U32>,~St.Resources<S>,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~Ord.runner(~S,~Col.Column<S,U32>,~St.Resources<S>,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~R.Ops(~S),~R.declaration(~S),~R.body(~S))),owners)
def dispatch(~S:Data,owners:Owners(~S),world:W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,id:U32) -> Comp.Outcome<W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,Owners(~S),Comp.Choice<Q.Error<F.Error>,R.Error>>:
  Comp.pair_dispatch(~W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,~QLeaf.Leaf<S,Col.Column<S,U32>,St.Resources<S>,Unit,P.Pack,F.Ops,F.Args,F.Error,U32,F.query(~S),F.body>,~RLeaf.Leaf<S,Col.Column<S,U32>,St.Resources<S>,Unit,Array<U32>,R.Args,R.Error,Unit,Ord.runner(~S,~Col.Column<S,U32>,~St.Resources<S>,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~R.Ops(~S),~R.declaration(~S),~R.body(~S))>,~Q.Error<F.Error>,~R.Error,~QLeaf.catalog(~S,~Col.Column<S,U32>,~St.Resources<S>,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body),~QLeaf.dispatch(~S,~Col.Column<S,U32>,~St.Resources<S>,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body),~RLeaf.dispatch(~S,~Col.Column<S,U32>,~St.Resources<S>,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~Ord.runner(~S,~Col.Column<S,U32>,~St.Resources<S>,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~R.Ops(~S),~R.declaration(~S),~R.body(~S))),owners,world,id)
def BaseSchedule(~S:Data) -> Type:
  Run.Owned<S,Col.Column<S,U32>,St.Resources<S>,Unit,Owners(~S),Comp.Choice<Q.Error<F.Error>,R.Error>,catalog(~S),dispatch(~S)>
def plan(~S:Data) -> SP.Plan<S>:
  SP.Sequence{SP.Entry{Sch.Phase{"outer"},[]},SP.Sequence{SP.Sequence{SP.Entry{Sch.System{1,0},[SP.Component{1},SP.Resource{3}]},SP.Entry{Sch.Phase{"inner"},[]}},SP.Sequence{SP.Entry{Sch.System{2,0},[SP.Resource{2}]},SP.Entry{Sch.Barrier{},[]}}}}
def base_bind(~S:Data,query:F.Owned(S),resource:R.Instance(~S),qargs:F.Args,rargs:R.Args,enabled:Bool) -> BaseSchedule(~S):
  Run.compose(~S,~Col.Column<S,U32>,~St.Resources<S>,~Unit,~Owners(~S),~Comp.Choice<Q.Error<F.Error>,R.Error>,~catalog(~S),~dispatch(~S),"nested-captures",plan(~S),(QLeaf.bind(~S,~Col.Column<S,U32>,~St.Resources<S>,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body,query,qargs,True{}),RLeaf.bind(~S,~Col.Column<S,U32>,~St.Resources<S>,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~Ord.runner(~S,~Col.Column<S,U32>,~St.Resources<S>,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~R.Ops(~S),~R.declaration(~S),~R.body(~S)),resource,rargs,enabled)))
def provision(~S:Data,world:W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>) -> W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit> & List<&2,SP.Requirement<S>>:
  (world,[SP.Component{1},SP.Resource{2},SP.Resource{3}])
def base_update(~S:Data,schedule:BaseSchedule(~S),qargs:F.Args,rargs:R.Args,enabled:Bool) -> BaseSchedule(~S):
  match schedule:
    case Run.Owned{name,plan,(QLeaf.Leaf{query,_,_},RLeaf.Leaf{resource,_,_})}:Run.Owned{name,plan,(QLeaf.bind(~S,~Col.Column<S,U32>,~St.Resources<S>,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body,query,qargs,True{}),RLeaf.bind(~S,~Col.Column<S,U32>,~St.Resources<S>,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~Ord.runner(~S,~Col.Column<S,U32>,~St.Resources<S>,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~R.Ops(~S),~R.declaration(~S),~R.body(~S)),resource,rargs,enabled))}
def Schedule(~S:Data) -> Type:
  Guarded.Owned<S,Col.Column<S,U32>,St.Resources<S>,Unit,Owners(~S),Cnd.Owners(~S),Comp.Choice<Q.Error<F.Error>,R.Error>,catalog(~S),dispatch(~S),Cnd.select(~S)>
def bind(~S:Data,query:F.Owned(S),resource:R.Instance(~S),condition:Cnd.Instance(~S)) -> Schedule(~S):
  Guarded.attach(~S,~Col.Column<S,U32>,~St.Resources<S>,~Unit,~Owners(~S),~Cnd.Owners(~S),~Comp.Choice<Q.Error<F.Error>,R.Error>,~catalog(~S),~dispatch(~S),~Cnd.select(~S),base_bind(~S,query,resource,F.Args{1,0},R.Args{10,False{}},True{}),Cnd.bind(~S,condition))
def run(~S:Data,schedule:Schedule(~S),world:W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>) -> Run.Run<W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,Schedule(~S),S,Cond.Error<Comp.Choice<Q.Error<F.Error>,R.Error>>>:
  Guarded.run(~S,~Col.Column<S,U32>,~St.Resources<S>,~Unit,~Owners(~S),~Cnd.Owners(~S),~Comp.Choice<Q.Error<F.Error>,R.Error>,~catalog(~S),~dispatch(~S),~Cnd.select(~S),~provision(~S),schedule,world)
def rejoin(~S:Data,conditions:Cnd.Bindings(~S),schedule:BaseSchedule(~S)) -> Schedule(~S):
  match schedule:
    case Run.Owned{name,plan,owners}:Guarded.Owned{name,plan,owners,conditions}
def update(~S:Data,schedule:Schedule(~S),qargs:F.Args,rargs:R.Args,enabled:Bool) -> Schedule(~S):
  match schedule:
    case Guarded.Owned{name,plan,owners,conditions}:rejoin(~S,conditions,base_update(~S,Run.Owned{name,plan,owners},qargs,rargs,enabled))
