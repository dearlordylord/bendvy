import Base
import ordinary-app-composer.bend as Build
import ordinary-app-records.bend as Leaf
import ordinary-app-registration-fields.bend as Records
import ordinary-app-observation-data.bend as DTO
import execution-context.bend as Ctx
import system.bend as Sys
import schedule-provision.bend as SP
import schedule.bend as Sch
import captured-schedule-composition.bend as Identity

type Recipe<S:Data,World:Type,Owners:Type,Error:Data,-plan:Owners -> Owners & SP.Plan<S>,-dispatch:Owners -> Ctx.Context<World> -> U32 -> Owners & Sys.Outcome<Ctx.Context<World>,Error,Unit>,-provide:World -> World & List<&2,SP.Requirement<S>>> is Type:
  Recipe{}
type Registered<S:Data,World:Type,Owners:Type,Rows:Data,-observe:World -> World & DTO.Observation<Rows>,-fold:Owners -> Owners & List<&2,Records.Fields<S>>,Error:Data,-plan:Owners -> Owners & SP.Plan<S>,-dispatch:Owners -> Ctx.Context<World> -> U32 -> Owners & Sys.Outcome<Ctx.Context<World>,Error,Unit>,-provide:World -> World & List<&2,SP.Requirement<S>>> is Type:
  Registered{app:Build.Registered<S,World,Owners,Rows,observe,fold>,execution:Recipe<S,World,Owners,Error,plan,dispatch,provide>}
def identities(~S:Data,fields:List<&2,Records.Fields<S>>) -> List<&2,Identity.Identity>:
  match fields:
    case []:[]
    case Records.Fields{namespace,id,name,access,_,_,_,_} <> rest:Identity.Identity{namespace,id,name,access} <> identities(~S,rest)
def registration_id(~S:Data,fields:Records.Fields<S>) -> U32:
  match fields:
    case Records.Fields{_,id,_,_,_,_,_,_}:id
def member(~S:Data,fields:List<&2,Records.Fields<S>>,id:U32) -> Bool:
  Identity.member(identities(~S,fields),id)
def empty_plan(~S:Data,owner:Unit) -> Unit & SP.Plan<S>:
  (owner,SP.Empty{})
def empty_provide(~S:Data,~World:Type,world:World) -> World & List<&2,SP.Requirement<S>>:
  (world,[])
def empty_dispatch(~World:Type,owner:Unit,world:Ctx.Context<World>,id:U32) -> Unit & Sys.Outcome<Ctx.Context<World>,Unit,Unit>:
  (owner,Sys.Failed{world,Unit{}})
def empty(~S:Data,~World:Type,world:World) -> Registered<S,World,Unit,Unit,Build.empty_observe(~World),Leaf.empty(~S),Unit,empty_plan(~S),empty_dispatch(~World),empty_provide(~S,~World)>:
  Registered{Build.empty(~S,~World,world),Recipe{}}
def plan_right(~S:Data,~L:Type,~R:Type,left:L,before:SP.Plan<S>,result:R & SP.Plan<S>) -> (L & R) & SP.Plan<S>:
  match result:
    case (right,after):((left,right),SP.Sequence{before,after})
def plan_left(~S:Data,~L:Type,~R:Type,~right:R -> R & SP.Plan<S>,owner:R,result:L & SP.Plan<S>) -> (L & R) & SP.Plan<S>:
  match result:
    case (left,before):plan_right(~S,~L,~R,left,before,right(owner))
def plan_pair(~S:Data,~L:Type,~R:Type,~left:L -> L & SP.Plan<S>,~right:R -> R & SP.Plan<S>,owners:L & R) -> (L & R) & SP.Plan<S>:
  match owners:
    case (a,b):plan_left(~S,~L,~R,~right,b,left(a))
def provision_right(~S:Data,~World:Type,before:List<&2,SP.Requirement<S>>,result:World & List<&2,SP.Requirement<S>>) -> World & List<&2,SP.Requirement<S>>:
  match result:
    case (world,after):(world,List.append(&2,SP.Requirement<S>,before,after))
def provision_left(~S:Data,~World:Type,~right:World -> World & List<&2,SP.Requirement<S>>,result:World & List<&2,SP.Requirement<S>>) -> World & List<&2,SP.Requirement<S>>:
  match result:
    case (world,before):provision_right(~S,~World,before,right(world))
def provision_pair(~S:Data,~World:Type,~left:World -> World & List<&2,SP.Requirement<S>>,~right:World -> World & List<&2,SP.Requirement<S>>,world:World) -> World & List<&2,SP.Requirement<S>>:
  provision_left(~S,~World,~right,left(world))
def left_outcome(~World:Type,~LE:Data,~RE:Data,outcome:Sys.Outcome<Ctx.Context<World>,LE,Unit>) -> Sys.Outcome<Ctx.Context<World>,Identity.Choice<LE,RE>,Unit>:
  match outcome:
    case Sys.Measured{outcome,measurement}:Sys.Measured{left_outcome(~World,~LE,~RE,outcome),measurement}
    case Sys.Succeeded{world,output}:Sys.Succeeded{world,output}
    case Sys.Failed{world,error}:Sys.Failed{world,Identity.LeftError{error}}
def right_outcome(~World:Type,~LE:Data,~RE:Data,outcome:Sys.Outcome<Ctx.Context<World>,RE,Unit>) -> Sys.Outcome<Ctx.Context<World>,Identity.Choice<LE,RE>,Unit>:
  match outcome:
    case Sys.Measured{outcome,measurement}:Sys.Measured{right_outcome(~World,~LE,~RE,outcome),measurement}
    case Sys.Succeeded{world,output}:Sys.Succeeded{world,output}
    case Sys.Failed{world,error}:Sys.Failed{world,Identity.RightError{error}}
def left_returned(~World:Type,~L:Type,~R:Type,~LE:Data,~RE:Data,right:R,result:L & Sys.Outcome<Ctx.Context<World>,LE,Unit>) -> (L & R) & Sys.Outcome<Ctx.Context<World>,Identity.Choice<LE,RE>,Unit>:
  match result:
    case (left,outcome):((left,right),left_outcome(~World,~LE,~RE,outcome))
def right_returned(~World:Type,~L:Type,~R:Type,~LE:Data,~RE:Data,left:L,result:R & Sys.Outcome<Ctx.Context<World>,RE,Unit>) -> (L & R) & Sys.Outcome<Ctx.Context<World>,Identity.Choice<LE,RE>,Unit>:
  match result:
    case (right,outcome):((left,right),right_outcome(~World,~LE,~RE,outcome))
def dispatch_selected(~World:Type,~L:Type,~R:Type,~LE:Data,~RE:Data,~left:L -> Ctx.Context<World> -> U32 -> L & Sys.Outcome<Ctx.Context<World>,LE,Unit>,~right:R -> Ctx.Context<World> -> U32 -> R & Sys.Outcome<Ctx.Context<World>,RE,Unit>,found:Bool,a:L,b:R,world:Ctx.Context<World>,id:U32) -> (L & R) & Sys.Outcome<Ctx.Context<World>,Identity.Choice<LE,RE>,Unit>:
  match found:
    case True{}:left_returned(~World,~L,~R,~LE,~RE,b,left(a,world,id))
    case False{}:right_returned(~World,~L,~R,~LE,~RE,a,right(b,world,id))
def dispatch_folded(~S:Data,~World:Type,~L:Type,~R:Type,~LE:Data,~RE:Data,~left:L -> Ctx.Context<World> -> U32 -> L & Sys.Outcome<Ctx.Context<World>,LE,Unit>,~right:R -> Ctx.Context<World> -> U32 -> R & Sys.Outcome<Ctx.Context<World>,RE,Unit>,b:R,world:Ctx.Context<World>,+id:U32,result:L & List<&2,Records.Fields<S>>) -> (L & R) & Sys.Outcome<Ctx.Context<World>,Identity.Choice<LE,RE>,Unit>:
  match result:
    case (a,fields):dispatch_selected(~World,~L,~R,~LE,~RE,~left,~right,member(~S,fields,id),a,b,world,id)
def dispatch_pair(~S:Data,~World:Type,~L:Type,~R:Type,~LE:Data,~RE:Data,~fold:L -> L & List<&2,Records.Fields<S>>,~left:L -> Ctx.Context<World> -> U32 -> L & Sys.Outcome<Ctx.Context<World>,LE,Unit>,~right:R -> Ctx.Context<World> -> U32 -> R & Sys.Outcome<Ctx.Context<World>,RE,Unit>,owners:L & R,world:Ctx.Context<World>,id:U32) -> (L & R) & Sys.Outcome<Ctx.Context<World>,Identity.Choice<LE,RE>,Unit>:
  match owners:
    case (a,b):dispatch_folded(~S,~World,~L,~R,~LE,~RE,~left,~right,b,world,id,fold(a))
type Invocation<S:Data,Token:Type,Args:Data,Out:Data> is Type:
  Invocation{record:Leaf.Record<S,Token>,args:Args,outputs:List<&2,Out>}
def invocation_fields(~S:Data,~Token:Type,~Args:Data,~Out:Data,value:Invocation<S,Token,Args,Out>) -> Invocation<S,Token,Args,Out> & List<&2,Records.Fields<S>>:
  match value:
    case Invocation{Leaf.Record{token,+fields},args,outputs}:(Invocation{Leaf.Record{token,fields},args,outputs},[fields])
def invocation_plan(~S:Data,~Token:Type,~Args:Data,~Out:Data,value:Invocation<S,Token,Args,Out>) -> Invocation<S,Token,Args,Out> & SP.Plan<S>:
  match value:
    case Invocation{Leaf.Record{token,Records.Fields{+namespace,+id,+name,+access,+cursor,+slot,+clauses,+kind}},args,outputs}:(Invocation{Leaf.Record{token,Records.Fields{namespace,id,name,access,cursor,slot,clauses,kind}},args,outputs},SP.Entry{Sch.System{id,0},[]})
