import Base
import ./ordinary-checked-bindings.bend as B
import ./checked-condition-schedule.bend as Checked
import ./world.bend as W
import ./system.bend as Sys
import ./schedule.bend as Sch
import ./schedule-provision.bend as SP
import ./ordinary-schema.bend as Schema
import ./ordinary-app-schema.bend as App
import ./ordinary-app-composer.bend as Build
import ./ordinary-app-schedule.bend as Schedule
import ./ordinary-app-recipe.bend as Tree
import ./ordinary-app-observation-data.bend as DTO
import ./ordinary-app-registration-fields.bend as Records
# Check descriptions derive from operational declarations and explicit bindings.
# The existing App, recipe, ordinary registration owners and real plan are retained.
type Application<S:Data,C:Type,R:Type,E:Data,H:Type,Rows:Data,-observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,-fold:H -> H & List<&2,Records.Fields<S>>,B:Type,-select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>> is Type:
  Application{app:Schedule.Application<S,C,R,E,H,Rows,observe,fold>,bindings:B.Bindings<W.World<S,C,R,E>,B,select>}
type Attachment<-Original:Type,-Guards:Type,-Scheduled:Type> is Type:
  Attached{app:Scheduled}
  Invalid{app:Original,bindings:Guards}
type Description<S:Data,Rows:Data> is Data:
  Description{original:Schedule.Description<S,Rows>,bindings:List<&2,B.Description>}
def attached(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,schema:Schema.Schema<S,C,R>,world:W.World<S,C,R,E>,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,plan:SP.Plan<S>,needs:List<&2,SP.Requirement<S>>,result:Checked.Attachment<S,C,R,E,H,B,select>) -> Attachment<Schedule.Application<S,C,R,E,H,Rows,observe,fold>,B.Bindings<W.World<S,C,R,E>,B,select>,Application<S,C,R,E,H,Rows,observe,fold,B,select>>:
  match result:
    case Checked.Attached{Sch.Schedule{namespace,name,steps,(owners,bindings)}}:Attached{Application{Schedule.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},bindings}}
    case Checked.AttachmentRejected{Sch.Schedule{namespace,name,steps,owners},bindings}:Invalid{Schedule.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},bindings}
def attach(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,value:Schedule.Application<S,C,R,E,H,Rows,observe,fold>,bindings:B.Bindings<W.World<S,C,R,E>,B,select>) -> Attachment<Schedule.Application<S,C,R,E,H,Rows,observe,fold>,B.Bindings<W.World<S,C,R,E>,B,select>,Application<S,C,R,E,H,Rows,observe,fold,B,select>>:
  match value:
    case Schedule.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs}:attached(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~B,~select,schema,world,recipe,debug,plan,needs,Checked.attach(~S,~C,~R,~E,~H,~B,~select,Sch.Schedule{namespace,name,steps,owners},bindings))
def enabled(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,value:Application<S,C,R,E,H,Rows,observe,fold,B,select>,flag:Bool) -> Application<S,C,R,E,H,Rows,observe,fold,B,select>:
  match value:
    case Application{app,bindings}:Application{Schedule.enabled(~S,~C,~R,~E,~H,~Rows,~observe,~fold,app,flag),bindings}
def snapshot_present(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,app:Schedule.Application<S,C,R,E,H,Rows,observe,fold>,view:Schedule.Description<S,Rows>,bindings:B.Bindings<W.World<S,C,R,E>,B,select>) -> Application<S,C,R,E,H,Rows,observe,fold,B,select> & Maybe<&2,Description<S,Rows>>:
  match bindings:
    case B.Bindings{owner,+facts}:(Application{app,B.Bindings{owner,facts}},Some{Description{view,facts}})
def snapshot_returned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,bindings:B.Bindings<W.World<S,C,R,E>,B,select>,observed:Schedule.Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,Schedule.Description<S,Rows>>) -> Application<S,C,R,E,H,Rows,observe,fold,B,select> & Maybe<&2,Description<S,Rows>>:
  match observed:
    case (app,None{}):(Application{app,bindings},None{})
    case (app,Some{view}):snapshot_present(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~B,~select,app,view,bindings)
def snapshot(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,value:Application<S,C,R,E,H,Rows,observe,fold,B,select>) -> Application<S,C,R,E,H,Rows,observe,fold,B,select> & Maybe<&2,Description<S,Rows>>:
  match value:
    case Application{app,bindings}:snapshot_returned(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~B,~select,bindings,Schedule.snapshot(~S,~C,~R,~E,~H,~Rows,~observe,~fold,app))
def executed(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,schema:Schema.Schema<S,C,R>,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,plan:SP.Plan<S>,needs:List<&2,SP.Requirement<S>>,result:Sch.RunResult<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>,Checked.Error<BodyError>>) -> Schedule.RunResult<Application<S,C,R,E,H,Rows,observe,fold,B,select>,S,Checked.Error<BodyError>>:
  match result:
    case Sch.Finished{Sch.Schedule{namespace,name,steps,(owners,bindings)},world,observations}:Schedule.Finished{Application{Schedule.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},bindings},observations}
    case Sch.Failed{Sch.Schedule{namespace,name,steps,(owners,bindings)},world,error,observations}:Schedule.Failed{Application{Schedule.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},bindings},error,observations}
    case Sch.Rejected{Sch.Schedule{namespace,name,steps,(owners,bindings)},world}:Schedule.Rejected{Application{Schedule.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},bindings}}
def provisioned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,schema:Schema.Schema<S,C,R>,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,plan:SP.Plan<S>,result:SP.ProvisionResult<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>,Checked.Error<BodyError>>) -> Schedule.RunResult<Application<S,C,R,E,H,Rows,observe,fold,B,select>,S,Checked.Error<BodyError>>:
  match result:
    case SP.Missing{SP.Provisioned{Sch.Schedule{namespace,name,steps,(owners,bindings)},needs},world,missing}:Schedule.Missing{Application{Schedule.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},bindings},missing}
    case SP.Executed{result,needs}:executed(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~B,~select,~BodyError,~dispatch,schema,recipe,debug,plan,needs,result)
def run(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,value:Application<S,C,R,E,H,Rows,observe,fold,B,select>) -> Schedule.RunResult<Application<S,C,R,E,H,Rows,observe,fold,B,select>,S,Checked.Error<BodyError>>:
  match value:
    case Application{Schedule.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},bindings}:provisioned(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~B,~select,~BodyError,~dispatch,schema,recipe,debug,plan,Checked.run_provisioned(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,~provision,SP.Provisioned{Sch.Schedule{namespace,name,steps,(owners,bindings)},needs},world))
