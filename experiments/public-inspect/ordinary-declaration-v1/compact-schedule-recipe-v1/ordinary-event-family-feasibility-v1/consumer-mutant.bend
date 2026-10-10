import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-declaration.bend as Event
import publication-mutant.bend as F
import stream-mutant.bend as Leaf

type Schema is Data: Schema{}
type First is Data: First{value:U32}
type Second is Data: Second{value:Bool}
type Error is Data: Aborted{}
def World() -> Type: W.World<Schema,Array<U32>,Array<U32>,F.Publication<First,Second>>
def Host() -> Type: F.Application<Schema,Array<U32>,Array<U32>,First,Second,Array<U32>>
type Scene is Type:
  Ready{factory:W.Factory,app:Host(),first:Ev.Reading<First>,second:Ev.Reading<Second>,outcome:Tx.Outcome<Error>}
  Rejected{factory:W.Factory,resource:Array<U32>,sibling:Array<U32>}
def empty(_:Unit) -> Array<U32>:ALeaf{41}
def enqueue_loop(commands:List<&1,World() -> World()>,world:World()) -> World():
  match commands:
    case []:world
    case command <> rest:enqueue_loop(rest,command(world))
def enqueue(world:World(),commands:List<&1,World() -> World()>) -> World():enqueue_loop(commands,world)
def publish(world:World(),events:List<&2,F.Publication<First,Second>>) -> World():
  W.event_publish(~Schema,~Array<U32>,~Array<U32>,~F.Publication<First,Second>,world,events)
def staged(world:World()) -> Tx.Tx<World(),F.Publication<First,Second>>:
  F.emit_first(~Schema,~Array<U32>,~Array<U32>,~First,~Second,F.emit_second(~Schema,~Array<U32>,~Array<U32>,~First,~Second,F.emit_first(~Schema,~Array<U32>,~Array<U32>,~First,~Second,Tx.begin(~World(),~F.Publication<First,Second>,world),First{7}),Second{True{}}),First{8})
def read_second(factory:W.Factory,world:World(),journal:List<&2,Ev.Batch<F.Publication<First,Second>>>,tick:Nat,frameStart:Nat,first:Ev.Reading<First>,outcome:Tx.Outcome<Error>,returned:F.Streams<Schema,First,Second,Array<U32>> & Ev.Reading<Second>) -> Scene:
  match returned:
    case (streams,second):Ready{factory,F.Application{world,streams,journal,tick,frameStart},first,second,outcome}
def read_first(factory:W.Factory,world:World(),journal:List<&2,Ev.Batch<F.Publication<First,Second>>>,+tick:Nat,frameStart:Nat,outcome:Tx.Outcome<Error>,returned:F.Streams<Schema,First,Second,Array<U32>> & Ev.Reading<First>) -> Scene:
  match returned:
    case (streams,first):read_second(factory,world,journal,tick,frameStart,first,outcome,F.observe(~Schema,~Second,~F.Streams<Schema,First,Second,Array<U32>>,~(streams => F.second_take(~Schema,~First,~Second,~Array<U32>,streams)),~(streams => stream => F.second_put(~Schema,~First,~Second,~Array<U32>,streams,stream)),streams,1,tick))
def observed(factory:W.Factory,app:Host(),outcome:Tx.Outcome<Error>) -> Scene:
  match app:
    case F.Application{world,streams,journal,+tick,frameStart}:read_first(factory,world,journal,tick,frameStart,outcome,F.observe(~Schema,~First,~F.Streams<Schema,First,Second,Array<U32>>,~(streams => F.first_take(~Schema,~First,~Second,~Array<U32>,streams)),~(streams => stream => F.first_put(~Schema,~First,~Second,~Array<U32>,streams,stream)),streams,1,tick))
def finished(factory:W.Factory,sibling:Array<U32>,returned:Tx.Returned<World(),Error>) -> Scene:
  match returned:
    case Tx.Returned{world,outcome}:observed(factory,F.sync(~Schema,~Array<U32>,~Array<U32>,~First,~Second,~Array<U32>,F.setup(~Schema,~Array<U32>,~Array<U32>,~First,~Second,~Array<U32>,world,Event.domain(~Schema,~First,"Signal"),Event.domain(~Schema,~Second,"Signal"),sibling,16n)),outcome)
def created(sibling:Array<U32>,outcome:Tx.Outcome<Error>,creation:W.Creation<Schema,Array<U32>,Array<U32>,F.Publication<First,Second>>) -> Scene:
  match creation:
    case W.CreateRejected{factory,resource}:Rejected{factory,resource,sibling}
    case W.Created{factory,world}:finished(factory,sibling,Tx.finish(~World(),~F.Publication<First,Second>,~Error,~enqueue,~publish,staged(world),outcome))
def scenario(outcome:Tx.Outcome<Error>) -> Scene:
  created(ALeaf{61},outcome,W.create(~Schema,~Array<U32>,~Array<U32>,~F.Publication<First,Second>,~empty,W.factory(),ALeaf{51}))
