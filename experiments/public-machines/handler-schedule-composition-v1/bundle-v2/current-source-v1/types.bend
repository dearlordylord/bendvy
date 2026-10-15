import Base
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/column.bend as Col
import ../../../../../src/ecs/local.bend as Local
import ../../../../../src/ecs/machine.bend as M
import ../../../../../src/ecs/machine-stream.bend as Stream

type SchemaA is Data:
  SchemaA{}
type SchemaB is Data:
  SchemaB{}
type MachineKey is Data:
  MachineKey{}
type State is Data:
  Boot{}
  Play{}
  Pause{}
type Store<S:Data> is Type:
  Store{column:Col.Column<S,Array<U32>>}
# Trusted app storage, keyed by actual namespaced system registration.
type LocalOwner is Type:
  LocalOwner{namespace:U32,id:U32,cell:Local.Cell<Array<U32>>}
type Resources<S:Data> is Type:
  Resources{owned:Array<U32>,slot:M.Slot<S,MachineKey,State>,stream:Stream.Stream<State>,reader:Maybe<&1,Stream.Reader<S,MachineKey>>,locals:List<&1,LocalOwner>,tick:Nat,prefix:List<&2,String>,delivered:List<&2,M.Transition<State>>,structuralApplied:U32}
type Atom<S:Data> is Data:
  Current{value:State}
  HasResource{}
type Environment<S:Data> is Data:
  Environment{current:State,hasResource:Bool}
def same(left:State,right:State) -> Bool:
  match left right:
    case Boot{} Boot{}: True{}
    case Play{} Play{}: True{}
    case Pause{} Pause{}: True{}
    case _ _: False{}
def condition(~S:Data,atom:Atom<S>,env:Environment<S>) -> Bool:
  match atom env:
    case Current{wanted} Environment{current,_}: same(wanted,current)
    case HasResource{} Environment{_,available}: available
