import Base
import ../src/ecs/event-runtime.bend as Ev
def batch(value:Ev.Batch<U32>) -> String:
  match value:
    case Ev.Batch{tick,values}:Nat.show(tick) ++ ":" ++ List.show(&2,U32,U32.show,values)
def result(value:Ev.Trimmed<U32>) -> String:
  match value:
    case Ev.Trimmed{batches,dropped}:"drop=" ++ Nat.show(dropped) ++ ";batches=" ++ List.show(&2,Ev.Batch<U32>,batch,batches)
def row(+capacity:Nat,+dropped:Nat,+batches:List<&2,Ev.Batch<U32>>) -> String:
  "cap=" ++ Nat.show(capacity) ++ ";initial=" ++ Nat.show(dropped) ++ ";input=" ++ List.show(&2,Ev.Batch<U32>,batch,batches) ++ ";" ++ result(Ev.at_capacity(~U32,batches,capacity,dropped))
def main() -> List<&2,String>:
  [row(0n,0n,[]),row(0n,4n,[Ev.Batch{7n,[]}]),row(0n,0n,[Ev.Batch{7n,[]},Ev.Batch{2n,[10u,11u]},Ev.Batch{3n,[12u]}]),row(1n,0n,[Ev.Batch{7n,[]},Ev.Batch{2n,[10u,11u]},Ev.Batch{3n,[12u]}]),row(2n,0n,[Ev.Batch{2n,[10u,11u]},Ev.Batch{7n,[]}]),row(1n,12n,[Ev.Batch{9n,[1u]},Ev.Batch{4n,[2u]},Ev.Batch{2n,[3u]}]),row(1n,0n,[Ev.Batch{9n,[1u]},Ev.Batch{4n,[2u]},Ev.Batch{2n,[3u]}]),row(2n,0n,[Ev.Batch{1n,[1u,2u,3u]},Ev.Batch{2n,[4u]}]),row(4n,0n,[Ev.Batch{1n,[1u,2u,3u]},Ev.Batch{2n,[4u]}]),row(0n,9n,[Ev.Batch{1n,[1u]},Ev.Batch{2n,[]}])]
