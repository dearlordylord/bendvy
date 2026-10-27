import Base
import ./declarations.bend as Ordinary
import ./receiver.bend as Receiver
import ./retry.bend as Retry
import ./observation.bend as Observe
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-composer-schema.bend as Schema
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/execution-reservation-materialization.bend as Materialize
import ../../src/ecs/execution-reservation-bundle.bend as Bundle
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/world.bend as W
import ../../src/ecs/world-io.bend as WorldIO
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/change-tick.bend as Tick

def observed(~S:Data,result:Retry.Outcome<S>) -> String:Retry.observed(~S,result)
def published(~S:Data,native:Bool,result:Bundle.Publication<S,Layout.columns(~S,Receiver.Components(~S)),Receiver.Resources(~S),Unit,Receiver.Components(~S)>) -> IO(String):
  match result:
    case Bundle.Materialized{world,_,_}:IO.bind(Retry.Outcome<S>,String,Retry.run(~S,native,world),result => IO.pure(String,observed(~S,result)))
    case Bundle.RefusedPublication{_,_,_,_}:IO.pure(String,"initial-publication-refused")
def clocked(~S:Data,native:Bool,handle:W.Handle<S>,result:Receiver.World(~S) & Tick.Tick) -> IO(String):
  match result:
    case (world,tick):published(~S,native,Materialize.apply_at(~S,~Receiver.Resources(~S),~Unit,~Receiver.Components(~S),Permission.EntityStructural{},world,handle,Product.Owner{Some{Ordinary.Actor{"ordinary",ALeaf{41}}},Some{Ordinary.Scratch{ALeaf{808}}}},tick))
def reserved(~S:Data,native:Bool,result:Receiver.World(~S) & W.Reservation<S>) -> IO(String):
  match result:
    case (world,W.Reserved{+handle}):clocked(~S,native,handle,W.write_clock(~S,~Layout.columns(~S,Receiver.Components(~S)),~Receiver.Resources(~S),~Unit,W.mark_pending(~S,~Layout.columns(~S,Receiver.Components(~S)),~Receiver.Resources(~S),~Unit,world,handle)))
    case (_,W.ReservationRejected{_}):IO.pure(String,"initial-reservation-refused")
def created(~S:Data,native:Bool,result:WorldIO.Creation<S,Layout.columns(~S,Receiver.Components(~S)),Receiver.Resources(~S),Unit>) -> IO(String):
  match result:
    case WorldIO.Created{world}:reserved(~S,native,W.reserve_id(~S,~Layout.columns(~S,Receiver.Components(~S)),~Receiver.Resources(~S),~Unit,Schema.initialized_world(~S,~Receiver.Components(~S),~Plan.layout(Ordinary.resources(~S)),~Unit,world)))
    case WorldIO.Refused{_}:IO.pure(String,"world-creation-refused")
def run(~S:Data,native:Bool) -> IO(String):
  IO.bind(WorldIO.Creation<S,Layout.columns(~S,Receiver.Components(~S)),Receiver.Resources(~S),Unit>,String,WorldIO.create(~S,~Layout.columns(~S,Receiver.Components(~S)),~Receiver.Resources(~S),~Unit,~Ordinary.empty(~S),Ordinary.initial_resources(~S)),result => created(~S,native,result))
def print_beta_native(_:Unit) -> IO(Unit):IO.bind(String,Unit,run(~Ordinary.Beta,True{}),value => IO.print("beta/native " ++ value))
def print_beta_serial(_:Unit) -> IO(Unit):IO.bind(Unit,Unit,IO.bind(String,Unit,run(~Ordinary.Beta,False{}),value => IO.print("beta/serial " ++ value)),print_beta_native)
def print_alpha_native(_:Unit) -> IO(Unit):IO.bind(Unit,Unit,IO.bind(String,Unit,run(~Ordinary.Alpha,True{}),value => IO.print("alpha/native " ++ value)),print_beta_serial)
def main() -> IO(Unit):IO.bind(Unit,Unit,IO.bind(String,Unit,run(~Ordinary.Alpha,False{}),value => IO.print("alpha/serial " ++ value)),print_alpha_native)
