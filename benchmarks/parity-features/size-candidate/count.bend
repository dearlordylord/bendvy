import Base
import ../../../src/ecs/event-runtime.bend as Ev

def size_loop(~E:Data,batches:List<&2,Ev.Batch<E>>, +acc:Nat) -> Nat:
  match batches:
    case []: acc
    case Ev.Batch{_,items} <> rest: size_loop(~E,rest,Ev.count_loop(~E,items,acc))
def size(~E:Data,batches:List<&2,Ev.Batch<E>>) -> Nat:
  size_loop(~E,batches,0n)
