import Base
import ./ordinary-condition-composition.bend as Comp
import ordinary-app-recipe.bend as Tree
import ordinary-app-schema.bend as App
import ordinary-app-composer.bend as Build
import ordinary-app-registration-fields.bend as Records
import ordinary-app-observation-data.bend as DTO
import ordinary-schema.bend as Schema
import world.bend as W
import system.bend as Sys
import schedule.bend as Sch
import schedule-provision.bend as SP
# Plan is ordinary operational input; only enabled snapshots lower its description.
type PlannedStep<S:Data> is Data:
  PlannedStep{step:Sch.Step,requirements:List<&2,SP.Requirement<S>>}
type Description<S:Data,Rows:Data> is Data:
  Description{application:App.Description<S,Rows>,namespace:U32,name:String,steps:List<&2,PlannedStep<S>>}
type Application<S:Data,C:Type,R:Type,E:Data,H:Type,Rows:Data,-observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,-fold:H -> H & List<&2,Records.Fields<S>>> is Type:
  Application{app:App.Application<S,C,R,E,H,Rows,observe,fold>,plan:SP.Plan<S>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>}
type Attachment<-Original:Type,-Scheduled:Type> is Type:
  Attached{app:Scheduled}
  Invalid{app:Original}
type RunResult<-A:Type,-S:Data,-Error:Data> is Type:
  Finished{app:A,observations:List<&2,Sch.Observation>}
  Failed{app:A,error:Error,observations:List<&2,Sch.Observation>}
  Rejected{app:A}
  Missing{app:A,requirements:List<&2,SP.Requirement<S>>}
def planned(~S:Data,plan:SP.Plan<S>) -> List<&2,PlannedStep<S>>:
  match plan:
    case SP.Empty{}:[]
    case SP.Entry{step,needs}:[PlannedStep{step,needs}]
    case SP.Sequence{left,right}:List.append(&2,PlannedStep<S>,planned(~S,left),planned(~S,right))
def ids(registrations:List<&2,W.RegistrationMeta>) -> List<&2,U32>:
  match registrations:
    case []:[]
    case W.RegistrationMeta{id,_,_} <> rest:id <> ids(rest)
def catalog(~S:Data,~C:Type,~R:Type,~E:Data,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & (U32 & List<&2,U32>):
  match world:
    case W.World{+namespace,allocator,store,resource,events,pending,+registrations,nextSystemId,clock}:(W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock},(namespace,ids(registrations)))
def built(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,schema:Schema.Schema<S,C,R>,world:W.World<S,C,R,E>,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,+plan:SP.Plan<S>,result:SP.Build<S,C,R,E,H>) -> Attachment<App.Application<S,C,R,E,H,Rows,observe,fold>,Application<S,C,R,E,H,Rows,observe,fold>>:
  match result:
    case SP.Invalid{owners}:Invalid{App.Application{schema,Build.Registered{world,owners,recipe,debug}}}
    case SP.Built{SP.Provisioned{Sch.Schedule{namespace,name,steps,owners},needs}}:Attached{Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs}}
def cataloged(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,schema:Schema.Schema<S,C,R>,owners:H,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,+plan:SP.Plan<S>,name:String,result:W.World<S,C,R,E> & (U32 & List<&2,U32>)) -> Attachment<App.Application<S,C,R,E,H,Rows,observe,fold>,Application<S,C,R,E,H,Rows,observe,fold>>:
  match result:
    case (world,(namespace,known)):built(~S,~C,~R,~E,~H,~Rows,~observe,~fold,schema,world,recipe,debug,plan,SP.build(~S,~C,~R,~E,~H,namespace,name,plan,known,owners))
def attach(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,app:App.Application<S,C,R,E,H,Rows,observe,fold>,name:String,plan:SP.Plan<S>) -> Attachment<App.Application<S,C,R,E,H,Rows,observe,fold>,Application<S,C,R,E,H,Rows,observe,fold>>:
  match app:
    case App.Application{schema,Build.Registered{world,owners,recipe,debug}}:cataloged(~S,~C,~R,~E,~H,~Rows,~observe,~fold,schema,owners,recipe,debug,plan,name,catalog(~S,~C,~R,~E,world))
def enabled(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,value:Application<S,C,R,E,H,Rows,observe,fold>,flag:Bool) -> Application<S,C,R,E,H,Rows,observe,fold>:
  match value:
    case Application{app,plan,namespace,name,steps,needs}:Application{App.enabled(~S,~C,~R,~E,~H,~Rows,~observe,~fold,app,flag),plan,namespace,name,steps,needs}
def observed(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,+plan:SP.Plan<S>,+namespace:U32,+name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>,result:App.Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,App.Description<S,Rows>>) -> Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,Description<S,Rows>>:
  match result:
    case (app,None{}):(Application{app,plan,namespace,name,steps,needs},None{})
    case (app,Some{view}):(Application{app,plan,namespace,name,steps,needs},Some{Description{view,namespace,name,planned(~S,plan)}})
def snapshot(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,value:Application<S,C,R,E,H,Rows,observe,fold>) -> Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,Description<S,Rows>>:
  match value:
    case Application{app,plan,namespace,name,steps,needs}:observed(~S,~C,~R,~E,~H,~Rows,~observe,~fold,plan,namespace,name,steps,needs,App.snapshot(~S,~C,~R,~E,~H,~Rows,~observe,~fold,app))
def executed(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,schema:Schema.Schema<S,C,R>,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,plan:SP.Plan<S>,needs:List<&2,SP.Requirement<S>>,result:Sch.RunResult<S,C,R,E,H,Error>) -> RunResult<Application<S,C,R,E,H,Rows,observe,fold>,S,Error>:
  match result:
    case Sch.Finished{Sch.Schedule{namespace,name,steps,owners},world,observations}:Finished{Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},observations}
    case Sch.Failed{Sch.Schedule{namespace,name,steps,owners},world,error,observations}:Failed{Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},error,observations}
    case Sch.Rejected{Sch.Schedule{namespace,name,steps,owners},world}:Rejected{Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs}}
def provisioned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,schema:Schema.Schema<S,C,R>,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,plan:SP.Plan<S>,result:SP.ProvisionResult<S,C,R,E,H,Error>) -> RunResult<Application<S,C,R,E,H,Rows,observe,fold>,S,Error>:
  match result:
    case SP.Missing{SP.Provisioned{Sch.Schedule{namespace,name,steps,owners},needs},world,missing}:Missing{Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},missing}
    case SP.Executed{result,needs}:executed(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,schema,recipe,debug,plan,needs,result)
def run(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,value:Application<S,C,R,E,H,Rows,observe,fold>) -> RunResult<Application<S,C,R,E,H,Rows,observe,fold>,S,Error>:
  match value:
    case Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs}:provisioned(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,schema,recipe,debug,plan,SP.run(~S,~C,~R,~E,~H,~Error,~dispatch,~condition,~provision,SP.Provisioned{Sch.Schedule{namespace,name,steps,owners},needs},world))

# Stateful guards are retained beside the same ordinary App, not in its resources.
type ConditionedApplication<S:Data,C:Type,R:Type,E:Data,H:Type,Rows:Data,-observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,-fold:H -> H & List<&2,Records.Fields<S>>,B:Type,-select:B -> W.World<S,C,R,E> -> U32 -> Comp.Evaluation<W.World<S,C,R,E>,B>> is Type:
  ConditionedApplication{app:Application<S,C,R,E,H,Rows,observe,fold>,bindings:Comp.Bindings<W.World<S,C,R,E>,B,select>}
type ConditionAttachment<-Original:Type,-Guards:Type,-Scheduled:Type> is Type:
  ConditionsAttached{app:Scheduled}
  ConditionsInvalid{app:Original,bindings:Guards}
type ConditionDescription<S:Data,Rows:Data> is Data:
  ConditionDescription{original:Description<S,Rows>,bindings:List<&2,Comp.BindingDescription>}
def conditions_attached(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> Comp.Evaluation<W.World<S,C,R,E>,B>,schema:Schema.Schema<S,C,R>,world:W.World<S,C,R,E>,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,plan:SP.Plan<S>,needs:List<&2,SP.Requirement<S>>,result:Comp.Attachment<S,C,R,E,H,B,select>) -> ConditionAttachment<Application<S,C,R,E,H,Rows,observe,fold>,Comp.Bindings<W.World<S,C,R,E>,B,select>,ConditionedApplication<S,C,R,E,H,Rows,observe,fold,B,select>>:
  match result:
    case Comp.Attached{Sch.Schedule{namespace,name,steps,(owners,bindings)}}:ConditionsAttached{ConditionedApplication{Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},bindings}}
    case Comp.AttachmentRejected{Sch.Schedule{namespace,name,steps,owners},bindings}:ConditionsInvalid{Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},bindings}
def attach_conditions(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> Comp.Evaluation<W.World<S,C,R,E>,B>,value:Application<S,C,R,E,H,Rows,observe,fold>,bindings:Comp.Bindings<W.World<S,C,R,E>,B,select>) -> ConditionAttachment<Application<S,C,R,E,H,Rows,observe,fold>,Comp.Bindings<W.World<S,C,R,E>,B,select>,ConditionedApplication<S,C,R,E,H,Rows,observe,fold,B,select>>:
  match value:
    case Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs}:conditions_attached(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~B,~select,schema,world,recipe,debug,plan,needs,Comp.attach(~S,~C,~R,~E,~H,~B,~select,Sch.Schedule{namespace,name,steps,owners},bindings))
def enabled_conditions(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> Comp.Evaluation<W.World<S,C,R,E>,B>,value:ConditionedApplication<S,C,R,E,H,Rows,observe,fold,B,select>,flag:Bool) -> ConditionedApplication<S,C,R,E,H,Rows,observe,fold,B,select>:
  match value:
    case ConditionedApplication{app,bindings}:ConditionedApplication{enabled(~S,~C,~R,~E,~H,~Rows,~observe,~fold,app,flag),bindings}
def conditions_snapshot_present(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> Comp.Evaluation<W.World<S,C,R,E>,B>,app:Application<S,C,R,E,H,Rows,observe,fold>,view:Description<S,Rows>,bindings:Comp.Bindings<W.World<S,C,R,E>,B,select>) -> ConditionedApplication<S,C,R,E,H,Rows,observe,fold,B,select> & Maybe<&2,ConditionDescription<S,Rows>>:
  match bindings:
    case Comp.Bindings{owner,+facts}:(ConditionedApplication{app,Comp.Bindings{owner,facts}},Some{ConditionDescription{view,facts}})
def conditions_snapshot_returned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> Comp.Evaluation<W.World<S,C,R,E>,B>,bindings:Comp.Bindings<W.World<S,C,R,E>,B,select>,observed:Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,Description<S,Rows>>) -> ConditionedApplication<S,C,R,E,H,Rows,observe,fold,B,select> & Maybe<&2,ConditionDescription<S,Rows>>:
  match observed:
    case (app,None{}):(ConditionedApplication{app,bindings},None{})
    case (app,Some{view}):conditions_snapshot_present(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~B,~select,app,view,bindings)
def snapshot_conditions(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> Comp.Evaluation<W.World<S,C,R,E>,B>,value:ConditionedApplication<S,C,R,E,H,Rows,observe,fold,B,select>) -> ConditionedApplication<S,C,R,E,H,Rows,observe,fold,B,select> & Maybe<&2,ConditionDescription<S,Rows>>:
  match value:
    case ConditionedApplication{app,bindings}:conditions_snapshot_returned(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~B,~select,bindings,snapshot(~S,~C,~R,~E,~H,~Rows,~observe,~fold,app))
def conditions_executed(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> Comp.Evaluation<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,schema:Schema.Schema<S,C,R>,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,plan:SP.Plan<S>,needs:List<&2,SP.Requirement<S>>,result:Sch.RunResult<S,C,R,E,H & Comp.Bindings<W.World<S,C,R,E>,B,select>,Comp.Error<BodyError>>) -> RunResult<ConditionedApplication<S,C,R,E,H,Rows,observe,fold,B,select>,S,Comp.Error<BodyError>>:
  match result:
    case Sch.Finished{Sch.Schedule{namespace,name,steps,(owners,bindings)},world,observations}:Finished{ConditionedApplication{Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},bindings},observations}
    case Sch.Failed{Sch.Schedule{namespace,name,steps,(owners,bindings)},world,error,observations}:Failed{ConditionedApplication{Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},bindings},error,observations}
    case Sch.Rejected{Sch.Schedule{namespace,name,steps,(owners,bindings)},world}:Rejected{ConditionedApplication{Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},bindings}}
def conditions_provisioned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> Comp.Evaluation<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,schema:Schema.Schema<S,C,R>,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,plan:SP.Plan<S>,result:SP.ProvisionResult<S,C,R,E,H & Comp.Bindings<W.World<S,C,R,E>,B,select>,Comp.Error<BodyError>>) -> RunResult<ConditionedApplication<S,C,R,E,H,Rows,observe,fold,B,select>,S,Comp.Error<BodyError>>:
  match result:
    case SP.Missing{SP.Provisioned{Sch.Schedule{namespace,name,steps,(owners,bindings)},needs},world,missing}:Missing{ConditionedApplication{Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},bindings},missing}
    case SP.Executed{result,needs}:conditions_executed(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~B,~select,~BodyError,~dispatch,schema,recipe,debug,plan,needs,result)
def run_conditions(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> Comp.Evaluation<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,value:ConditionedApplication<S,C,R,E,H,Rows,observe,fold,B,select>) -> RunResult<ConditionedApplication<S,C,R,E,H,Rows,observe,fold,B,select>,S,Comp.Error<BodyError>>:
  match value:
    case ConditionedApplication{Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},bindings}:conditions_provisioned(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~B,~select,~BodyError,~dispatch,schema,recipe,debug,plan,Comp.run_provisioned(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,~provision,SP.Provisioned{Sch.Schedule{namespace,name,steps,(owners,bindings)},needs},world))
