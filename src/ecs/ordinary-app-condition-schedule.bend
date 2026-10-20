import Base
import ./world.bend as W
import ./ordinary-app-schema.bend as SchemaApp
import ./ordinary-app-schedule.bend as Schedule
import ./ordinary-app-schedule-description.bend as Named
import ./ordinary-app-observation-data.bend as DTO
import ./ordinary-app-registration-fields.bend as Fields
import ./ordinary-condition-declaration.bend as Condition
import ./schedule.bend as Sch
import ./schedule-provision.bend as SP
import ./system.bend as Sys
# The same closed ordinary Program derives operational routing and descriptions.
# Existing provision, step order, dispatch, condition truth, skip and barriers run
# unchanged. Stateful registered conditions/readers remain outside this adapter.
# Ordinary scheduled App retaining materialized condition entries from the
# same closed Program used to route predicates. World/system owners remain
# single; stateful registered guards/readers use their separate binding APIs.
type Application<S:Data,C:Type,R:Type,E:Data,H:Type,Rows:Data,-observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,-fold:H -> H & List<&2,Fields.Fields<S>>,-Ids:Data,-declaration:Condition.Program<S,C,R,E,Ids>> is Type:
  Application{scheduled:Schedule.Application<S,C,R,E,H,Rows,observe,fold>,program:Condition.Entries<S>}
# Detached condition name/slot at an actual system position.
# Missing name remains None rather than creating a new condition declaration.
type ConditionPlacement is Data:
  ConditionPlacement{position:Nat,slot:U32,name:Maybe<&2,String>}
# Detached enabled-debug schedule view with its condition placements.
# Contains no guard owners, World save or additional gameplay authority.
type Description<S:Data,Rows:Data> is Data:
  Description{schedule:Named.Description<S,Rows>,conditions:List<&2,ConditionPlacement>}
def attached(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~Ids:Data,~declaration:Condition.Program<S,C,R,E,Ids>,program:Condition.Entries<S>,result:Schedule.Attachment<SchemaApp.Application<S,C,R,E,H,Rows,observe,fold>,Schedule.Application<S,C,R,E,H,Rows,observe,fold>>) -> Schedule.Attachment<SchemaApp.Application<S,C,R,E,H,Rows,observe,fold>,Application<S,C,R,E,H,Rows,observe,fold,Ids,declaration>>:
  match result:
    case Schedule.Attached{scheduled}:Schedule.Attached{Application{scheduled,program}}
    case Schedule.Invalid{app}:Schedule.Invalid{app}
def validated(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~Ids:Data,~declaration:Condition.Program<S,C,R,E,Ids>,valid:Bool,app:SchemaApp.Application<S,C,R,E,H,Rows,observe,fold>,name:String,+program:Condition.Entries<S>) -> Schedule.Attachment<SchemaApp.Application<S,C,R,E,H,Rows,observe,fold>,Application<S,C,R,E,H,Rows,observe,fold,Ids,declaration>>:
  match valid:
    case False{}:Schedule.Invalid{app}
    case True{}:attached(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Ids,~declaration,program,Schedule.attach(~S,~C,~R,~E,~H,~Rows,~observe,~fold,app,name,Condition.plan(~S,program)))
def prepared(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~Ids:Data,~declaration:Condition.Program<S,C,R,E,Ids>,app:SchemaApp.Application<S,C,R,E,H,Rows,observe,fold>,name:String,+program:Condition.Entries<S>) -> Schedule.Attachment<SchemaApp.Application<S,C,R,E,H,Rows,observe,fold>,Application<S,C,R,E,H,Rows,observe,fold,Ids,declaration>>:
  validated(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Ids,~declaration,Condition.valid(~S,program),app,name,program)
# Materialize/structurally validate the closed condition Program, then
# validate ordinary schedule attachment against existing registrations.
# Invalid returns the original App owner; Attached retains App and entries.
# No guard/system body or structural barrier executes while attaching.
def attach(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~Ids:Data,~declaration:Condition.Program<S,C,R,E,Ids>,app:SchemaApp.Application<S,C,R,E,H,Rows,observe,fold>,name:String,ids:Ids) -> Schedule.Attachment<SchemaApp.Application<S,C,R,E,H,Rows,observe,fold>,Application<S,C,R,E,H,Rows,observe,fold,Ids,declaration>>:
  prepared(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Ids,~declaration,app,name,Condition.materialize(~S,~C,~R,~E,~Ids,declaration,ids))
# Toggle debug, retaining App and materialized condition entries.
# Does not evaluate guards or registered systems.
def enabled(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~Ids:Data,~declaration:Condition.Program<S,C,R,E,Ids>,app:Application<S,C,R,E,H,Rows,observe,fold,Ids,declaration>,flag:Bool) -> Application<S,C,R,E,H,Rows,observe,fold,Ids,declaration>:
  match app:
    case Application{scheduled,program}:Application{Schedule.enabled(~S,~C,~R,~E,~H,~Rows,~observe,~fold,scheduled,flag),program}
def condition_placement(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~Ids:Data,~declaration:Condition.Program<S,C,R,E,Ids>,+program:Condition.Entries<S>,placement:Named.Placement<S>) -> Maybe<&2,ConditionPlacement>:
  match placement:
    case Named.System{position,_,_,_,+slot,_}:Some{ConditionPlacement{position,slot,Condition.condition_name(~S,program,slot)}}
    case Named.Phase{_,_,_}:None{}
    case Named.Barrier{_,_}:None{}
def added(first:Maybe<&2,ConditionPlacement>,rest:List<&2,ConditionPlacement>) -> List<&2,ConditionPlacement>:
  match first:
    case None{}:rest
    case Some{view}:view <> rest
def placements(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~Ids:Data,~declaration:Condition.Program<S,C,R,E,Ids>,items:List<&2,Named.Placement<S>>,+program:Condition.Entries<S>) -> List<&2,ConditionPlacement>:
  match items:
    case []:[]
    case first <> rest:added(condition_placement(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Ids,~declaration,program,first),placements(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Ids,~declaration,rest,program))
def described(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~Ids:Data,~declaration:Condition.Program<S,C,R,E,Ids>,+program:Condition.Entries<S>,description:Named.Description<S,Rows>) -> Description<S,Rows>:
  match description:
    case Named.Description{original,+items}:Description{Named.Description{original,items},placements(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Ids,~declaration,items,program)}
def observed(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~Ids:Data,~declaration:Condition.Program<S,C,R,E,Ids>,+program:Condition.Entries<S>,result:Schedule.Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,Named.Description<S,Rows>>) -> Application<S,C,R,E,H,Rows,observe,fold,Ids,declaration> & Maybe<&2,Description<S,Rows>>:
  match result:
    case (scheduled,None{}):(Application{scheduled,program},None{})
    case (scheduled,Some{view}):(Application{scheduled,program},Some{described(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Ids,~declaration,program,view)})
# Return App with optional detached schedule/condition descriptions.
# Disabled observation returns None; enabled names come from the same ordinary
# program. Does not evaluate predicates or advance system reader cursors.
def snapshot(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~Ids:Data,~declaration:Condition.Program<S,C,R,E,Ids>,app:Application<S,C,R,E,H,Rows,observe,fold,Ids,declaration>) -> Application<S,C,R,E,H,Rows,observe,fold,Ids,declaration> & Maybe<&2,Description<S,Rows>>:
  match app:
    case Application{scheduled,program}:observed(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Ids,~declaration,program,Named.snapshot(~S,~C,~R,~E,~H,~Rows,~observe,~fold,scheduled))
def executed(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~Ids:Data,~declaration:Condition.Program<S,C,R,E,Ids>,~Error:Data,program:Condition.Entries<S>,result:Schedule.RunResult<Schedule.Application<S,C,R,E,H,Rows,observe,fold>,S,Error>) -> Schedule.RunResult<Application<S,C,R,E,H,Rows,observe,fold,Ids,declaration>,S,Error>:
  match result:
    case Schedule.Finished{scheduled,observations}:Schedule.Finished{Application{scheduled,program},observations}
    case Schedule.Failed{scheduled,error,observations}:Schedule.Failed{Application{scheduled,program},error,observations}
    case Schedule.Rejected{scheduled}:Schedule.Rejected{Application{scheduled,program}}
    case Schedule.Missing{scheduled,requirements}:Schedule.Missing{Application{scheduled,program},requirements}
# Run the retained ordinary schedule with the matching Program evaluator.
# False skips dispatch; ordinary condition World changes are retained even
# when false because predicates are trusted World-threading callbacks.
# Provision/admission failures retain App; system failure preserves earlier
# successful steps and the failed runner's transaction contract. Structural
# visibility changes only at explicit barriers, not automatically at run end.
def run(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~Ids:Data,~declaration:Condition.Program<S,C,R,E,Ids>,~Error:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,app:Application<S,C,R,E,H,Rows,observe,fold,Ids,declaration>) -> Schedule.RunResult<Application<S,C,R,E,H,Rows,observe,fold,Ids,declaration>,S,Error>:
  match app:
    case Application{scheduled,program}:executed(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Ids,~declaration,~Error,program,Schedule.run(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,~dispatch,~Condition.evaluator(~S,~C,~R,~E,~Ids,declaration),~provision,scheduled))
