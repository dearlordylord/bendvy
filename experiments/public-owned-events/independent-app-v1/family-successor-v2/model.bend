import Base
import ../../../../src/ecs/capabilities.bend as Cap
import ../../../../src/ecs/ordinary-owned-event.bend as Pub
import ../../../../src/ecs/owned-event-family-reader-runtime.bend as Read
import ../../../../src/ecs/owner-product.bend as Product
import ../../../../src/ecs/owned-event-log.bend as Log
import ../../../../src/ecs/ordinary-owned-event-binding.bend as Binding
import ../../../../src/ecs/owned-event-key-route.bend as Key
import ../../../../src/ecs/ordinary-event-family.bend as Family
import ../../../../src/ecs/ordinary-event-declaration.bend as Event
import ../../../../src/ecs/event-stream.bend as Stream
import ../../../../src/ecs/event-family-runtime.bend as FR
import ../../../../src/ecs/event-family-routing.bend as Route
import ../../../../src/ecs/ordinary-owned-event-family-reader-binding.bend as Setup
import ../../../../src/ecs/ordinary-owned-event-family-reader.bend as FamilyRead
import ../../../../src/ecs/ordinary-owned-event-family-write.bend as Write
import ../../../../src/ecs/ordinary-owned-event-declaration.bend as Declaration
import ../../../../src/ecs/ordinary-owned-event-family-publisher.bend as Publish
import ../../../../src/ecs/owned-event-family-catalog.bend as Catalog
import ../../../../src/ecs/event-runtime.bend as Ev
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/transaction.bend as T
import ../../../../src/ecs/world.bend as W

type Schema is Data:
  CargoSchema{}
type Manifest is Type:
  Manifest{code:U32,slots:Array<U32>}
type PublishArgs is Type:
  PublishArgs{fail:Bool,payload:Manifest}
type ReaderArgs is Type:
  ReaderArgs{fail:Bool,seen:List<&2,List<&2,U32>>,scratch:Array<U32>}

def empty(_:Unit) -> Unit:
  Unit{}
def identity() -> Pub.Domain<Schema,Manifest>:
  Pub.domain(~Schema,~Manifest,"cargo:manifest")
def Resources() -> Type:
  Product.Owner<Array<U32>,Log.Log<Manifest>>
def World() -> Type:
  W.World<Schema,Unit,Resources(),Nat>
def FamilyState() -> Type:
  FR.State<Nat,Stream.Stream<Schema,Nat>,Unit>
def Runtime() -> Type:
  Route.Runtime<Schema,Unit,Resources(),Nat,FamilyState()>
def array(+seed:U32) -> Array<U32>:
  a = [0 : U32*4n]
  a[0] <- seed
  a[1] <- (seed + 3 : U32)
  a[2] <- (seed + 8 : U32)
  a[3] <- (seed + 15 : U32)
  a

def bind(-A:Type,-B:Type,-C:Type,r:A & B,f:A -> B -> C) -> C:
  (a,b) = r
  f(a,b)
def projected(a:Array<U32>) -> Array<U32> & List<&2,U32>:
  match a:
    case ALeaf{+x}: (ALeaf{x},[x])
    case ANode{a,b}:
      bind(Array<U32>,List<&2,U32>,Array<U32> & List<&2,U32>,projected(a),a => sa => (
        bind(Array<U32>,List<&2,U32>,Array<U32> & List<&2,U32>,projected(b),b => sb => (ANode{a,b},List.append(&2,U32,sa,sb)))))
def at(payload:Manifest,_:Unit) -> Manifest & List<&2,U32>:
  Manifest{+code,slots} = payload
  bind(Array<U32>,List<&2,U32>,Manifest & List<&2,U32>,projected(slots),slots => values => (
    (Manifest{code,slots},code <> values)
  ))
def semantic(fail:Bool) -> T.Outcome<U32>:
  match fail:
    case True{}:
      T.Failure{73}
    case False{}:
      T.Success{}
def publish(~H:Type,~grant:Pub.Write<Schema,Manifest,identity(),H>,args:PublishArgs,h:H) -> H & (T.Outcome<U32> & Unit):
  PublishArgs{fail,payload} = args
  h = Pub.emit(~Schema,~Manifest,~identity(),~H,~grant,h,payload)
  (h,(semantic(fail),Unit{}))
def remember(values:List<&2,U32>,scratch:Array<U32>) -> Array<U32>:
  match values:
    case Nil{}: scratch
    case Con{code,rest}:
      scratch[0] <- code
      scratch
def consume(~H:Type,~read:Cap.Request<H,Unit,List<&2,U32>>,h:H,args:ReaderArgs) -> H & (T.Outcome<U32> & ReaderArgs):
  ReaderArgs{+fail,seen,scratch} = args
  bind(H,List<&2,U32>,H & (T.Outcome<U32> & ReaderArgs),Cap.request(~H,~Unit,~List<&2,U32>,~read,h,Unit{}),h => +values => (
    (h,(semantic(fail),ReaderArgs{fail,values <> seen,remember(values,scratch)}))
  ))
def retry(args:ReaderArgs) -> ReaderArgs:
  ReaderArgs{fail,seen,scratch} = args
  ReaderArgs{False{},seen,scratch}
def initial_reader(fail:Bool,seed:U32) -> ReaderArgs:
  ReaderArgs{fail,[],array(seed)}
def setup() -> Setup.Setup<Schema,Resources(),Manifest,Array<U32> & Unit,Nat,Event.Domain<Schema,Nat>,Stream.Stream<Schema,Nat>,Binding.right_path(~Array<U32>,~Log.Log<Manifest>,~Manifest,~Unit,~Binding.identity_lens(~Log.Log<Manifest>)),Key.inject_leaf,Key.select_leaf,identity(),Family.leaf_make(~Schema,~Nat),Family.leaf_sync(~Schema,~Nat),Family.leaf_frame(~Schema,~Nat),Family.leaf_retain(~Schema,~Nat),Family.leaf_inventory(~Schema,~Nat),Family.selected_leaf(~Schema,~Nat),Family.replaced_leaf(~Schema,~Nat)>:
  Setup.under_resource(~Schema,~Array<U32>,~Log.Log<Manifest>,~Manifest,~Unit,~Nat,~Event.Domain<Schema,Nat>,~Stream.Stream<Schema,Nat>,~Binding.identity_lens(~Log.Log<Manifest>),~Key.inject_leaf,~Key.select_leaf,~identity(),~Family.leaf_make(~Schema,~Nat),~Family.leaf_sync(~Schema,~Nat),~Family.leaf_frame(~Schema,~Nat),~Family.leaf_retain(~Schema,~Nat),~Family.leaf_inventory(~Schema,~Nat),~Family.selected_leaf(~Schema,~Nat),~Family.replaced_leaf(~Schema,~Nat),Setup.leaf(~Schema,~Manifest,~identity()))
def selected_owned(value:Setup.Setup<Schema,Resources(),Manifest,Array<U32> & Unit,Nat,Event.Domain<Schema,Nat>,Stream.Stream<Schema,Nat>,Binding.right_path(~Array<U32>,~Log.Log<Manifest>,~Manifest,~Unit,~Binding.identity_lens(~Log.Log<Manifest>)),Key.inject_leaf,Key.select_leaf,identity(),Family.leaf_make(~Schema,~Nat),Family.leaf_sync(~Schema,~Nat),Family.leaf_frame(~Schema,~Nat),Family.leaf_retain(~Schema,~Nat),Family.leaf_inventory(~Schema,~Nat),Family.selected_leaf(~Schema,~Nat),Family.replaced_leaf(~Schema,~Nat)>) -> Binding.Binding<Schema,Resources(),Manifest,Array<U32> & Unit,Nat,Binding.right_path(~Array<U32>,~Log.Log<Manifest>,~Manifest,~Unit,~Binding.identity_lens(~Log.Log<Manifest>)),Key.inject_leaf,Key.select_leaf,identity()>:
  Setup.Setup{owned,provision,selection} = value
  owned
def owned() -> Binding.Binding<Schema,Resources(),Manifest,Array<U32> & Unit,Nat,Binding.right_path(~Array<U32>,~Log.Log<Manifest>,~Manifest,~Unit,~Binding.identity_lens(~Log.Log<Manifest>)),Key.inject_leaf,Key.select_leaf,identity()>:
  selected_owned(setup())
def declaration() -> Declaration.Declaration<Schema,World(),List<Manifest>,Write.Ops(~Schema,~Manifest,~identity()),Write.grant(~Schema,~Unit,~Resources(),~Manifest,~Array<U32> & Unit,~Nat,~Binding.right_path(~Array<U32>,~Log.Log<Manifest>,~Manifest,~Unit,~Binding.identity_lens(~Log.Log<Manifest>)),~Key.inject_leaf,~identity())>:
  Write.declaration(~Schema,~Unit,~Resources(),~Manifest,~Array<U32> & Unit,~Nat,~Binding.right_path(~Array<U32>,~Log.Log<Manifest>,~Manifest,~Unit,~Binding.identity_lens(~Log.Log<Manifest>)),~Key.inject_leaf,~Key.select_leaf,~identity(),~owned())
def Publisher() -> Type:
  Publish.Registry(~Schema,~Unit,~Resources(),~Nat,~List<Manifest>,~Write.Ops(~Schema,~Manifest,~identity()),~Write.grant(~Schema,~Unit,~Resources(),~Manifest,~Array<U32> & Unit,~Nat,~Binding.right_path(~Array<U32>,~Log.Log<Manifest>,~Manifest,~Unit,~Binding.identity_lens(~Log.Log<Manifest>)),~Key.inject_leaf,~identity()),~declaration(),~PublishArgs,~U32,~Unit,~publish)
def ReadRunner() -> World() -> Ev.Input<Nat,ReaderArgs> -> Sys.Outcome<World(),Unit,Read.Reply<U32,ReaderArgs>>:
  Read.runner(~Schema,~Unit,~Resources(),~Manifest,~Array<U32> & Unit,~Nat,~Binding.right_path(~Array<U32>,~Log.Log<Manifest>,~Manifest,~Unit,~Binding.identity_lens(~Log.Log<Manifest>)),~Unit,~List<&2,U32>,~ReaderArgs,~U32,~at,~consume)
def ReaderRegistry() -> Type:
  Sys.Registry<Schema,Unit,Resources(),Nat,Ev.Input<Nat,ReaderArgs>,Unit,Read.Reply<U32,ReaderArgs>,Read.runner(~Schema,~Unit,~Resources(),~Manifest,~Array<U32> & Unit,~Nat,~Binding.right_path(~Array<U32>,~Log.Log<Manifest>,~Manifest,~Unit,~Binding.identity_lens(~Log.Log<Manifest>)),~Unit,~List<&2,U32>,~ReaderArgs,~U32,~at,~consume)>
def Reader() -> Type:
  Route.Reader<Schema,Nat,FamilyState(),FR.take(~Schema,~Nat,~Nat,~Stream.Stream<Schema,Nat>,~Unit,~Family.selected_leaf(~Schema,~Nat)),FR.put(~Schema,~Nat,~Nat,~Stream.Stream<Schema,Nat>,~Unit,~Family.replaced_leaf(~Schema,~Nat))>
def PubResult() -> Type:
  Sys.RunResult<Schema,Unit,Resources(),Nat,PublishArgs,Unit,Publish.Reply<U32,Unit,List<Manifest>>,Publish.runner(~Schema,~Unit,~Resources(),~Nat,~List<Manifest>,~Write.Ops(~Schema,~Manifest,~identity()),~Write.grant(~Schema,~Unit,~Resources(),~Manifest,~Array<U32> & Unit,~Nat,~Binding.right_path(~Array<U32>,~Log.Log<Manifest>,~Manifest,~Unit,~Binding.identity_lens(~Log.Log<Manifest>)),~Key.inject_leaf,~identity()),~declaration(),~PublishArgs,~U32,~Unit,~publish)>
def ReadResult() -> Type:
  Route.RunResult<Schema,Unit,Resources(),Nat,Nat,FamilyState(),ReaderArgs,Unit,Read.Reply<U32,ReaderArgs>,FR.take(~Schema,~Nat,~Nat,~Stream.Stream<Schema,Nat>,~Unit,~Family.selected_leaf(~Schema,~Nat)),FR.put(~Schema,~Nat,~Nat,~Stream.Stream<Schema,Nat>,~Unit,~Family.replaced_leaf(~Schema,~Nat)),Read.runner(~Schema,~Unit,~Resources(),~Manifest,~Array<U32> & Unit,~Nat,~Binding.right_path(~Array<U32>,~Log.Log<Manifest>,~Manifest,~Unit,~Binding.identity_lens(~Log.Log<Manifest>)),~Unit,~List<&2,U32>,~ReaderArgs,~U32,~at,~consume)>
def RegisteredReader() -> Type:
  Route.Registration<Schema,Unit,Resources(),Nat,Nat,FamilyState(),ReaderArgs,Unit,Read.Reply<U32,ReaderArgs>,FR.take(~Schema,~Nat,~Nat,~Stream.Stream<Schema,Nat>,~Unit,~Family.selected_leaf(~Schema,~Nat)),FR.put(~Schema,~Nat,~Nat,~Stream.Stream<Schema,Nat>,~Unit,~Family.replaced_leaf(~Schema,~Nat)),Read.runner(~Schema,~Unit,~Resources(),~Manifest,~Array<U32> & Unit,~Nat,~Binding.right_path(~Array<U32>,~Log.Log<Manifest>,~Manifest,~Unit,~Binding.identity_lens(~Log.Log<Manifest>)),~Unit,~List<&2,U32>,~ReaderArgs,~U32,~at,~consume)>
def RegisteredPublisher() -> Type:
  Sys.RegistrationResult<Schema,Unit,Resources(),Nat,PublishArgs,Unit,Publish.Reply<U32,Unit,List<Manifest>>,Publish.runner(~Schema,~Unit,~Resources(),~Nat,~List<Manifest>,~Write.Ops(~Schema,~Manifest,~identity()),~Write.grant(~Schema,~Unit,~Resources(),~Manifest,~Array<U32> & Unit,~Nat,~Binding.right_path(~Array<U32>,~Log.Log<Manifest>,~Manifest,~Unit,~Binding.identity_lens(~Log.Log<Manifest>)),~Key.inject_leaf,~identity()),~declaration(),~PublishArgs,~U32,~Unit,~publish)>
def catalog() -> Catalog.Catalog<Nat,Log.Log<Manifest>,Stream.Stream<Schema,Nat>,List<Log.Row<Manifest>>,Log.retain(~Manifest),Log.drain(~Manifest),Catalog.leaf_clear(~Schema)>:
  Catalog.leaf(~Schema,~Manifest)
