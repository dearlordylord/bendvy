import Base
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/dependency-application.bend as DepApp
type Handler is Type:
  Handler{token:Array<U32>,errors:U32}
def handle(owner:Handler,_:String) -> Handler & Exec.Handling:
  match owner:
    case Handler{token,errors}:(Handler{token,U32.add(errors,1)},Exec.Continue{})
def available(_:String) -> Bool:True{}
def event(value:Exec.Observation<String,String>) -> String:
  match value:
    case Exec.Ran{id,out}:U32.show(id) ++ "/success/" ++ out
    case Exec.BodyFailed{id,error,out}:U32.show(id) ++ "/error/" ++ error ++ "/" ++ out
    case Exec.Skipped{id}:U32.show(id) ++ "/disabled"
    case Exec.ConditionFailed{id,error}:U32.show(id) ++ "/condition-error/" ++ error
    case Exec.ConditionRejected{id}:U32.show(id) ++ "/condition-refused"
    case Exec.AdmissionRejected{id}:U32.show(id) ++ "/refused"
def event_id(value:Exec.Observation<String,String>) -> U32:
  match value:
    case Exec.Ran{id,_}:id
    case Exec.BodyFailed{id,_,_}:id
    case Exec.Skipped{id}:id
    case Exec.ConditionFailed{id,_}:id
    case Exec.ConditionRejected{id}:id
    case Exec.AdmissionRejected{id}:id
def event_le(left:Exec.Observation<String,String>,right:Exec.Observation<String,String>) -> Bool:
  U32.is_le(event_id(left),event_id(right))
def canonical(events:List<&2,Exec.Observation<String,String>>) -> List<&2,Exec.Observation<String,String>>:
  List.sort(~Exec.Observation<String,String>,~event_le,events)
def events(values:List<&2,Exec.Observation<String,String>>) -> String:
  List.show(&2,Exec.Observation<String,String>,event,canonical(values))
def invalid(reason:Plan.Invalid<String>) -> String:
  match reason:
    case Plan.Duplicate{id}:"duplicate/" ++ U32.show(id)
    case Plan.UnknownDependency{id}:"unknown-dependency/" ++ U32.show(id)
    case Plan.Missing{id,requirement}:"missing/" ++ U32.show(id) ++ "/" ++ requirement
    case Plan.Cycle{}:"cycle"
    case Plan.InvalidCondition{id}:"invalid-condition/" ++ U32.show(id)
def report(value:DepApp.Report<String,String>) -> String:
  match value:
    case DepApp.Finished{values}:events(values)
    case DepApp.Stopped{error,values}:"stopped/" ++ error ++ "/" ++ events(values)
    case DepApp.Invalid{reason}:"invalid/" ++ invalid(reason)
def handler_observed(errors:U32,result:Array<U32> & U32) -> String:
  match result:
    case (_,id):U32.show(id) ++ ":" ++ U32.show(errors)
def handler(owner:Handler) -> String:
  match owner:
    case Handler{token,errors}:handler_observed(errors,Array.get(U32,token,0))
