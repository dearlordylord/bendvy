import Base
import ./actor.bend as Actor
import ./setup.bend as Scene
import ./initialize.bend as Initialize
import ./failure-reader.bend as ExistingReader
import ./failure-message-text.bend as Text
import ./sparse-failure-reader.bend as Reader
import ./sparse-failure-application.bend as Application
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-relation-schema-setup.bend as Setup
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/execution-relation-world-publication.bend as Publication
import ../../src/ecs/execution-relation-operation.bend as Operation
import ../../src/ecs/execution-relation-store.bend as Store
import ../../src/ecs/execution-relation-failure-registration.bend as Registration
import ../../src/ecs/execution-relation-failure-channel.bend as Cursor
import ../../src/ecs/execution-relation-failure-local.bend as Local
import ../../src/ecs/execution-relation-failure-message.bend as Message
import ../../src/ecs/execution-resource-query-leaf.bend as Leaf
import ../../src/ecs/execution-generalized-root-application.bend as General
import ../../src/ecs/execution-parallel-root-application.bend as Root
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-stream-channel.bend as Channel
import ../../src/ecs/machine-stream-queue.bend as Queue
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/entity-allocator.bend as Allocator
import ../../src/ecs/entity-key.bend as Key
import ../../src/ecs/relation-types.bend as Relation
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/lifecycle.bend as Life
import ../../src/ecs/clock-state.bend as Clock

def Context() -> Data:Context.Context<Reader.Schema,Application.Resources(),Actor.resources(~Reader.Schema),{==}>
def Binding() -> Data:Context.Binding<Reader.Schema,Application.Resources(),Actor.resources(~Reader.Schema),{==},Actor.route(),Scene.hierarchy(~Reader.Schema),{==},{==},{==}>
def edge(value:Relation.Edge<Reader.Schema>) -> String:
  match value:
    case Relation.Edge{_,source,target}:Text.key(source) ++ "->" ++ Text.key(target)
def inverse(value:Relation.Inverse<Reader.Schema>) -> String:
  match value:
    case Relation.Inverse{family,target,sources}:Text.descriptor(Reader.Schema,family) ++ "/" ++ Text.key(target) ++ "/" ++ List.show(&2,Key.Key,Text.key,sources)
def graph(value:Relation.Graph<Reader.Schema>) -> String:
  match value:
    case Relation.Graph{edges,inverses}:"edges=" ++ List.show(&2,Relation.Edge<Reader.Schema>,edge,edges) ++ ",inverses=" ++ List.show(&2,Relation.Inverse<Reader.Schema>,inverse,inverses)
def tick(value:Maybe<&2,Tick.Tick>) -> String:
  match value:
    case None{}:"never"
    case Some{value}:Tick.show(value)
def stamp_text(value:Life.Stamp) -> String:
  match value:
    case Life.Stamp{added,changed}:tick(added) ++ "/" ++ tick(changed)
def seed_reason(value:Store.Reason) -> String:
  match value:
    case Store.NamespaceMismatch{}:"namespace-mismatch"
    case Store.OperationRefused{Operation.RelationError{error}}:Text.error(error)
    case Store.OperationRefused{Operation.HierarchyRequired{}}:"hierarchy-required"
def receipt(value:Store.Receipt<Reader.Schema>) -> String:
  match value:
    case Store.Applied{operation}:"applied/" ++ Text.operation(Reader.Schema,operation)
    case Store.Refused{operation,reason}:"refused/" ++ Text.operation(Reader.Schema,operation) ++ "/" ++ seed_reason(reason)
def observation(value:Exec.Observation<String,String>) -> String:
  match value:
    case Exec.Ran{id,out}:U32.show(id) ++ "/ran/" ++ out
    case Exec.BodyFailed{id,error,out}:U32.show(id) ++ "/body-error/" ++ error ++ "/" ++ out
    case Exec.Skipped{id}:U32.show(id) ++ "/skipped"
    case Exec.ConditionFailed{id,error}:U32.show(id) ++ "/condition-error/" ++ error
    case Exec.ConditionRejected{id}:U32.show(id) ++ "/condition-refused"
    case Exec.AdmissionRejected{id}:U32.show(id) ++ "/admission-refused"
def channel(value:Channel.Store<Message.Message<Reader.Schema,Scene.hierarchy(~Reader.Schema)>>) -> String:
  match value:
    case Channel.Store{Queue.Queue{_,_,size,dropped,_},older,at}:"retained=" ++ Nat.show(size) ++ ",dropped=" ++ Nat.show(dropped) ++ ",older=" ++ Nat.show(older)
def owner_text(owner:Reader.Owner()) -> String:
  match owner:
    case Sys.Owner{namespace,id,name,access,cursor,Local.Local{Cursor.Reader{readerNamespace,readerId,through},ExistingReader.User{Actor.Session{session},calls,received,missed,messages}}}:name ++ "/namespace=" ++ U32.show(namespace) ++ "/id=" ++ U32.show(id) ++ "/reader=" ++ U32.show(readerNamespace) ++ ":" ++ U32.show(readerId) ++ "/through=" ++ Nat.show(through) ++ "/calls=" ++ Nat.show(calls) ++ "/received=" ++ Nat.show(received) ++ "/missed=" ++ Nat.show(missed) ++ "/session=" ++ U32.show(session) ++ "/messages=" ++ List.show(&2,Message.Message<Reader.Schema,Scene.hierarchy(~Reader.Schema)>,value => Text.message(Reader.Schema,Scene.hierarchy(~Reader.Schema),value),messages)
def world_text(world:Application.World()) -> String:
  match world:
    case W.World{namespace,_,_,Product.Owner{Layout.ResourceSlot{Layout.Viewed{Store.Store{storedNamespace,actual,failures,sequence,nextReader},Store.View{cachedNamespace,cached,cachedFailures,cachedSequence,cachedNextReader}},stamp},Layout.ResourceSlot{Layout.Viewed{Actor.Session{session},cache},_}},_,_,_,_,clock,_}:"world=" ++ U32.show(namespace) ++ "/graph-namespace=" ++ U32.show(storedNamespace) ++ "/" ++ graph(actual) ++ "/" ++ channel(failures) ++ "/sequence=" ++ Nat.show(sequence) ++ "/nextReader=" ++ U32.show(nextReader) ++ "/cache-namespace=" ++ U32.show(cachedNamespace) ++ "/cache-" ++ graph(cached) ++ "/cache-" ++ channel(cachedFailures) ++ "/cache-sequence=" ++ Nat.show(cachedSequence) ++ "/cache-nextReader=" ++ U32.show(cachedNextReader) ++ "/stamp=" ++ stamp_text(stamp) ++ "/clock=" ++ Tick.show(Clock.now(clock)) ++ "/session=" ++ U32.show(session) ++ "/cache=" ++ U32.show(cache)
def report(value:Context.RunReport<App.Report<String,String>>) -> String:
  match value:
    case Context.ContextRefused{}:"context-refused"
    case Context.RunReported{App.Finished{events}}:"finished/" ++ List.show(&2,Exec.Observation<String,String>,observation,events)
    case Context.RunReported{App.Stopped{error,_}}:"stopped/" ++ error
    case Context.RunReported{App.Invalid{_}}:"invalid"
def finish(prior:String,result:Application.Run) -> IO(Unit):
  match result:
    case Application.CatalogueRefused{_,_}:IO.print(prior ++ "\ncatalogue-refused")
    case Application.Returned{Context.Bound{_,Root.Scheduled{App.State{General.Present{world,_},Product.Owner{left,right},_,Application.Handler{_,receipts},_},_,_,_,_}},status}:IO.print(prior ++ "\nsecond/" ++ report(status) ++ "\n" ++ owner_text(Reader.retire(left)) ++ "\n" ++ owner_text(Reader.retire(right)) ++ "\n" ++ world_text(world) ++ "/seed-receipts=" ++ List.show(&2,Store.Receipt<Reader.Schema>,receipt,receipts))
    case _:IO.print(prior ++ "\nphysical-inventory-refused")
def first(result:Application.Run) -> IO(Unit):
  match result:
    case Application.CatalogueRefused{_,_}:IO.print("catalogue-refused")
    case Application.Returned{app,status}:IO.bind(Application.Run,Unit,Application.run(app),result => finish("first/" ++ report(status),result))
def defined(value:Application.Definition) -> IO(Unit):
  match value:
    case Application.DefinitionReady{app}:IO.bind(Application.Run,Unit,Application.run(app),first)
    case _:IO.print("system-definition-refused")
def registered(frame:Publication.Frame<Reader.Schema,Reader.WC(),Application.Resources(),Unit>,allocator:Allocator.Allocator,result:Registration.Registration<Reader.Schema,Actor.resources(~Reader.Schema),Actor.route(),Scene.hierarchy(~Reader.Schema)>) -> Application.World() & Maybe<&1,Cursor.Reader<Reader.Schema,Scene.hierarchy(~Reader.Schema),Actor.resources(~Reader.Schema),Actor.route()>>:
  match frame result:
    case Publication.Frame{namespace,columns,events,pending,registrations,nextSystem,clock,lifecycle} Registration.Registered{resources,reader}:(W.World{namespace,allocator,columns,resources,events,pending,registrations,nextSystem,clock,lifecycle},Some{reader})
    case Publication.Frame{namespace,columns,events,pending,registrations,nextSystem,clock,lifecycle} Registration.Refused{resources}:(W.World{namespace,allocator,columns,resources,events,pending,registrations,nextSystem,clock,lifecycle},None{})
def register(world:Application.World()) -> Application.World() & Maybe<&1,Cursor.Reader<Reader.Schema,Scene.hierarchy(~Reader.Schema),Actor.resources(~Reader.Schema),Actor.route()>>:
  match world:
    case W.World{namespace,allocator,columns,resources,events,pending,registrations,nextSystem,clock,lifecycle}:registered(Publication.Frame{namespace,columns,events,pending,registrations,nextSystem,clock,lifecycle},allocator,Registration.register(~Reader.Schema,~Actor.resources(~Reader.Schema),~Actor.route(),~{==},~Scene.hierarchy(~Reader.Schema),~{==},~{==},~{==},resources))
def second_seeded(factory:W.Factory,firstReceipt:Store.Receipt<Reader.Schema>,left:Reader.Local(),right:Reader.Local(),result:Application.World() & (Binding() & Store.Receipt<Reader.Schema>)) -> IO(Unit):
  match result:
    case (world,(Context.Binding{context},receipt)):defined(Application.define(context,world,Application.Handler{factory,[firstReceipt,receipt]},left,right))
def first_seeded(factory:W.Factory,+handle:W.Handle<Reader.Schema>,tick:Tick.Tick,left:Reader.Local(),right:Reader.Local(),result:Application.World() & (Binding() & Store.Receipt<Reader.Schema>)) -> IO(Unit):
  match result:
    case (world,(binding,receipt)):second_seeded(factory,receipt,left,right,Publication.apply(~Reader.Schema,~Reader.WC(),~Application.Resources(),~Unit,~Actor.resources(~Reader.Schema),~{==},~Actor.route(),~{==},~Scene.hierarchy(~Reader.Schema),~{==},~{==},~{==},binding,world,Operation.Relate{handle,handle},tick))
def clocked(factory:W.Factory,binding:Binding(),+handle:W.Handle<Reader.Schema>,left:Reader.Local(),right:Reader.Local(),result:Application.World() & Tick.Tick) -> IO(Unit):
  match result:
    case (world,+tick):first_seeded(factory,handle,tick,left,right,Publication.apply(~Reader.Schema,~Reader.WC(),~Application.Resources(),~Unit,~Actor.resources(~Reader.Schema),~{==},~Actor.route(),~{==},~Scene.hierarchy(~Reader.Schema),~{==},~{==},~{==},binding,world,Operation.Relate{handle,handle},tick))
def second_registered(factory:W.Factory,context:Context(),handle:W.Handle<Reader.Schema>,left:Reader.Local(),result:Application.World() & Maybe<&1,Cursor.Reader<Reader.Schema,Scene.hierarchy(~Reader.Schema),Actor.resources(~Reader.Schema),Actor.route()>>) -> IO(Unit):
  match result:
    case (world,Some{reader}):clocked(factory,Scene.binding(~Reader.Schema,~Actor.Session,~U32,~Actor.project,context),handle,left,Local.Local{reader,ExistingReader.User{Actor.Session{888},0n,0n,0n,[]}},W.clock(~Reader.Schema,~Reader.WC(),~Application.Resources(),~Unit,world))
    case _:IO.print("right-reader-registration-refused")
def first_registered(factory:W.Factory,context:Context(),handle:W.Handle<Reader.Schema>,result:Application.World() & Maybe<&1,Cursor.Reader<Reader.Schema,Scene.hierarchy(~Reader.Schema),Actor.resources(~Reader.Schema),Actor.route()>>) -> IO(Unit):
  match result:
    case (world,Some{reader}):second_registered(factory,context,handle,Local.Local{reader,ExistingReader.User{Actor.Session{777},0n,0n,0n,[]}},register(world))
    case _:IO.print("left-reader-registration-refused")
def node_created(factory:W.Factory,context:Context(),result:Initialize.Node<Reader.Schema>) -> IO(Unit):
  match result:
    case Initialize.NodeReady{world,handle}:first_registered(factory,context,handle,register(world))
    case _:IO.print("node-refused")
def created(value:Context.Initialization<Reader.Schema,Actor.components(),Actor.resources(~Reader.Schema),Unit>) -> IO(Unit):
  match value:
    case Context.ContextCreated{factory,world,context}:node_created(factory,context,Initialize.node(~Reader.Schema,world))
    case _:IO.print("schema-refused")
def main() -> IO(Unit):
  created(Setup.create(~Reader.Schema,~Actor.components(),~Actor.resources(~Reader.Schema),~Unit,~Actor.Session,~Scene.owners(~Reader.Schema,~Actor.Session,~U32,~Actor.project),W.factory(),Actor.Session{401}))
