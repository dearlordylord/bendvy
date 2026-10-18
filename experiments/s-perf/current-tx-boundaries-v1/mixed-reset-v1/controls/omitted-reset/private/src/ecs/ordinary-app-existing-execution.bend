import Base
import ordinary-app-execution-recipe.bend as Exec
import ordinary-app-registration-fields.bend as Fields
import ordinary-app-records.bend as Records
import ordinary-app-composer.bend as Build
import execution-context.bend as Ctx
import schedule-provision.bend as SP
import schedule.bend as Sch
import system.bend as Sys
import local.bend as Local
import ordinary-reader-system.bend as Reader
import ordinary-app-recipe.bend as Tree
import world.bend as W

def folded(~S:Data,~O:Type,~Shared:Type,shared:Shared,result:O & Fields.Fields<S>) -> (O & Shared) & List<&2,Fields.Fields<S>>:
  match result:
    case (owner,fields):((owner,shared),[fields])
def fold(~S:Data,~O:Type,~Shared:Type,~catalog:O -> O & Fields.Fields<S>,value:O & Shared) -> (O & Shared) & List<&2,Fields.Fields<S>>:
  match value:
    case (owner,shared):folded(~S,~O,~Shared,shared,catalog(owner))
def selected_plan(~S:Data,enabled:Bool,field:Fields.Fields<S>,needs:List<&2,SP.Requirement<S>>) -> SP.Plan<S>:
  match enabled:
    case True{}:SP.Entry{Sch.System{Exec.registration_id(~S,field),0},needs}
    case False{}:SP.Empty{}
def planned(~S:Data,~O:Type,~Shared:Type,needs:List<&2,SP.Requirement<S>>,result:O & Fields.Fields<S>,selection:Shared & Bool) -> (O & Shared) & SP.Plan<S>:
  match result selection:
    case (owner,fields),(shared,enabled):((owner,shared),selected_plan(~S,enabled,fields,needs))
def plan(~S:Data,~O:Type,~Shared:Type,~catalog:O -> O & Fields.Fields<S>,~enabled:Shared -> Shared & Bool,~needs:List<&2,SP.Requirement<S>>,value:O & Shared) -> (O & Shared) & SP.Plan<S>:
  match value:
    case (owner,shared):planned(~S,~O,~Shared,needs,catalog(owner),enabled(shared))
def returned(~World:Type,~O:Type,~Shared:Type,~Error:Data,result:O & (Shared & Sys.Outcome<Ctx.Context<World>,Error,Unit>)) -> (O & Shared) & Sys.Outcome<Ctx.Context<World>,Error,Unit>:
  match result:
    case (owner,(shared,outcome)):((owner,shared),outcome)
def invoked(~S:Data,~World:Type,~O:Type,~Shared:Type,~Error:Data,~invoke:O -> Shared -> Ctx.Context<World> -> O & (Shared & Sys.Outcome<Ctx.Context<World>,Error,Unit>),~refused:Error,allowed:Bool,owner:O,shared:Shared,context:Ctx.Context<World>) -> (O & Shared) & Sys.Outcome<Ctx.Context<World>,Error,Unit>:
  match allowed:
    case False{}:((owner,shared),Sys.Failed{context,refused})
    case True{}:returned(~World,~O,~Shared,~Error,invoke(owner,shared,context))
def catalogued(~S:Data,~World:Type,~O:Type,~Shared:Type,~Error:Data,~invoke:O -> Shared -> Ctx.Context<World> -> O & (Shared & Sys.Outcome<Ctx.Context<World>,Error,Unit>),~refused:Error,shared:Shared,context:Ctx.Context<World>,id:U32,result:O & Fields.Fields<S>) -> (O & Shared) & Sys.Outcome<Ctx.Context<World>,Error,Unit>:
  match result:
    case (owner,fields):invoked(~S,~World,~O,~Shared,~Error,~invoke,~refused,U32.is_eq(Exec.registration_id(~S,fields),id),owner,shared,context)
def dispatch(~S:Data,~World:Type,~O:Type,~Shared:Type,~Error:Data,~catalog:O -> O & Fields.Fields<S>,~invoke:O -> Shared -> Ctx.Context<World> -> O & (Shared & Sys.Outcome<Ctx.Context<World>,Error,Unit>),~refused:Error,value:O & Shared,context:Ctx.Context<World>,id:U32) -> (O & Shared) & Sys.Outcome<Ctx.Context<World>,Error,Unit>:
  match value:
    case (owner,shared):catalogued(~S,~World,~O,~Shared,~Error,~invoke,~refused,shared,context,id,catalog(owner))
def right_folded(~S:Data,~L:Type,~R:Type,~Shared:Type,left:L,first:List<&2,Fields.Fields<S>>,result:(R & Shared) & List<&2,Fields.Fields<S>>) -> ((L & R) & Shared) & List<&2,Fields.Fields<S>>:
  match result:
    case ((right,shared),last):(((left,right),shared),List.append(&2,Fields.Fields<S>,first,last))
def left_folded(~S:Data,~L:Type,~R:Type,~Shared:Type,~rightFold:(R & Shared) -> (R & Shared) & List<&2,Fields.Fields<S>>,right:R,result:(L & Shared) & List<&2,Fields.Fields<S>>) -> ((L & R) & Shared) & List<&2,Fields.Fields<S>>:
  match result:
    case ((left,shared),fields):right_folded(~S,~L,~R,~Shared,left,fields,rightFold((right,shared)))
def pair_fold(~S:Data,~L:Type,~R:Type,~Shared:Type,~leftFold:(L & Shared) -> (L & Shared) & List<&2,Fields.Fields<S>>,~rightFold:(R & Shared) -> (R & Shared) & List<&2,Fields.Fields<S>>,value:(L & R) & Shared) -> ((L & R) & Shared) & List<&2,Fields.Fields<S>>:
  match value:
    case ((left,right),shared):left_folded(~S,~L,~R,~Shared,~rightFold,right,leftFold((left,shared)))
def right_planned(~S:Data,~L:Type,~R:Type,~Shared:Type,left:L,before:SP.Plan<S>,result:(R & Shared) & SP.Plan<S>) -> ((L & R) & Shared) & SP.Plan<S>:
  match result:
    case ((right,shared),after):(((left,right),shared),SP.Sequence{before,after})
def left_planned(~S:Data,~L:Type,~R:Type,~Shared:Type,~rightPlan:(R & Shared) -> (R & Shared) & SP.Plan<S>,right:R,result:(L & Shared) & SP.Plan<S>) -> ((L & R) & Shared) & SP.Plan<S>:
  match result:
    case ((left,shared),before):right_planned(~S,~L,~R,~Shared,left,before,rightPlan((right,shared)))
def pair_plan(~S:Data,~L:Type,~R:Type,~Shared:Type,~leftPlan:(L & Shared) -> (L & Shared) & SP.Plan<S>,~rightPlan:(R & Shared) -> (R & Shared) & SP.Plan<S>,value:(L & R) & Shared) -> ((L & R) & Shared) & SP.Plan<S>:
  match value:
    case ((left,right),shared):left_planned(~S,~L,~R,~Shared,~rightPlan,right,leftPlan((left,shared)))
def left_returned(~World:Type,~L:Type,~R:Type,~Shared:Type,~Error:Data,right:R,result:(L & Shared) & Sys.Outcome<Ctx.Context<World>,Error,Unit>) -> ((L & R) & Shared) & Sys.Outcome<Ctx.Context<World>,Error,Unit>:
  match result:
    case ((left,shared),outcome):(((left,right),shared),outcome)
def right_returned(~World:Type,~L:Type,~R:Type,~Shared:Type,~Error:Data,left:L,result:(R & Shared) & Sys.Outcome<Ctx.Context<World>,Error,Unit>) -> ((L & R) & Shared) & Sys.Outcome<Ctx.Context<World>,Error,Unit>:
  match result:
    case ((right,shared),outcome):(((left,right),shared),outcome)
def pair_selected(~World:Type,~L:Type,~R:Type,~Shared:Type,~Error:Data,~leftDispatch:(L & Shared) -> Ctx.Context<World> -> U32 -> (L & Shared) & Sys.Outcome<Ctx.Context<World>,Error,Unit>,~rightDispatch:(R & Shared) -> Ctx.Context<World> -> U32 -> (R & Shared) & Sys.Outcome<Ctx.Context<World>,Error,Unit>,selected:Bool,left:L,right:R,shared:Shared,context:Ctx.Context<World>,id:U32) -> ((L & R) & Shared) & Sys.Outcome<Ctx.Context<World>,Error,Unit>:
  match selected:
    case True{}:left_returned(~World,~L,~R,~Shared,~Error,right,leftDispatch((left,shared),context,id))
    case False{}:right_returned(~World,~L,~R,~Shared,~Error,left,rightDispatch((right,shared),context,id))
def pair_catalogued(~S:Data,~World:Type,~L:Type,~R:Type,~Shared:Type,~Error:Data,~leftDispatch:(L & Shared) -> Ctx.Context<World> -> U32 -> (L & Shared) & Sys.Outcome<Ctx.Context<World>,Error,Unit>,~rightDispatch:(R & Shared) -> Ctx.Context<World> -> U32 -> (R & Shared) & Sys.Outcome<Ctx.Context<World>,Error,Unit>,right:R,context:Ctx.Context<World>,+id:U32,result:(L & Shared) & List<&2,Fields.Fields<S>>) -> ((L & R) & Shared) & Sys.Outcome<Ctx.Context<World>,Error,Unit>:
  match result:
    case ((left,shared),fields):pair_selected(~World,~L,~R,~Shared,~Error,~leftDispatch,~rightDispatch,Exec.member(~S,fields,id),left,right,shared,context,id)
def pair_dispatch(~S:Data,~World:Type,~L:Type,~R:Type,~Shared:Type,~Error:Data,~leftFold:(L & Shared) -> (L & Shared) & List<&2,Fields.Fields<S>>,~leftDispatch:(L & Shared) -> Ctx.Context<World> -> U32 -> (L & Shared) & Sys.Outcome<Ctx.Context<World>,Error,Unit>,~rightDispatch:(R & Shared) -> Ctx.Context<World> -> U32 -> (R & Shared) & Sys.Outcome<Ctx.Context<World>,Error,Unit>,value:(L & R) & Shared,context:Ctx.Context<World>,id:U32) -> ((L & R) & Shared) & Sys.Outcome<Ctx.Context<World>,Error,Unit>:
  match value:
    case ((left,right),shared):pair_catalogued(~S,~World,~L,~R,~Shared,~Error,~leftDispatch,~rightDispatch,right,context,id,leftFold((left,shared)))
def barrier_plan(~S:Data,enabled:Bool,before:SP.Plan<S>) -> SP.Plan<S>:
  match enabled:
    case False{}:before
    case True{}:SP.Sequence{before,SP.Entry{Sch.Barrier{},[]}}
def after_selected(~S:Data,~O:Type,~Shared:Type,owner:O,before:SP.Plan<S>,selection:Shared & Bool) -> (O & Shared) & SP.Plan<S>:
  match selection:
    case (shared,enabled):((owner,shared),barrier_plan(~S,enabled,before))
def after_planned(~S:Data,~O:Type,~Shared:Type,~after:Shared -> Shared & Bool,result:(O & Shared) & SP.Plan<S>) -> (O & Shared) & SP.Plan<S>:
  match result:
    case ((owner,shared),before):after_selected(~S,~O,~Shared,owner,before,after(shared))
def after(~S:Data,~O:Type,~Shared:Type,~plan:(O & Shared) -> (O & Shared) & SP.Plan<S>,~after:Shared -> Shared & Bool,value:O & Shared) -> (O & Shared) & SP.Plan<S>:
  after_planned(~S,~O,~Shared,~after,plan(value))
def local_fields(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> L -> Args -> Local.Outcome<W.World<S,C,R,E>,L,Error,Out>,value:Local.Instance<S,C,R,E,L,Args,Error,Out,runner>) -> Local.Instance<S,C,R,E,L,Args,Error,Out,runner> & Fields.Fields<S>:
  match value:
    case Local.Instance{+namespace,+id,+name,+access,local}:(Local.Instance{namespace,id,name,access,local},Fields.Fields{namespace,id,name,access,0,name,[],Fields.MixedKind{[]}})
def system_fields(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,value:Sys.Registry<S,C,R,E,Args,Error,Out,runner>) -> Sys.Registry<S,C,R,E,Args,Error,Out,runner> & Fields.Fields<S>:
  match value:
    case Sys.Registry{+namespace,+id,+name,+access,+cursor}:(Sys.Registry{namespace,id,name,access,cursor},Fields.Fields{namespace,id,name,access,cursor,name,[],Fields.MixedKind{[]}})
def reader_fields(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,~Owner:Type,~Param:Type,~Decl:Type,value:Reader.Provider<Sys.Registry<S,C,R,E,Args,Error,Out,runner>,Owner,Param,Decl>) -> Reader.Provider<Sys.Registry<S,C,R,E,Args,Error,Out,runner>,Owner,Param,Decl> & Fields.Fields<S>:
  match value:
    case Reader.Provider{Sys.Registry{+namespace,+id,+name,+access,+cursor},owner,param,decl}:(Reader.Provider{Sys.Registry{namespace,id,name,access,cursor},owner,param,decl},Fields.Fields{namespace,id,name,access,cursor,name,[],Fields.MixedKind{[]}})

def registered(~S:Data,~World:Type,~H:Type,~fold:H -> H & List<&2,Fields.Fields<S>>,~Error:Data,~plan:H -> H & SP.Plan<S>,~dispatch:H -> Ctx.Context<World> -> U32 -> H & Sys.Outcome<Ctx.Context<World>,Error,Unit>,~provide:World -> World & List<&2,SP.Requirement<S>>,world:World,owners:H) -> Exec.Registered<S,World,H,Unit,Build.empty_observe(~World),fold,Error,plan,dispatch,provide>:
  Exec.Registered{Build.Registered{world,owners,Tree.Recipe{},False{}},Exec.Recipe{}}
