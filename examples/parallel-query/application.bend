import Base
import ./payloads.bend as P
import ./declarations.bend as D
import ./body.bend as Body
import ./observation.bend as Observe
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-app.bend as Execute
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-query.bend as Q

def Runtime(~S:Data) -> Type: W.World<S,D.Store(~S),D.Resources(~S),Unit>
def Owner(~S:Data,~mode:Q.Mode) -> Type: Sys.Owner<S,D.Store(~S),D.Resources(~S),Unit,Q.Ops(~S,~String),Body.Local,String,String,D.declaration(~S,~mode),Body.run(~S)>
def QueryApp(~S:Data,~mode:Q.Mode) -> Type: Execute.Application<S,D.Store(~S),D.Resources(~S),Unit,Q.Ops(~S,~String),Body.Local,String,String,D.declaration(~S,~mode),Body.run(~S)>
def run_once(~S:Data,~mode:Q.Mode,application:QueryApp(~S,~mode)) -> QueryApp(~S,~mode) & Execute.Status<String,String>:
  Execute.run(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Q.Ops(~S,~String),~Body.Local,~String,~String,~D.declaration(~S,~mode),~Body.run(~S),application)
def completion(value:Sys.Completion<String,String>) -> String:
  match value:
    case Sys.Success{out}: "success/" ++ out
    case Sys.BodyError{error,out}: "error/" ++ error ++ "/" ++ out
def status(value:Execute.Status<String,String>) -> String:
  match value:
    case Execute.Ran{done}: completion(done)
    case Execute.AdmissionRefused{}: "refused"
def refused(~S:Data,~mode:Q.Mode,original:Runtime(~S),result:Sys.RunResult<Runtime(~S),Owner(~S,~mode),String,String>) -> String:
  match result:
    case Sys.Refused{world,Sys.Owner{namespace,id,name,access,cursor,local}}: "admission=refused;system={namespace=" ++ U32.show(namespace) ++ ",id=" ++ U32.show(id) ++ ",name=" ++ name ++ ",access=" ++ List.show(&2,String,value=>value,access) ++ ",cursor=" ++ Observe.maybe_tick(cursor) ++ ",local=" ++ Observe.local(local) ++ "};original={" ++ Observe.world(~S,original) ++ "};foreign={" ++ Observe.world(~S,world) ++ "}"
    case Sys.Executed{_,_,_}: "ERROR: foreign system invoked"
def foreign(~S:Data,~mode:Q.Mode,application:QueryApp(~S,~mode),result:W.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> String:
  match application result:
    case Execute.Application{original,system} W.Created{_,world}: refused(~S,~mode,original,Sys.run(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Q.Ops(~S,~String),~Body.Local,~String,~String,~D.declaration(~S,~mode),~Body.run(~S),system,world))
    case _ _: "ERROR: foreign creation"
def final(~S:Data,~mode:Q.Mode,factory:W.Factory,a:String,b:String,result:QueryApp(~S,~mode) & Execute.Status<String,String>) -> String:
  match result:
    case (application,done): "statuses=[" ++ a ++ "," ++ b ++ "," ++ status(done) ++ "];" ++ foreign(~S,~mode,application,W.create(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.empty(~S),factory,D.resource(~S)))
def second(~S:Data,~mode:Q.Mode,factory:W.Factory,a:String,result:QueryApp(~S,~mode) & Execute.Status<String,String>) -> String:
  match result:
    case (application,done): final(~S,~mode,factory,a,status(done),run_once(~S,~mode,application))
def first(~S:Data,~mode:Q.Mode,factory:W.Factory,result:QueryApp(~S,~mode) & Execute.Status<String,String>) -> String:
  match result:
    case (application,done): second(~S,~mode,factory,status(done),run_once(~S,~mode,application))
def registered(~S:Data,~mode:Q.Mode,factory:W.Factory,result:Execute.Built<QueryApp(~S,~mode),Runtime(~S),Body.Local>) -> String:
  match result:
    case Execute.Built{application}: first(~S,~mode,factory,run_once(~S,~mode,application))
    case Execute.BuildRefused{_,_}: "ERROR: definition refused"
def defined(~S:Data,~mode:Q.Mode,factory:W.Factory,world:Runtime(~S)) -> String:
  registered(~S,~mode,factory,Execute.define(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Q.Ops(~S,~String),~Body.Local,~String,~String,~D.declaration(~S,~mode),~Body.run(~S),world,"query",Body.Local{ALeaf{900},0}))
def activated(~S:Data,result:Runtime(~S) & W.Status) -> Runtime(~S):
  match result:
    case (world,_): world
def reserved(~S:Data,result:Runtime(~S) & W.Reservation<S>) -> Runtime(~S):
  match result:
    case (world,W.Reserved{handle}): activated(~S,W.activate(~S,~D.Store(~S),~D.Resources(~S),~Unit,world,handle))
    case (world,_): world
def spawn(~S:Data,fuel:Nat,world:Runtime(~S)) -> Runtime(~S):
  match fuel:
    case 0n: world
    case 1n+rest: spawn(~S,rest,reserved(~S,W.reserve_id(~S,~D.Store(~S),~D.Resources(~S),~Unit,world)))
def created(~S:Data,~mode:Q.Mode,result:W.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> String:
  match result:
    case W.Created{factory,world}: defined(~S,~mode,factory,spawn(~S,18n,world))
    case W.CreateRejected{_,_}: "ERROR: creation"
def run(~S:Data,~mode:Q.Mode) -> String:
  created(~S,~mode,W.create(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.empty(~S),W.factory(),D.resource(~S)))
