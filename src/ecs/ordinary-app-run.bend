import Base
import ./ordinary-app-execution-recipe.bend as Recipe
import ./ordinary-app-composer.bend as Build
import ./ordinary-app-recipe.bend as Tree
import ./ordinary-app-schema.bend as App
import ./ordinary-app-schedule.bend as Single
import ./ordinary-app-execution.bend as Execute
import ./ordinary-app-registration-fields.bend as Records
import ./ordinary-app-observation-data.bend as DTO
import ./ordinary-schema.bend as Schema
import ./captured-schedule-composition.bend as Identity
import ./execution-context.bend as Ctx
import ./world.bend as W
import ./system.bend as Sys
import ./schedule.bend as Sch
import ./schedule-provision.bend as SP
# Executable application owning one world, registered system owners and a
# declaration-derived execution recipe. Thread this affine value through run;
# its type binds schema, observations and dispatch together.
# Example: examples/scheduled-health/registration.bend, Application().
type Application<S:Data,C:Type,R:Type,E:Data,H:Type,Rows:Data,-observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,-fold:H -> H & List<&2,Records.Fields<S>>,Error:Data,-plan:H -> H & SP.Plan<S>,-dispatch:H -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> H & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,Error,Unit>,-provide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>> is Type:
  Application{app:Single.Application<S,C,R,E,H,Rows,observe,fold>,execution:Recipe.Recipe<S,W.World<S,C,R,E>,H,Error,plan,dispatch,provide>}
def initial(~S:Data,barrier:Bool,plan:SP.Plan<S>) -> SP.Plan<S>:
  match barrier:
    case False{}:plan
    case True{}:SP.Sequence{SP.Entry{Sch.Barrier{},[]},plan}
def built(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,~plan:H -> H & SP.Plan<S>,~dispatch:H -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> H & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,Error,Unit>,~provide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,schema:Schema.Schema<S,C,R>,world:W.World<S,C,R,E>,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,+selected:SP.Plan<S>,result:SP.Build<S,C,R,E,H>) -> Single.Attachment<Recipe.Registered<S,W.World<S,C,R,E>,H,Rows,observe,fold,Error,plan,dispatch,provide>,Application<S,C,R,E,H,Rows,observe,fold,Error,plan,dispatch,provide>>:
  match result:
    case SP.Invalid{owners}:Single.Invalid{Recipe.Registered{Build.Registered{world,owners,recipe,debug},Recipe.Recipe{}}}
    case SP.Built{SP.Provisioned{Sch.Schedule{namespace,name,steps,owners},needs}}:Single.Attached{Application{Single.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},selected,namespace,name,steps,needs},Recipe.Recipe{}}}
def checked(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,~plan:H -> H & SP.Plan<S>,~dispatch:H -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> H & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,Error,Unit>,~provide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,valid:Bool,schema:Schema.Schema<S,C,R>,world:W.World<S,C,R,E>,owners:H,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,+selected:SP.Plan<S>,namespace:U32,name:String,ids:List<&2,U32>) -> Single.Attachment<Recipe.Registered<S,W.World<S,C,R,E>,H,Rows,observe,fold,Error,plan,dispatch,provide>,Application<S,C,R,E,H,Rows,observe,fold,Error,plan,dispatch,provide>>:
  match valid:
    case False{}:Single.Invalid{Recipe.Registered{Build.Registered{world,owners,recipe,debug},Recipe.Recipe{}}}
    case True{}:built(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,~plan,~dispatch,~provide,schema,world,recipe,debug,selected,SP.build(~S,~C,~R,~E,~H,namespace,name,selected,ids,owners))
def folded(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,~plan:H -> H & SP.Plan<S>,~dispatch:H -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> H & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,Error,Unit>,~provide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,schema:Schema.Schema<S,C,R>,world:W.World<S,C,R,E>,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,selected:SP.Plan<S>,name:String,result:H & List<&2,Records.Fields<S>>) -> Single.Attachment<Recipe.Registered<S,W.World<S,C,R,E>,H,Rows,observe,fold,Error,plan,dispatch,provide>,Application<S,C,R,E,H,Rows,observe,fold,Error,plan,dispatch,provide>>:
  match world:
    case W.World{+namespace,allocator,store,resource,events,pending,+registrations,nextSystemId,clock,lifecycle}:
      match result:
        case (owners,+fields):checked(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,~plan,~dispatch,~provide,Identity.identities_valid(namespace,registrations,Recipe.identities(~S,fields),[]),schema,W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,lifecycle},owners,recipe,debug,selected,namespace,name,Identity.ids(Recipe.identities(~S,fields)))
def planned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,~plan:H -> H & SP.Plan<S>,~dispatch:H -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> H & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,Error,Unit>,~provide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,schema:Schema.Schema<S,C,R>,world:W.World<S,C,R,E>,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,name:String,barrier:Bool,result:H & SP.Plan<S>) -> Single.Attachment<Recipe.Registered<S,W.World<S,C,R,E>,H,Rows,observe,fold,Error,plan,dispatch,provide>,Application<S,C,R,E,H,Rows,observe,fold,Error,plan,dispatch,provide>>:
  match result:
    case (owners,selected):folded(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,~plan,~dispatch,~provide,schema,world,recipe,debug,initial(~S,barrier,selected),name,fold(owners))
# Derive and validate a schedule from the existing registered application.
# Returns Attached with the executable App, or Invalid with the original
# registered owner; world and registration owners are never copied.
# Validates registration identity and schedule structure before execution.
# barrier=True prepends an explicit barrier; False adds none. Registration
# order is retained by the derived plan. No system body runs here.
# Example: examples/scheduled-health/registration.bend, attach().
def attach(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,~plan:H -> H & SP.Plan<S>,~dispatch:H -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> H & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,Error,Unit>,~provide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,schema:Schema.Schema<S,C,R>,value:Recipe.Registered<S,W.World<S,C,R,E>,H,Rows,observe,fold,Error,plan,dispatch,provide>,name:String,barrier:Bool) -> Single.Attachment<Recipe.Registered<S,W.World<S,C,R,E>,H,Rows,observe,fold,Error,plan,dispatch,provide>,Application<S,C,R,E,H,Rows,observe,fold,Error,plan,dispatch,provide>>:
  match value:
    case Recipe.Registered{Build.Registered{world,owners,recipe,debug},_}:planned(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,~plan,~dispatch,~provide,schema,world,recipe,debug,name,barrier,plan(owners))
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,~plan:H -> H & SP.Plan<S>,~dispatch:H -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> H & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,Error,Unit>,~provide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,result:Single.RunResult<Single.Application<S,C,R,E,H,Rows,observe,fold>,S,Error>) -> Single.RunResult<Application<S,C,R,E,H,Rows,observe,fold,Error,plan,dispatch,provide>,S,Error>:
  match result:
    case Single.Finished{app,observations}:Single.Finished{Application{app,Recipe.Recipe{}},observations}
    case Single.Failed{app,error,observations}:Single.Failed{Application{app,Recipe.Recipe{}},error,observations}
    case Single.Rejected{app}:Single.Rejected{Application{app,Recipe.Recipe{}}}
    case Single.Missing{app,requirements}:Single.Missing{Application{app,Recipe.Recipe{}},requirements}
def executed(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,~plan:H -> H & SP.Plan<S>,~dispatch:H -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> H & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,Error,Unit>,~provide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,result:Execute.Run<Single.Application<S,C,R,E,H,Rows,observe,fold>,S,Error>) -> Execute.Run<Application<S,C,R,E,H,Rows,observe,fold,Error,plan,dispatch,provide>,S,Error>:
  match result:
    case Execute.Run{result,batch}:Execute.Run{returned(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,~plan,~dispatch,~provide,result),batch}
# Run the derived schedule with a per-system condition(world, id), returning
# an Execute.Run containing the application result and detached trace batch.
# Finished/Failed/Rejected/Missing all retain the application owner. A failed
# system rolls back its ECS transaction, preserving earlier successful systems;
# retained local/capture state and host IO follow their own contracts.
# Structural commands become visible only at plan barriers, not at run end.
# A false condition bypasses dispatch and leaves its invocation/lifecycle cursor
# unchanged. condition is a trusted world-transforming callback: its returned
# world is retained even when false; it is not confined to read-only access.
def run_when(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,~plan:H -> H & SP.Plan<S>,~dispatch:H -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> H & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,Error,Unit>,~provide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,~condition:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,value:Application<S,C,R,E,H,Rows,observe,fold,Error,plan,dispatch,provide>) -> Execute.Run<Application<S,C,R,E,H,Rows,observe,fold,Error,plan,dispatch,provide>,S,Error>:
  match value:
    case Application{app,_}:executed(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,~plan,~dispatch,~provide,Execute.run(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,~dispatch,~condition,~provide,app))
# Return the same application owner with debug enabled or disabled.
# Enabling derives observations from declarations; no repeated metadata input
# is required. This call neither runs systems nor advances their cursors.
def enabled(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,~plan:H -> H & SP.Plan<S>,~dispatch:H -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> H & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,Error,Unit>,~provide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,value:Application<S,C,R,E,H,Rows,observe,fold,Error,plan,dispatch,provide>,flag:Bool) -> Application<S,C,R,E,H,Rows,observe,fold,Error,plan,dispatch,provide>:
  match value:
    case Application{app,execution}:Application{Single.enabled(~S,~C,~R,~E,~H,~Rows,~observe,~fold,app,flag),execution}
def observed(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,~plan:H -> H & SP.Plan<S>,~dispatch:H -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> H & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,Error,Unit>,~provide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,result:Single.Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,Single.Description<S,Rows>>) -> Application<S,C,R,E,H,Rows,observe,fold,Error,plan,dispatch,provide> & Maybe<&2,Single.Description<S,Rows>>:
  match result:
    case (app,view):(Application{app,Recipe.Recipe{}},view)
# Return the application owner with Some detached debug description when
# enabled, or None when disabled. This is inspection, not a restorable save.
# It does not execute systems or consume their lifecycle/event cursors.
# Example: examples/scheduled-health/registration.bend, snapshot().
def snapshot(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,~plan:H -> H & SP.Plan<S>,~dispatch:H -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> H & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,Error,Unit>,~provide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,value:Application<S,C,R,E,H,Rows,observe,fold,Error,plan,dispatch,provide>) -> Application<S,C,R,E,H,Rows,observe,fold,Error,plan,dispatch,provide> & Maybe<&2,Single.Description<S,Rows>>:
  match value:
    case Application{app,_}:observed(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,~plan,~dispatch,~provide,Single.snapshot(~S,~C,~R,~E,~H,~Rows,~observe,~fold,app))
# Rebuild the derived schedule from the same application registrations.
# Preserves the world and invocation owners; name and leading barrier replace
# the prior plan configuration. Returns Attached, or Invalid with the retained
# registered owner. Does not run bodies or recreate their registration state.
# Example: examples/scheduled-health/registration.bend, replan().
def replan(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,~plan:H -> H & SP.Plan<S>,~dispatch:H -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> H & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,Error,Unit>,~provide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,value:Application<S,C,R,E,H,Rows,observe,fold,Error,plan,dispatch,provide>,name:String,barrier:Bool) -> Single.Attachment<Recipe.Registered<S,W.World<S,C,R,E>,H,Rows,observe,fold,Error,plan,dispatch,provide>,Application<S,C,R,E,H,Rows,observe,fold,Error,plan,dispatch,provide>>:
  match value:
    case Application{Single.Application{App.Application{schema,app},_,_,_,_,_},_}:attach(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,~plan,~dispatch,~provide,schema,Recipe.Registered{app,Recipe.Recipe{}},name,barrier)
def always(~World:Type,world:World,id:U32) -> World & Bool:
  (world,True{})
# Execute one pass of the declaration-derived schedule with all systems
# eligible; returns Execute.Run with a retained App on every result variant
# (Finished, Failed, Rejected or Missing) plus a detached trace batch.
# Earlier successful systems remain committed if a later system fails.
# Deferred commands remain pending until an explicit schedule barrier.
# Example: examples/scheduled-health/application.bend, ticks().
def run(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,~plan:H -> H & SP.Plan<S>,~dispatch:H -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> H & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,Error,Unit>,~provide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,value:Application<S,C,R,E,H,Rows,observe,fold,Error,plan,dispatch,provide>) -> Execute.Run<Application<S,C,R,E,H,Rows,observe,fold,Error,plan,dispatch,provide>,S,Error>:
  run_when(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,~plan,~dispatch,~provide,~always(~W.World<S,C,R,E>),value)
def inspected(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,~plan:H -> H & SP.Plan<S>,~dispatch:H -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> H & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,Error,Unit>,~provide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,~Value:Data,schema:Schema.Schema<S,C,R>,owners:H,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,selected:SP.Plan<S>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>,result:W.World<S,C,R,E> & Value) -> Application<S,C,R,E,H,Rows,observe,fold,Error,plan,dispatch,provide> & Value:
  match result:
    case (world,value):(Application{Single.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},selected,namespace,name,steps,needs},Recipe.Recipe{}},value)
# Advanced world projection callback: consumes and returns the application
# together with detached Data Value. project must return the world owner.
# This adapter does not itself restrict project to read-only operations; use
# public Inspector projections for noninterfering observation. No system is run.
def inspect(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,~plan:H -> H & SP.Plan<S>,~dispatch:H -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> H & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,Error,Unit>,~provide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,~Value:Data,~project:W.World<S,C,R,E> -> W.World<S,C,R,E> & Value,value:Application<S,C,R,E,H,Rows,observe,fold,Error,plan,dispatch,provide>) -> Application<S,C,R,E,H,Rows,observe,fold,Error,plan,dispatch,provide> & Value:
  match value:
    case Application{Single.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},selected,namespace,name,steps,needs},_}:inspected(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,~plan,~dispatch,~provide,~Value,schema,owners,recipe,debug,selected,namespace,name,steps,needs,project(world))

# Advanced adapter to modify retained invocation owners with caller-supplied
# arguments, including affine Type values.
# Returns the application with the same world, plan and execution recipe;
# modify must return H and preserve registration identity/metadata invariants.
# It is not an ECS transaction and does not validate arbitrary owner changes.
def update_owners(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,~plan:H -> H & SP.Plan<S>,~dispatch:H -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> H & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,Error,Unit>,~provide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,~Args:Type,~modify:H -> Args -> H,value:Application<S,C,R,E,H,Rows,observe,fold,Error,plan,dispatch,provide>,args:Args) -> Application<S,C,R,E,H,Rows,observe,fold,Error,plan,dispatch,provide>:
  match value:
    case Application{Single.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},selected,namespace,name,steps,needs},execution}:Application{Single.Application{App.Application{schema,Build.Registered{world,modify(owners,args),recipe,debug}},selected,namespace,name,steps,needs},execution}
