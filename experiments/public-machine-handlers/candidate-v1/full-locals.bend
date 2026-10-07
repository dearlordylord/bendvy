import Base
import ../../../src/ecs/local.bend as L
import ../../../src/ecs/world.bend as W
import full-provider.bend as P

# Trusted fixture placement: one affine Cell per actual namespaced registration.
# Called only inside a validated Sys runner, before its gameplay transaction.
def increment_value(pair:Array<U32> & U32) -> Array<U32> & U32:
  (owner,+value)=pair
  +next=U32.add(value,1)
  (Array.set(U32,owner,0,next),next)
def increment_array(owner:Array<U32>) -> Array<U32> & U32:
  increment_value(Array.get(U32,owner,0))
def increment_cell(cell:L.Cell<Array<U32>>) -> L.Cell<Array<U32>> & U32:
  match cell:
    case L.Cell{owner}: L.projected(~Array<U32>,~U32,increment_array(owner))
def joined(head:P.LocalEntry,tail:List<&1,P.LocalEntry> & U32) -> List<&1,P.LocalEntry> & U32:
  (rest,value)=tail
  (head <> rest,value)
def updated(namespace:U32,id:U32,pair:L.Cell<Array<U32>> & U32,rest:List<&1,P.LocalEntry>) -> List<&1,P.LocalEntry> & U32:
  (cell,value)=pair
  (P.LocalEntry{namespace,id,cell} <> rest,value)
def selected(yes:Bool,+namespace:U32,+id:U32,cell:L.Cell<Array<U32>>,tail:List<&1,P.LocalEntry> & U32) -> List<&1,P.LocalEntry> & U32:
  match yes tail:
    case True{}, (rest,_): updated(namespace,id,increment_cell(cell),rest)
    case False{}, tail: joined(P.LocalEntry{namespace,id,cell},tail)
def increment(entries:List<&1,P.LocalEntry>,+namespace:U32,+id:U32) -> List<&1,P.LocalEntry> & U32:
  match entries:
    case []: ([],0)
    case P.LocalEntry{+ns,+key,cell} <> rest: selected(Bool.and(U32.is_eq(ns,namespace),U32.is_eq(key,id)),ns,key,cell,increment(rest,namespace,id))
def world_updated(~S:Data,pair:List<&1,P.LocalEntry> & U32,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>) -> W.World<S,P.Store<S>,P.Resources<S>,P.Ping> & U32:
  match pair world:
    case (locals,value), W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,stream,levelStream,frame,tick,trace,P.Aux{_,ping,attempts,deliveries,phase,position,enabled}},events,commands,registrations,nextSystem,clock}:
      (W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,stream,levelStream,frame,tick,trace,P.Aux{locals,ping,attempts,deliveries,phase,position,enabled}},events,commands,registrations,nextSystem,clock},value)
def invoke(~S:Data,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,+id:U32) -> W.World<S,P.Store<S>,P.Resources<S>,P.Ping> & U32:
  match world:
    case W.World{+ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,stream,levelStream,frame,tick,trace,P.Aux{locals,ping,attempts,deliveries,phase,position,enabled}},events,commands,registrations,nextSystem,clock}:
      world_updated(~S,increment(locals,ns,id),W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,stream,levelStream,frame,tick,trace,P.Aux{[],ping,attempts,deliveries,phase,position,enabled}},events,commands,registrations,nextSystem,clock})
def install(~S:Data,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,id:U32) -> W.World<S,P.Store<S>,P.Resources<S>,P.Ping>:
  match world:
    case W.World{+ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,stream,levelStream,frame,tick,trace,P.Aux{locals,ping,attempts,deliveries,phase,position,enabled}},events,commands,registrations,nextSystem,clock}:
      W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,stream,levelStream,frame,tick,trace,P.Aux{List.append(&1,P.LocalEntry,locals,[P.LocalEntry{ns,id,L.Cell{ALeaf{0}}}]),ping,attempts,deliveries,phase,position,enabled}},events,commands,registrations,nextSystem,clock}
