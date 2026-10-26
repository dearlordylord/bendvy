import Base
import ./world.bend as W
import ./schedule.bend as Sch
import ./schedule-provision.bend as SP
import ./captured-schedule.bend as Run
import ./captured-schedule-composition.bend as Comp
import ./ordinary-condition-composition.bend as Cond
# Registered condition identities are preflight-only, never executable step IDs.
def leaf_identities(leaves:List<&2,Cond.LeafDescription>) -> List<&2,Comp.Identity>:
  match leaves:
    case []:[]
    case Cond.StateChanged{ns,id,name,access} <> rest:Comp.Identity{ns,id,name,access} <> leaf_identities(rest)
    case _ <> rest:leaf_identities(rest)
def condition_identities(facts:List<&2,Cond.BindingDescription>) -> List<&2,Comp.Identity>:
  match facts:
    case []:[]
    case Cond.BindingDescription{_,Cond.Description{_,_,leaves}} <> rest:List.append(&2,Comp.Identity,leaf_identities(leaves),condition_identities(rest))
type Owned<-S:Data,-C:Type,-R:Type,-E:Data,H:Type,B:Type,-Error:Data,-catalog:H -> H & List<&2,Comp.Identity>,-dispatch:H -> W.World<S,C,R,E> -> U32 -> Comp.Outcome<W.World<S,C,R,E>,H,Error>,-select:B -> W.World<S,C,R,E> -> U32 -> Cond.Evaluation<W.World<S,C,R,E>,B>> is Type:
  Owned{name:String,plan:SP.Plan<S>,owners:H,conditions:Cond.Bindings<W.World<S,C,R,E>,B,select>}
def attach(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~Error:Data,~catalog:H -> H & List<&2,Comp.Identity>,~dispatch:H -> W.World<S,C,R,E> -> U32 -> Comp.Outcome<W.World<S,C,R,E>,H,Error>,~select:B -> W.World<S,C,R,E> -> U32 -> Cond.Evaluation<W.World<S,C,R,E>,B>,schedule:Run.Owned<S,C,R,E,H,Error,catalog,dispatch>,conditions:Cond.Bindings<W.World<S,C,R,E>,B,select>) -> Owned<S,C,R,E,H,B,Error,catalog,dispatch,select>:
  match schedule:
    case Run.Owned{name,plan,owners}:Owned{name,plan,owners,conditions}
def body_done(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~Error:Data,~catalog:H -> H & List<&2,Comp.Identity>,~dispatch:H -> W.World<S,C,R,E> -> U32 -> Comp.Outcome<W.World<S,C,R,E>,H,Error>,~select:B -> W.World<S,C,R,E> -> U32 -> Cond.Evaluation<W.World<S,C,R,E>,B>,next:H -> Cond.Bindings<W.World<S,C,R,E>,B,select> -> W.World<S,C,R,E> -> List<&2,Sch.Observation> -> Run.Run<W.World<S,C,R,E>,Owned<S,C,R,E,H,B,Error,catalog,dispatch,select>,S,Cond.Error<Error>>,conditions:Cond.Bindings<W.World<S,C,R,E>,B,select>,name:String,plan:SP.Plan<S>,+id:U32,+observations:List<&2,Sch.Observation>,result:Comp.Outcome<W.World<S,C,R,E>,H,Error>) -> Run.Run<W.World<S,C,R,E>,Owned<S,C,R,E,H,B,Error,catalog,dispatch,select>,S,Cond.Error<Error>>:
  match result:
    case Comp.Completed{world,owner}:next(owner,conditions,world,List.append(&2,Sch.Observation,observations,[Sch.Ran{id}]))
    case Comp.Skipped{world,owner}:next(owner,conditions,world,List.append(&2,Sch.Observation,observations,[Sch.Skipped{id}]))
    case Comp.Failed{world,owner,error}:Run.Failed{world,Owned{name,plan,owner,conditions},Cond.SystemError{error},List.append(&2,Sch.Observation,observations,[Sch.Ran{id}])}
    case Comp.Refused{world,owner}:Run.Refused{world,Owned{name,plan,owner,conditions},observations}
def decision(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~Error:Data,~catalog:H -> H & List<&2,Comp.Identity>,~dispatch:H -> W.World<S,C,R,E> -> U32 -> Comp.Outcome<W.World<S,C,R,E>,H,Error>,~select:B -> W.World<S,C,R,E> -> U32 -> Cond.Evaluation<W.World<S,C,R,E>,B>,next:H -> Cond.Bindings<W.World<S,C,R,E>,B,select> -> W.World<S,C,R,E> -> List<&2,Sch.Observation> -> Run.Run<W.World<S,C,R,E>,Owned<S,C,R,E,H,B,Error,catalog,dispatch,select>,S,Cond.Error<Error>>,allowed:Bool,owners:H,conditions:Cond.Bindings<W.World<S,C,R,E>,B,select>,world:W.World<S,C,R,E>,name:String,plan:SP.Plan<S>,+id:U32,+observations:List<&2,Sch.Observation>) -> Run.Run<W.World<S,C,R,E>,Owned<S,C,R,E,H,B,Error,catalog,dispatch,select>,S,Cond.Error<Error>>:
  match allowed:
    case False{}:next(owners,conditions,world,List.append(&2,Sch.Observation,observations,[Sch.Skipped{id}]))
    case True{}:body_done(~S,~C,~R,~E,~H,~B,~Error,~catalog,~dispatch,~select,next,conditions,name,plan,id,observations,dispatch(owners,world,id))
def condition_done(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~Error:Data,~catalog:H -> H & List<&2,Comp.Identity>,~dispatch:H -> W.World<S,C,R,E> -> U32 -> Comp.Outcome<W.World<S,C,R,E>,H,Error>,~select:B -> W.World<S,C,R,E> -> U32 -> Cond.Evaluation<W.World<S,C,R,E>,B>,next:H -> Cond.Bindings<W.World<S,C,R,E>,B,select> -> W.World<S,C,R,E> -> List<&2,Sch.Observation> -> Run.Run<W.World<S,C,R,E>,Owned<S,C,R,E,H,B,Error,catalog,dispatch,select>,S,Cond.Error<Error>>,owners:H,facts:List<&2,Cond.BindingDescription>,name:String,plan:SP.Plan<S>,id:U32,observations:List<&2,Sch.Observation>,result:Cond.Evaluation<W.World<S,C,R,E>,B>) -> Run.Run<W.World<S,C,R,E>,Owned<S,C,R,E,H,B,Error,catalog,dispatch,select>,S,Cond.Error<Error>>:
  match result:
    case Cond.Value{world,state,value}:decision(~S,~C,~R,~E,~H,~B,~Error,~catalog,~dispatch,~select,next,value,owners,Cond.Bindings{state,facts},world,name,plan,id,observations)
    case Cond.NoBinding{world,state}:decision(~S,~C,~R,~E,~H,~B,~Error,~catalog,~dispatch,~select,next,True{},owners,Cond.Bindings{state,facts},world,name,plan,id,observations)
    case Cond.NoValue{world,state}:Run.Failed{world,Owned{name,plan,owners,Cond.Bindings{state,facts}},Cond.ConditionUnavailable{},observations}
    case Cond.InvalidRegistration{world,state}:Run.Failed{world,Owned{name,plan,owners,Cond.Bindings{state,facts}},Cond.ConditionRegistrationRejected{},observations}
def condition_run(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~Error:Data,~catalog:H -> H & List<&2,Comp.Identity>,~dispatch:H -> W.World<S,C,R,E> -> U32 -> Comp.Outcome<W.World<S,C,R,E>,H,Error>,~select:B -> W.World<S,C,R,E> -> U32 -> Cond.Evaluation<W.World<S,C,R,E>,B>,next:H -> Cond.Bindings<W.World<S,C,R,E>,B,select> -> W.World<S,C,R,E> -> List<&2,Sch.Observation> -> Run.Run<W.World<S,C,R,E>,Owned<S,C,R,E,H,B,Error,catalog,dispatch,select>,S,Cond.Error<Error>>,owners:H,conditions:Cond.Bindings<W.World<S,C,R,E>,B,select>,world:W.World<S,C,R,E>,name:String,plan:SP.Plan<S>,+id:U32,observations:List<&2,Sch.Observation>) -> Run.Run<W.World<S,C,R,E>,Owned<S,C,R,E,H,B,Error,catalog,dispatch,select>,S,Cond.Error<Error>>:
  match conditions:
    case Cond.Bindings{state,facts}:condition_done(~S,~C,~R,~E,~H,~B,~Error,~catalog,~dispatch,~select,next,owners,facts,name,plan,id,observations,select(state,world,id))
def execute(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~Error:Data,~catalog:H -> H & List<&2,Comp.Identity>,~dispatch:H -> W.World<S,C,R,E> -> U32 -> Comp.Outcome<W.World<S,C,R,E>,H,Error>,~select:B -> W.World<S,C,R,E> -> U32 -> Cond.Evaluation<W.World<S,C,R,E>,B>,steps:List<&2,Sch.Step>,owners:H,conditions:Cond.Bindings<W.World<S,C,R,E>,B,select>,world:W.World<S,C,R,E>,+name:String,+plan:SP.Plan<S>,+observations:List<&2,Sch.Observation>) -> Run.Run<W.World<S,C,R,E>,Owned<S,C,R,E,H,B,Error,catalog,dispatch,select>,S,Cond.Error<Error>>:
  match steps:
    case []:Run.Finished{world,Owned{name,plan,owners,conditions},observations}
    case Sch.Phase{phase} <> rest:execute(~S,~C,~R,~E,~H,~B,~Error,~catalog,~dispatch,~select,rest,owners,conditions,world,name,plan,List.append(&2,Sch.Observation,observations,[Sch.Entered{phase}]))
    case Sch.Barrier{} <> rest:execute(~S,~C,~R,~E,~H,~B,~Error,~catalog,~dispatch,~select,rest,owners,conditions,W.barrier(~S,~C,~R,~E,world),name,plan,List.append(&2,Sch.Observation,observations,[Sch.Applied{}]))
    case Sch.System{+id,_} <> rest:condition_run(~S,~C,~R,~E,~H,~B,~Error,~catalog,~dispatch,~select,h => c => w => logs => execute(~S,~C,~R,~E,~H,~B,~Error,~catalog,~dispatch,~select,rest,h,c,w,name,plan,logs),owners,conditions,world,name,plan,id,observations)
def requirements(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~Error:Data,~catalog:H -> H & List<&2,Comp.Identity>,~dispatch:H -> W.World<S,C,R,E> -> U32 -> Comp.Outcome<W.World<S,C,R,E>,H,Error>,~select:B -> W.World<S,C,R,E> -> U32 -> Cond.Evaluation<W.World<S,C,R,E>,B>,owners:H,conditions:Cond.Bindings<W.World<S,C,R,E>,B,select>,world:W.World<S,C,R,E>,name:String,+plan:SP.Plan<S>,missing:List<&2,SP.Requirement<S>>) -> Run.Run<W.World<S,C,R,E>,Owned<S,C,R,E,H,B,Error,catalog,dispatch,select>,S,Cond.Error<Error>>:
  match missing:
    case []:execute(~S,~C,~R,~E,~H,~B,~Error,~catalog,~dispatch,~select,SP.flatten(~S,plan),owners,conditions,world,name,plan,[])
    case first <> rest:Run.Missing{world,Owned{name,plan,owners,conditions},first <> rest}
def available(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~Error:Data,~catalog:H -> H & List<&2,Comp.Identity>,~dispatch:H -> W.World<S,C,R,E> -> U32 -> Comp.Outcome<W.World<S,C,R,E>,H,Error>,~select:B -> W.World<S,C,R,E> -> U32 -> Cond.Evaluation<W.World<S,C,R,E>,B>,owners:H,conditions:Cond.Bindings<W.World<S,C,R,E>,B,select>,name:String,+plan:SP.Plan<S>,result:W.World<S,C,R,E> & List<&2,SP.Requirement<S>>) -> Run.Run<W.World<S,C,R,E>,Owned<S,C,R,E,H,B,Error,catalog,dispatch,select>,S,Cond.Error<Error>>:
  match result:
    case (world,provided):requirements(~S,~C,~R,~E,~H,~B,~Error,~catalog,~dispatch,~select,owners,conditions,world,name,plan,SP.missing_requirements(~S,SP.unique(~S,SP.requirements(~S,plan)),provided))
def allowed(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~Error:Data,~catalog:H -> H & List<&2,Comp.Identity>,~dispatch:H -> W.World<S,C,R,E> -> U32 -> Comp.Outcome<W.World<S,C,R,E>,H,Error>,~select:B -> W.World<S,C,R,E> -> U32 -> Cond.Evaluation<W.World<S,C,R,E>,B>,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,valid:Bool,owners:H,conditions:Cond.Bindings<W.World<S,C,R,E>,B,select>,world:W.World<S,C,R,E>,name:String,plan:SP.Plan<S>) -> Run.Run<W.World<S,C,R,E>,Owned<S,C,R,E,H,B,Error,catalog,dispatch,select>,S,Cond.Error<Error>>:
  match valid:
    case False{}:Run.Refused{world,Owned{name,plan,owners,conditions},[]}
    case True{}:available(~S,~C,~R,~E,~H,~B,~Error,~catalog,~dispatch,~select,owners,conditions,name,plan,provision(world))
def cataloged(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~Error:Data,~catalog:H -> H & List<&2,Comp.Identity>,~dispatch:H -> W.World<S,C,R,E> -> U32 -> Comp.Outcome<W.World<S,C,R,E>,H,Error>,~select:B -> W.World<S,C,R,E> -> U32 -> Cond.Evaluation<W.World<S,C,R,E>,B>,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,world:W.World<S,C,R,E>,name:String,+plan:SP.Plan<S>,conditions:Cond.Bindings<W.World<S,C,R,E>,B,select>,observed:H & List<&2,Comp.Identity>) -> Run.Run<W.World<S,C,R,E>,Owned<S,C,R,E,H,B,Error,catalog,dispatch,select>,S,Cond.Error<Error>>:
  match world conditions observed:
    case W.World{+ns,allocator,store,resource,events,pending,+regs,sid,clock,lifecycle}, Cond.Bindings{state,+facts}, (owners,+entries):allowed(~S,~C,~R,~E,~H,~B,~Error,~catalog,~dispatch,~select,~provision,Bool.and(Comp.identities_valid(ns,regs,entries,[]),Bool.and(Comp.identities_valid(ns,regs,condition_identities(facts),[]),Bool.and(Cond.unique_bindings(facts,[]),Bool.and(Cond.binding_targets(facts,SP.flatten(~S,plan)),Bool.and(Run.canonical_steps(SP.flatten(~S,plan)),Sch.valid(SP.flatten(~S,plan),Comp.ids(entries),[])))))),owners,Cond.Bindings{state,facts},W.World{ns,allocator,store,resource,events,pending,regs,sid,clock,lifecycle},name,plan)
def run(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~Error:Data,~catalog:H -> H & List<&2,Comp.Identity>,~dispatch:H -> W.World<S,C,R,E> -> U32 -> Comp.Outcome<W.World<S,C,R,E>,H,Error>,~select:B -> W.World<S,C,R,E> -> U32 -> Cond.Evaluation<W.World<S,C,R,E>,B>,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,owner:Owned<S,C,R,E,H,B,Error,catalog,dispatch,select>,world:W.World<S,C,R,E>) -> Run.Run<W.World<S,C,R,E>,Owned<S,C,R,E,H,B,Error,catalog,dispatch,select>,S,Cond.Error<Error>>:
  match owner:
    case Owned{name,plan,owners,conditions}:cataloged(~S,~C,~R,~E,~H,~B,~Error,~catalog,~dispatch,~select,~provision,world,name,plan,conditions,catalog(owners))
