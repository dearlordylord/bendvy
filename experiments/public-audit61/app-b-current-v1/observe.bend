import Base
import bundle.bend as B
import resources.bend as R
import owner-observer.bend as Dump
import graph-dump.bend as GraphDump
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-system.bend as Ordinary
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Query
def store_join(+graph:G.Graph<B.Scene>,left:Col.Column<B.Scene,Array<U32>> & String,right:Col.Column<B.Scene,U32> & String) -> B.Store() & String:
  (arrays,sa)=left
  (scalars,ss)=right
  (A.Store{B.Components{arrays,scalars},graph},"arrays={" ++ sa ++ "};scalars={" ++ ss ++ "};graph=" ++ GraphDump.graph(~B.Scene,graph))
def store_snapshot(value:B.Store()) -> B.Store() & String:
  match value:
    case A.Store{B.Components{arrays,scalars},graph}:store_join(graph,Dump.column(~B.Scene,~Array<U32>,~Dump.u32_array,arrays),Dump.column(~B.Scene,~U32,~Dump.u32_value,scalars))
def world_join(+namespace:U32,+nextId:U32,+high:U32,+capacity:U32,+depth:Nat,+events:List<&2,A.Notice<B.Scene,U32>>,+registrations:List<&2,W.RegistrationMeta>,+nextSystem:U32,+clock:U32,observedLive:Array<Bool> & String,observedStore:B.Store() & String,observedResources:R.Resources() & String,observedPending:List<(B.World(R.Resources()) -> B.World(R.Resources()))> & Nat) -> B.World(R.Resources()) & String:
  (live,sl)=observedLive
  (store,ss)=observedStore
  (resources,sr)=observedResources
  (pending,count)=observedPending
  (W.World{namespace,nextId,high,live,capacity,depth,store,resources,events,pending,registrations,nextSystem,clock},"namespace=" ++ U32.show(namespace) ++ "|next=" ++ U32.show(nextId) ++ "|high=" ++ U32.show(high) ++ "|live=" ++ sl ++ "|capacity=" ++ U32.show(capacity) ++ "|depth=" ++ Nat.show(depth) ++ "|store=" ++ ss ++ "|resources=" ++ sr ++ "|events=" ++ List.show(&2,A.Notice<B.Scene,U32>,GraphDump.notice(~B.Scene),events) ++ "|pending=" ++ Nat.show(count) ++ "|registrations=" ++ List.show(&2,W.RegistrationMeta,Dump.registration,registrations) ++ "|nextSystem=" ++ U32.show(nextSystem) ++ "|clock=" ++ U32.show(clock))
def world(value:B.World(R.Resources())) -> B.World(R.Resources()) & String:
  match value:
    case W.World{namespace,nextId,high,live,capacity,depth,store,resources,events,pending,registrations,nextSystem,clock}:world_join(namespace,nextId,high,capacity,depth,events,registrations,nextSystem,clock,Dump.bool_array(live),store_snapshot(store),R.resource_view(resources),Dump.callbacks(~B.World(R.Resources()),~B.World(R.Resources()),pending))
