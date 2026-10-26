import Base
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
def event_selected(selected:Bool,value:Exec.Observation<String,String>,rest:String) -> String:
  match selected:
    case True{}:event(value)
    case False{}:rest
def event_for(+id:U32,values:List<&2,Exec.Observation<String,String>>) -> String:
  match values:
    case []:"missing"
    case +first <> rest:event_selected(U32.is_eq(id,event_id(first)),first,event_for(id,rest))
def handler_observed(errors:U32,result:Array<U32> & U32) -> String:
  match result:
    case (_,id):U32.show(id) ++ ":" ++ U32.show(errors)
def handler(owner:Handler) -> String:
  match owner:
    case Handler{token,errors}:handler_observed(errors,Array.get(U32,token,0))
