import Base
import ./fixture.bend as F
import ./resource.bend as R
import ../../public-captures/ordinary-owner-v1/payload.bend as P
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/ordinary-app-local-fields.bend as Ord
import ../../../src/ecs/captured-schedule-composition.bend as Comp
import ../../../src/ecs/captured-schedule.bend as Run
import ../../../src/ecs/captured-schedule-query.bend as QLeaf
import ../../../src/ecs/captured-schedule-local.bend as RLeaf
import ../../../src/ecs/schedule.bend as Sch
import ../../../src/ecs/schedule-provision.bend as SP
def Owners(~S:Data) -> Type:
  QLeaf.Leaf<S,Col.Column<S,U32>,U32,Unit,P.Pack,F.Ops,F.Args,F.Error,U32,F.query(~S),F.body> & RLeaf.Leaf<S,Col.Column<S,U32>,U32,Unit,Array<U32>,R.Args,R.Error,Unit,Ord.runner(~S,~Col.Column<S,U32>,~U32,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~R.Ops,~R.declaration(~S),~R.body)>
def catalog(~S:Data,owners:Owners(~S)) -> Owners(~S) & List<&2,Comp.Identity>:
  Comp.pair_catalog(~QLeaf.Leaf<S,Col.Column<S,U32>,U32,Unit,P.Pack,F.Ops,F.Args,F.Error,U32,F.query(~S),F.body>,~RLeaf.Leaf<S,Col.Column<S,U32>,U32,Unit,Array<U32>,R.Args,R.Error,Unit,Ord.runner(~S,~Col.Column<S,U32>,~U32,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~R.Ops,~R.declaration(~S),~R.body)>,~QLeaf.catalog(~S,~Col.Column<S,U32>,~U32,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body),~RLeaf.catalog(~S,~Col.Column<S,U32>,~U32,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~Ord.runner(~S,~Col.Column<S,U32>,~U32,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~R.Ops,~R.declaration(~S),~R.body)),owners)
def dispatch(~S:Data,owners:Owners(~S),world:W.World<S,Col.Column<S,U32>,U32,Unit>,id:U32) -> Comp.Outcome<W.World<S,Col.Column<S,U32>,U32,Unit>,Owners(~S),Comp.Choice<Q.Error<F.Error>,R.Error>>:
  Comp.pair_dispatch(~W.World<S,Col.Column<S,U32>,U32,Unit>,~QLeaf.Leaf<S,Col.Column<S,U32>,U32,Unit,P.Pack,F.Ops,F.Args,F.Error,U32,F.query(~S),F.body>,~RLeaf.Leaf<S,Col.Column<S,U32>,U32,Unit,Array<U32>,R.Args,R.Error,Unit,Ord.runner(~S,~Col.Column<S,U32>,~U32,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~R.Ops,~R.declaration(~S),~R.body)>,~Q.Error<F.Error>,~R.Error,~QLeaf.catalog(~S,~Col.Column<S,U32>,~U32,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body),~QLeaf.dispatch(~S,~Col.Column<S,U32>,~U32,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body),~RLeaf.dispatch(~S,~Col.Column<S,U32>,~U32,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~Ord.runner(~S,~Col.Column<S,U32>,~U32,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~R.Ops,~R.declaration(~S),~R.body)),owners,world,id)
def Schedule(~S:Data) -> Type:
  Run.Owned<S,Col.Column<S,U32>,U32,Unit,Owners(~S),Comp.Choice<Q.Error<F.Error>,R.Error>,catalog(~S),dispatch(~S)>
def plan(~S:Data) -> SP.Plan<S>:
  SP.Sequence{SP.Entry{Sch.Phase{"outer"},[]},SP.Sequence{SP.Sequence{SP.Entry{Sch.System{1,0},[SP.Component{1}]},SP.Entry{Sch.Phase{"inner"},[]}},SP.Sequence{SP.Entry{Sch.System{2,0},[SP.Resource{2}]},SP.Entry{Sch.Barrier{},[]}}}}
def bind(~S:Data,query:F.Owned(S),resource:R.Instance(S),qargs:F.Args,rargs:R.Args,enabled:Bool) -> Schedule(~S):
  Run.compose(~S,~Col.Column<S,U32>,~U32,~Unit,~Owners(~S),~Comp.Choice<Q.Error<F.Error>,R.Error>,~catalog(~S),~dispatch(~S),"nested-captures",plan(~S),(QLeaf.bind(~S,~Col.Column<S,U32>,~U32,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body,query,qargs,True{}),RLeaf.bind(~S,~Col.Column<S,U32>,~U32,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~Ord.runner(~S,~Col.Column<S,U32>,~U32,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~R.Ops,~R.declaration(~S),~R.body),resource,rargs,enabled)))
def provision(~S:Data,world:W.World<S,Col.Column<S,U32>,U32,Unit>) -> W.World<S,Col.Column<S,U32>,U32,Unit> & List<&2,SP.Requirement<S>>:
  (world,[SP.Component{1},SP.Resource{2}])
def run(~S:Data,schedule:Schedule(~S),world:W.World<S,Col.Column<S,U32>,U32,Unit>) -> Run.Run<W.World<S,Col.Column<S,U32>,U32,Unit>,Schedule(~S),S,Comp.Choice<Q.Error<F.Error>,R.Error>>:
  Run.run(~S,~Col.Column<S,U32>,~U32,~Unit,~Owners(~S),~Comp.Choice<Q.Error<F.Error>,R.Error>,~catalog(~S),~dispatch(~S),~provision(~S),schedule,world)
def update(~S:Data,schedule:Schedule(~S),qargs:F.Args,rargs:R.Args,enabled:Bool) -> Schedule(~S):
  match schedule:
    case Run.Owned{name,plan,(QLeaf.Leaf{query,_,_},RLeaf.Leaf{resource,_,_})}:Run.Owned{name,plan,(QLeaf.bind(~S,~Col.Column<S,U32>,~U32,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body,query,qargs,True{}),RLeaf.bind(~S,~Col.Column<S,U32>,~U32,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~Ord.runner(~S,~Col.Column<S,U32>,~U32,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~R.Ops,~R.declaration(~S),~R.body),resource,rargs,enabled))}
