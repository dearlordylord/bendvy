import Base
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/relation-commands.bend as A
import ../../../../../src/ecs/check.bend as K
import ../../../../../src/ecs/system.bend as Sys
import ../../../../../src/ecs/schedule.bend as Sch
import ../../../../../src/ecs/schedule-checked.bend as Checked
import ./state.bend as State
import ./render.bend as Render

def World(~S:Data) -> Type: W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>
def noop(~S:Data,world:World(~S),_:Unit) -> Sys.Outcome<World(~S),K.Error,Unit>: Sys.Succeeded{world,Unit{}}
def Owner(~S:Data) -> Type: Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Unit,noop(~S)>
def dispatched(~S:Data,result:Sys.RunResult<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Unit,noop(~S)>) -> Owner(~S) & Sys.Outcome<World(~S),K.Error,Unit>:
  match result:
    case Sys.Completed{registry,outcome}:(registry,outcome)
    case Sys.RegistrationRejected{registry,world,_}:(registry,Sys.Failed{world,K.MissingRuntimeRequirements{["NoopRegistration"]}})
def dispatch(~S:Data,owner:Owner(~S),world:World(~S),_:U32) -> Owner(~S) & Sys.Outcome<World(~S),K.Error,Unit>:
  dispatched(~S,Sys.run_tracked(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~Unit,~K.Error,~Unit,~noop(~S),owner,world,Unit{}))
def skip(~S:Data,owner:Owner(~S),world:World(~S),_:U32) -> Owner(~S) & World(~S): (owner,world)
def observation(items:List<&2,Sch.Observation>) -> String:
  match items:
    case [Sch.Ran{_}]:"{\"called\":true,\"allowed\":true,\"ran\":true}"
    case [Sch.Skipped{_}]:"{\"called\":true,\"allowed\":false,\"ran\":false}"
    case _:"{\"scheduleObservationFailure\":true}"
type Value is Data: Value{result:String,registry:String}
def registry_actual(~S:Data,owner:Owner(~S)) -> String:
  match owner:
    case Sys.Registry{namespace,id,name,access,cursor}:"Registry(" ++ U32.show(namespace) ++ "," ++ U32.show(id) ++ "," ++ name ++ "," ++ List.show(&2,String,x => x,access) ++ "," ++ U32.show(cursor) ++ ")"
def registry_text(~S:Data,physical:Bool,owner:Owner(~S)) -> String:
  match physical:
    case True{}:registry_actual(~S,owner)
    case False{}:""
def completed(~S:Data,physical:Bool,world:World(~S),result:String,schedule:Sch.Schedule<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Owner(~S)>) -> World(~S) & Value:
  match schedule:
    case Sch.Schedule{_,_,_,owner}:(world,Value{result,registry_text(~S,physical,owner)})
def error(value:K.Error) -> String:
  match value:
    case K.MissingRuntimeRequirements{resources}:"{\"missingRuntimeRequirements\":" ++ Render.array(Render.strings(resources)) ++ "}"
def finished(~S:Data,physical:Bool,result:Sch.RunResult<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Owner(~S),K.Error>) -> World(~S) & Value:
  match result:
    case Sch.Finished{schedule,world,observations}:completed(~S,physical,world,observation(observations),schedule)
    case Sch.Failed{schedule,world,err,_}:completed(~S,physical,world,error(err),schedule)
    case Sch.Rejected{schedule,world}:completed(~S,physical,world,"{\"scheduleRejected\":true}",schedule)
def built(~S:Data,~condition:World(~S) -> U32 -> World(~S) & Result<K.Error,Bool>,physical:Bool,world:World(~S),result:Sch.Build<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Owner(~S)>) -> World(~S) & Value:
  match result:
    case Sch.Built{schedule}:finished(~S,physical,Checked.run_with_skip(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~Owner(~S),~K.Error,~skip(~S),~dispatch(~S),~condition,schedule,world))
    case Sch.Invalid{_}:(world,Value{"{\"invalidSchedule\":true}","InvalidSchedule"})
def identified(~S:Data,~condition:World(~S) -> U32 -> World(~S) & Result<K.Error,Bool>,physical:Bool,name:String,world:World(~S),identity:Owner(~S) & U32) -> World(~S) & Value:
  match identity:
    case (Sys.Registry{+namespace,+id,+storedName,+access,+cursor},_):built(~S,~condition,physical,world,Sch.build(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~Owner(~S),namespace,name,[Sch.System{id,0}],[id],Sys.Registry{namespace,id,storedName,access,cursor}))
def registered(~S:Data,~condition:World(~S) -> U32 -> World(~S) & Result<K.Error,Bool>,physical:Bool,name:String,result:Sys.RegistrationResult<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Unit,noop(~S)>) -> World(~S) & Value:
  match result:
    case Sys.Registered{world,registry}:identified(~S,~condition,physical,name,world,Sys.identity(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~Unit,~K.Error,~Unit,~noop(~S),registry))
    case Sys.RegistrationFailed{world}:(world,Value{"{\"registrationFailure\":true}","RegistrationFailed"})
def run(~S:Data,~condition:World(~S) -> U32 -> World(~S) & Result<K.Error,Bool>,physical:Bool,+name:String,world:World(~S)) -> World(~S) & Value:
  registered(~S,~condition,physical,name,Sys.register(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~Unit,~K.Error,~Unit,~noop(~S),world,name,[]))
