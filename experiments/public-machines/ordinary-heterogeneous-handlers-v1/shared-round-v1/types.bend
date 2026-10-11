import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/local.bend as Local
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/machine-stream.bend as Stream
type SchemaA is Data: SchemaA{}
type FirstKey is Data: FirstKey{}
type SecondKey is Data: SecondKey{}
type First is Data:
  Cold{}
  Warm{}
  Settled{}
type Second is Data:
  Idle{}
  Active{value:U32}
type Pulse is Data: Callback{machine:U32,phase:U32}
type Store<S:Data> is Type: Store{first:Col.Column<S,Array<U32>>,sibling:Col.Column<S,Array<U32>>}
type LocalOwner is Type: LocalOwner{namespace:U32,id:U32,cell:Local.Cell<Array<U32>>}
type Resources<S:Data> is Type:
  Resources{owned:Array<U32>,sibling:Array<U32>,first:M.Slot<S,FirstKey,First>,second:M.Slot<S,SecondKey,Second>,firstStream:Stream.Stream<First>,secondStream:Stream.Stream<Second>,firstReader:Maybe<&1,Stream.Reader<S,FirstKey>>,secondReader:Maybe<&1,Stream.Reader<S,SecondKey>>,locals:List<&1,LocalOwner>,firstTick:Nat,secondTick:Nat,trace:List<&2,String>,firstDelivered:List<&2,M.Transition<First>>,secondDelivered:List<&2,M.Transition<Second>>,applied:U32}
def same_first(a:First,b:First) -> Bool:
  match a b:
    case Cold{} Cold{}:True{}
    case Warm{} Warm{}:True{}
    case Settled{} Settled{}:True{}
    case _ _:False{}
def same_second(a:Second,b:Second) -> Bool:
  match a b:
    case Idle{} Idle{}:True{}
    case Active{a} Active{b}:U32.is_eq(a,b)
    case _ _:False{}
