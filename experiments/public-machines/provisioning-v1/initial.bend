import Base
import ../../../../../bendvy/src/ecs/machine.bend as M

# Private checked empty-slot primitive, not a duplicate initial provision policy.
type Installation<W: Type,V: Data> is Type:
  Installed{world: W}
  Occupied{world: W,incoming: V}

def empty(~S: Data,~K: Data,~V: Data) -> M.Slot<S,K,V>:
  M.Missing{}

# Existing selected initialization only; Rust initial message/changed adaptation
# is explicitly outside this candidate.
def selected_initial(~S: Data,~K: Data,~V: Data,value: V) -> M.Slot<S,K,V>:
  M.Present{value,M.NoPending{},None{},False{}}

def inspected(~S: Data,~K: Data,~V: Data,~W: Type,
  ~put: W -> M.Slot<S,K,V> -> W,
  value: V,pair: W & M.Slot<S,K,V>) -> Installation<W,V>:
  match pair:
    case (world,M.Missing{}): Installed{put(world,selected_initial(~S,~K,~V,value))}
    case (world,slot): Occupied{put(world,slot),value}

def install_empty(~S: Data,~K: Data,~V: Data,~W: Type,
  ~take: W -> W & M.Slot<S,K,V>,~put: W -> M.Slot<S,K,V> -> W,
  _: M.Family<S,K,V,W,take,put>,world: W,value: V) -> Installation<W,V>:
  inspected(~S,~K,~V,~W,~put,value,take(world))
