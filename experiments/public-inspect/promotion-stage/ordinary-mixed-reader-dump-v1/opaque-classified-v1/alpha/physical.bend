import Base
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import ./state.bend as F
import ./event-setup.bend as Events
import /workspace/formal-proofs/bendvy/src/ecs/event-notice-runtime.bend as Mixed
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as Relation
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/event-family-runtime.bend as Family
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/event-stream.bend as Stream
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-schema-debug-v1/refusal-preservation-v1/public-successor/consumer/owner-observer.bend as Owner

type WorldView is Data:
  WorldView{namespace:U32,nextId:U32,highWater:U32,live:String,capacity:U32,depth:Nat,components:String,graph:G.Graph<F.S>,resources:String,events:List<&2,F.Events()>,pending:Nat,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32}
type View is Data:
  View{world:WorldView,first:Stream.Stream<F.S,F.FirstEvent>,second:Stream.Stream<F.S,F.SecondEvent>,unused:Stream.Stream<F.S,F.UnusedEvent>,owners:String,journal:List<&2,Ev.Batch<Events.Events()>>,frameStart:Nat,failures:Mixed.Failures<F.S,Events.Events()>,typedTick:Nat}
def store_returned(+graph:G.Graph<F.S>,column:Col.Column<F.S,F.Payload> & String,sibling:Array<U32> & String) -> F.Store() & (String & G.Graph<F.S>):
  match column sibling:
    case (column,text),(sibling,other):(Relation.Store{F.Components{column,sibling},graph},(text ++ ";sibling=" ++ other,graph))
def store(value:F.Store()) -> F.Store() & (String & G.Graph<F.S>):
  match value:
    case Relation.Store{F.Components{column,sibling},graph}:store_returned(graph,Owner.column(~F.S,~F.Payload,~F.present,column),Owner.u32_array(sibling))
def world_returned(+namespace:U32,+nextId:U32,+highWater:U32,+capacity:U32,+depth:Nat,+events:List<&2,F.Events()>,+registrations:List<&2,W.RegistrationMeta>,+nextSystemId:U32,+clock:U32,live:Array<Bool> & String,components:F.Store() & (String & G.Graph<F.S>),resources:F.Resources() & String,pending:List<(F.World() -> F.World())> & Nat) -> F.World() & WorldView:
  match live components resources pending:
    case (live,liveText),(store,(componentText,graph)),(resources,resourceText),(pending,count):(W.World{namespace,nextId,highWater,live,capacity,depth,store,resources,events,pending,registrations,nextSystemId,clock},WorldView{namespace,nextId,highWater,liveText,capacity,depth,componentText,graph,resourceText,events,count,registrations,nextSystemId,clock})
def world(value:F.World()) -> F.World() & WorldView:
  match value:
    case W.World{namespace,nextId,highWater,live,capacity,depth,components,resources,events,pending,registrations,nextSystemId,clock}:world_returned(namespace,nextId,highWater,capacity,depth,events,registrations,nextSystemId,clock,Owner.bool_array(live),store(components),Owner.u32_array(resources),Owner.callbacks(~F.World(),~F.World(),pending))
def owner_returned(world:F.World(),worldView:WorldView,+first:Stream.Stream<F.S,F.FirstEvent>,+second:Stream.Stream<F.S,F.SecondEvent>,+unused:Stream.Stream<F.S,F.UnusedEvent>,+journal:List<&2,Ev.Batch<Events.Events()>>,+frameStart:Nat,+failures:Mixed.Failures<F.S,Events.Events()>,+tick:Nat,observed:Array<U32> & String) -> Events.Runtime() & View:
  match observed:
    case (owners,text):(Route.Runtime{world,Mixed.State{Family.State{Product.Owner{Product.Owner{first,second},unused},owners,journal,frameStart},failures},tick},View{worldView,first,second,unused,text,journal,frameStart,failures,tick})
def observed(+first:Stream.Stream<F.S,F.FirstEvent>,+second:Stream.Stream<F.S,F.SecondEvent>,+unused:Stream.Stream<F.S,F.UnusedEvent>,owners:Array<U32>,journal:List<&2,Ev.Batch<Events.Events()>>,frameStart:Nat,failures:Mixed.Failures<F.S,Events.Events()>,tick:Nat,returned:F.World() & WorldView) -> Events.Runtime() & View:
  match returned:
    case (world,view):owner_returned(world,view,first,second,unused,journal,frameStart,failures,tick,Owner.u32_array(owners))
def runtime(value:Events.Runtime()) -> Events.Runtime() & View:
  match value:
    case Route.Runtime{w,Mixed.State{Family.State{Product.Owner{Product.Owner{first,second},unused},owners,journal,frameStart},failures},tick}:observed(first,second,unused,owners,journal,frameStart,failures,tick,world(w))
