import Base
import ../../../../src/ecs/registration.bend as Reg
import ../fixture.bend as F
import ../../../public-captures/ordinary-owner-v1/payload.bend as P
import ../../../../src/ecs/ordinary-app-local-fields.bend as Ord
import ../resource.bend as R
import ../wiring.bend as Bind
import ../observe.bend as Obs
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/compose.bend as Q
import ../../../../src/ecs/local.bend as Local
import ../../../../src/ecs/ordinary-capture-query.bend as O
import ../../../../src/ecs/captured-schedule.bend as Run
import ../../../../src/ecs/captured-schedule-composition.bend as Comp
import ../../../../src/ecs/captured-schedule-query.bend as QLeaf
import ../../../../src/ecs/captured-schedule-local.bend as RLeaf
import ../../../../src/ecs/schedule.bend as Sch
import ../../../../src/ecs/schedule-provision.bend as SP

type State<S:Data> is Type:
  State{world:W.World<S,Col.Column<S,U32>,U32,Unit>,foreign:W.World<S,Col.Column<S,U32>,U32,Unit>,schedule:Bind.Schedule(~S),text:String}
def observation(value:Sch.Observation) -> String:
  match value:
    case Sch.Entered{name}:"phase:" ++ name
    case Sch.Ran{id}:"ran:" ++ U32.show(id)
    case Sch.Skipped{id}:"skipped:" ++ U32.show(id)
    case Sch.Applied{}:"barrier"
def step(value:Sch.Step) -> String:
  match value:
    case Sch.Phase{name}:"phase:" ++ name
    case Sch.System{id,slot}:"system:" ++ U32.show(id) ++ ":" ++ U32.show(slot)
    case Sch.Barrier{}:"barrier"
def requirement(~S:Data,value:SP.Requirement<S>) -> String:
  match value:
    case SP.Component{id}:"component:" ++ U32.show(id)
    case SP.Resource{id}:"resource:" ++ U32.show(id)
    case SP.Service{id}:"service:" ++ U32.show(id)
def plan(~S:Data,value:SP.Plan<S>) -> String:
  match value:
    case SP.Empty{}:"empty"
    case SP.Entry{value,needs}:step(value) ++ ":" ++ List.show(~&2,~SP.Requirement<S>,~requirement(~S),needs)
    case SP.Sequence{left,right}:"(" ++ plan(~S,left) ++ "," ++ plan(~S,right) ++ ")"
def error(value:Comp.Choice<Q.Error<F.Error>,R.Error>) -> String:
  match value:
    case Comp.LeftError{Q.UserError{F.FailedAt{v}}}:"query:" ++ U32.show(v)
    case Comp.LeftError{Q.UserError{F.Missing{}}}:"query:Missing"
    case Comp.LeftError{Q.AccessError{W.MissingEntity{}}}:"query:MissingEntity"
    case Comp.LeftError{Q.AccessError{W.CapacityExceeded{}}}:"query:CapacityExceeded"
    case Comp.LeftError{Q.AccessError{W.NamespaceExhausted{}}}:"query:NamespaceExhausted"
    case Comp.LeftError{Q.AccessError{W.SystemIdExhausted{}}}:"query:SystemIdExhausted"
    case Comp.RightError{R.Failed{}}:"resource:Failed"
def observed(~S:Data,label:String,old:String,+name:String,+steps:SP.Plan<S>,+qargs:F.Args,+qa:Bool,+rargs:R.Args,+ra:Bool,w:W.World<S,Col.Column<S,U32>,U32,Unit> & String,f:W.World<S,Col.Column<S,U32>,U32,Unit> & String,q:F.Owned(S) & String,r:R.Instance(S) & String) -> State<S>:
  match qargs rargs w f q r:
    case F.Args{qd,qf}, R.Args{rd,rf}, (world,wt), (foreign,ft), (query,qt), (resource,rt):State{world,foreign,Run.Owned{name,steps,(QLeaf.Leaf{query,qargs,qa},RLeaf.Leaf{resource,rargs,ra})},old ++ label ++ "|" ++ name ++ ":" ++ plan(~S,steps) ++ "|args=" ++ U32.show(qd) ++ ":" ++ U32.show(qf) ++ ":" ++ Bool.show(qa) ++ "," ++ U32.show(rd) ++ ":" ++ Bool.show(rf) ++ ":" ++ Bool.show(ra) ++ "|" ++ wt ++ "|" ++ ft ++ "|" ++ qt ++ "|" ++ rt ++ "\n"}
def snapshot(~S:Data,label:String,state:State<S>) -> State<S>:
  match state:
    case State{world,foreign,Run.Owned{+name,+steps,(QLeaf.Leaf{query,+qargs,+qa},RLeaf.Leaf{resource,+rargs,+ra})},text}:observed(~S,label,text,name,steps,qargs,qa,rargs,ra,Obs.world(~S,world),Obs.world(~S,foreign),Obs.owner(~S,query),Obs.resource_owner(~S,resource))
def returned(~S:Data,label:String,foreign:W.World<S,Col.Column<S,U32>,U32,Unit>,text:String,result:Run.Run<W.World<S,Col.Column<S,U32>,U32,Unit>,Bind.Schedule(~S),S,Comp.Choice<Q.Error<F.Error>,R.Error>>) -> State<S>:
  match result:
    case Run.Finished{world,schedule,logs}:snapshot(~S,label ++ ":success:" ++ List.show(~&2,~Sch.Observation,~observation,logs),State{world,foreign,schedule,text})
    case Run.Failed{world,schedule,err,logs}:snapshot(~S,label ++ ":failure:" ++ error(err) ++ ":" ++ List.show(~&2,~Sch.Observation,~observation,logs),State{world,foreign,schedule,text})
    case Run.Refused{world,schedule,logs}:snapshot(~S,label ++ ":refused:" ++ List.show(~&2,~Sch.Observation,~observation,logs),State{world,foreign,schedule,text})
    case Run.Missing{world,schedule,missing}:snapshot(~S,label ++ ":missing:" ++ List.show(~&2,~SP.Requirement<S>,~requirement(~S),missing),State{world,foreign,schedule,text})
def run(~S:Data,label:String,qargs:F.Args,rargs:R.Args,enabled:Bool,state:State<S>) -> State<S>:
  match state:
    case State{world,foreign,schedule,text}:returned(~S,label,foreign,text,Bind.run(~S,Bind.update(~S,schedule,qargs,rargs,enabled),world))
def foreign_returned(~S:Data,world:W.World<S,Col.Column<S,U32>,U32,Unit>,text:String,result:Run.Run<W.World<S,Col.Column<S,U32>,U32,Unit>,Bind.Schedule(~S),S,Comp.Choice<Q.Error<F.Error>,R.Error>>) -> State<S>:
  match result:
    case Run.Refused{foreign,schedule,logs}:snapshot(~S,"foreign:refused:" ++ List.show(~&2,~Sch.Observation,~observation,logs),State{world,foreign,schedule,text})
    case Run.Finished{foreign,schedule,logs}:snapshot(~S,"BUG:foreign-success",State{world,foreign,schedule,text})
    case Run.Failed{foreign,schedule,_,_}:snapshot(~S,"BUG:foreign-failed",State{world,foreign,schedule,text})
    case Run.Missing{foreign,schedule,_}:snapshot(~S,"BUG:foreign-missing",State{world,foreign,schedule,text})
def foreign_run(~S:Data,state:State<S>) -> State<S>:
  match state:
    case State{world,foreign,schedule,text}:foreign_returned(~S,world,text,Bind.run(~S,schedule,foreign))
def finish(~S:Data,state:State<S>) -> String:
  match state:
    case State{_,_,_,text}:text
def replan(~S:Data,newplan:SP.Plan<S>,state:State<S>) -> State<S>:
  match state:
    case State{world,foreign,Run.Owned{name,_,owners},text}:State{world,foreign,Run.Owned{name,newplan,owners},text}
def selected(~S:Data,+label:String,newplan:SP.Plan<S>,state:State<S>) -> State<S>:
  run(~S,label,F.Args{1,0},R.Args{10,False{}},False{},snapshot(~S,label ++ ":before",replan(~S,newplan,state)))
def prefix(~S:Data,tail:SP.Plan<S>) -> SP.Plan<S>:
  SP.Sequence{SP.Entry{Sch.Phase{"must-not-enter"},[]},SP.Sequence{SP.Entry{Sch.Barrier{},[]},tail}}
def stale_returned(~S:Data,foreign:W.World<S,Col.Column<S,U32>,U32,Unit>,schedule:Bind.Schedule(~S),text:String,observed:W.World<S,Col.Column<S,U32>,U32,Unit> & Bool) -> State<S>:
  match observed:
    case (world,removed):selected(~S,"stale:" ++ Bool.show(removed),Bind.plan(~S),State{world,foreign,schedule,text})
def stale_instance(~S:Data,world:W.World<S,Col.Column<S,U32>,U32,Unit>,foreign:W.World<S,Col.Column<S,U32>,U32,Unit>,name:String,plan:SP.Plan<S>,query:F.Owned(S),qargs:F.Args,qa:Bool,rargs:R.Args,ra:Bool,text:String,instance:R.Instance(S)) -> State<S>:
  match instance:
    case Local.Instance{+ns,+id,+rname,+access,pack}:stale_returned(~S,foreign,Run.Owned{name,plan,(QLeaf.Leaf{query,qargs,qa},RLeaf.Leaf{Local.Instance{ns,id,rname,access,pack},rargs,ra})},text,Reg.remove(~S,~Col.Column<S,U32>,~U32,~Unit,world,ns,id,rname,access))
def stale(~S:Data,state:State<S>) -> State<S>:
  match state:
    case State{world,foreign,Run.Owned{name,plan,(QLeaf.Leaf{query,qargs,qa},RLeaf.Leaf{resource,rargs,ra})},text}:stale_instance(~S,world,foreign,name,plan,query,qargs,qa,rargs,ra,text,resource)
def drain(~S:Data,state:State<S>) -> State<S>:
  match state:
    case State{world,foreign,schedule,text}:snapshot(~S,"terminal-drain",State{W.barrier(~S,~Col.Column<S,U32>,~U32,~Unit,world),foreign,schedule,text})
def sequence(~S:Data,state:State<S>) -> String:
  state = snapshot(~S,"registered",state)
  state = foreign_run(~S,state)
  state = selected(~S,"nested-duplicate",prefix(~S,SP.Sequence{SP.Entry{Sch.System{1,0},[]},SP.Sequence{SP.Empty{},SP.Entry{Sch.System{1,0},[]}}}),state)
  state = selected(~S,"missing-id",prefix(~S,SP.Entry{Sch.System{999,0},[]}),state)
  state = selected(~S,"nonzero-slot",prefix(~S,SP.Entry{Sch.System{1,7},[]}),state)
  state = selected(~S,"missing-unselected-requirements",prefix(~S,SP.Entry{Sch.System{2,0},[SP.Resource{99},SP.Service{99},SP.Resource{99}]}),state)
  state = selected(~S,"empty",SP.Empty{},state)
  finish(~S,drain(~S,stale(~S,state)))
def deferred_value(value:U32) -> U32 & U32:
  +value = value
  (value,value)
def deferred_replaced(~S:Data,observed:W.World<S,Col.Column<S,U32>,U32,Unit> & U32) -> W.World<S,Col.Column<S,U32>,U32,Unit>:
  match observed:
    case (world,_):world
def deferred_read(~S:Data,observed:W.World<S,Col.Column<S,U32>,U32,Unit> & U32) -> W.World<S,Col.Column<S,U32>,U32,Unit>:
  (world,value) = observed
  deferred_replaced(~S,W.replace_resource(~S,~Col.Column<S,U32>,~U32,~Unit,world,(value + 37 : U32)))
def deferred(~S:Data,world:W.World<S,Col.Column<S,U32>,U32,Unit>) -> W.World<S,Col.Column<S,U32>,U32,Unit>:
  deferred_read(~S,W.observe_resource(~S,~Col.Column<S,U32>,~U32,~Unit,~U32,~deferred_value,world))
def foreign_resource_observed(~S:Data,world:W.World<S,Col.Column<S,U32>,U32,Unit>,schedule:Bind.Schedule(~S),qtext:String,w:W.World<S,Col.Column<S,U32>,U32,Unit> & String,r:R.Instance(S) & String) -> String:
  match w r:
    case (foreign,wt), (resource,rt):sequence(~S,State{W.enqueue(~S,~Col.Column<S,U32>,~U32,~Unit,world,deferred(~S)),foreign,schedule,"foreign-registered|" ++ wt ++ "|" ++ qtext ++ "|" ++ rt ++ "\n"})
def foreign_query_observed(~S:Data,world:W.World<S,Col.Column<S,U32>,U32,Unit>,foreign:W.World<S,Col.Column<S,U32>,U32,Unit>,schedule:Bind.Schedule(~S),resource:R.Instance(S),observed:F.Owned(S) & String) -> String:
  match observed:
    case (query,qt):foreign_resource_observed(~S,world,schedule,qt,Obs.world(~S,foreign),Obs.resource_owner(~S,resource))
def foreign_resource(~S:Data,world:W.World<S,Col.Column<S,U32>,U32,Unit>,schedule:Bind.Schedule(~S),query:F.Owned(S),result:Local.Registered<S,Col.Column<S,U32>,U32,Unit,Array<U32>,R.Args,R.Error,Unit,Ord.runner(~S,~Col.Column<S,U32>,~U32,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~R.Ops,~R.declaration(~S),~R.body)>) -> String:
  match result:
    case Local.Registered{foreign,resource}:foreign_query_observed(~S,world,foreign,schedule,resource,Obs.owner(~S,query))
    case _:"BUG:foreign-resource"
def foreign_query(~S:Data,world:W.World<S,Col.Column<S,U32>,U32,Unit>,schedule:Bind.Schedule(~S),result:O.Registration<W.World<S,Col.Column<S,U32>,U32,Unit>,F.Owned(S),P.Pack>) -> String:
  match result:
    case O.Registered{foreign,query}:foreign_resource(~S,world,schedule,query,R.define(~S,foreign))
    case _:"BUG:foreign-query"
def resource_defined(~S:Data,foreign:W.World<S,Col.Column<S,U32>,U32,Unit>,query:F.Owned(S),result:Local.Registered<S,Col.Column<S,U32>,U32,Unit,Array<U32>,R.Args,R.Error,Unit,Ord.runner(~S,~Col.Column<S,U32>,~U32,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~R.Ops,~R.declaration(~S),~R.body)>) -> String:
  match result:
    case Local.Registered{world,resource}:foreign_query(~S,world,Bind.bind(~S,query,resource,F.Args{1,0},R.Args{10,False{}},True{}),F.define(~S,foreign))
    case _:"BUG:resource-registration"
def query_defined(~S:Data,foreign:W.World<S,Col.Column<S,U32>,U32,Unit>,result:O.Registration<W.World<S,Col.Column<S,U32>,U32,Unit>,F.Owned(S),P.Pack>) -> String:
  match result:
    case O.Registered{world,query}:resource_defined(~S,foreign,query,R.define(~S,world))
    case _:"BUG:query-registration"
def start(~S:Data,world:W.World<S,Col.Column<S,U32>,U32,Unit>,foreign:W.World<S,Col.Column<S,U32>,U32,Unit>) -> String:
  query_defined(~S,foreign,F.define(~S,F.populate(~S,F.populate(~S,F.spawn(~S,F.spawn(~S,F.spawn(~S,world))),1,10),2,20)))
