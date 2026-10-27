import Base
import ../../src/ecs/execution-builder.bend as Build
import ./declarations.bend as D
import ./actor.bend as Actor
import ./bodies.bend as Body
import ./probe-declaration.bend as Probe
import ./observation.bend as Observe
import ../../src/ecs/execution-app.bend as Ordinary
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-machine-state.bend as Machine
import ../../src/ecs/world.bend as W
import ../../src/ecs/deferred-command.bend as Deferred
import ../../src/ecs/change-tick.bend as Tick
import ../../test-fixtures/common/column-observation.bend as Common

def World(~S:Data) -> Type:W.World<S,D.Store(~S),D.Resources(~S),Unit>
def Application(~S:Data) -> Type:Ordinary.Application<S,D.Store(~S),D.Resources(~S),Unit,Actor.Ops(~S),Actor.Local<S>,String,String,Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Actor.Ops(~S),~Probe.declaration(~S)),Actor.body(~S)>
def empty(~S:Data,_:Unit) -> D.Store(~S):Layout.empty_columns(~S,D.component_layout(~S))
def resources(~S:Data) -> D.Resources(~S):Layout.ResourceSlot{Layout.initialize(D.layout(~S),Layout.AtLeaf{},Machine.empty(~S,~D.Key,~D.Mode)),Layout.unknown_stamp()}
def status(value:Ordinary.Status<String,String>) -> String:
  match value:
    case Ordinary.Ran{Sys.Success{out}}:out
    case Ordinary.Ran{Sys.BodyError{error,out}}:"error/" ++ error ++ "/" ++ out
    case Ordinary.AdmissionRefused{}:"admission-refused"
def lifecycle_status(value:W.Status) -> String:
  match value:
    case W.Accepted{}:"accepted"
    case W.Rejected{_}:"rejected"
def run_once(~S:Data,app:Application(~S)) -> IO(Application(~S) & Ordinary.Status<String,String>):
  Ordinary.run(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Actor.Ops(~S),~Actor.Local<S>,~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Actor.Ops(~S),~Probe.declaration(~S)),~Actor.body(~S),app)
def phase_returned(~S:Data,restore:World(~S) -> Application(~S),result:World(~S) & W.Status) -> Application(~S) & String:
  match result:
    case (world,value):(restore(world),lifecycle_status(value))
def activated(~S:Data,world:World(~S),handle:W.Handle<S>) -> World(~S) & W.Status:W.activate(~S,~D.Store(~S),~D.Resources(~S),~Unit,world,handle)
def deactivated(~S:Data,world:World(~S),handle:W.Handle<S>) -> World(~S) & W.Status:W.deactivate(~S,~D.Store(~S),~D.Resources(~S),~Unit,world,handle)
def change_phase(~S:Data,~change:World(~S) -> W.Handle<S> -> World(~S) & W.Status,app:Application(~S)) -> Application(~S) & String:
  match app:
    case Ordinary.Application{world,Sys.Owner{namespace,id,name,access,cursor,Actor.Local{+handle,retained}}}:phase_returned(~S,world => Ordinary.Application{world,Sys.Owner{namespace,id,name,access,cursor,Actor.Local{handle,retained}}},change(world,handle))
def final(~S:Data,trace:String,result:Application(~S) & Ordinary.Status<String,String>) -> String:
  match result:
    case (Ordinary.Application{W.World{namespace,allocator,columns,resource,events,pending,registrations,next,clock,lifecycle},Sys.Owner{ownerNamespace,id,name,access,cursor,local}},value):trace ++ "|" ++ status(value) ++ "|namespace=" ++ U32.show(namespace) ++ "/clock=" ++ Common.clock(clock) ++ "/columns=" ++ Observe.store(~S,columns) ++ "/resource=" ++ Observe.resource(~S,resource) ++ "/allocator=" ++ Common.allocator(allocator) ++ "/registrations=" ++ List.show(&2,W.RegistrationMeta,Common.registration,registrations) ++ "/next-system=" ++ U32.show(next) ++ "/legacy-events=" ++ Nat.show(List.length(&2,Unit,events)) ++ "/legacy-pending=" ++ Nat.show(List.length(&1,Deferred.Command<World(~S)>,pending)) ++ "/owner=" ++ U32.show(ownerNamespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,Observe.text,access) ++ ":" ++ Tick.cursor_show(cursor) ++ ":" ++ Observe.actor_local(~S,local) ++ "/lifecycle=" ++ Observe.journal(~S,lifecycle)
def dead(~S:Data,trace:String,result:Application(~S) & String) -> IO(String):
  match result:
    case (app,phase):IO.bind(Application(~S) & Ordinary.Status<String,String>,String,run_once(~S,app),result => IO.pure(String,final(~S,trace ++ "/deactivate=" ++ phase,result)))
def absent(~S:Data,trace:String,result:Application(~S) & Ordinary.Status<String,String>) -> IO(String):
  match result:
    case (app,value):dead(~S,trace ++ "|" ++ status(value),change_phase(~S,~deactivated(~S),app))
def active(~S:Data,trace:String,result:Application(~S) & String) -> IO(String):
  match result:
    case (app,phase):IO.bind(Application(~S) & Ordinary.Status<String,String>,String,run_once(~S,app),absent(~S,trace ++ "/activate=" ++ phase))
def pending(~S:Data,result:Application(~S) & Ordinary.Status<String,String>) -> IO(String):
  match result:
    case (app,value):active(~S,status(value),change_phase(~S,~activated(~S),app))
def defined(~S:Data,result:Ordinary.Built<Application(~S),World(~S),Actor.Local<S>>) -> IO(String):
  match result:
    case Ordinary.Built{app}:IO.bind(Application(~S) & Ordinary.Status<String,String>,String,run_once(~S,app),pending(~S))
    case Ordinary.BuildRefused{_,_}:IO.pure(String,"ERROR:define")
def reserved(~S:Data,result:World(~S) & W.Reservation<S>) -> IO(String):
  match result:
    case (world,W.Reserved{handle}):defined(~S,Ordinary.define(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Actor.Ops(~S),~Actor.Local<S>,~String,~String,~Probe.declaration(~S),~Actor.body(~S),world,"state-probe",Actor.Local{handle,Body.local(101,102)}))
    case (_,W.ReservationRejected{_}):IO.pure(String,"ERROR:reserve")
def run(~S:Data,world:World(~S)) -> IO(String):reserved(~S,W.reserve_id(~S,~D.Store(~S),~D.Resources(~S),~Unit,world))
def created(~S:Data,result:W.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> IO(String):
  match result:
    case W.Created{_,world}:run(~S,world)
    case W.CreateRejected{_,_}:IO.pure(String,"ERROR:create")
type Schema is Data:
  Schema{}
def main() -> IO(Unit):IO.bind(String,Unit,created(~Schema,W.create(~Schema,~D.Store(~Schema),~D.Resources(~Schema),~Unit,~empty(~Schema),W.factory(),resources(~Schema))),IO.print)
