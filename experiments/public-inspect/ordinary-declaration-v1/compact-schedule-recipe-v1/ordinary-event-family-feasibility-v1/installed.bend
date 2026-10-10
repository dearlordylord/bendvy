import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-declaration.bend as Event
import family.bend as F
import stream.bend as Leaf
import routing.bend as Route

type State<S:Data,A:Data,B:Data,H:Type> is Type:
  State{streams:F.Streams<S,A,B,H>,journal:List<&2,Ev.Batch<F.Publication<A,B>>>,frameStart:Nat}
def first_take(~S:Data,~A:Data,~B:Data,~H:Type,state:State<S,A,B,H>) -> State<S,A,B,H> & Leaf.Stream<S,A>:
  match state:
    case State{F.Streams{+first,second,owners},journal,frameStart}:(State{F.Streams{first,second,owners},journal,frameStart},first)
def first_put(~S:Data,~A:Data,~B:Data,~H:Type,state:State<S,A,B,H>,first:Leaf.Stream<S,A>) -> State<S,A,B,H>:
  match state:
    case State{F.Streams{_,second,owners},journal,frameStart}:State{F.Streams{first,second,owners},journal,frameStart}
def second_take(~S:Data,~A:Data,~B:Data,~H:Type,state:State<S,A,B,H>) -> State<S,A,B,H> & Leaf.Stream<S,B>:
  match state:
    case State{F.Streams{first,+second,owners},journal,frameStart}:(State{F.Streams{first,second,owners},journal,frameStart},second)
def second_put(~S:Data,~A:Data,~B:Data,~H:Type,state:State<S,A,B,H>,second:Leaf.Stream<S,B>) -> State<S,A,B,H>:
  match state:
    case State{F.Streams{first,_,owners},journal,frameStart}:State{F.Streams{first,second,owners},journal,frameStart}
def converted(~S:Data,~C:Type,~R:Type,~A:Data,~B:Data,~H:Type,app:F.Application<S,C,R,A,B,H>) -> Route.Runtime<S,C,R,F.Publication<A,B>,State<S,A,B,H>>:
  match app:
    case F.Application{world,streams,journal,tick,frameStart}:Route.Runtime{world,State{streams,journal,frameStart},tick}
def setup(~S:Data,~C:Type,~R:Type,~A:Data,~B:Data,~H:Type,world:W.World<S,C,R,F.Publication<A,B>>,first:Event.Domain<S,A>,second:Event.Domain<S,B>,owners:H,capacity:Nat) -> Route.Runtime<S,C,R,F.Publication<A,B>,State<S,A,B,H>>:
  converted(~S,~C,~R,~A,~B,~H,F.setup(~S,~C,~R,~A,~B,~H,world,first,second,owners,capacity))
def synchronized(~S:Data,~C:Type,~R:Type,~A:Data,~B:Data,~H:Type,app:F.Application<S,C,R,A,B,H>) -> W.World<S,C,R,F.Publication<A,B>> & State<S,A,B,H>:
  match app:
    case F.Application{world,streams,journal,_,frameStart}:(world,State{streams,journal,frameStart})
def synchronize(~S:Data,~C:Type,~R:Type,~A:Data,~B:Data,~H:Type,world:W.World<S,C,R,F.Publication<A,B>>,state:State<S,A,B,H>,tick:Nat) -> W.World<S,C,R,F.Publication<A,B>> & State<S,A,B,H>:
  match state:
    case State{streams,journal,frameStart}:synchronized(~S,~C,~R,~A,~B,~H,F.synced(~S,~C,~R,~A,~B,~H,W.events_view(~S,~C,~R,~F.Publication<A,B>,world),streams,journal,tick,frameStart))
def frame(~S:Data,~C:Type,~R:Type,~A:Data,~B:Data,~H:Type,runtime:Route.Runtime<S,C,R,F.Publication<A,B>,State<S,A,B,H>>) -> Route.Runtime<S,C,R,F.Publication<A,B>,State<S,A,B,H>>:
  match runtime:
    case Route.Runtime{world,State{streams,journal,frameStart},tick}:converted(~S,~C,~R,~A,~B,~H,F.frame(~S,~C,~R,~A,~B,~H,F.Application{world,streams,journal,tick,frameStart}))
