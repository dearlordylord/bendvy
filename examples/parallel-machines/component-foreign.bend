import Base
import ./component-probe.bend as Probe
import ./probe-declaration.bend as Declaration
import ./declarations.bend as D
import ./actor.bend as Actor
import ./bodies.bend as Body
import ./observation.bend as Observe
import ../../src/ecs/execution-app.bend as Ordinary
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/world.bend as W
import ../../src/ecs/deferred-command.bend as Deferred
import ../../test-fixtures/common/column-observation.bend as Common

# The foreign handle comes from a second actual World of the SAME schema.
# This core accepts created Worlds so the real WorldIO driver shares its path.
def source(~S:Data,world:Probe.World(~S)) -> String:
  match world:
    case W.World{namespace,allocator,columns,resource,events,pending,registrations,next,clock,lifecycle}:"namespace=" ++ U32.show(namespace) ++ "/allocator=" ++ Common.allocator(allocator) ++ "/columns=" ++ Observe.store(~S,columns) ++ "/resource=" ++ Observe.resource(~S,resource) ++ "/clock=" ++ Common.clock(clock) ++ "/registrations=" ++ List.show(&2,W.RegistrationMeta,Common.registration,registrations) ++ "/next-system=" ++ U32.show(next) ++ "/legacy-events=" ++ Nat.show(List.length(&2,Unit,events)) ++ "/legacy-pending=" ++ Nat.show(List.length(&1,Deferred.Command<Probe.World(~S)>,pending)) ++ "/lifecycle=" ++ Observe.journal(~S,lifecycle)
def defined(~S:Data,foreign:String,result:Ordinary.Built<Probe.Application(~S),Probe.World(~S),Actor.Local<S>>) -> IO(String):
  match result:
    case Ordinary.Built{app}:IO.bind(Probe.Application(~S) & Ordinary.Status<String,String>,String,Probe.run_once(~S,app),result => IO.pure(String,Probe.final(~S,"foreign{" ++ foreign ++ "}",result)))
    case Ordinary.BuildRefused{_,_}:IO.pure(String,"ERROR:define")
def activated(~S:Data,target:Probe.World(~S),handle:W.Handle<S>,result:Probe.World(~S) & W.Status) -> IO(String):
  match result:
    case (foreign,W.Accepted{}):defined(~S,source(~S,foreign),Ordinary.define(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Actor.Ops(~S),~Actor.Local<S>,~String,~String,~Declaration.declaration(~S),~Actor.body(~S),target,"foreign-state-probe",Actor.Local{handle,Body.local(101,102)}))
    case (_,W.Rejected{_}):IO.pure(String,"ERROR:activate")
def reserved(~S:Data,target:Probe.World(~S),result:Probe.World(~S) & W.Reservation<S>) -> IO(String):
  match result:
    case (foreign,W.Reserved{+handle}):activated(~S,target,handle,W.activate(~S,~D.Store(~S),~D.Resources(~S),~Unit,foreign,handle))
    case (_,W.ReservationRejected{_}):IO.pure(String,"ERROR:reserve")
def target_activated(~S:Data,foreign:Probe.World(~S),result:Probe.World(~S) & W.Status) -> IO(String):
  match result:
    case (target,W.Accepted{}):reserved(~S,target,W.reserve_id(~S,~D.Store(~S),~D.Resources(~S),~Unit,foreign))
    case (_,W.Rejected{_}):IO.pure(String,"ERROR:target-activate")
def target_reserved(~S:Data,foreign:Probe.World(~S),result:Probe.World(~S) & W.Reservation<S>) -> IO(String):
  match result:
    case (target,W.Reserved{handle}):target_activated(~S,foreign,W.activate(~S,~D.Store(~S),~D.Resources(~S),~Unit,target,handle))
    case (_,W.ReservationRejected{_}):IO.pure(String,"ERROR:target-reserve")
def run(~S:Data,target:Probe.World(~S),foreign:Probe.World(~S)) -> IO(String):
  target_reserved(~S,foreign,W.reserve_id(~S,~D.Store(~S),~D.Resources(~S),~Unit,target))
def second_created(~S:Data,target:Probe.World(~S),result:W.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> IO(String):
  match result:
    case W.Created{_,foreign}:run(~S,target,foreign)
    case W.CreateRejected{_,_}:IO.pure(String,"ERROR:second-create")
def first_created(~S:Data,result:W.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> IO(String):
  match result:
    case W.Created{factory,target}:second_created(~S,target,W.create(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Probe.empty(~S),factory,Probe.resources(~S)))
    case W.CreateRejected{_,_}:IO.pure(String,"ERROR:first-create")
type Schema is Data:
  Schema{}
def main() -> IO(Unit):IO.bind(String,Unit,first_created(~Schema,W.create(~Schema,~D.Store(~Schema),~D.Resources(~Schema),~Unit,~Probe.empty(~Schema),W.factory(),Probe.resources(~Schema))),IO.print)
