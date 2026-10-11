import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/event-stream.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-declaration.bend as Event
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap

# Read-only retained leaf values. No operational reader action or World adapter.
def selected(~S:Data,~E:Data,allowed:Bool,+stream:Leaf.Stream<S,E>) -> Leaf.Stream<S,E> & Maybe<&2,List<&2,E>>:
  match allowed stream:
    case False{} stream:(stream,None{})
    case True{} Leaf.Stream{domain,+batches,positions,nextReader,frameStart,boundary,capacity,dropped}:(Leaf.Stream{domain,batches,positions,nextReader,frameStart,boundary,capacity,dropped},Some{Ev.values(~E,batches)})
def declared(~S:Data,~E:Data,declaration:Event.Declaration<S,E>,+stream:Leaf.Stream<S,E>) -> Leaf.Stream<S,E> & Maybe<&2,List<&2,E>>:
  match declaration stream:
    case Event.Declaration{_,Event.Write{}} stream:(stream,None{})
    case Event.Declaration{Event.Domain{expected},Event.Read{}} Leaf.Stream{Event.Domain{+actual},+batches,+positions,+nextReader,+frameStart,+boundary,+capacity,+dropped}:selected(~S,~E,String.eq(expected,actual),Leaf.Stream{Event.Domain{actual},batches,positions,nextReader,frameStart,boundary,capacity,dropped})
def restored(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~take:F -> F & Leaf.Stream<S,E>,~put:F -> Leaf.Stream<S,E> -> F,world:W.World<S,C,R,P>,tick:Nat,reader:Route.Reader<S,E,F,take,put>,family:F,returned:Leaf.Stream<S,E> & Maybe<&2,List<&2,E>>) -> (Route.Runtime<S,C,R,P,F> & Route.Reader<S,E,F,take,put>) & Maybe<&2,List<&2,E>>:
  match returned:
    case (stream,values):((Route.Runtime{world,put(family,stream),tick},reader),values)
def taken(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~take:F -> F & Leaf.Stream<S,E>,~put:F -> Leaf.Stream<S,E> -> F,declaration:Event.Declaration<S,E>,world:W.World<S,C,R,P>,tick:Nat,reader:Route.Reader<S,E,F,take,put>,returned:F & Leaf.Stream<S,E>) -> (Route.Runtime<S,C,R,P,F> & Route.Reader<S,E,F,take,put>) & Maybe<&2,List<&2,E>>:
  match returned:
    case (family,stream):restored(~S,~C,~R,~P,~E,~F,~take,~put,world,tick,reader,family,declared(~S,~E,declaration,stream))
def get(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~take:F -> F & Leaf.Stream<S,E>,~put:F -> Leaf.Stream<S,E> -> F,declaration:Event.Declaration<S,E>,owner:Route.Runtime<S,C,R,P,F> & Route.Reader<S,E,F,take,put>) -> (Route.Runtime<S,C,R,P,F> & Route.Reader<S,E,F,take,put>) & Maybe<&2,List<&2,E>>:
  match owner:
    case (Route.Runtime{world,family,tick},reader):taken(~S,~C,~R,~P,~E,~F,~take,~put,declaration,world,tick,reader,take(family))
def read(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~take:F -> F & Leaf.Stream<S,E>,~put:F -> Leaf.Stream<S,E> -> F,declaration:Event.Declaration<S,E>) -> Cap.ValueRead<(Route.Runtime<S,C,R,P,F> & Route.Reader<S,E,F,take,put>),Maybe<&2,List<&2,E>>>:
  Cap.ValueRead{owner => get(~S,~C,~R,~P,~E,~F,~take,~put,declaration,owner)}
def values(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~take:F -> F & Leaf.Stream<S,E>,~put:F -> Leaf.Stream<S,E> -> F,declaration:Event.Declaration<S,E>,owner:Route.Runtime<S,C,R,P,F> & Route.Reader<S,E,F,take,put>) -> (Route.Runtime<S,C,R,P,F> & Route.Reader<S,E,F,take,put>) & Maybe<&2,List<&2,E>>:
  Cap.value_read_field(~(Route.Runtime<S,C,R,P,F> & Route.Reader<S,E,F,take,put>),~Maybe<&2,List<&2,E>>,read(~S,~C,~R,~P,~E,~F,~take,~put,declaration))(owner)
