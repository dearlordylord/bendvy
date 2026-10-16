import Base
import ../scenario.bend as B
import ../state.bend as St
import ../fixture.bend as F
import ../resource.bend as R
import ../wiring.bend as Bind
import ../conditions.bend as Cnd
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/column.bend as Col
import ../../../../../src/ecs/compose.bend as Q
import ../../../../../src/ecs/local.bend as Local
import ../../../../../src/ecs/system.bend as Sys
import ../../../../../src/ecs/registration.bend as Reg
import ../../../../../src/ecs/ordinary-capture-query.bend as O
import ../../../../../src/ecs/ordinary-app-local-fields.bend as Ord
import ../../../../../src/ecs/captured-schedule.bend as Run
import ../../../../../src/ecs/captured-schedule-condition.bend as Guarded
import ../../../../../src/ecs/captured-schedule-composition.bend as Comp
import ../../../../../src/ecs/ordinary-condition-composition.bend as Cond
import ../../../../../src/ecs/ordinary-machine-condition.bend as Changed
import ../../../../../src/ecs/schedule.bend as Sch
import ../../../../../src/ecs/schedule-provision.bend as SP
import ../../../../public-captures/ordinary-owner-v1/payload.bend as P
# Trusted availability hook reports the condition's declared provisioning token absent.
# The actual typed resource owner remains present and fully observed.
def missing_provision(~S:Data,world:W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>) -> W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit> & List<&2,SP.Requirement<S>>:
  (world,[SP.Component{1},SP.Resource{2}])
def missing(~S:Data,state:B.State<S>) -> B.State<S>:
  match state:
    case B.State{world,foreign,schedule,text}:B.returned(~S,"missing-condition-token",foreign,text,Guarded.run(~S,~Col.Column<S,U32>,~St.Resources<S>,~Unit,~Bind.Owners(~S),~Cnd.Owners(~S),~Comp.Choice<Q.Error<F.Error>,R.Error>,~Bind.catalog(~S),~Bind.dispatch(~S),~Cnd.select(~S),~missing_provision(~S),schedule,world))
def wrong_plan(~S:Data,id:U32) -> SP.Plan<S>:
  SP.Sequence{SP.Entry{Sch.Phase{"must-not-enter"},[]},SP.Sequence{Bind.plan(~S),SP.Entry{Sch.System{id,0},[]}}}
def selected_condition(~S:Data,state:B.State<S>) -> B.State<S>:
  match state:
    case B.State{world,foreign,Guarded.Owned{name,_,owners,Cond.Bindings{(Cond.BoundOwner{a,Changed.Instance{Sys.Registry{ns,+id,n,access,cursor},revision}},other),facts}},text}:
      B.snapshot(~S,"condition-id-plan",B.State{world,foreign,Guarded.Owned{name,wrong_plan(~S,id),owners,Cond.Bindings{(Cond.BoundOwner{a,Changed.Instance{Sys.Registry{ns,id,n,access,cursor},revision}},other),facts}},text})
def restored(~S:Data,state:B.State<S>) -> B.State<S>:
  match state:
    case B.State{world,foreign,Guarded.Owned{name,_,owners,conditions},text}:B.snapshot(~S,"restore-plan",B.State{world,foreign,Guarded.Owned{name,Bind.plan(~S),owners,conditions},text})
def removed(~S:Data,foreign:W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,schedule:Bind.Schedule(~S),text:String,result:W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit> & Bool) -> B.State<S>:
  match result:
    case (world,removed):B.snapshot(~S,"remove-condition-registration:" ++ Bool.show(removed),B.State{world,foreign,schedule,text})
# Administrative removal uses exact genuine registration metadata, retaining the
# original condition owner to test stale-registration refusal without copying it.
def stale(~S:Data,state:B.State<S>) -> B.State<S>:
  match state:
    case B.State{world,foreign,Guarded.Owned{name,plan,owners,Cond.Bindings{(Cond.BoundOwner{a,Changed.Instance{Sys.Registry{+ns,+id,+n,+access,cursor},revision}},other),facts}},text}:
      removed(~S,foreign,Guarded.Owned{name,plan,owners,Cond.Bindings{(Cond.BoundOwner{a,Changed.Instance{Sys.Registry{ns,id,n,access,cursor},revision}},other),facts}},text,Reg.remove(~S,~Col.Column<S,U32>,~St.Resources<S>,~Unit,world,ns,id,n,access))
def sequence(~S:Data,state:B.State<S>) -> String:
  B.finish(~S,B.run(~S,"stale-condition-refused",F.Args{1,0},R.Args{1,False{}},True{},stale(~S,B.run(~S,"admitted",F.Args{1,0},R.Args{1,False{}},True{},restored(~S,B.run(~S,"condition-id-refused",F.Args{1,0},R.Args{1,False{}},True{},selected_condition(~S,missing(~S,B.insert(~S,1,B.run(~S,"missing-mode-false",F.Args{1,0},R.Args{1,False{}},True{},B.snapshot(~S,"registered-missing-mode",state)))))))))))
def condition_defined(~S:Data,foreign:W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,query:F.Owned(S),resource:R.Instance(~S),result:Changed.Definition<S,St.Mode,U32,Col.Column<S,U32>,St.Resources<S>,Unit,St.take(~S),St.put(~S)>) -> String:
  match result:
    case Changed.Defined{world,condition}:sequence(~S,B.State{world,foreign,Bind.bind(~S,query,resource,condition),""})
    case _:"BUG:condition-registration"
def resource_defined(~S:Data,foreign:W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,query:F.Owned(S),result:Local.Registered<S,Col.Column<S,U32>,St.Resources<S>,Unit,Array<U32>,R.Args,R.Error,Unit,Ord.runner(~S,~Col.Column<S,U32>,~St.Resources<S>,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~R.Ops(~S),~R.declaration(~S),~R.body(~S))>) -> String:
  match result:
    case Local.Registered{world,resource}:condition_defined(~S,foreign,query,resource,Cnd.define(~S,world))
    case _:"BUG:resource-registration"
def query_defined(~S:Data,foreign:W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,result:O.Registration<W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,F.Owned(S),P.Pack>) -> String:
  match result:
    case O.Registered{world,query}:resource_defined(~S,foreign,query,R.define(~S,world))
    case _:"BUG:query-registration"
def start(~S:Data,world:W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,foreign:W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>) -> String:
  query_defined(~S,foreign,F.define(~S,F.populate(~S,F.populate(~S,F.spawn(~S,F.spawn(~S,F.spawn(~S,world))),1,10),2,20)))
