import Base
import ../../../../../src/ecs/machine-stream-queue.bend as Q
import ../../../../../src/ecs/machine-stream.bend as St
import ../../../../../src/ecs/machine.bend as M
import ../../../../../src/ecs/event-runtime.bend as Ev

def bool(value:Bool) -> String:
  match value:
    case False{}:"false"
    case True{}:"true"
def values(items:List<&2,U32>) -> String:List.show(&2,U32,U32.show,items)
def batch(value:Ev.Batch<U32>) -> String:
  match value:
    case Ev.Batch{tick,items}:Nat.show(tick) ++ ":" ++ values(items)
def queued_batch(value:Q.Batch<U32>) -> String:
  match value:
    case Q.Batch{tick,count,items}:Nat.show(tick) ++ ":" ++ Nat.show(count) ++ ":" ++ values(items)
def queue(value:Q.Queue<U32>) -> String:
  match value:
    case Q.Queue{+front,+back,+size,+dropped,+count}:"front=" ++ List.show(&2,Q.Batch<U32>,queued_batch,front) ++ ";back=" ++ List.show(&2,Q.Batch<U32>,queued_batch,back) ++ ";size=" ++ Nat.show(size) ++ ";batchCount=" ++ Nat.show(count) ++ ";dropped=" ++ Nat.show(dropped) ++ ";values=" ++ values(Q.read(~U32,Q.Queue{front,back,size,dropped,count},0n))
def reference(value:Ev.Trimmed<U32>) -> String:
  match value:
    case Ev.Trimmed{+batches,dropped}:"batches=" ++ List.show(&2,Ev.Batch<U32>,batch,batches) ++ ";size=" ++ Nat.show(Ev.size(~U32,batches)) ++ ";batchCount=" ++ Nat.show(List.length(&2,Ev.Batch<U32>,batches)) ++ ";dropped=" ++ Nat.show(dropped)
def loaded(batches:List<&2,Ev.Batch<U32>>,queue:Q.Queue<U32>) -> Q.Queue<U32>:
  match batches:
    case []:queue
    case Ev.Batch{tick,+items} <> rest:loaded(rest,Q.publish_nonempty(~U32,queue,tick,items,Q.count_loop(~U32,items,0n)))
def trim_case(label:String,+batches:List<&2,Ev.Batch<U32>>,+boundary:Nat,+capacity:Nat,+dropped:Nat) -> String:
  label ++ "|input=" ++ List.show(&2,Ev.Batch<U32>,batch,batches) ++ ";boundary=" ++ Nat.show(boundary) ++ ";capacity=" ++ Nat.show(capacity) ++ ";dropped=" ++ Nat.show(dropped) ++ "\nreference|" ++ reference(Ev.trim_capacity(~U32,Ev.past_window(~U32,batches,boundary,dropped),capacity)) ++ "\nactual|" ++ queue(Q.trim(~U32,loaded(batches,Q.Queue{[],[],0n,dropped,0n}),boundary,capacity))
def transition(value:M.Transition<U32>) -> String:
  match value:
    case M.Initial{to}:"initial>" ++ U32.show(to)
    case M.Transition{from,to}:U32.show(from) ++ ">" ++ U32.show(to)
def transition_batch(value:Ev.Batch<M.Transition<U32>>) -> String:
  match value:
    case Ev.Batch{tick,items}:Nat.show(tick) ++ ":" ++ List.show(&2,M.Transition<U32>,transition,items)
def position(value:Ev.Position) -> String:
  match value:
    case Ev.Position{id,cursor,registered}:U32.show(id) ++ ":" ++ Nat.show(cursor) ++ ":" ++ Nat.show(registered)
def snapshot(value:List<&2,Ev.Batch<M.Transition<U32>>> & (List<&2,Ev.Position> & (Nat & Nat))) -> String:
  match value:
    case (batches,(positions,(dropped,start))):"batches=" ++ List.show(&2,Ev.Batch<M.Transition<U32>>,transition_batch,batches) ++ ";positions=" ++ List.show(&2,Ev.Position,position,positions) ++ ";dropped=" ++ Nat.show(dropped) ++ ";frameStart=" ++ Nat.show(start)
def reading(value:Ev.Reading<M.Transition<U32>>) -> String:
  match value:
    case Ev.Reading{items,lagged}:List.show(&2,M.Transition<U32>,transition,items) ++ ":lagged=" ++ bool(lagged)
def stream_cache(value:St.Stream<U32>) -> String:
  match value:
    case St.Stream{Q.Queue{_,_,size,dropped,count},_,_}:"size=" ++ Nat.show(size) ++ ";batchCount=" ++ Nat.show(count) ++ ";queueDropped=" ++ Nat.show(dropped)
def stream(label:String,+value:St.Stream<U32>) -> String:
  label ++ "|" ++ snapshot(St.snapshot(~U32,value)) ++ ";" ++ stream_cache(value) ++ ";read7=" ++ reading(St.observe(~U32,value,7,35n)) ++ ";read9=" ++ reading(St.observe(~U32,value,9,35n))
def completion(+value:St.Stream<U32>) -> String:
  stream("complete-true",value) ++ "\n" ++ stream("disposed",St.dispose(~U32,value,7))
def failed_completion(+value:St.Stream<U32>) -> String:
  stream("complete-false",value) ++ "\n" ++ completion(St.complete(~U32,value,7,32n,True{}))
def skipped(+value:St.Stream<U32>) -> String:
  stream("skip",value) ++ "\n" ++ failed_completion(St.complete(~U32,value,7,32n,False{}))
def initialized(+value:St.Stream<U32>) -> String:
  stream("initial",value) ++ "\n" ++ skipped(St.skip(~U32,value,7,31n))
def initial_case(+value:St.Stream<U32>) -> String:
  stream("seed",value) ++ "\n" ++ initialized(St.initial(~U32,value,30n,9))
def run() -> String:
  trim_case("nonmonotonic",[Ev.Batch{10n,[1]},Ev.Batch{2n,[2]},Ev.Batch{9n,[3]}],3n,2n,0n) ++ "\n" ++ trim_case("empty-prefix",[Ev.Batch{2n,[]},Ev.Batch{1n,[]},Ev.Batch{3n,[]},Ev.Batch{7n,[70]}],3n,5n,0n) ++ "\n" ++ trim_case("whole-multievent",[Ev.Batch{4n,[1,2]},Ev.Batch{9n,[3,4,5]},Ev.Batch{7n,[]}],0n,3n,1n) ++ "\n" ++ initial_case(St.trimmed(~U32,12n,[Ev.Position{7,3n,2n},Ev.Position{9,5n,4n}],Ev.Trimmed{[Ev.Batch{20n,[M.Transition{0,1}]},Ev.Batch{21n,[M.Initial{2}]}],5n}))
def main() -> IO(Unit):IO.print(run())
