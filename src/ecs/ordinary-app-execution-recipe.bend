import Base
import ./ordinary-app-composer.bend as Build
import ./ordinary-app-records.bend as Leaf
import ./ordinary-app-registration-fields.bend as Records
import ./ordinary-app-observation-data.bend as DTO
import ./execution-context.bend as Ctx
import ./system.bend as Sys
import ./schedule-provision.bend as SP
import ./schedule.bend as Sch
import ./captured-schedule-composition.bend as Identity

# Advanced erased execution recipe retaining plan/dispatch/provision types, not
# a second runtime owner bundle. Actual owners remain in Registered.app. Closed
# callbacks are trusted setup, not authority inferred from a Data plan or id.
type Recipe<S:Data,World:Type,Owners:Type,Error:Data,-plan:Owners -> Owners & SP.Plan<S>,-dispatch:Owners -> Ctx.Context<World> -> U32 -> Owners & Sys.Outcome<Ctx.Context<World>,Error,Unit>,-provide:World -> World & List<&2,SP.Requirement<S>>> is Type:
  Recipe{}
# Execution-enabled App pairing the actual composer App with its typed Recipe.
# World, registrations and affine Local/capture state are retained in app; this
# wrapper alone neither dispatches a system nor validates arbitrary callbacks.
type Registered<S:Data,World:Type,Owners:Type,Rows:Data,-observe:World -> World & DTO.Observation<Rows>,-fold:Owners -> Owners & List<&2,Records.Fields<S>>,Error:Data,-plan:Owners -> Owners & SP.Plan<S>,-dispatch:Owners -> Ctx.Context<World> -> U32 -> Owners & Sys.Outcome<Ctx.Context<World>,Error,Unit>,-provide:World -> World & List<&2,SP.Requirement<S>>> is Type:
  Registered{app:Build.Registered<S,World,Owners,Rows,observe,fold>,execution:Recipe<S,World,Owners,Error,plan,dispatch,provide>}
# Advanced metadata conversion retaining namespace/id/name/ordered access.
# Does not inspect payloads or turn presentation metadata into gameplay grants.
def identities(~S:Data,fields:List<&2,Records.Fields<S>>) -> List<&2,Identity.Identity>:
  match fields:
    case []:[]
    case Records.Fields{namespace,id,name,access,_,_,_,_} <> rest:Identity.Identity{namespace,id,name,access} <> identities(~S,rest)
# Extract the recorded system id without validating its World or runner owner.
def registration_id(~S:Data,fields:Records.Fields<S>) -> U32:
  match fields:
    case Records.Fields{_,id,_,_,_,_,_,_}:id
# Advanced dispatch-routing membership test by id against supplied field records.
# Not a namespace/provenance or capability check for arbitrary forged records.
def member(~S:Data,fields:List<&2,Records.Fields<S>>,id:U32) -> Bool:
  Identity.member(identities(~S,fields),id)
# Empty execution setup: retain Unit owner and return SP.Empty, with no steps.
def empty_plan(~S:Data,owner:Unit) -> Unit & SP.Plan<S>:
  (owner,SP.Empty{})
# Empty provisioning returns World unchanged and no schedule requirements.
def empty_provide(~S:Data,~World:Type,world:World) -> World & List<&2,SP.Requirement<S>>:
  (world,[])
# Empty dispatcher retains owner/context and returns Sys.Failed(Unit) for every
# id. It never treats an unknown id as a successfully executed empty system.
def empty_dispatch(~World:Type,owner:Unit,world:Ctx.Context<World>,id:U32) -> Unit & Sys.Outcome<Ctx.Context<World>,Unit,Unit>:
  (owner,Sys.Failed{world,Unit{}})
# Start an empty execution-enabled App with debug disabled and no steps or
# requirements. Does not execute empty_dispatch or register a runner.
def empty(~S:Data,~World:Type,world:World) -> Registered<S,World,Unit,Unit,Build.empty_observe(~World),Leaf.empty(~S),Unit,empty_plan(~S),empty_dispatch(~World),empty_provide(~S,~World)>:
  Registered{Build.empty(~S,~World,world),Recipe{}}
def plan_right(~S:Data,~L:Type,~R:Type,left:L,before:SP.Plan<S>,result:R & SP.Plan<S>) -> (L & R) & SP.Plan<S>:
  match result:
    case (right,after):((left,right),SP.Sequence{before,after})
def plan_left(~S:Data,~L:Type,~R:Type,~right:R -> R & SP.Plan<S>,owner:R,result:L & SP.Plan<S>) -> (L & R) & SP.Plan<S>:
  match result:
    case (left,before):plan_right(~S,~L,~R,left,before,right(owner))
# Advanced ordered plan composition: call left then right with their respective
# actual owners, returning both owners and SP.Sequence(before,after). No scheduling
# conflict or registration validation is added by this adapter.
def plan_pair(~S:Data,~L:Type,~R:Type,~left:L -> L & SP.Plan<S>,~right:R -> R & SP.Plan<S>,owners:L & R) -> (L & R) & SP.Plan<S>:
  match owners:
    case (a,b):plan_left(~S,~L,~R,~right,b,left(a))
def provision_right(~S:Data,~World:Type,before:List<&2,SP.Requirement<S>>,result:World & List<&2,SP.Requirement<S>>) -> World & List<&2,SP.Requirement<S>>:
  match result:
    case (world,after):(world,List.append(&2,SP.Requirement<S>,before,after))
def provision_left(~S:Data,~World:Type,~right:World -> World & List<&2,SP.Requirement<S>>,result:World & List<&2,SP.Requirement<S>>) -> World & List<&2,SP.Requirement<S>>:
  match result:
    case (world,before):provision_right(~S,~World,before,right(world))
# Advanced requirement composition threading the World through left then right.
# Concatenate requirements in that order; callbacks must return their actual World.
# This does not grant gameplay access from requirement strings.
def provision_pair(~S:Data,~World:Type,~left:World -> World & List<&2,SP.Requirement<S>>,~right:World -> World & List<&2,SP.Requirement<S>>,world:World) -> World & List<&2,SP.Requirement<S>>:
  provision_left(~S,~World,~right,left(world))
def left_outcome(~World:Type,~LE:Data,~RE:Data,outcome:Sys.Outcome<Ctx.Context<World>,LE,Unit>) -> Sys.Outcome<Ctx.Context<World>,Identity.Choice<LE,RE>,Unit>:
  match outcome:
    case Sys.Succeeded{world,output}:Sys.Succeeded{world,output}
    case Sys.Failed{world,error}:Sys.Failed{world,Identity.LeftError{error}}
def right_outcome(~World:Type,~LE:Data,~RE:Data,outcome:Sys.Outcome<Ctx.Context<World>,RE,Unit>) -> Sys.Outcome<Ctx.Context<World>,Identity.Choice<LE,RE>,Unit>:
  match outcome:
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
# Advanced owner-preserving routing: fold left metadata, dispatch left if its id
# is present, otherwise delegate to right. Return both actual owners and tag failed
# outcomes LeftError/RightError. This is not two-system execution, global duplicate
# id validation or an extra transaction; each dispatcher supplies its own contract.
def dispatch_pair(~S:Data,~World:Type,~L:Type,~R:Type,~LE:Data,~RE:Data,~fold:L -> L & List<&2,Records.Fields<S>>,~left:L -> Ctx.Context<World> -> U32 -> L & Sys.Outcome<Ctx.Context<World>,LE,Unit>,~right:R -> Ctx.Context<World> -> U32 -> R & Sys.Outcome<Ctx.Context<World>,RE,Unit>,owners:L & R,world:Ctx.Context<World>,id:U32) -> (L & R) & Sys.Outcome<Ctx.Context<World>,Identity.Choice<LE,RE>,Unit>:
  match owners:
    case (a,b):dispatch_folded(~S,~World,~L,~R,~LE,~RE,~left,~right,b,world,id,fold(a))
# Affine registered invocation owner retaining its actual token, Data arguments
# and latest detached row outputs. Field metadata alone cannot reconstruct token
# or guarantee authority; ordinary App runners define output/refusal updates.
type Invocation<S:Data,Token:Type,Args:Data,Out:Data> is Type:
  Invocation{record:Leaf.Record<S,Token>,args:Args,outputs:List<&2,Out>}
# Advanced owner-returning fold exposing this invocation's single field record.
# Arguments, outputs and actual token remain retained unchanged.
def invocation_fields(~S:Data,~Token:Type,~Args:Data,~Out:Data,value:Invocation<S,Token,Args,Out>) -> Invocation<S,Token,Args,Out> & List<&2,Records.Fields<S>>:
  match value:
    case Invocation{Leaf.Record{token,+fields},args,outputs}:(Invocation{Leaf.Record{token,fields},args,outputs},[fields])
# Advanced owner-returning plan for this registered id: one System step with
# condition slot zero and no requirements. Does not derive requirement grants from
# field access metadata, invoke gameplay or change retained invocation outputs.
def invocation_plan(~S:Data,~Token:Type,~Args:Data,~Out:Data,value:Invocation<S,Token,Args,Out>) -> Invocation<S,Token,Args,Out> & SP.Plan<S>:
  match value:
    case Invocation{Leaf.Record{token,Records.Fields{+namespace,+id,+name,+access,+cursor,+slot,+clauses,+kind}},args,outputs}:(Invocation{Leaf.Record{token,Records.Fields{namespace,id,name,access,cursor,slot,clauses,kind}},args,outputs},SP.Entry{Sch.System{id,0},[]})
