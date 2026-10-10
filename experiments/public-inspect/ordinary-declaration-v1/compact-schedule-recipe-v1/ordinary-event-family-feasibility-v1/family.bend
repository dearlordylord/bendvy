import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-declaration.bend as Event
import stream.bend as Leaf

# Each ordinary emit stages one singleton product record. Tx.finish preserves
# the record list's emission order; products are never merged across emissions.
type Publication<A:Data,B:Data> is Data:
  Publication{first:List<&2,A>,second:List<&2,B>}
type Streams<S:Data,A:Data,B:Data,H:Type> is Type:
  Streams{first:Leaf.Stream<S,A>,second:Leaf.Stream<S,B>,owners:H}
type Application<S:Data,C:Type,R:Type,A:Data,B:Data,H:Type> is Type:
  Application{world:W.World<S,C,R,Publication<A,B>>,streams:Streams<S,A,B,H>,journal:List<&2,Ev.Batch<Publication<A,B>>>,tick:Nat,frameStart:Nat}
def setup(~S:Data,~C:Type,~R:Type,~A:Data,~B:Data,~H:Type,world:W.World<S,C,R,Publication<A,B>>,first:Event.Domain<S,A>,second:Event.Domain<S,B>,owners:H,+capacity:Nat) -> Application<S,C,R,A,B,H>:
  Application{world,Streams{Leaf.provision(~S,~A,first,capacity),Leaf.provision(~S,~B,second,capacity),owners},[],0n,0n}
def first_take(~S:Data,~A:Data,~B:Data,~H:Type,streams:Streams<S,A,B,H>) -> Streams<S,A,B,H> & Leaf.Stream<S,A>:
  match streams:
    case Streams{+first,second,owners}:(Streams{first,second,owners},first)
def first_put(~S:Data,~A:Data,~B:Data,~H:Type,streams:Streams<S,A,B,H>,first:Leaf.Stream<S,A>) -> Streams<S,A,B,H>:
  match streams:
    case Streams{_,second,owners}:Streams{first,second,owners}
def second_take(~S:Data,~A:Data,~B:Data,~H:Type,streams:Streams<S,A,B,H>) -> Streams<S,A,B,H> & Leaf.Stream<S,B>:
  match streams:
    case Streams{first,+second,owners}:(Streams{first,second,owners},second)
def second_put(~S:Data,~A:Data,~B:Data,~H:Type,streams:Streams<S,A,B,H>,second:Leaf.Stream<S,B>) -> Streams<S,A,B,H>:
  match streams:
    case Streams{first,_,owners}:Streams{first,second,owners}
def emit_first(~S:Data,~C:Type,~R:Type,~A:Data,~B:Data,tx:Tx.Tx<W.World<S,C,R,Publication<A,B>>,Publication<A,B>>,event:A) -> Tx.Tx<W.World<S,C,R,Publication<A,B>>,Publication<A,B>>:
  Tx.emit(~W.World<S,C,R,Publication<A,B>>,~Publication<A,B>,tx,Publication{[event],[]})
def emit_second(~S:Data,~C:Type,~R:Type,~A:Data,~B:Data,tx:Tx.Tx<W.World<S,C,R,Publication<A,B>>,Publication<A,B>>,event:B) -> Tx.Tx<W.World<S,C,R,Publication<A,B>>,Publication<A,B>>:
  Tx.emit(~W.World<S,C,R,Publication<A,B>>,~Publication<A,B>,tx,Publication{[],[event]})
def first_values(~A:Data,~B:Data,items:List<&2,Publication<A,B>>) -> List<&2,A>:
  match items:
    case []:[]
    case Publication{first,_} <> rest:Ev.append(~A,first,first_values(~A,~B,rest))
def second_values(~A:Data,~B:Data,items:List<&2,Publication<A,B>>) -> List<&2,B>:
  match items:
    case []:[]
    case Publication{_,second} <> rest:Ev.append(~B,second,second_values(~A,~B,rest))
def synced(~S:Data,~C:Type,~R:Type,~A:Data,~B:Data,~H:Type,observed:W.World<S,C,R,Publication<A,B>> & List<&2,Publication<A,B>>,streams:Streams<S,A,B,H>,+journal:List<&2,Ev.Batch<Publication<A,B>>>,+tick:Nat,frameStart:Nat) -> Application<S,C,R,A,B,H>:
  match observed streams:
    case (world,items) Streams{first,second,owners}:
      +published=List.drop(&2,Publication<A,B>,items,Ev.size(~Publication<A,B>,journal))
      Application{world,Streams{Leaf.append(~S,~A,first,tick,first_values(~A,~B,published)),Leaf.append(~S,~B,second,tick,second_values(~A,~B,published)),owners},Ev.sync_checked(~Publication<A,B>,Nat.is_lt(0n,Ev.count(~Publication<A,B>,published)),journal,tick,published),tick,frameStart}
def sync(~S:Data,~C:Type,~R:Type,~A:Data,~B:Data,~H:Type,app:Application<S,C,R,A,B,H>) -> Application<S,C,R,A,B,H>:
  match app:
    case Application{world,streams,journal,+tick,frameStart}:synced(~S,~C,~R,~A,~B,~H,W.events_view(~S,~C,~R,~Publication<A,B>,world),streams,journal,1n+tick,frameStart)

# Arbitrary finite products can use this same closed selection operation. The
# generated take/put retain every other leaf and arbitrary affine owner H.
def observed_read(~S:Data,~E:Data,~F:Type,~put:F -> Leaf.Stream<S,E> -> F,family:F,returned:Leaf.Stream<S,E> & Ev.Reading<E>) -> F & Ev.Reading<E>:
  match returned:
    case (stream,reading):(put(family,stream),reading)
def observed_leaf(~S:Data,~E:Data,~F:Type,~put:F -> Leaf.Stream<S,E> -> F,returned:F & Leaf.Stream<S,E>,+tick:Nat,id:U32) -> F & Ev.Reading<E>:
  match returned:
    case (family,+stream):observed_read(~S,~E,~F,~put,family,Leaf.reading(~S,~E,stream,id,tick))
def observe(~S:Data,~E:Data,~F:Type,~take:F -> F & Leaf.Stream<S,E>,~put:F -> Leaf.Stream<S,E> -> F,family:F,id:U32,tick:Nat) -> F & Ev.Reading<E>:
  observed_leaf(~S,~E,~F,~put,take(family),tick,id)
