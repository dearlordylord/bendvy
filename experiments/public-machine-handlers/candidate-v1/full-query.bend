import Base
import full-provider.bend as P
import full-context.bend as Ctx
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/component.bend as Cmp
import ../../../src/ecs/transaction.bend as Tx

# Trusted declared query lowering: every actual live owner is accessed via Cmp.
# Gameplay receives an opaque rank2 operation rather than the World or lenses.
def write_world(~S:Data,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,undo:List<&1,(W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> W.World<S,P.Store<S>,P.Resources<S>,P.Ping>)>,commands:List<&1,(W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> W.World<S,P.Store<S>,P.Resources<S>,P.Ping>)>,events:List<&2,P.Ping>,error:Maybe<&2,String>,id:U32,value:Array<U32>) -> Ctx.Frame<S>:
  match world:
    case W.World{+ns,next,high,live,capacity,depth,store,resource,bus,pending,registrations,nextSystem,clock}:
      Ctx.cells_result(~S,Cmp.tx_set(~S,~P.Store<S>,~P.Resources<S>,~P.Ping,~Unit,~Array<U32>,~List<&2,U32>,~P.CellsToken,~(store => P.store_take(~S,store)),~(rest => col => P.store_put(~S,rest,col)),~P.array_view,Cmp.Family{"Cells"},Tx.Tx{W.World{ns,next,high,live,capacity,depth,store,resource,bus,pending,registrations,nextSystem,clock},undo,commands,events},W.Handle{ns,id},value),error)

def write_at(~S:Data,frame:Ctx.Frame<S>,+id:U32,value:Array<U32>) -> Ctx.Frame<S>:
  match frame:
    case Ctx.Frame{Tx.Tx{world,undo,commands,events},error}: write_world(~S,world,undo,commands,events,error,id,value)

def read_result(~S:Data,error:Maybe<&2,String>,pair:Tx.Tx<W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,P.Ping> & Cmp.Access<List<&2,U32>>) -> Ctx.Frame<S> & Cmp.Access<List<&2,U32>>:
  (tx,value)=pair
  (Ctx.Frame{tx,error},value)
def read_world(~S:Data,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,undo:List<&1,(W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> W.World<S,P.Store<S>,P.Resources<S>,P.Ping>)>,commands:List<&1,(W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> W.World<S,P.Store<S>,P.Resources<S>,P.Ping>)>,events:List<&2,P.Ping>,error:Maybe<&2,String>,id:U32) -> Ctx.Frame<S> & Cmp.Access<List<&2,U32>>:
  match world:
    case W.World{+ns,next,high,live,capacity,depth,store,resource,bus,pending,registrations,nextSystem,clock}:
      read_result(~S,error,Cmp.tx_get(~S,~P.Store<S>,~P.Resources<S>,~P.Ping,~Unit,~Array<U32>,~List<&2,U32>,~P.CellsToken,~(store => P.store_take(~S,store)),~(rest => col => P.store_put(~S,rest,col)),~P.array_view,Cmp.Family{"Cells"},Tx.Tx{W.World{ns,next,high,live,capacity,depth,store,resource,bus,pending,registrations,nextSystem,clock},undo,commands,events},W.Handle{ns,id}))
def read_at(~S:Data,frame:Ctx.Frame<S>,id:U32) -> Ctx.Frame<S> & Cmp.Access<List<&2,U32>>:
  match frame:
    case Ctx.Frame{Tx.Tx{world,undo,commands,events},error}: read_world(~S,world,undo,commands,events,error,id)
def matched_values(~S:Data,frame:Ctx.Frame<S>,id:U32,values:List<&2,U32>) -> Ctx.Frame<S>:
  match frame values:
    case frame, a <> b <> c <> pad <> []: write_at(~S,frame,id,ANode{ANode{ALeaf{a},ALeaf{b}},ANode{ALeaf{U32.add(c,1)},ALeaf{pad}}})
    case Ctx.Frame{tx,error}, _: Ctx.Frame{tx,Ctx.first_error(error,"ComponentPayloadShape")}
def read_updated(~S:Data,id:U32,pair:Ctx.Frame<S> & Cmp.Access<List<&2,U32>>) -> Ctx.Frame<S>:
  match pair:
    case (frame,Cmp.Found{values}): matched_values(~S,frame,id,values)
    case (frame,_): frame

def scan(~S:Data,fuel:Nat,+id:U32,frame:Ctx.Frame<S>) -> Ctx.Frame<S>:
  match fuel:
    case 0n: frame
    case 1n+rest: scan(~S,rest,U32.add(id,1),read_updated(~S,id,read_at(~S,frame,id)))
def sized(~S:Data,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,undo:List<&1,(W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> W.World<S,P.Store<S>,P.Resources<S>,P.Ping>)>,commands:List<&1,(W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> W.World<S,P.Store<S>,P.Resources<S>,P.Ping>)>,events:List<&2,P.Ping>,error:Maybe<&2,String>) -> Ctx.Frame<S>:
  match world:
    case W.World{ns,+next,high,live,capacity,depth,store,resource,bus,pending,registrations,nextSystem,clock}:
      scan(~S,U32.to_nat(U32.sub(next,1)),1,Ctx.Frame{Tx.Tx{W.World{ns,next,high,live,capacity,depth,store,resource,bus,pending,registrations,nextSystem,clock},undo,commands,events},error})
def increment_all(~S:Data,frame:Ctx.Frame<S>,_:Unit) -> Ctx.Frame<S>:
  match frame:
    case Ctx.Frame{Tx.Tx{world,undo,commands,events},error}: sized(~S,world,undo,commands,events,error)

def owned_read_join(~S:Data,pair:Array<U32> & List<&2,U32>,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>) -> W.World<S,P.Store<S>,P.Resources<S>,P.Ping> & List<&2,U32>:
  match pair world:
    case (owner,values), W.World{ns,next,high,live,capacity,depth,store,P.Resources{_,flow,level,stream,levelStream,frame,tick,trace,aux},events,commands,registrations,nextSystem,clock}:
      (W.World{ns,next,high,live,capacity,depth,store,P.Resources{Some{owner},flow,level,stream,levelStream,frame,tick,trace,aux},events,commands,registrations,nextSystem,clock},values)
def owned_read_world(~S:Data,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>) -> W.World<S,P.Store<S>,P.Resources<S>,P.Ping> & List<&2,U32>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,P.Resources{Some{owned},flow,level,stream,levelStream,frame,tick,trace,aux},events,commands,registrations,nextSystem,clock}:
      owned_read_join(~S,P.array_view(owned),W.World{ns,next,high,live,capacity,depth,store,P.Resources{None{},flow,level,stream,levelStream,frame,tick,trace,aux},events,commands,registrations,nextSystem,clock})
    case world: (world,[])
def owned_ready(~S:Data,undo:List<&1,(W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> W.World<S,P.Store<S>,P.Resources<S>,P.Ping>)>,commands:List<&1,(W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> W.World<S,P.Store<S>,P.Resources<S>,P.Ping>)>,events:List<&2,P.Ping>,error:Maybe<&2,String>,pair:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> & List<&2,U32>) -> Ctx.Frame<S> & List<&2,U32>:
  (world,values)=pair
  (Ctx.Frame{Tx.Tx{world,undo,commands,events},error},values)
def owned_project(~S:Data,frame:Ctx.Frame<S>) -> Ctx.Frame<S> & List<&2,U32>:
  match frame:
    case Ctx.Frame{Tx.Tx{world,undo,commands,events},error}: owned_ready(~S,undo,commands,events,error,owned_read_world(~S,world))
def owned_incremented(~S:Data,pair:Ctx.Frame<S> & List<&2,U32>) -> Ctx.Frame<S>:
  match pair:
    case (frame,a <> b <> []): Ctx.owned_write(~S,frame,ANode{ALeaf{U32.add(a,1)},ALeaf{U32.add(b,10)}})
    case (Ctx.Frame{tx,error},_): Ctx.Frame{tx,Ctx.first_error(error,"ResourcePayloadShape")}
def increment_owned(~S:Data,frame:Ctx.Frame<S>,_:Unit) -> Ctx.Frame<S>:
  owned_incremented(~S,owned_project(~S,frame))
