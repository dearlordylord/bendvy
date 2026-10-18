import Base
import ./world.bend as W
import ./event-runtime.bend as Ev
import ./machine-stream.bend as St
import ./relation-commands.bend as A
import ./capabilities.bend as Cap
import ./inspector-stream-frame.bend as F

type Declaration<S:Data,K:Data,V:Data,R:Type,-take:R -> R & St.Stream<V>> is Data:
  Declaration{name:String}
type TransitionLog<S:Data,K:Data,V:Data> is Data:
  TransitionLog{stream:St.Stream<V>}
def joined(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,cursor:U32,namespace:U32,batches:List<&2,Ev.Batch<A.Notice<S,E>>>,positions:List<&2,Ev.Position>,nextReader:U32,tick:Nat,frameStart:Nat,boundary:Nat,capacity:Nat,dropped:Nat,observed:W.World<S,C,R,A.Notice<S,E>> & St.Stream<V>) -> F.Frame<S,C,R,E> & TransitionLog<S,K,V>:
  (world,stream)=observed
  (F.Frame{Ev.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped},cursor},TransitionLog{stream})
def from_runtime(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & St.Stream<V>,cursor:U32,runtime:Ev.Runtime<S,C,R,A.Notice<S,E>>) -> F.Frame<S,C,R,E> & TransitionLog<S,K,V>:
  match runtime:
    case Ev.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped}:joined(~S,~K,~V,~C,~R,~E,cursor,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped,W.observe_resource(~S,~C,~R,~A.Notice<S,E>,~St.Stream<V>,~take,world))
def read(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & St.Stream<V>,frame:F.Frame<S,C,R,E>) -> F.Frame<S,C,R,E> & TransitionLog<S,K,V>:
  match frame:
    case F.Frame{runtime,cursor}:from_runtime(~S,~K,~V,~C,~R,~E,~take,cursor,runtime)
def inspect(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & St.Stream<V>,~declaration:Declaration<S,K,V,R,take>) -> Cap.ValueRead<F.Frame<S,C,R,E>,TransitionLog<S,K,V>>:
  Cap.ValueRead{read(~S,~K,~V,~C,~R,~E,~take)}
