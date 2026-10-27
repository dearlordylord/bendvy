import Base
import ./extended-target.bend as Target
import ./extended-reader.bend as Read
import ../../src/ecs/lifetime-scope.bend as Scope
import ../../src/ecs/execution-lifetime-scope-store.bend as ScopeStore
import ../../src/ecs/lifecycle.bend as Life
import ../../src/ecs/execution-relation-failure-message.bend as FailureMessage
import ../../src/ecs/execution-relation-failure-channel.bend as Failure
import ../../src/ecs/execution-relation-store.bend as Store
import ../../src/ecs/execution-machine-state.bend as Cell
import ../../src/ecs/execution-machine-stream.bend as Stream
import ../../src/ecs/execution-stream-channel.bend as Channel
import ../../src/ecs/machine-stream-queue.bend as Queue
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/world.bend as W
import ../../src/ecs/change-tick.bend as Tick
import ./extended-flow.bend as Flow
import ./extended-save.bend as Save
import ./extended-restore.bend as Restore
import ./extended-admission.bend as Admission
import ./extended-declarations.bend as Schema
import ./observation.bend as BasicObserve
import ./declarations.bend as O
import ../parallel-machines/declarations.bend as Modes
import ../../src/ecs/decode-data.bend as D
import ../../src/ecs/execution-restore-extended-data.bend as Extended
import ../../src/ecs/restore-graph-data.bend as Graph
import ../../src/ecs/execution-save-gate.bend as Gate
import ../../src/ecs/execution-save-recipe.bend as Recipe
import ../../src/ecs/restore-data.bend as R
import ../../src/ecs/entity-key-render.bend as Key
import ../../src/ecs/entity-key.bend as K

def group(value:Graph.Group) -> String:
  match value:
    case Graph.Group{target,sources}:Key.show(target) ++ "<-" ++ List.show(&2,K.Key,Key.show,sources)
def relation(value:Graph.Relation) -> String:
  match value:
    case Graph.Relation{name,groups}:name ++ List.show(&2,Graph.Group,group,groups)
def current(value:Maybe<&2,D.Raw>) -> String:
  match value:
    case None{}:"missing"
    case Some{value}:BasicObserve.raw(value)
def machine(value:Extended.Machine) -> String:
  match value:
    case Extended.Machine{name,value,revision,_}:name ++ ":" ++ current(value) ++ "/revision=" ++ Nat.show(revision)
def member(value:Scope.Member) -> String:
  match value:
    case Scope.Member{name,key}:name ++ ":" ++ Key.show(key)
def snapshot(~S:Data,value:Extended.Snapshot<S>) -> String:
  match value:
    case Extended.Snapshot{basic,relations,machines,scopes}:BasicObserve.snapshot(~S,basic) ++ "/relations=" ++ List.show(&2,Graph.Relation,relation,relations) ++ "/machines=" ++ List.show(&2,Extended.Machine,machine,machines) ++ "/scopes=" ++ List.show(&2,Scope.Member,member,scopes)
def tick(value:Maybe<&2,Tick.Tick>) -> String:
  match value:
    case None{}:"none"
    case Some{Tick.Tick{epoch,low}}:Nat.show(epoch) ++ ":" ++ U32.show(low)
def intent(~S:Data,value:Cell.Intent<Modes.Mode>) -> String:
  match value:
    case Cell.Idle{}:"idle"
    case Cell.Initial{_}:"initial"
    case Cell.Transition{_,_,_}:"transition"
def owner_details(~S:Data,world:Schema.World(~S)) -> String:
  match world:
    case W.World{_,_,_,Product.Owner{Layout.ResourceSlot{Layout.Viewed{Store.Store{namespace,_,Channel.Store{Queue.Queue{_,_,size,dropped,batches},older,maintenance},sequence,nextReader},_},_},Product.Owner{Layout.ResourceSlot{Layout.Viewed{Cell.Cell{_,Stream.Store{Queue.Queue{_,_,cellSize,_,_},cellOlder,cellMaintenance},revision,stamp,nextStamp,cellSequence,initialPending,cellNamespace,cellIntent},_},_},_}},_,_,_,_,_,_}:"graph-owner=" ++ U32.show(namespace) ++ "/sequence=" ++ Nat.show(sequence) ++ "/nextReader=" ++ U32.show(nextReader) ++ "/channel=" ++ Nat.show(size) ++ ":" ++ Nat.show(dropped) ++ ":" ++ Nat.show(batches) ++ ":" ++ Nat.show(older) ++ ":" ++ tick(maintenance) ++ "/cell-owner=revision:" ++ Nat.show(revision) ++ "/stamp=" ++ tick(stamp) ++ "/nextStamp=" ++ tick(nextStamp) ++ "/sequence=" ++ Nat.show(cellSequence) ++ "/stream=" ++ Nat.show(cellSize) ++ ":" ++ Nat.show(cellOlder) ++ ":" ++ tick(cellMaintenance) ++ "/initialPending=" ++ Bool.show(initialPending) ++ "/intent=" ++ intent(~S,cellIntent)
def scope_summary(~S:Data,resources:Schema.Resources(~S)) -> Schema.Resources(~S) & String:
  match resources:
    case Product.Owner{graph,Product.Owner{cell,Layout.ResourceSlot{Layout.Viewed{ScopeStore.Store{+namespace,members},view},Life.Stamp{+added,+changed}}}}:(Product.Owner{graph,Product.Owner{cell,Layout.ResourceSlot{Layout.Viewed{ScopeStore.Store{namespace,members},view},Life.Stamp{added,changed}}}},"scope-owner=" ++ U32.show(namespace) ++ "/added=" ++ Tick.cursor_show(added) ++ "/changed=" ++ Tick.cursor_show(changed))
def scope_observed(~S:Data,result:Schema.World(~S) & String) -> String:
  match result:
    case (world,text):text ++ "/" ++ owner_details(~S,world)
def owner_values(~S:Data,world:Schema.World(~S)) -> String:scope_observed(~S,W.observe_resource(~S,~Layout.columns(~S,Schema.components(~S)),~Schema.Resources(~S),~Unit,~String,~scope_summary(~S),world))
def owner_clock(~S:Data,result:Schema.World(~S) & Tick.Tick) -> String:
  match result:
    case (world,tick):"worldClock=" ++ Tick.show(tick) ++ "/" ++ owner_values(~S,world)
def owners(~S:Data,world:Schema.World(~S)) -> String:owner_clock(~S,W.clock(~S,~Layout.columns(~S,Schema.components(~S)),~Schema.Resources(~S),~Unit,world))
def reader(~S:Data,value:Maybe<&1,Target.Reader(~S)>) -> String:
  match value:
    case None{}:"reader-registration-refused"
    case Some{Failure.Reader{namespace,id,cursor}}:U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ Nat.show(cursor)
def read_observed(~S:Data,result:Schema.World(~S) & Read.Reading(~S)) -> String:
  match result:
    case (world,Failure.Read{retained,messages,missed,tick}):owners(~S,world) ++ "/retainedReader=" ++ reader(~S,Some{retained}) ++ "/readMessages=" ++ Nat.show(List.length(&2,FailureMessage.Message<S,Schema.hierarchy(~S)>,messages)) ++ "/missed=" ++ Nat.show(missed) ++ "/readTick=" ++ Tick.show(tick)
    case (world,Failure.Refused{retained}):owners(~S,world) ++ "/readerRefused=" ++ reader(~S,Some{retained})
def read_world(~S:Data,world:Schema.World(~S),retained:Maybe<&1,Target.Reader(~S)>) -> String:
  match retained:
    case None{}:owners(~S,world) ++ "/reader-registration-refused"
    case Some{retained}:read_observed(~S,Read.read(~S,world,retained))
def saved(~S:Data,input:Extended.Snapshot<S>,mapping:List<&2,R.Binding<S>>,retained:Maybe<&1,Target.Reader(~S)>,result:Admission.Recipes(~S) & (Schema.World(~S) & Gate.Outcome<Extended.Snapshot<S>,Recipe.Refusal>)) -> String:
  match result:
    case (_,(world,Gate.Saved{after})):"before=" ++ snapshot(~S,input) ++ "/mapping=" ++ List.show(&2,R.Binding<S>,BasicObserve.binding(~S),mapping) ++ "/after=" ++ snapshot(~S,after) ++ "/" ++ read_world(~S,world,retained)
    case _:"save-refused"
def restored(~S:Data,retained:Maybe<&1,Target.Reader(~S)>,result:Restore.Outcome<S>) -> String:
  match result:
    case Restore.Restored{Restore.State{schema,input,_,_,_},world,_,mapping,_,_}:saved(~S,input,mapping,retained,Save.save(~S,schema,world))
    case Restore.InputRefused{_,_,_,_}:"input-refused"
    case Restore.ReceiverRefused{_,_}:"receiver-refused"
    case Restore.NamespaceRefused{_,_}:"namespace-refused"
    case Restore.StagingRefused{_,_,_}:"staging-refused"
    case Restore.RowsRefused{_,_,_}:"rows-refused"
    case Restore.ClearPartial{_,_,_}:"clear-partial"
    case Restore.Published{_,_,_}:"publication-partial"
    case Restore.MappingRefused{_,_,_,_}:"mapping-refused"
    case Restore.ResourcePartial{_,_,_,_,_}:"resource-partial"
def observed(~S:Data,result:Flow.Outcome<S>) -> String:
  match result:
    case Flow.Restored{_,_,retainedReader,Store.Refused{_,_},result}:restored(~S,retainedReader,result) ++ "/receiverRelation=refused"
    case Flow.Restored{_,_,retainedReader,_,result}:restored(~S,retainedReader,result) ++ "/receiverRelation=applied"
    case _:"source-or-target-refused"
def main() -> IO(Unit):IO.bind(Flow.Outcome<O.Alpha>,Unit,Flow.run(~O.Alpha),a => IO.bind(Unit,Unit,IO.print("alpha " ++ observed(~O.Alpha,a)),u => IO.bind(Flow.Outcome<O.Beta>,Unit,Flow.run(~O.Beta),b => IO.print("beta " ++ observed(~O.Beta,b)))))
