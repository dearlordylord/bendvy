import Base
import ./count.bend as C
import ../../../src/ecs/event-runtime.bend as Ev

def observe(+batches:List<&2,Ev.Batch<U32>>) -> String:
  Nat.show(Ev.size(~U32,batches)) ++ ":" ++ Nat.show(C.size(~U32,batches))
def main() -> IO(Unit):
  IO.print(observe([Ev.Batch{0n,[]},Ev.Batch{0n,[]},Ev.Batch{1n,[]}]) ++ "\n" ++ observe([Ev.Batch{7n,[]},Ev.Batch{0n,[]},Ev.Batch{1n,[]}]) ++ "\n" ++ observe([Ev.Batch{0n,[]},Ev.Batch{0n,[]},Ev.Batch{1n,[9]}]) ++ "\n" ++ observe([Ev.Batch{7n,[]},Ev.Batch{0n,[]},Ev.Batch{1n,[9]}]) ++ "\n" ++ observe([Ev.Batch{0n,[]},Ev.Batch{0n,[]},Ev.Batch{1n,[9,9,0]}]) ++ "\n" ++ observe([Ev.Batch{7n,[]},Ev.Batch{0n,[]},Ev.Batch{1n,[9,9,0]}]) ++ "\n" ++ observe([Ev.Batch{0n,[1]},Ev.Batch{0n,[]},Ev.Batch{1n,[]}]) ++ "\n" ++ observe([Ev.Batch{7n,[1]},Ev.Batch{0n,[]},Ev.Batch{1n,[]}]) ++ "\n" ++ observe([Ev.Batch{0n,[1]},Ev.Batch{0n,[]},Ev.Batch{1n,[9]}]) ++ "\n" ++ observe([Ev.Batch{7n,[1]},Ev.Batch{0n,[]},Ev.Batch{1n,[9]}]) ++ "\n" ++ observe([Ev.Batch{0n,[1]},Ev.Batch{0n,[]},Ev.Batch{1n,[9,9,0]}]) ++ "\n" ++ observe([Ev.Batch{7n,[1]},Ev.Batch{0n,[]},Ev.Batch{1n,[9,9,0]}]) ++ "\n" ++ observe([Ev.Batch{0n,[1,2,3]},Ev.Batch{0n,[]},Ev.Batch{1n,[]}]) ++ "\n" ++ observe([Ev.Batch{7n,[1,2,3]},Ev.Batch{0n,[]},Ev.Batch{1n,[]}]) ++ "\n" ++ observe([Ev.Batch{0n,[1,2,3]},Ev.Batch{0n,[]},Ev.Batch{1n,[9]}]) ++ "\n" ++ observe([Ev.Batch{7n,[1,2,3]},Ev.Batch{0n,[]},Ev.Batch{1n,[9]}]) ++ "\n" ++ observe([Ev.Batch{0n,[1,2,3]},Ev.Batch{0n,[]},Ev.Batch{1n,[9,9,0]}]) ++ "\n" ++ observe([Ev.Batch{7n,[1,2,3]},Ev.Batch{0n,[]},Ev.Batch{1n,[9,9,0]}]))
