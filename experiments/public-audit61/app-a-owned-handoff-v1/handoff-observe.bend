import Base
import bundle.bend as B
import resources.bend as R
import recovery.bend as Recovery
import events.bend as Events
import observe.bend as Observe
import owner-observer.bend as Dump
import capture-observe.bend as Capture
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-recovery-system.bend as Recover
import /workspace/formal-proofs/bendvy/src/ecs/recoverable-component.bend as RC
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
import /workspace/formal-proofs/bendvy/src/ecs/event-family-runtime.bend as FR
import /workspace/formal-proofs/bendvy/src/ecs/event-stream.bend as Stream
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-declaration.bend as Event
import /workspace/formal-proofs/bendvy/src/ecs/lifecycle.bend as Life

def recovery(value:Recovery.Owned()) -> Recovery.Owned() & String:
  match value:
    case Recover.Owner{Sys.Registry{+ns,+id,+name,+access,+cursor},Unit{}}:(Recover.Owner{Sys.Registry{ns,id,name,access,cursor},Unit{}},"recovery{" ++ Capture.identity(ns,id,name,access) ++ ";cursor=" ++ U32.show(cursor) ++ ";capture=Unit}")
def handle_text(value:W.Handle<B.AuditWorkshop>) -> String:
  match value:
    case W.Handle{ns,id}:U32.show(ns) ++ ":" ++ U32.show(id)
def record_join(+handle:W.Handle<B.AuditWorkshop>,+stamp:Life.Stamp,observed:Maybe<&1,Array<U32>> & String) -> RC.Record<B.AuditWorkshop,Array<U32>> & String:
  (payload,text)=observed
  (RC.Record{handle,stamp,payload},"handle=" ++ handle_text(handle) ++ ";stamp=" ++ Dump.stamp(stamp) ++ ";payload=" ++ text)
def record(value:RC.Record<B.AuditWorkshop,Array<U32>>) -> RC.Record<B.AuditWorkshop,Array<U32>> & String:
  match value:
    case RC.Record{handle,stamp,payload}:record_join(handle,stamp,Dump.optional(~Array<U32>,~Dump.u32_array,payload))
def records_join(head:RC.Record<B.AuditWorkshop,Array<U32>> & String,tail:Recovery.Recovery() & String) -> Recovery.Recovery() & String:
  (head,ht)=head
  (tail,tt)=tail
  (head <> tail,"cons({" ++ ht ++ "}," ++ tt ++ ")")
def records(values:Recovery.Recovery()) -> Recovery.Recovery() & String:
  match values:
    case []:([],"[]")
    case head <> tail:records_join(record(head),records(tail))
def batch(value:Ev.Batch<Nat>) -> String:
  match value:
    case Ev.Batch{tick,values}:"(" ++ Nat.show(tick) ++ "," ++ List.show(&2,Nat,Nat.show,values) ++ ")"
def position(value:Ev.Position) -> String:
  match value:
    case Ev.Position{id,cursor,registeredAt}:"(" ++ U32.show(id) ++ "," ++ Nat.show(cursor) ++ "," ++ Nat.show(registeredAt) ++ ")"
def status(value:Ev.ReaderStatus) -> String:
  match value:
    case Ev.ReaderStatus{id,cursor,registeredAt,unread,lagged}:"(" ++ U32.show(id) ++ "," ++ Nat.show(cursor) ++ "," ++ Nat.show(registeredAt) ++ "," ++ Nat.show(unread) ++ "," ++ Bool.show(lagged) ++ ")"
def stream(value:Stream.Stream<B.AuditWorkshop,Nat>) -> String:
  match value:
    case Stream.Stream{Event.Domain{key},+batches,+positions,next,start,boundary,capacity,+dropped}:"stream{domain=" ++ key ++ ";batches=" ++ List.show(&2,Ev.Batch<Nat>,batch,batches) ++ ";positions=" ++ List.show(&2,Ev.Position,position,positions) ++ ";statuses=" ++ List.show(&2,Ev.ReaderStatus,status,Ev.reader_statuses(~Nat,positions,batches,dropped)) ++ ";nextReader=" ++ U32.show(next) ++ ";frameStart=" ++ Nat.show(start) ++ ";boundary=" ++ Nat.show(boundary) ++ ";capacity=" ++ Nat.show(capacity) ++ ";dropped=" ++ Nat.show(dropped) ++ "}"
def state(value:FR.State<Nat,Stream.Stream<B.AuditWorkshop,Nat>,Unit>) -> FR.State<Nat,Stream.Stream<B.AuditWorkshop,Nat>,Unit> & String:
  match value:
    case FR.State{+family,Unit{},+journal,+start}:(FR.State{family,Unit{},journal,start},"state{" ++ stream(family) ++ ";owners=Unit;journal=" ++ List.show(&2,Ev.Batch<Nat>,batch,journal) ++ ";journalSize=" ++ Nat.show(Ev.size(~Nat,journal)) ++ ";frameStart=" ++ Nat.show(start) ++ "}")
def runtime_join(+tick:Nat,observedWorld:B.World(R.Resources()) & String,observedState:FR.State<Nat,Stream.Stream<B.AuditWorkshop,Nat>,Unit> & String) -> Events.Runtime() & String:
  (world,wt)=observedWorld
  (family,ft)=observedState
  (Route.Runtime{world,family,tick},"runtime{tick=" ++ Nat.show(tick) ++ "|" ++ wt ++ "|" ++ ft ++ "}")
def runtime(value:Events.Runtime()) -> Events.Runtime() & String:
  match value:
    case Route.Runtime{world,family,tick}:runtime_join(tick,Observe.world(world),state(family))
def reader(value:Events.ReaderOwner()) -> Events.ReaderOwner() & String:
  match value:
    case Route.Reader{+ns,+id,+registryId}:(Route.Reader{ns,id,registryId},"reader{namespace=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";registryId=" ++ U32.show(registryId) ++ "}")
def publisher(value:Events.PublisherRegistry()) -> Events.PublisherRegistry() & String:
  match value:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}:(Sys.Registry{ns,id,name,access,cursor},"publisher{" ++ Capture.identity(ns,id,name,access) ++ ";cursor=" ++ U32.show(cursor) ++ "}")
def registry(value:Events.ReaderRegistry()) -> Events.ReaderRegistry() & String:
  match value:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}:(Sys.Registry{ns,id,name,access,cursor},"readerRegistry{" ++ Capture.identity(ns,id,name,access) ++ ";cursor=" ++ U32.show(cursor) ++ "}")
