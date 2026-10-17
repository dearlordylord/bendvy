import Base
import bundle.bend as B
import resources.bend as R
import component.bend as C
import capture.bend as Capture
import ../../../src/ecs/ordinary-owned-event-binding.bend as Binding
import ../../../src/ecs/ordinary-owned-event-family-reader-binding.bend as Setup
import ../../../src/ecs/ordinary-owned-event-family-reader.bend as Reader
import ../../../src/ecs/ordinary-owned-event-family-reader-query.bend as ReaderQuery
import ../../../src/ecs/ordinary-owned-event-family-write.bend as Write
import ../../../src/ecs/ordinary-owned-event-family-publisher.bend as Publisher
import ../../../src/ecs/ordinary-owned-event-declaration.bend as D
import ../../../src/ecs/ordinary-owned-event.bend as Pub
import ../../../src/ecs/owned-event-log.bend as Log
import ../../../src/ecs/ordinary-event-declaration.bend as Event
import ../../../src/ecs/ordinary-event-family.bend as Family
import ../../../src/ecs/owned-event-key-route.bend as Key
import ../../../src/ecs/event-family-routing.bend as Route
import ../../../src/ecs/event-family-runtime.bend as FR
import ../../../src/ecs/event-stream.bend as Stream
import ../../../src/ecs/event-runtime.bend as Ev
import ../../../src/ecs/owned-event-family-reader-query.bend as Core
import ../../../src/ecs/ordinary-query-declaration.bend as Decl
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/component.bend as Component
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/owner-product.bend as Product
def domain() -> Pub.Domain<B.AuditWorkshop,Array<U32>>:
  Pub.domain(~B.AuditWorkshop,~Array<U32>,"RecoveredCargo")
def path() -> Product.Lens<R.Resources(),Log.Log<Array<U32>>,R.User() & Unit>:
  Binding.right_path(~R.User(),~Log.Log<Array<U32>>,~Array<U32>,~Unit,~Binding.identity_lens(~Log.Log<Array<U32>>))
def binding() -> Binding.Binding<B.AuditWorkshop,R.Resources(),Array<U32>,R.User() & Unit,Nat,path(),Key.inject_leaf,Key.select_leaf,domain()>:
  Binding.under_resource(~B.AuditWorkshop,~R.User(),~Log.Log<Array<U32>>,~Array<U32>,~Unit,~Nat,~Binding.identity_lens(~Log.Log<Array<U32>>),~Key.inject_leaf,~Key.select_leaf,~domain(),Binding.leaf(~B.AuditWorkshop,~Array<U32>,~domain()))
def Descriptor() -> Data:
  Setup.Setup<B.AuditWorkshop,R.Resources(),Array<U32>,R.User() & Unit,Nat,Event.Domain<B.AuditWorkshop,Nat>,Stream.Stream<B.AuditWorkshop,Nat>,path(),Key.inject_leaf,Key.select_leaf,domain(),Family.leaf_make(~B.AuditWorkshop,~Nat),Family.leaf_sync(~B.AuditWorkshop,~Nat),Family.leaf_frame(~B.AuditWorkshop,~Nat),Family.leaf_retain(~B.AuditWorkshop,~Nat),Family.leaf_inventory(~B.AuditWorkshop,~Nat),Family.selected_leaf(~B.AuditWorkshop,~Nat),Family.replaced_leaf(~B.AuditWorkshop,~Nat)>
def descriptor() -> Descriptor():
  Setup.under_resource(~B.AuditWorkshop,~R.User(),~Log.Log<Array<U32>>,~Array<U32>,~Unit,~Nat,~Event.Domain<B.AuditWorkshop,Nat>,~Stream.Stream<B.AuditWorkshop,Nat>,~Binding.identity_lens(~Log.Log<Array<U32>>),~Key.inject_leaf,~Key.select_leaf,~domain(),~Family.leaf_make(~B.AuditWorkshop,~Nat),~Family.leaf_sync(~B.AuditWorkshop,~Nat),~Family.leaf_frame(~B.AuditWorkshop,~Nat),~Family.leaf_retain(~B.AuditWorkshop,~Nat),~Family.leaf_inventory(~B.AuditWorkshop,~Nat),~Family.selected_leaf(~B.AuditWorkshop,~Nat),~Family.replaced_leaf(~B.AuditWorkshop,~Nat),Setup.leaf(~B.AuditWorkshop,~Array<U32>,~domain()))
def Runtime() -> Type:
  Route.Runtime<B.AuditWorkshop,B.Store,R.Resources(),Nat,FR.State<Nat,Stream.Stream<B.AuditWorkshop,Nat>,Unit>>
def setup(world:B.World(R.Resources())) -> Runtime():
  Reader.setup(~B.AuditWorkshop,~B.Store,~R.Resources(),~Array<U32>,~(R.User() & Unit),~Nat,~Event.Domain<B.AuditWorkshop,Nat>,~Stream.Stream<B.AuditWorkshop,Nat>,~path(),~Key.inject_leaf,~Key.select_leaf,~domain(),~Family.leaf_make(~B.AuditWorkshop,~Nat),~Family.leaf_sync(~B.AuditWorkshop,~Nat),~Family.leaf_frame(~B.AuditWorkshop,~Nat),~Family.leaf_retain(~B.AuditWorkshop,~Nat),~Family.leaf_inventory(~B.AuditWorkshop,~Nat),~Family.selected_leaf(~B.AuditWorkshop,~Nat),~Family.replaced_leaf(~B.AuditWorkshop,~Nat),~Unit,descriptor(),world,Unit{},2n)
def PublishOps() -> Type -> Type:
  Write.Ops(~B.AuditWorkshop,~Array<U32>,~domain())
def declaration() -> D.Declaration<B.AuditWorkshop,B.World(R.Resources()),List<Array<U32>>,PublishOps(),Write.grant(~B.AuditWorkshop,~B.Store,~R.Resources(),~Array<U32>,~(R.User() & Unit),~Nat,~path(),~Key.inject_leaf,~domain())>:
  Write.declaration(~B.AuditWorkshop,~B.Store,~R.Resources(),~Array<U32>,~(R.User() & Unit),~Nat,~path(),~Key.inject_leaf,~Key.select_leaf,~domain(),~binding())
def publish_body(~H:Type,~cap:PublishOps()(H),incoming:Array<U32>,owner:H) -> H & (T.Outcome<Unit> & Unit):
  (Pub.emit(~B.AuditWorkshop,~Array<U32>,~domain(),~H,~cap,owner,incoming),(T.Success{},Unit{}))
def PublisherRegistry() -> Type:
  Publisher.Registry(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~List<Array<U32>>,~PublishOps(),~Write.grant(~B.AuditWorkshop,~B.Store,~R.Resources(),~Array<U32>,~(R.User() & Unit),~Nat,~path(),~Key.inject_leaf,~domain()),~declaration(),~Array<U32>,~Unit,~Unit,~publish_body)
def define_publisher(world:B.World(R.Resources())) -> Sys.RegistrationResult<B.AuditWorkshop,B.Store,R.Resources(),Nat,Array<U32>,Unit,Publisher.Reply<Unit,Unit,List<Array<U32>>>,Publisher.runner(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~List<Array<U32>>,~PublishOps(),~Write.grant(~B.AuditWorkshop,~B.Store,~R.Resources(),~Array<U32>,~(R.User() & Unit),~Nat,~path(),~Key.inject_leaf,~domain()),~declaration(),~Array<U32>,~Unit,~Unit,~publish_body)>:
  Publisher.define(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~List<Array<U32>>,~PublishOps(),~Write.grant(~B.AuditWorkshop,~B.Store,~R.Resources(),~Array<U32>,~(R.User() & Unit),~Nat,~path(),~Key.inject_leaf,~domain()),~declaration(),~Array<U32>,~Unit,~Unit,~publish_body,world,"PublishRecoveredCargo")
def publish(registry:PublisherRegistry(),world:B.World(R.Resources()),incoming:Array<U32>) -> Sys.RunResult<B.AuditWorkshop,B.Store,R.Resources(),Nat,Array<U32>,Unit,Publisher.Reply<Unit,Unit,List<Array<U32>>>,Publisher.runner(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~List<Array<U32>>,~PublishOps(),~Write.grant(~B.AuditWorkshop,~B.Store,~R.Resources(),~Array<U32>,~(R.User() & Unit),~Nat,~path(),~Key.inject_leaf,~domain()),~declaration(),~Array<U32>,~Unit,~Unit,~publish_body)>:
  Publisher.run(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~List<Array<U32>>,~PublishOps(),~Write.grant(~B.AuditWorkshop,~B.Store,~R.Resources(),~Array<U32>,~(R.User() & Unit),~Nat,~path(),~Key.inject_leaf,~domain()),~declaration(),~Array<U32>,~Unit,~Unit,~publish_body,registry,world,incoming)
def sum(values:List<&2,U32>) -> U32:
  match values:
    case []:0
    case head <> tail:(head + sum(tail) : U32)
def at_returned(result:Array<U32> & List<&2,U32>) -> Array<U32> & U32:
  (payload,values)=result
  (payload,sum(values))
def at(payload:Array<U32>,request:Unit) -> Array<U32> & U32:
  at_returned(B.project_array(payload))
def projected(~H:Type,args:Array<U32>,result:H & U32) -> H & Core.Projected<Array<U32>,U32,Unit>:
  (owner,value)=result
  (owner,Core.Ready{args,value})
def project(~H:Type,~read:Cap.Request<H,Unit,U32>,owner:H,args:Array<U32>) -> H & Core.Projected<Array<U32>,U32,Unit>:
  projected(~H,args,Cap.request(~H,~Unit,~U32,~read,owner,Unit{}))
def got(~H:Type,~cap:C.Ops(H),+observation:U32,args:Array<U32>,result:H & Component.Access<U32>) -> H & (U32 & (Array<U32> & (T.Outcome<Unit> & U32))):
  match result:
    case (owner,Component.Found{+value}):(Cap.set(~H,~U32,~U32,~cap,owner,(value + observation : U32)),(observation,(Capture.increment(observation,args),(T.Success{},value))))
    case (owner,_):(owner,(observation,(args,(T.Failure{Unit{}},0))))
def body(~H:Type,~cap:C.Ops(H),observation:U32,args:Array<U32>,owner:H) -> H & (U32 & (Array<U32> & (T.Outcome<Unit> & U32))):
  got(~H,~cap,observation,args,Cap.get(~H,~U32,~U32,~cap,owner))
def ReaderOwner() -> Type:
  Route.Reader<B.AuditWorkshop,Nat,FR.State<Nat,Stream.Stream<B.AuditWorkshop,Nat>,Unit>,FR.take(~B.AuditWorkshop,~Nat,~Nat,~Stream.Stream<B.AuditWorkshop,Nat>,~Unit,~Family.selected_leaf(~B.AuditWorkshop,~Nat)),FR.put(~B.AuditWorkshop,~Nat,~Nat,~Stream.Stream<B.AuditWorkshop,Nat>,~Unit,~Family.replaced_leaf(~B.AuditWorkshop,~Nat))>
def ReaderRegistry() -> Type:
  Sys.Registry<B.AuditWorkshop,B.Store,R.Resources(),Nat,Ev.Input<Nat,Array<U32> & U32>,Unit,Core.Reply<Array<U32>,U32,Unit,U32>,Core.runner(~B.AuditWorkshop,~B.Store,~R.Resources(),~Array<U32>,~(R.User() & Unit),~Nat,~path(),~Unit,~U32,~Array<U32>,~U32,~Unit,~U32,~C.Ops,~at,~project,~C.declaration(),~body)>
def Registration() -> Type:
  Route.Registration<B.AuditWorkshop,B.Store,R.Resources(),Nat,Nat,FR.State<Nat,Stream.Stream<B.AuditWorkshop,Nat>,Unit>,Array<U32> & U32,Unit,Core.Reply<Array<U32>,U32,Unit,U32>,FR.take(~B.AuditWorkshop,~Nat,~Nat,~Stream.Stream<B.AuditWorkshop,Nat>,~Unit,~Family.selected_leaf(~B.AuditWorkshop,~Nat)),FR.put(~B.AuditWorkshop,~Nat,~Nat,~Stream.Stream<B.AuditWorkshop,Nat>,~Unit,~Family.replaced_leaf(~B.AuditWorkshop,~Nat)),Core.runner(~B.AuditWorkshop,~B.Store,~R.Resources(),~Array<U32>,~(R.User() & Unit),~Nat,~path(),~Unit,~U32,~Array<U32>,~U32,~Unit,~U32,~C.Ops,~at,~project,~C.declaration(),~body)>
def register(runtime:Runtime()) -> Registration():
  ReaderQuery.register(~B.AuditWorkshop,~B.Store,~R.Resources(),~Array<U32>,~(R.User() & Unit),~Nat,~Event.Domain<B.AuditWorkshop,Nat>,~Stream.Stream<B.AuditWorkshop,Nat>,~path(),~Key.inject_leaf,~Key.select_leaf,~domain(),~Family.leaf_make(~B.AuditWorkshop,~Nat),~Family.leaf_sync(~B.AuditWorkshop,~Nat),~Family.leaf_frame(~B.AuditWorkshop,~Nat),~Family.leaf_retain(~B.AuditWorkshop,~Nat),~Family.leaf_inventory(~B.AuditWorkshop,~Nat),~Family.selected_leaf(~B.AuditWorkshop,~Nat),~Family.replaced_leaf(~B.AuditWorkshop,~Nat),~descriptor(),~Unit,~Unit,~U32,~Array<U32>,~U32,~Unit,~U32,~C.Ops,~at,~project,~C.declaration(),~body,runtime,"ReadRecoveredCargo")
def ReadResult() -> Type:
  Route.RunResult<B.AuditWorkshop,B.Store,R.Resources(),Nat,Nat,FR.State<Nat,Stream.Stream<B.AuditWorkshop,Nat>,Unit>,Array<U32> & U32,Unit,Core.Reply<Array<U32>,U32,Unit,U32>,FR.take(~B.AuditWorkshop,~Nat,~Nat,~Stream.Stream<B.AuditWorkshop,Nat>,~Unit,~Family.selected_leaf(~B.AuditWorkshop,~Nat)),FR.put(~B.AuditWorkshop,~Nat,~Nat,~Stream.Stream<B.AuditWorkshop,Nat>,~Unit,~Family.replaced_leaf(~B.AuditWorkshop,~Nat)),Core.runner(~B.AuditWorkshop,~B.Store,~R.Resources(),~Array<U32>,~(R.User() & Unit),~Nat,~path(),~Unit,~U32,~Array<U32>,~U32,~Unit,~U32,~C.Ops,~at,~project,~C.declaration(),~body)>
def read(runtime:Runtime(),reader:ReaderOwner(),registry:ReaderRegistry(),args:Array<U32>) -> ReadResult():
  ReaderQuery.run(~B.AuditWorkshop,~B.Store,~R.Resources(),~Array<U32>,~(R.User() & Unit),~Nat,~Event.Domain<B.AuditWorkshop,Nat>,~Stream.Stream<B.AuditWorkshop,Nat>,~path(),~Key.inject_leaf,~Key.select_leaf,~domain(),~Family.leaf_make(~B.AuditWorkshop,~Nat),~Family.leaf_sync(~B.AuditWorkshop,~Nat),~Family.leaf_frame(~B.AuditWorkshop,~Nat),~Family.leaf_retain(~B.AuditWorkshop,~Nat),~Family.leaf_inventory(~B.AuditWorkshop,~Nat),~Family.selected_leaf(~B.AuditWorkshop,~Nat),~Family.replaced_leaf(~B.AuditWorkshop,~Nat),~descriptor(),~Unit,~Unit,~U32,~Array<U32>,~U32,~Unit,~U32,~C.Ops,~at,~project,~C.declaration(),~body,runtime,reader,registry,args)
def PublishResult() -> Type:
  Sys.RunResult<B.AuditWorkshop,B.Store,R.Resources(),Nat,Array<U32>,Unit,Publisher.Reply<Unit,Unit,List<Array<U32>>>,Publisher.runner(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~List<Array<U32>>,~PublishOps(),~Write.grant(~B.AuditWorkshop,~B.Store,~R.Resources(),~Array<U32>,~(R.User() & Unit),~Nat,~path(),~Key.inject_leaf,~domain()),~declaration(),~Array<U32>,~Unit,~Unit,~publish_body)>
def with_world(~Out:Type,action:B.World(R.Resources()) -> B.World(R.Resources()) & Out,runtime:Runtime()) -> Runtime() & Out:
  Reader.with_world(~B.AuditWorkshop,~B.Store,~R.Resources(),~Array<U32>,~(R.User() & Unit),~Nat,~Event.Domain<B.AuditWorkshop,Nat>,~Stream.Stream<B.AuditWorkshop,Nat>,~path(),~Key.inject_leaf,~Key.select_leaf,~domain(),~Family.leaf_make(~B.AuditWorkshop,~Nat),~Family.leaf_sync(~B.AuditWorkshop,~Nat),~Family.leaf_frame(~B.AuditWorkshop,~Nat),~Family.leaf_retain(~B.AuditWorkshop,~Nat),~Family.leaf_inventory(~B.AuditWorkshop,~Nat),~Family.selected_leaf(~B.AuditWorkshop,~Nat),~Family.replaced_leaf(~B.AuditWorkshop,~Nat),~descriptor(),~Unit,~Out,action,runtime)
def PublisherRegistration() -> Type:
  Sys.RegistrationResult<B.AuditWorkshop,B.Store,R.Resources(),Nat,Array<U32>,Unit,Publisher.Reply<Unit,Unit,List<Array<U32>>>,Publisher.runner(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~List<Array<U32>>,~PublishOps(),~Write.grant(~B.AuditWorkshop,~B.Store,~R.Resources(),~Array<U32>,~(R.User() & Unit),~Nat,~path(),~Key.inject_leaf,~domain()),~declaration(),~Array<U32>,~Unit,~Unit,~publish_body)>
