import Base
import ./conditions.bend as Cnd
import ../../../../src/ecs/captured-schedule-condition.bend as Guarded
import ../../../../src/ecs/ordinary-condition-composition.bend as Cond
import ../../../../src/ecs/ordinary-machine-condition.bend as Changed
import ./state.bend as St
import ./fixture.bend as F
import ../../../public-captures/ordinary-owner-v1/payload.bend as P
import ../../../../src/ecs/ordinary-app-local-fields.bend as Ord
import ./resource.bend as R
import ./wiring.bend as Bind
import ./observe.bend as Obs
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
  State{world:W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,foreign:W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,schedule:Bind.Schedule(~S),text:String}
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
def body_error(value:Comp.Choice<Q.Error<F.Error>,R.Error>) -> String:
  match value:
    case Comp.LeftError{Q.UserError{F.FailedAt{v}}}:"query:" ++ U32.show(v)
    case Comp.LeftError{Q.UserError{F.Missing{}}}:"query:Missing"
    case Comp.LeftError{Q.AccessError{W.MissingEntity{}}}:"query:MissingEntity"
    case Comp.LeftError{Q.AccessError{W.CapacityExceeded{}}}:"query:CapacityExceeded"
    case Comp.LeftError{Q.AccessError{W.NamespaceExhausted{}}}:"query:NamespaceExhausted"
    case Comp.LeftError{Q.AccessError{W.SystemIdExhausted{}}}:"query:SystemIdExhausted"
    case Comp.RightError{R.Failed{}}:"resource:Failed"
def error(value:Cond.Error<Comp.Choice<Q.Error<F.Error>,R.Error>>) -> String:
  match value:
    case Cond.SystemError{err}:body_error(err)
    case Cond.ConditionUnavailable{}:"condition:unavailable"
    case Cond.ConditionRegistrationRejected{}:"condition:registration-rejected"
def observed(~S:Data,label:String,old:String,+name:String,+steps:SP.Plan<S>,+qargs:F.Args,+qa:Bool,+rargs:R.Args,+ra:Bool,w:W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit> & String,f:W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit> & String,q:F.Owned(S) & String,r:R.Instance(~S) & String,c:Cnd.Bindings(~S) & String) -> State<S>:
  match qargs rargs w f q r c:
    case F.Args{qd,qf}, R.Args{rd,rf}, (world,wt), (foreign,ft), (query,qt), (resource,rt), (conditions,conditionText):State{world,foreign,Guarded.Owned{name,steps,(QLeaf.Leaf{query,qargs,qa},RLeaf.Leaf{resource,rargs,ra}),conditions},old ++ label ++ "|" ++ name ++ ":" ++ plan(~S,steps) ++ "|args=" ++ U32.show(qd) ++ ":" ++ U32.show(qf) ++ ":" ++ Bool.show(qa) ++ "," ++ U32.show(rd) ++ ":" ++ Bool.show(rf) ++ ":" ++ Bool.show(ra) ++ "|" ++ wt ++ "|" ++ ft ++ "|" ++ qt ++ "|" ++ rt ++ "|conditions=" ++ conditionText ++ "\n"}
def snapshot(~S:Data,label:String,state:State<S>) -> State<S>:
  match state:
    case State{world,foreign,Guarded.Owned{+name,+steps,(QLeaf.Leaf{query,+qargs,+qa},RLeaf.Leaf{resource,+rargs,+ra}),conditions},text}:observed(~S,label,text,name,steps,qargs,qa,rargs,ra,Obs.world(~S,world),Obs.world(~S,foreign),Obs.owner(~S,query),Obs.resource_owner(~S,resource),Cnd.observed(~S,conditions))
def returned(~S:Data,label:String,foreign:W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,text:String,result:Run.Run<W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,Bind.Schedule(~S),S,Cond.Error<Comp.Choice<Q.Error<F.Error>,R.Error>>>) -> State<S>:
  match result:
    case Run.Finished{world,schedule,logs}:snapshot(~S,label ++ ":success:" ++ List.show(~&2,~Sch.Observation,~observation,logs),State{world,foreign,schedule,text})
    case Run.Failed{world,schedule,err,logs}:snapshot(~S,label ++ ":failure:" ++ error(err) ++ ":" ++ List.show(~&2,~Sch.Observation,~observation,logs),State{world,foreign,schedule,text})
    case Run.Refused{world,schedule,logs}:snapshot(~S,label ++ ":refused:" ++ List.show(~&2,~Sch.Observation,~observation,logs),State{world,foreign,schedule,text})
    case Run.Missing{world,schedule,missing}:snapshot(~S,label ++ ":missing:" ++ List.show(~&2,~SP.Requirement<S>,~requirement(~S),missing),State{world,foreign,schedule,text})
def run(~S:Data,label:String,qargs:F.Args,rargs:R.Args,enabled:Bool,state:State<S>) -> State<S>:
  match state:
    case State{world,foreign,schedule,text}:returned(~S,label,foreign,text,Bind.run(~S,Bind.update(~S,schedule,qargs,rargs,enabled),world))
def foreign_returned(~S:Data,world:W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,text:String,result:Run.Run<W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,Bind.Schedule(~S),S,Cond.Error<Comp.Choice<Q.Error<F.Error>,R.Error>>>) -> State<S>:
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
def insert(~S:Data,+value:U32,state:State<S>) -> State<S>:
  match state:
    case State{world,foreign,schedule,text}:snapshot(~S,"insert-state:" ++ U32.show(value),State{St.insert(~S,world,value),foreign,schedule,text})
def sequence(~S:Data,state:State<S>) -> String:
  finish(~S,foreign_run(~S,run(~S,"retry",F.Args{1,0},R.Args{3,False{}},True{},run(~S,"resource-failure",F.Args{1,0},R.Args{2,True{}},True{},run(~S,"state-changed",F.Args{1,0},R.Args{1,False{}},True{},insert(~S,2,run(~S,"unchanged-skip",F.Args{1,0},R.Args{1,False{}},True{},run(~S,"first",F.Args{1,0},R.Args{10,False{}},True{},snapshot(~S,"registered",state)))))))))
def condition_defined(~S:Data,foreign:W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,query:F.Owned(S),resource:R.Instance(~S),result:Changed.Definition<S,St.Mode,U32,Col.Column<S,U32>,St.Resources<S>,Unit,St.take(~S),St.put(~S)>) -> String:
  match result:
    case Changed.Defined{world,condition}:sequence(~S,State{world,foreign,Bind.bind(~S,query,resource,condition),""})
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
  query_defined(~S,foreign,F.define(~S,St.insert(~S,F.populate(~S,F.populate(~S,F.spawn(~S,F.spawn(~S,F.spawn(~S,world))),1,10),2,20),1)))
