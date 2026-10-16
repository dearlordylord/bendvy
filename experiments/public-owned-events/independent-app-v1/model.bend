import Base
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/ordinary-owned-event.bend as Pub
import ../../../src/ecs/owned-event-runtime.bend as Read
import ../../../src/ecs/owned-event-storage.bend as Store
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/world.bend as W

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
def World() -> Type:
  W.World<Schema,Unit,Store.Resources<Array<U32>,Manifest>,Nat>
def Runtime() -> Type:
  Store.Runtime(~Schema,~Unit,~Array<U32>,~Manifest)
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
def Publisher() -> Type:
  Pub.Registry(~Schema,~Unit,~Array<U32>,~Manifest,~identity(),~PublishArgs,~U32,~Unit,~publish)
def ReaderRegistry() -> Type:
  Read.Registry(~Schema,~Unit,~Array<U32>,~Manifest,~Unit,~List<&2,U32>,~ReaderArgs,~U32,~identity(),~at,~consume)
