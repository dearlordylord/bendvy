import Base
import ../../../src/ecs/owned-event-log.bend as Log
import model.bend as F
import schema.bend as Schema
import reader.bend as Reader
import events.bend as Event
import catalog.bend as Catalog
import observe.bend as O
import ../../../src/ecs/owner-product.bend as Product
import ../../../src/ecs/event-stream.bend as Stream
import ../../../src/ecs/event-runtime.bend as Ev
import ../../../src/ecs/owned-event-family-reader-runtime.bend as Core
import ../../../src/ecs/restore-public.bend as Public
import ../../../src/ecs/restore-data.bend as R
import ../../../src/ecs/decode-data.bend as D
import ../../../src/ecs/decode-construction.bend as Constructor
import ../../../src/ecs/snapshot-data.bend as Snapshot
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/transaction.bend as T

def nat_stream(~S:Data,value:Stream.Stream<S,Nat>) -> Stream.Stream<S,Nat> & String:O.stream(~S,~Nat,~Nat.show,value)
def change_stream(~S:Data,value:Stream.Stream<S,R.Change<S>>) -> Stream.Stream<S,R.Change<S>> & String:O.stream(~S,~R.Change<S>,~O.change(~S),value)
def family(~S:Data,value:Event.FamilyOwner(~S)) -> Event.FamilyOwner(~S) & String:O.product(~Stream.Stream<S,Nat>,~Stream.Stream<S,R.Change<S>>,~nat_stream(~S),~change_stream(~S),value)
def runtime(~S:Data,value:Event.Runtime(~S)) -> Event.Runtime(~S) & String:O.runtime(~S,~Event.FamilyOwner(~S),~Array<U32>,~family(~S),~O.u32_array,value)
def registry(~S:Data,value:Reader.Registry(~S)) -> Reader.Registry(~S) & String:O.registry(~S,~Ev.Input<Nat,Array<U32>>,~Unit,~Core.Reply<Unit,Array<U32>>,~Reader.runner(~S),value)
def reader(~S:Data,value:Reader.ReaderOwner(~S)) -> Reader.ReaderOwner(~S) & String:O.reader(~S,~Nat,~Event.State(~S),~Event.state_take(~S),~Event.state_put(~S),value)
def decode_error(value:D.Error) -> String:
  match value:
    case D.Invalid{path,expected,actual}:"invalid(" ++ path ++ "," ++ expected ++ "," ++ O.raw(actual) ++ ")"
    case D.FuelExhausted{path}:"fuel(" ++ path ++ ")"
def constructor_error(value:Constructor.Error<String>) -> String:
  match value:
    case Constructor.Validation{error}:"validation(" ++ decode_error(error) ++ ")"
    case Constructor.Constructor{error}:"constructor(" ++ error ++ ")"
def error(value:R.Error<String>) -> String:
  match value:
    case R.InvalidSnapshot{path}:"invalidSnapshot(" ++ path ++ ")"
    case R.UnsupportedVersion{version}:"version(" ++ O.raw(version) ++ ")"
    case R.DuplicateEntity{saved}:"duplicate(" ++ O.key(saved) ++ ")"
    case R.UnknownComponent{saved,name}:"unknownComponent(" ++ O.key(saved) ++ "," ++ name ++ ")"
    case R.UnknownResource{name}:"unknownResource(" ++ name ++ ")"
    case R.InvalidComponent{saved,name,error}:"invalidComponent(" ++ O.key(saved) ++ "," ++ name ++ "," ++ constructor_error(error) ++ ")"
    case R.InvalidResource{name,error}:"invalidResource(" ++ name ++ "," ++ constructor_error(error) ++ ")"
    case R.UnvalidatedDescriptor{name}:"unvalidated(" ++ name ++ ")"
    case R.Capacity{nextEntity}:"capacity(" ++ U32.show(nextEntity) ++ ")"
def binding(~S:Data,value:R.Binding<S>) -> String:
  match value:
    case R.Binding{saved,target}:O.key(saved) ++ "=>" ++ O.handle(~S,target)
def outcome(~S:Data,value:Public.Outcome<S,String>) -> String:
  match value:
    case Public.Restored{bindings}:"restored" ++ List.show(&2,R.Binding<S>,binding(~S),bindings)
    case Public.RestoreRejected{input,failure}:"rejected(" ++ O.snapshot(input) ++ "," ++ error(failure) ++ ")"
def drain(value:Maybe<&1,Catalog.DrainReceipt()>) -> Maybe<&1,Catalog.DrainReceipt()> & String:O.optional(~Catalog.DrainReceipt(),~O.product(~List<Log.Row<Array<U32>>>,~Unit,~O.owners(~Log.Row<Array<U32>>,~O.log_row),~O.unit),value)
def world_error(value:W.WorldError) -> String:
  match value:
    case W.MissingEntity{}:"MissingEntity"
    case W.CapacityExceeded{}:"CapacityExceeded"
    case W.NamespaceExhausted{}:"NamespaceExhausted"
    case W.SystemIdExhausted{}:"SystemIdExhausted"
def status(value:W.Status) -> String:
  match value:
    case W.Accepted{}:"Accepted"
    case W.Rejected{error}:world_error(error)
def reservation(~S:Data,value:W.Reservation<S>) -> String:
  match value:
    case W.Reserved{handle}:"reserved(" ++ O.handle(~S,handle) ++ ")"
    case W.ReservationRejected{error}:world_error(error)
