import Base
import ../../src/ecs/execution-builder.bend as Build
import ./declarations.bend as D
import ./body.bend as Body
import ./observation.bend as Observe
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-app.bend as Execute
import ../../src/ecs/execution-system.bend as Sys

def completion(value:Sys.Completion<String,String>) -> String:
  match value:
    case Sys.Success{out}:"success/" ++ out
    case Sys.BodyError{error,out}:"error/" ++ error ++ "/" ++ out
def status(value:Execute.Status<String,String>) -> String:
  match value:
    case Execute.Ran{done}:completion(done)
    case Execute.AdmissionRefused{}:"refused"
def refused(~S:Data,original:W.World<S,D.Store(~S),D.Resources(~S),Unit>,result:Sys.RunResult<W.World<S,D.Store(~S),D.Resources(~S),Unit>,Sys.Owner<S,D.Store(~S),D.Store(~S),D.Resources(~S),Unit,D.Ops(~S),Body.Local<S>,String,String,Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~D.Ops(~S),~D.declaration(~S)),Body.run(~S)>,String,String>) -> IO(String):
  match result:
    case Sys.Refused{world,Sys.Owner{namespace,id,name,access,cursor,local}}:IO.pure(String,"refused;" ++ Observe.world(~S,original) ++ ";system={" ++ Observe.system(namespace,id,name,access,cursor) ++ "};local=" ++ Observe.local(~S,local) ++ ";foreign=" ++ Observe.world(~S,world))
    case Sys.Executed{_,_,_}:IO.pure(String,"ERROR: foreign system body executed")
def foreign(~S:Data,application:Execute.Application<S,D.Store(~S),D.Resources(~S),Unit,D.Ops(~S),Body.Local<S>,String,String,Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~D.Ops(~S),~D.declaration(~S)),Body.run(~S)>,result:W.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> IO(String):
  match application result:
    case Execute.Application{original,system} W.Created{_,world}:IO.bind(Sys.RunResult<W.World<S,D.Store(~S),D.Resources(~S),Unit>,Sys.Owner<S,D.Store(~S),D.Store(~S),D.Resources(~S),Unit,D.Ops(~S),Body.Local<S>,String,String,Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~D.Ops(~S),~D.declaration(~S)),Body.run(~S)>,String,String>,String,Sys.run(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.Ops(~S),~Body.Local<S>,~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~D.Ops(~S),~D.declaration(~S)),~Body.run(~S),system,world),result => refused(~S,original,result))
    case Execute.Application{_,_} W.CreateRejected{_,_}:IO.pure(String,"ERROR: foreign creation")
def final(~S:Data,factory:W.Factory,a:String,b:String,result:Execute.Application<S,D.Store(~S),D.Resources(~S),Unit,D.Ops(~S),Body.Local<S>,String,String,Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~D.Ops(~S),~D.declaration(~S)),Body.run(~S)> & Execute.Status<String,String>) -> IO(String):
  match result:
    case (application,done):IO.bind(String,String,foreign(~S,application,W.create(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.empty(~S),factory,D.resources(~S))),text => IO.pure(String,a ++ "|" ++ b ++ "|" ++ status(done) ++ "|" ++ text))
def second(~S:Data,factory:W.Factory,a:String,result:Execute.Application<S,D.Store(~S),D.Resources(~S),Unit,D.Ops(~S),Body.Local<S>,String,String,Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~D.Ops(~S),~D.declaration(~S)),Body.run(~S)> & Execute.Status<String,String>) -> IO(String):
  match result:
    case (application,done):IO.bind(Execute.Application<S,D.Store(~S),D.Resources(~S),Unit,D.Ops(~S),Body.Local<S>,String,String,Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~D.Ops(~S),~D.declaration(~S)),Body.run(~S)> & Execute.Status<String,String>,String,Execute.run(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.Ops(~S),~Body.Local<S>,~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~D.Ops(~S),~D.declaration(~S)),~Body.run(~S),application),result => final(~S,factory,a,status(done),result))
def first(~S:Data,factory:W.Factory,result:Execute.Application<S,D.Store(~S),D.Resources(~S),Unit,D.Ops(~S),Body.Local<S>,String,String,Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~D.Ops(~S),~D.declaration(~S)),Body.run(~S)> & Execute.Status<String,String>) -> IO(String):
  match result:
    case (application,done):IO.bind(Execute.Application<S,D.Store(~S),D.Resources(~S),Unit,D.Ops(~S),Body.Local<S>,String,String,Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~D.Ops(~S),~D.declaration(~S)),Body.run(~S)> & Execute.Status<String,String>,String,Execute.run(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.Ops(~S),~Body.Local<S>,~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~D.Ops(~S),~D.declaration(~S)),~Body.run(~S),application),result => second(~S,factory,status(done),result))
def registered(~S:Data,factory:W.Factory,result:Execute.Built<Execute.Application<S,D.Store(~S),D.Resources(~S),Unit,D.Ops(~S),Body.Local<S>,String,String,Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~D.Ops(~S),~D.declaration(~S)),Body.run(~S)>,W.World<S,D.Store(~S),D.Resources(~S),Unit>,Body.Local<S>>) -> IO(String):
  match result:
    case Execute.Built{application}:IO.bind(Execute.Application<S,D.Store(~S),D.Resources(~S),Unit,D.Ops(~S),Body.Local<S>,String,String,Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~D.Ops(~S),~D.declaration(~S)),Body.run(~S)> & Execute.Status<String,String>,String,Execute.run(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.Ops(~S),~Body.Local<S>,~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~D.Ops(~S),~D.declaration(~S)),~Body.run(~S),application),result => first(~S,factory,result))
    case Execute.BuildRefused{_,_}:IO.pure(String,"ERROR: definition refused")
def activate_more(~S:Data,first:W.Handle<S>,result:W.World<S,D.Store(~S),D.Resources(~S),Unit> & W.Status) -> W.World<S,D.Store(~S),D.Resources(~S),Unit> & W.Handle<S>:
  match result:
    case (world,_):(world,first)
def reserved_more(~S:Data,first:W.Handle<S>,result:W.World<S,D.Store(~S),D.Resources(~S),Unit> & W.Reservation<S>) -> W.World<S,D.Store(~S),D.Resources(~S),Unit> & W.Handle<S>:
  match result:
    case (world,W.Reserved{handle}):activate_more(~S,first,W.activate(~S,~D.Store(~S),~D.Resources(~S),~Unit,world,handle))
    case (world,W.ReservationRejected{_}):(world,first)
def spawn_more(~S:Data,fuel:Nat,result:W.World<S,D.Store(~S),D.Resources(~S),Unit> & W.Handle<S>) -> W.World<S,D.Store(~S),D.Resources(~S),Unit> & W.Handle<S>:
  match fuel result:
    case 0n result:result
    case 1n++rest, (world,first):spawn_more(~S,rest,reserved_more(~S,first,W.reserve_id(~S,~D.Store(~S),~D.Resources(~S),~Unit,world)))
def ready(~S:Data,factory:W.Factory,result:W.World<S,D.Store(~S),D.Resources(~S),Unit> & W.Handle<S>) -> IO(String):
  match result:
    case (world,handle):registered(~S,factory,Execute.define(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.Ops(~S),~Body.Local<S>,~String,~String,~D.declaration(~S),~Body.run(~S),world,"movement",Body.Local{ALeaf{501},0,handle}))
def activated(~S:Data,factory:W.Factory,+first:W.Handle<S>,result:W.World<S,D.Store(~S),D.Resources(~S),Unit> & W.Status) -> IO(String):
  match result:
    case (world,W.Accepted{}):ready(~S,factory,spawn_more(~S,15n,(world,first)))
    case (_,_):IO.pure(String,"ERROR: activate")
def reserved(~S:Data,factory:W.Factory,result:W.World<S,D.Store(~S),D.Resources(~S),Unit> & W.Reservation<S>) -> IO(String):
  match result:
    case (world,W.Reserved{+handle}):activated(~S,factory,handle,W.activate(~S,~D.Store(~S),~D.Resources(~S),~Unit,world,handle))
    case (_,_):IO.pure(String,"ERROR: reserve")
def created(~S:Data,result:W.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> IO(String):
  match result:
    case W.Created{factory,world}:reserved(~S,factory,W.reserve_id(~S,~D.Store(~S),~D.Resources(~S),~Unit,world))
    case W.CreateRejected{_,_}:IO.pure(String,"ERROR: create")
def run(~S:Data) -> IO(String):
  created(~S,W.create(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.empty(~S),W.factory(),D.resources(~S)))
