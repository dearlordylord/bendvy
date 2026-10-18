import Base
import ./world.bend as W
import ./schedule.bend as Sch
import ./schedule-provision.bend as SP
import ./captured-schedule-composition.bend as Comp
type Owned<-S:Data,-C:Type,-R:Type,-E:Data,H:Type,-Error:Data,-catalog:H -> H & List<&2,Comp.Identity>,-dispatch:H -> W.World<S,C,R,E> -> U32 -> Comp.Outcome<W.World<S,C,R,E>,H,Error>> is Type:
  Owned{name:String,plan:SP.Plan<S>,owners:H}
type Run<World:Type,Owner:Type,S:Data,Error:Data> is Type:
  Finished{world:World,owner:Owner,observations:List<&2,Sch.Observation>}
  Failed{world:World,owner:Owner,error:Error,observations:List<&2,Sch.Observation>}
  Refused{world:World,owner:Owner,observations:List<&2,Sch.Observation>}
  Missing{world:World,owner:Owner,requirements:List<&2,SP.Requirement<S>>}
# Conditions belong to typed leaves; only the canonical zero placeholder is
# accepted in the reused data-only plan. Arbitrary dispatcher slots are refused.
def canonical_steps(steps:List<&2,Sch.Step>) -> Bool:
  match steps:
    case []:True{}
    case Sch.System{_,slot} <> rest:Bool.and(U32.is_eq(slot,0),canonical_steps(rest))
    case _ <> rest:canonical_steps(rest)
def compose(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,~catalog:H -> H & List<&2,Comp.Identity>,~dispatch:H -> W.World<S,C,R,E> -> U32 -> Comp.Outcome<W.World<S,C,R,E>,H,Error>,name:String,plan:SP.Plan<S>,owners:H) -> Owned<S,C,R,E,H,Error,catalog,dispatch>:
  Owned{name,plan,owners}
def after(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,~catalog:H -> H & List<&2,Comp.Identity>,~dispatch:H -> W.World<S,C,R,E> -> U32 -> Comp.Outcome<W.World<S,C,R,E>,H,Error>,next:H -> W.World<S,C,R,E> -> List<&2,Sch.Observation> -> Run<W.World<S,C,R,E>,Owned<S,C,R,E,H,Error,catalog,dispatch>,S,Error>,name:String,plan:SP.Plan<S>,+id:U32,+observations:List<&2,Sch.Observation>,result:Comp.Outcome<W.World<S,C,R,E>,H,Error>) -> Run<W.World<S,C,R,E>,Owned<S,C,R,E,H,Error,catalog,dispatch>,S,Error>:
  match result:
    case Comp.Completed{world,owner}:next(owner,world,List.append(&2,Sch.Observation,observations,[Sch.Ran{id}]))
    case Comp.Skipped{world,owner}:next(owner,world,List.append(&2,Sch.Observation,observations,[Sch.Skipped{id}]))
    case Comp.Failed{world,owner,error}:Failed{world,Owned{name,plan,owner},error,List.append(&2,Sch.Observation,observations,[Sch.Ran{id}])}
    case Comp.Refused{world,owner}:Refused{world,Owned{name,plan,owner},observations}
def execute(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,~catalog:H -> H & List<&2,Comp.Identity>,~dispatch:H -> W.World<S,C,R,E> -> U32 -> Comp.Outcome<W.World<S,C,R,E>,H,Error>,steps:List<&2,Sch.Step>,owners:H,world:W.World<S,C,R,E>,+name:String,+plan:SP.Plan<S>,+observations:List<&2,Sch.Observation>) -> Run<W.World<S,C,R,E>,Owned<S,C,R,E,H,Error,catalog,dispatch>,S,Error>:
  match steps:
    case []:Finished{world,Owned{name,plan,owners},observations}
    case Sch.Phase{phase} <> rest:execute(~S,~C,~R,~E,~H,~Error,~catalog,~dispatch,rest,owners,world,name,plan,List.append(&2,Sch.Observation,observations,[Sch.Entered{phase}]))
    case Sch.Barrier{} <> rest:execute(~S,~C,~R,~E,~H,~Error,~catalog,~dispatch,rest,owners,W.barrier(~S,~C,~R,~E,world),name,plan,List.append(&2,Sch.Observation,observations,[Sch.Applied{}]))
    case Sch.System{+id,_} <> rest:after(~S,~C,~R,~E,~H,~Error,~catalog,~dispatch,h => w => logs => execute(~S,~C,~R,~E,~H,~Error,~catalog,~dispatch,rest,h,w,name,plan,logs),name,plan,id,observations,dispatch(owners,world,id))
def requirements(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,~catalog:H -> H & List<&2,Comp.Identity>,~dispatch:H -> W.World<S,C,R,E> -> U32 -> Comp.Outcome<W.World<S,C,R,E>,H,Error>,owners:H,world:W.World<S,C,R,E>,name:String,+plan:SP.Plan<S>,missing:List<&2,SP.Requirement<S>>) -> Run<W.World<S,C,R,E>,Owned<S,C,R,E,H,Error,catalog,dispatch>,S,Error>:
  match missing:
    case []:execute(~S,~C,~R,~E,~H,~Error,~catalog,~dispatch,SP.flatten(~S,plan),owners,world,name,plan,[])
    case first <> rest:Missing{world,Owned{name,plan,owners},first <> rest}
def available(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,~catalog:H -> H & List<&2,Comp.Identity>,~dispatch:H -> W.World<S,C,R,E> -> U32 -> Comp.Outcome<W.World<S,C,R,E>,H,Error>,owners:H,name:String,+plan:SP.Plan<S>,result:W.World<S,C,R,E> & List<&2,SP.Requirement<S>>) -> Run<W.World<S,C,R,E>,Owned<S,C,R,E,H,Error,catalog,dispatch>,S,Error>:
  match result:
    case (world,provided):requirements(~S,~C,~R,~E,~H,~Error,~catalog,~dispatch,owners,world,name,plan,SP.missing_requirements(~S,SP.unique(~S,SP.requirements(~S,plan)),provided))
def allowed(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,~catalog:H -> H & List<&2,Comp.Identity>,~dispatch:H -> W.World<S,C,R,E> -> U32 -> Comp.Outcome<W.World<S,C,R,E>,H,Error>,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,valid:Bool,owners:H,world:W.World<S,C,R,E>,name:String,plan:SP.Plan<S>) -> Run<W.World<S,C,R,E>,Owned<S,C,R,E,H,Error,catalog,dispatch>,S,Error>:
  match valid:
    case False{}:Refused{world,Owned{name,plan,owners},[]}
    case True{}:available(~S,~C,~R,~E,~H,~Error,~catalog,~dispatch,owners,name,plan,provision(world))
def cataloged(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,~catalog:H -> H & List<&2,Comp.Identity>,~dispatch:H -> W.World<S,C,R,E> -> U32 -> Comp.Outcome<W.World<S,C,R,E>,H,Error>,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,world:W.World<S,C,R,E>,name:String,+plan:SP.Plan<S>,observed:H & List<&2,Comp.Identity>) -> Run<W.World<S,C,R,E>,Owned<S,C,R,E,H,Error,catalog,dispatch>,S,Error>:
  match world observed:
    case W.World{+ns,allocator,store,resource,events,pending,+regs,sid,clock}, (owners,+entries):allowed(~S,~C,~R,~E,~H,~Error,~catalog,~dispatch,~provision,Bool.and(Comp.identities_valid(ns,regs,entries,[]),Bool.and(canonical_steps(SP.flatten(~S,plan)),Sch.valid(SP.flatten(~S,plan),Comp.ids(entries),[]))),owners,W.World{ns,allocator,store,resource,events,pending,regs,sid,clock},name,plan)
def run(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,~catalog:H -> H & List<&2,Comp.Identity>,~dispatch:H -> W.World<S,C,R,E> -> U32 -> Comp.Outcome<W.World<S,C,R,E>,H,Error>,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,owner:Owned<S,C,R,E,H,Error,catalog,dispatch>,world:W.World<S,C,R,E>) -> Run<W.World<S,C,R,E>,Owned<S,C,R,E,H,Error,catalog,dispatch>,S,Error>:
  match owner:
    case Owned{name,plan,owners}:cataloged(~S,~C,~R,~E,~H,~Error,~catalog,~dispatch,~provision,world,name,plan,catalog(owners))
