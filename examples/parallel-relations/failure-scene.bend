import Base
import ./actor.bend as Actor
import ./setup.bend as Scene
import ./initialize.bend as Initialize
import ./scheduled.bend as Existing
import ./failure-initialize.bend as Attach
import ./failure-reader.bend as Reader
import ./failure-message-text.bend as Text
import ./failure-scheduled.bend as Scheduled
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/execution-relation-store.bend as Store
import ../../src/ecs/execution-relation-failure-channel.bend as Cursor
import ../../src/ecs/execution-relation-failure-local.bend as Local
import ../../src/ecs/execution-relation-failure-message.bend as Message
import ../../src/ecs/execution-stream-channel.bend as Channel
import ../../src/ecs/machine-stream-queue.bend as Queue
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-root-application.bend as Root
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/world.bend as W
import ../../src/ecs/change-tick.bend as Tick

type Schema is Data:
  Scene{}
def maintenance(value:Maybe<&2,Tick.Tick>) -> String:
  match value:
    case None{}:"none"
    case Some{tick}:Tick.show(tick)
def channel(value:Channel.Store<Message.Message<Schema,Scene.hierarchy(~Schema)>>) -> String:
  match value:
    case Channel.Store{Queue.Queue{_,_,size,dropped,_},older,at}:"retained=" ++ Nat.show(size) ++ ",dropped=" ++ Nat.show(dropped) ++ ",older=" ++ Nat.show(older) ++ ",maintained=" ++ maintenance(at)
def snapshot(bound:Scheduled.Bound(~Schema)) -> Scheduled.Bound(~Schema) & String:
  match bound:
    case Context.Bound{context,Root.Scheduled{App.State{W.World{namespace,allocator,columns,Product.Owner{Layout.ResourceSlot{Layout.Viewed{Store.Store{storedNamespace,graph,+failures,+sequence,+nextReader},cache},stamp},resource},events,pending,registrations,nextSystem,clock,lifecycle},Product.Owner{Product.Owner{author,Sys.Owner{readerNamespace,id,name,access,systemCursor,Local.Local{Cursor.Reader{cursorNamespace,readerId,+cursor},Reader.User{Actor.Session{+session},+calls,+received,+missed,+messages}}}},peer},guards,handler,stateBindings},plan,bindings,rules,deferred}}:
      (Context.Bound{context,Root.Scheduled{App.State{W.World{namespace,allocator,columns,Product.Owner{Layout.ResourceSlot{Layout.Viewed{Store.Store{storedNamespace,graph,failures,sequence,nextReader},cache},stamp},resource},events,pending,registrations,nextSystem,clock,lifecycle},Product.Owner{Product.Owner{author,Sys.Owner{readerNamespace,id,name,access,systemCursor,Local.Local{Cursor.Reader{cursorNamespace,readerId,cursor},Reader.User{Actor.Session{session},calls,received,missed,messages}}}},peer},guards,handler,stateBindings},plan,bindings,rules,deferred}},channel(failures) ++ ",sequence=" ++ Nat.show(sequence) ++ ",nextReader=" ++ U32.show(nextReader) ++ ",cursor=" ++ Nat.show(cursor) ++ ",delivered-through=" ++ Nat.show(cursor) ++ ",messages=" ++ List.show(&2,Message.Message<Schema,Scene.hierarchy(~Schema)>,value => Text.message(Schema,Scene.hierarchy(~Schema),value),messages) ++ ",calls=" ++ Nat.show(calls) ++ ",received=" ++ Nat.show(received) ++ ",missed=" ++ Nat.show(missed) ++ ",session=" ++ U32.show(session))
def configure(finalApply:Bool,bound:Scheduled.Bound(~Schema)) -> Scheduled.Bound(~Schema):
  match bound:
    case Context.Bound{context,app}:Context.Bound{context,Root.configure(~Scheduled.State(~Schema),Settings.Settings{True{},finalApply,[],[]},app)}
def report(value:Context.RunReport<App.Report<String,String>>) -> String:
  match value:
    case Context.ContextRefused{}:"context-refused"
    case Context.RunReported{App.Finished{_}}:"finished"
    case Context.RunReported{App.Stopped{error,_}}:"stopped/" ++ error
    case Context.RunReported{App.Invalid{_}}:"invalid"
def show_final(prior:String,result:Scheduled.Bound(~Schema) & String) -> IO(Unit):
  match result:
    case (_,text):IO.print(prior ++ "/" ++ text)
def finished(prior:String,result:Scheduled.Run<Schema>) -> IO(Unit):
  match result:
    case Scheduled.CatalogueRefused{_,_}:IO.print(prior ++ "\ncatalogue-refused")
    case Scheduled.Returned{bound,status}:show_final(prior ++ "\nthird/" ++ report(status),snapshot(bound))
def second_snapshot(prior:String,result:Scheduled.Bound(~Schema) & String) -> IO(Unit):
  match result:
    case (bound,text):IO.bind(Scheduled.Run<Schema>,Unit,Scheduled.run(~Schema,bound),result => finished(prior ++ "/" ++ text,result))
def second(prior:String,result:Scheduled.Run<Schema>) -> IO(Unit):
  match result:
    case Scheduled.CatalogueRefused{_,_}:IO.print(prior ++ "\ncatalogue-refused")
    case Scheduled.Returned{bound,status}:second_snapshot(prior ++ "\nsecond/" ++ report(status),snapshot(bound))
def first_snapshot(prior:String,result:Scheduled.Bound(~Schema) & String) -> IO(Unit):
  match result:
    case (bound,text):IO.bind(Scheduled.Run<Schema>,Unit,Scheduled.run(~Schema,configure(True{},bound)),result => second(prior ++ "/" ++ text,result))
def first(result:Scheduled.Run<Schema>) -> IO(Unit):
  match result:
    case Scheduled.CatalogueRefused{_,_}:IO.print("catalogue-refused")
    case Scheduled.Returned{bound,status}:first_snapshot("first/" ++ report(status),snapshot(bound))
def attached(value:Attach.Definition<Schema>) -> IO(Unit):
  match value:
    case Attach.DefinitionReady{bound}:IO.bind(Scheduled.Run<Schema>,Unit,Scheduled.run(~Schema,configure(False{},bound)),first)
    case _:IO.print("reader-setup-refused")
def existing_ready(value:Existing.Definition<Schema>) -> IO(Unit):
  match value:
    case Existing.SceneReady{bound}:attached(Attach.attach(~Schema,bound,Reader.User{Actor.Session{777},0n,0n,0n,[]}))
    case _:IO.print("scene-registration-refused")
def initialized(value:Initialize.Initialization<Schema>) -> IO(Unit):
  match value:
    case Initialize.SceneInitialized{_,existing}:existing_ready(existing)
    case _:IO.print("scene-setup-refused")
def main() -> IO(Unit):
  initialized(Initialize.create(~Schema,W.factory(),Actor.Session{401},Actor.Session{601}))
