import Base
import ./payloads.bend as P
import ./declarations.bend as D
import ./body.bend as Body
import ./observation.bend as Observe
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-app.bend as Execute
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/execution-builder.bend as Build

def program(~S:Data,~mode:Q.Mode,~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Permit,~H,~B),book:B) -> B & D.Ops(~S,Permit,H):
  Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~D.Ops(~S),~D.declaration(~S,~mode),~Permit,~token,~H,~B,~builder,book)
def Runtime(~S:Data) -> Type: W.World<S,D.Store(~S),D.Resources(~S),Unit>
def Owner(~S:Data,~mode:Q.Mode) -> Type: Sys.Owner<S,D.Store(~S),D.Store(~S),D.Resources(~S),Unit,D.Ops(~S),Body.Local,String,String,program(~S,~mode),Body.run(~S)>
def QueryApp(~S:Data,~mode:Q.Mode) -> Type: Execute.Application<S,D.Store(~S),D.Resources(~S),Unit,D.Ops(~S),Body.Local,String,String,program(~S,~mode),Body.run(~S)>
def run_once(~S:Data,~mode:Q.Mode,application:QueryApp(~S,~mode)) -> IO(QueryApp(~S,~mode) & Execute.Status<String,String>):
  Execute.run(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.Ops(~S),~Body.Local,~String,~String,~program(~S,~mode),~Body.run(~S),application)
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
def foreign(~S:Data,~mode:Q.Mode,application:QueryApp(~S,~mode),result:W.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> IO(String):
  match application result:
    case Execute.Application{original,system} W.Created{_,world}:IO.bind(Sys.RunResult<Runtime(~S),Owner(~S,~mode),String,String>,String,Sys.run(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.Ops(~S),~Body.Local,~String,~String,~program(~S,~mode),~Body.run(~S),system,world),result => IO.pure(String,refused(~S,~mode,original,result)))
    case _ _:IO.pure(String,"ERROR: foreign creation")
def prefixed(prefix:String,result:IO(String)) -> IO(String):
  IO.bind(String,String,result,text => IO.pure(String,prefix ++ text))
def final(~S:Data,~mode:Q.Mode,factory:W.Factory,a:String,b:String,result:QueryApp(~S,~mode) & Execute.Status<String,String>) -> IO(String):
  match result:
    case (application,done):prefixed("statuses=[" ++ a ++ "," ++ b ++ "," ++ status(done) ++ "];",foreign(~S,~mode,application,W.create(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.empty(~S),factory,D.resource(~S))))
def second(~S:Data,~mode:Q.Mode,factory:W.Factory,a:String,result:QueryApp(~S,~mode) & Execute.Status<String,String>) -> IO(String):
  match result:
    case (application,done):IO.bind(QueryApp(~S,~mode) & Execute.Status<String,String>,String,run_once(~S,~mode,application),final(~S,~mode,factory,a,status(done)))
def first(~S:Data,~mode:Q.Mode,factory:W.Factory,result:QueryApp(~S,~mode) & Execute.Status<String,String>) -> IO(String):
  match result:
    case (application,done):IO.bind(QueryApp(~S,~mode) & Execute.Status<String,String>,String,run_once(~S,~mode,application),second(~S,~mode,factory,status(done)))
def registered(~S:Data,~mode:Q.Mode,factory:W.Factory,result:Execute.Built<QueryApp(~S,~mode),Runtime(~S),Body.Local>) -> IO(String):
  match result:
    case Execute.Built{application}:IO.bind(QueryApp(~S,~mode) & Execute.Status<String,String>,String,run_once(~S,~mode,application),first(~S,~mode,factory))
    case Execute.BuildRefused{_,_}:IO.pure(String,"ERROR: definition refused")
def defined(~S:Data,~mode:Q.Mode,factory:W.Factory,world:Runtime(~S)) -> IO(String):
  registered(~S,~mode,factory,Execute.define_framework(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.Ops(~S),~Body.Local,~String,~String,~program(~S,~mode),~Body.run(~S),world,"query",Body.Local{ALeaf{900},0}))
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
def created(~S:Data,~mode:Q.Mode,result:W.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> IO(String):
  match result:
    case W.Created{factory,world}: defined(~S,~mode,factory,spawn(~S,18n,world))
    case W.CreateRejected{_,_}:IO.pure(String,"ERROR: creation")
def run(~S:Data,~mode:Q.Mode) -> IO(String):
  created(~S,~mode,W.create(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.empty(~S),W.factory(),D.resource(~S)))
def error_final(~S:Data,~mode:Q.Mode,factory:W.Factory,a:String,result:QueryApp(~S,~mode) & Execute.Status<String,String>) -> IO(String):
  match result:
    case (application,done):prefixed("statuses=[" ++ a ++ "," ++ status(done) ++ "];",foreign(~S,~mode,application,W.create(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.empty(~S),factory,D.resource(~S))))
def error_first(~S:Data,~mode:Q.Mode,factory:W.Factory,result:QueryApp(~S,~mode) & Execute.Status<String,String>) -> IO(String):
  match result:
    case (application,done):IO.bind(QueryApp(~S,~mode) & Execute.Status<String,String>,String,run_once(~S,~mode,application),error_final(~S,~mode,factory,status(done)))
def error_registered(~S:Data,~mode:Q.Mode,factory:W.Factory,result:Execute.Built<QueryApp(~S,~mode),Runtime(~S),Body.Local>) -> IO(String):
  match result:
    case Execute.Built{application}:IO.bind(QueryApp(~S,~mode) & Execute.Status<String,String>,String,run_once(~S,~mode,application),error_first(~S,~mode,factory))
    case Execute.BuildRefused{_,_}:IO.pure(String,"ERROR: definition refused")
def error_created(~S:Data,~mode:Q.Mode,result:W.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> IO(String):
  match result:
    case W.Created{factory,world}: error_registered(~S,~mode,factory,Execute.define_framework(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.Ops(~S),~Body.Local,~String,~String,~program(~S,~mode),~Body.run(~S),spawn(~S,18n,world),"query",Body.Local{ALeaf{900},0}))
    case W.CreateRejected{_,_}:IO.pure(String,"ERROR: creation")
def run_error(~S:Data,~mode:Q.Mode) -> IO(String):
  error_created(~S,~mode,W.create(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.empty(~S),W.factory(),D.resource(~S)))
