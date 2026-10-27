import Base
import ./declarations.bend as D
import ./payloads.bend as P
import ./bodies.bend as Body
import ./events.bend as Events
import ./actor.bend as Actor
import ./peer.bend as Peer
import ./exit.bend as Exit
import ./conditions.bend as Cond
import ../../src/ecs/execution-machine-state.bend as State
import ../../src/ecs/execution-machine-stream.bend as Stream
import ../../src/ecs/machine-stream-queue.bend as Queue
import ../../src/ecs/machine.bend as M
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-capture.bend as Capture
import ../../src/ecs/chunk-column.bend as Column
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-lifecycle-notices.bend as Notice
import ../../src/ecs/lifecycle.bend as Lifecycle
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/world.bend as W
import ../../src/ecs/deferred-command.bend as Deferred
import ../../test-fixtures/common/column-observation.bend as Common

# Final observation consumes the actual retained owners after all ordinary runs.
def text(value:String) -> String:value
def bool(value:Bool) -> String:
  match value:
    case True{}:"true"
    case False{}:"false"
def numbers(values:Array<U32>) -> String:List.show(&1,U32,U32.show,Array.to_list(~U32,values))
def escaped_char(value:Char) -> String:
  match value:
    case '"':"\\\""
    case '\\':"\\\\"
    case '\n':"\\n"
    case '\r':"\\r"
    case '\t':"\\t"
    case value:SCon{value,SNil{}}
def escaped(value:String) -> String:
  match value:
    case SNil{}:""
    case SCon{head,tail}:escaped_char(head) ++ escaped(tail)
def quoted(value:String) -> String:"\"" ++ escaped(value) ++ "\""
def strings(values:Array<String>) -> String:List.show(&1,String,quoted,Array.to_list(~String,values))
def actor(~S:Data,value:P.Actor<S,D.Mode>) -> String:
  match value:
    case P.Actor{identity,mode,history}:"actor{" ++ numbers(identity) ++ "," ++ Body.mode_value(mode) ++ "," ++ strings(history) ++ "}"
def peer(~S:Data,value:P.PeerActor<S,D.Mode>) -> String:
  match value:
    case P.PeerActor{labels,mode}:"peer{" ++ strings(labels) ++ "," ++ Body.mode_value(mode) ++ "}"
def maybe_actor(~S:Data,value:Maybe<&1,P.Actor<S,D.Mode>>) -> String:
  match value:
    case None{}:"none"
    case Some{value}:actor(~S,value)
def maybe_peer(~S:Data,value:Maybe<&1,P.PeerActor<S,D.Mode>>) -> String:
  match value:
    case None{}:"none"
    case Some{value}:peer(~S,value)
def viewed_actor(~S:Data,value:Layout.Viewed<P.Actor<S,D.Mode>,D.Mode>) -> String:
  match value:
    case Layout.Viewed{owner,cache}:actor(~S,owner) ++ "/cache=" ++ Body.mode_value(cache)
def viewed_peer(~S:Data,value:Layout.Viewed<P.PeerActor<S,D.Mode>,D.Mode>) -> String:
  match value:
    case Layout.Viewed{owner,cache}:peer(~S,owner) ++ "/cache=" ++ Body.mode_value(cache)
def optional(~P:Type,~show:P -> String,value:Maybe<&1,P>) -> String:
  match value:
    case None{}:"none"
    case Some{owner}:show(owner)
def stamp(value:Lifecycle.Stamp) -> String:
  match value:
    case Lifecycle.Stamp{added,changed}:Tick.cursor_show(added) ++ "/" ++ Tick.cursor_show(changed)
def column(~S:Data,~P:Type,~show:P -> String,value:Column.Column<S,P>) -> String:
  match value:
    case Column.Leaf{values,stamps}:"leaf{" ++ List.show(&1,Maybe<&1,P>,optional(~P,~show),Array.to_list(~Maybe<&1,P>,values)) ++ ",stamps=" ++ List.show(&1,Lifecycle.Stamp,stamp,Array.to_list(~Lifecycle.Stamp,stamps)) ++ "}"
    case Column.Branch{half,left,right}:"branch{" ++ U32.show(half) ++ "," ++ column(~S,~P,~show,left) ++ "," ++ column(~S,~P,~show,right) ++ "}"
def store(~S:Data,value:D.Store(~S)) -> String:
  match value:
    case Product.Owner{Layout.ColumnSlot{left},Layout.ColumnSlot{right}}:column(~S,~Layout.Viewed<P.Actor<S,D.Mode>,D.Mode>,~viewed_actor(~S),left) ++ ";" ++ column(~S,~Layout.Viewed<P.PeerActor<S,D.Mode>,D.Mode>,~viewed_peer(~S),right)
def pending(value:M.Pending<D.Mode>) -> String:
  match value:
    case M.NoPending{}:"none"
    case M.Queued{mode,skipSame}:Body.mode_value(mode) ++ "/skip-same=" ++ bool(skipSame)
def previous(value:Maybe<&2,D.Mode>) -> String:
  match value:
    case None{}:"none"
    case Some{mode}:Body.mode_value(mode)
def slot(~S:Data,value:M.Slot<S,D.Key,D.Mode>) -> String:
  match value:
    case M.Missing{}:"missing"
    case M.Present{mode,next,prior,changed}:Body.mode_value(mode) ++ "/pending=" ++ pending(next) ++ "/previous=" ++ previous(prior) ++ "/changed=" ++ bool(changed)
def batch(value:Queue.Batch<M.Transition<D.Mode>>) -> String:
  match value:
    case Queue.Batch{serial,count,items}:Nat.show(serial) ++ ":" ++ Nat.show(count) ++ ":" ++ List.show(&2,M.Transition<D.Mode>,Events.event,items)
def stream(value:Stream.Store<D.Mode>) -> String:
  match value:
    case Stream.Store{Queue.Queue{front,back,size,dropped,batches},olderThrough,maintenance}:"front=" ++ List.show(&2,Queue.Batch<M.Transition<D.Mode>>,batch,front) ++ "/back=" ++ List.show(&2,Queue.Batch<M.Transition<D.Mode>>,batch,back) ++ "/size=" ++ Nat.show(size) ++ "/dropped=" ++ Nat.show(dropped) ++ "/batches=" ++ Nat.show(batches) ++ "/older=" ++ Nat.show(olderThrough) ++ "/maintenance=" ++ Tick.cursor_show(maintenance)
def namespace(value:Maybe<&2,U32>) -> String:
  match value:
    case None{}:"none"
    case Some{id}:U32.show(id)
def cell(~S:Data,value:State.Cell<S,D.Key,D.Mode>) -> String:
  match value:
    case State.Cell{current,events,revision,currentStamp,nextStamp,sequence,initialPending,origin,intent}:slot(~S,current) ++ "/revision=" ++ Nat.show(revision) ++ "/stamp=" ++ Tick.cursor_show(currentStamp) ++ "/next-stamp=" ++ Tick.cursor_show(nextStamp) ++ "/sequence=" ++ Nat.show(sequence) ++ "/initial-pending=" ++ bool(initialPending) ++ "/namespace=" ++ namespace(origin) ++ "/intent=" ++ Body.intent(intent) ++ "/stream{" ++ stream(events) ++ "}"
def resource(~S:Data,value:D.Resources(~S)) -> String:
  match value:
    case Layout.ResourceSlot{Layout.Viewed{owner,cache},stamp}:cell(~S,owner) ++ "/cache=" ++ Body.view(~S,cache) ++ "/resource-stamp=" ++ Common.stamp_text(Some{stamp})
def handle(~S:Data,value:W.Handle<S>) -> String:
  match value:
    case W.Handle{namespace,key}:U32.show(namespace) ++ ":" ++ Common.key(key)
def context(value:Body.Captured()) -> String:
  match value:
    case Capture.Captured{Body.Context{identity,history}}:numbers(identity) ++ ":" ++ strings(history)
def local(value:Body.Local()) -> String:
  match value:
    case Capture.Local{state,capture}:numbers(state) ++ "/capture=" ++ context(capture)
def actor_local(~S:Data,value:Actor.Local<S>) -> String:
  match value:
    case Actor.Local{target,retained}:handle(~S,target) ++ "/" ++ local(retained)
def peer_local(~S:Data,value:Peer.Local<S>) -> String:
  match value:
    case Peer.Local{target,retained}:handle(~S,target) ++ "/" ++ local(retained)
def reader(~S:Data,value:Events.Reader(~S)) -> String:
  match value:
    case Stream.Reader{namespace,id,cursor}:U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ Nat.show(cursor)
def maybe_reader(~S:Data,value:Maybe<&1,Events.Reader(~S)>) -> String:
  match value:
    case None{}:"unbound"
    case Some{value}:reader(~S,value)
def events_local(~S:Data,value:Events.Local<S>) -> String:
  match value:
    case Events.Local{owner,retained}:maybe_reader(~S,owner) ++ "/" ++ local(retained)
def phase(value:Cond.Phase) -> String:
  match value:
    case Cond.ExitPhase{}:"exit"
    case Cond.Transition{}:"transition"
    case Cond.Enter{}:"enter"
    case Cond.Running{}:"running"
def condition(value:Cond.Local) -> String:
  match value:
    case Cond.Local{identity,which}:numbers(identity) ++ "/" ++ phase(which)
def selector(value:Notice.Selector) -> String:
  match value:
    case Notice.Removed{key}:"removed/" ++ key
    case Notice.Despawned{}:"despawned"
def row(~S:Data,value:Notice.Row<S>) -> String:
  match value:
    case Notice.Row{sequence,Notice.Identity{namespace,key},tick}:Nat.show(sequence) ++ ":" ++ U32.show(namespace) ++ ":" ++ Common.key(key) ++ ":" ++ Tick.show(tick)
def channel(~S:Data,value:Notice.Channel<S>) -> String:
  match value:
    case Notice.Channel{which,next,previous,current,dropped}:selector(which) ++ "/next=" ++ Nat.show(next) ++ "/previous=" ++ List.show(&2,Notice.Row<S>,row(~S),previous) ++ "/current=" ++ List.show(&2,Notice.Row<S>,row(~S),current) ++ "/dropped=" ++ Nat.show(dropped)
def active_entry(value:Notice.Active) -> String:
  match value:
    case Notice.Active{id,which}:U32.show(id) ++ ":" ++ selector(which)
def journal(~S:Data,value:Notice.Journal<S>) -> String:
  match value:
    case Notice.Journal{namespace,channels,next,active}:U32.show(namespace) ++ "/channels=" ++ List.show(&2,Notice.Channel<S>,channel(~S),channels) ++ "/next=" ++ U32.show(next) ++ "/active=" ++ List.show(&2,Notice.Active,active_entry,active)
def world(~S:Data,value:W.World<S,D.Store(~S),Product.Owner<D.Resources(~S),Unit>,Unit>) -> String:
  match value:
    case W.World{namespace,allocator,columns,Product.Owner{machine,_},events,pending,registrations,next,clock,lifecycle}:"namespace=" ++ U32.show(namespace) ++ ";store=" ++ store(~S,columns) ++ ";machine=" ++ resource(~S,machine) ++ ";allocator=" ++ Common.allocator(allocator) ++ ";clock=" ++ Common.clock(clock) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,Common.registration,registrations) ++ ";next-system=" ++ U32.show(next) ++ ";legacy-events=" ++ Nat.show(List.length(&2,Unit,events)) ++ ";legacy-pending=" ++ Nat.show(List.length(&1,Deferred.Command<W.World<S,D.Store(~S),Product.Owner<D.Resources(~S),Unit>,Unit>>,pending)) ++ ";lifecycle=" ++ journal(~S,lifecycle)
