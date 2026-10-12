import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as SchemaApp
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule.bend as Schedule
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule-description.bend as Named
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Fields
import ./ordinary-condition-declaration.bend as Condition
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
# The same closed ordinary Program derives operational routing and descriptions.
# Existing provision, step order, dispatch, condition truth, skip and barriers run
# unchanged. Stateful registered conditions/readers remain outside this adapter.
type Application<S:Data,C:Type,R:Type,E:Data,H:Type,Rows:Data,-observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,-fold:H -> H & List<&2,Fields.Fields<S>>,-width:Nat,-evaluate:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool> is Type:
  Application{scheduled:Schedule.Application<S,C,R,E,H,Rows,observe,fold>,program:Condition.Program<S,C,R,E,width,evaluate>}
type ConditionPlacement is Data:
  ConditionPlacement{position:Nat,slot:U32,name:Maybe<&2,String>}
type Description<S:Data,Rows:Data> is Data:
  Description{schedule:Named.Description<S,Rows>,conditions:List<&2,ConditionPlacement>}
def attached(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~width:Nat,~evaluate:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,program:Condition.Program<S,C,R,E,width,evaluate>,result:Schedule.Attachment<SchemaApp.Application<S,C,R,E,H,Rows,observe,fold>,Schedule.Application<S,C,R,E,H,Rows,observe,fold>>) -> Schedule.Attachment<SchemaApp.Application<S,C,R,E,H,Rows,observe,fold>,Application<S,C,R,E,H,Rows,observe,fold,width,evaluate>>:
  match result:
    case Schedule.Attached{scheduled}:Schedule.Attached{Application{scheduled,program}}
    case Schedule.Invalid{app}:Schedule.Invalid{app}
def validated(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~width:Nat,~evaluate:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,valid:Bool,app:SchemaApp.Application<S,C,R,E,H,Rows,observe,fold>,name:String,+program:Condition.Program<S,C,R,E,width,evaluate>) -> Schedule.Attachment<SchemaApp.Application<S,C,R,E,H,Rows,observe,fold>,Application<S,C,R,E,H,Rows,observe,fold,width,evaluate>>:
  match valid:
    case False{}:Schedule.Invalid{app}
    case True{}:attached(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~width,~evaluate,program,Schedule.attach(~S,~C,~R,~E,~H,~Rows,~observe,~fold,app,name,Condition.plan(~S,~C,~R,~E,~width,~evaluate,program)))
def attach(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~width:Nat,~evaluate:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,app:SchemaApp.Application<S,C,R,E,H,Rows,observe,fold>,name:String,+program:Condition.Program<S,C,R,E,width,evaluate>) -> Schedule.Attachment<SchemaApp.Application<S,C,R,E,H,Rows,observe,fold>,Application<S,C,R,E,H,Rows,observe,fold,width,evaluate>>:
  validated(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~width,~evaluate,Condition.valid(~S,~C,~R,~E,~width,~evaluate,program),app,name,program)
def enabled(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~width:Nat,~evaluate:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,app:Application<S,C,R,E,H,Rows,observe,fold,width,evaluate>,flag:Bool) -> Application<S,C,R,E,H,Rows,observe,fold,width,evaluate>:
  match app:
    case Application{scheduled,program}:Application{Schedule.enabled(~S,~C,~R,~E,~H,~Rows,~observe,~fold,scheduled,flag),program}
def condition_placement(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~width:Nat,~evaluate:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,+program:Condition.Program<S,C,R,E,width,evaluate>,placement:Named.Placement<S>) -> Maybe<&2,ConditionPlacement>:
  match placement:
    case Named.System{position,_,_,_,+slot,_}:Some{ConditionPlacement{position,slot,Condition.condition_name(~S,~C,~R,~E,~width,~evaluate,program,slot)}}
    case Named.Phase{_,_,_}:None{}
    case Named.Barrier{_,_}:None{}
def added(first:Maybe<&2,ConditionPlacement>,rest:List<&2,ConditionPlacement>) -> List<&2,ConditionPlacement>:
  match first:
    case None{}:rest
    case Some{view}:view <> rest
def placements(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~width:Nat,~evaluate:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,items:List<&2,Named.Placement<S>>,+program:Condition.Program<S,C,R,E,width,evaluate>) -> List<&2,ConditionPlacement>:
  match items:
    case []:[]
    case first <> rest:added(condition_placement(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~width,~evaluate,program,first),placements(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~width,~evaluate,rest,program))
def described(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~width:Nat,~evaluate:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,+program:Condition.Program<S,C,R,E,width,evaluate>,description:Named.Description<S,Rows>) -> Description<S,Rows>:
  match description:
    case Named.Description{original,+items}:Description{Named.Description{original,items},placements(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~width,~evaluate,items,program)}
def observed(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~width:Nat,~evaluate:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,+program:Condition.Program<S,C,R,E,width,evaluate>,result:Schedule.Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,Named.Description<S,Rows>>) -> Application<S,C,R,E,H,Rows,observe,fold,width,evaluate> & Maybe<&2,Description<S,Rows>>:
  match result:
    case (scheduled,None{}):(Application{scheduled,program},None{})
    case (scheduled,Some{view}):(Application{scheduled,program},Some{described(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~width,~evaluate,program,view)})
def snapshot(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~width:Nat,~evaluate:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,app:Application<S,C,R,E,H,Rows,observe,fold,width,evaluate>) -> Application<S,C,R,E,H,Rows,observe,fold,width,evaluate> & Maybe<&2,Description<S,Rows>>:
  match app:
    case Application{scheduled,program}:observed(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~width,~evaluate,program,Named.snapshot(~S,~C,~R,~E,~H,~Rows,~observe,~fold,scheduled))
def executed(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~width:Nat,~evaluate:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,~Error:Data,program:Condition.Program<S,C,R,E,width,evaluate>,result:Schedule.RunResult<Schedule.Application<S,C,R,E,H,Rows,observe,fold>,S,Error>) -> Schedule.RunResult<Application<S,C,R,E,H,Rows,observe,fold,width,evaluate>,S,Error>:
  match result:
    case Schedule.Finished{scheduled,observations}:Schedule.Finished{Application{scheduled,program},observations}
    case Schedule.Failed{scheduled,error,observations}:Schedule.Failed{Application{scheduled,program},error,observations}
    case Schedule.Rejected{scheduled}:Schedule.Rejected{Application{scheduled,program}}
    case Schedule.Missing{scheduled,requirements}:Schedule.Missing{Application{scheduled,program},requirements}
def run(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~width:Nat,~evaluate:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,~Error:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,app:Application<S,C,R,E,H,Rows,observe,fold,width,evaluate>) -> Schedule.RunResult<Application<S,C,R,E,H,Rows,observe,fold,width,evaluate>,S,Error>:
  match app:
    case Application{scheduled,program}:executed(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~width,~evaluate,~Error,program,Schedule.run(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,~dispatch,~evaluate,~provision,scheduled))
