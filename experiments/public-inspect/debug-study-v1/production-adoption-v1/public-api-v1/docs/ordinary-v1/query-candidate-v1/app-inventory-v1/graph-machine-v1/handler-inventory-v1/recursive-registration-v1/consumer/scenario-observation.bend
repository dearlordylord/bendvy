import Base
import /workspace/formal-proofs/bendvy/src/ecs/lifecycle.bend as L
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/scenario-schema.bend as S
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/scenario-dto.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as C
import /workspace/formal-proofs/bendvy/experiments/public-simulation/bend-v1/owner-view.bend as V
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/persistence-declaration.bend as R

def plain(~key:String,recipe:R.Plain<S.Schema,Array<U32>,S.identity(key)>) -> D.Storage:
  match recipe:
    case R.Plain{}:D.Plain{}
def transient(~key:String,recipe:R.Transient<S.Schema,Array<U32>,S.identity(key)>) -> D.Storage:
  match recipe:
    case R.Transient{}:D.Transient{}
def constructed(~key:String,recipe:R.Constructed<S.Schema,Array<U32>,S.identity(key),S.save>) -> D.Storage:
  match recipe:
    case R.Constructed{codec}:D.Constructed{codec}
def cell_tail(+id:U32,payload:Maybe<&2,V.FullCell>,stamp:L.Stamp,observed:C.Column<S.Schema,Array<U32>> & List<&2,D.Cell>) -> C.Column<S.Schema,Array<U32>> & List<&2,D.Cell>:
  match observed:
    case (column,tail):(column,D.Cell{id,payload,stamp} <> tail)
def cell_stamp(next:C.Column<S.Schema,Array<U32>> -> C.Column<S.Schema,Array<U32>> & List<&2,D.Cell>,+id:U32,payload:Maybe<&2,V.FullCell>,observed:C.Column<S.Schema,Array<U32>> & L.Stamp) -> C.Column<S.Schema,Array<U32>> & List<&2,D.Cell>:
  match observed:
    case (column,stamp):cell_tail(id,payload,stamp,next(column))
def cell_payload(next:C.Column<S.Schema,Array<U32>> -> C.Column<S.Schema,Array<U32>> & List<&2,D.Cell>,+id:U32,observed:C.Column<S.Schema,Array<U32>> & Maybe<&2,V.FullCell>) -> C.Column<S.Schema,Array<U32>> & List<&2,D.Cell>:
  match observed:
    case (column,payload):cell_stamp(next,id,payload,C.lifecycle(~S.Schema,~Array<U32>,column,id))
def cells(count:Nat,+id:U32,column:C.Column<S.Schema,Array<U32>>) -> C.Column<S.Schema,Array<U32>> & List<&2,D.Cell>:
  match count:
    case 0n:(column,[])
    case 1n+rest:cell_payload((column => cells(rest,(id + 1 : U32),column)),id,C.view(~S.Schema,~Array<U32>,~V.FullCell,~V.view,column,id))
def slot_cells(~Owner:Type,~Recipe:Data,~put:Recipe -> C.Column<S.Schema,Array<U32>> -> Owner,~describe:Recipe -> D.Storage,+recipe:Recipe,observed:C.Column<S.Schema,Array<U32>> & List<&2,D.Cell>) -> Owner & D.Column:
  match observed:
    case (column,values):(put(recipe,column),D.Column{describe(recipe),values})
def slot_taken(~Owner:Type,~Recipe:Data,~put:Recipe -> C.Column<S.Schema,Array<U32>> -> Owner,~describe:Recipe -> D.Storage,+highWater:U32,taken:Recipe & C.Column<S.Schema,Array<U32>>) -> Owner & D.Column:
  match taken:
    case (+recipe,column):slot_cells(~Owner,~Recipe,~put,~describe,recipe,cells(U32.to_nat(highWater),1,column))
def slot(~Owner:Type,~Recipe:Data,~take:Owner -> Recipe & C.Column<S.Schema,Array<U32>>,~put:Recipe -> C.Column<S.Schema,Array<U32>> -> Owner,~describe:Recipe -> D.Storage,+highWater:U32,owner:Owner) -> Owner & D.Column:
  slot_taken(~Owner,~Recipe,~put,~describe,highWater,take(owner))
def columns_h(~P:Type,~RP:Data,~takeP:P -> RP & C.Column<S.Schema,Array<U32>>,~putP:RP -> C.Column<S.Schema,Array<U32>> -> P,~describeP:RP -> D.Storage,~V:Type,~RV:Data,~takeV:V -> RV & C.Column<S.Schema,Array<U32>>,~putV:RV -> C.Column<S.Schema,Array<U32>> -> V,~describeV:RV -> D.Storage,~H:Type,~RH:Data,~takeH:H -> RH & C.Column<S.Schema,Array<U32>>,~putH:RH -> C.Column<S.Schema,Array<U32>> -> H,~describeH:RH -> D.Storage,p:P,v:V,op:D.Column,ov:D.Column,got:H & D.Column) -> S.Store<P,V,H> & D.Columns:
  match got:
    case (h,oh):(S.Store{p,v,h},D.Columns{op,ov,oh})
def columns_v(~P:Type,~RP:Data,~takeP:P -> RP & C.Column<S.Schema,Array<U32>>,~putP:RP -> C.Column<S.Schema,Array<U32>> -> P,~describeP:RP -> D.Storage,~V:Type,~RV:Data,~takeV:V -> RV & C.Column<S.Schema,Array<U32>>,~putV:RV -> C.Column<S.Schema,Array<U32>> -> V,~describeV:RV -> D.Storage,~H:Type,~RH:Data,~takeH:H -> RH & C.Column<S.Schema,Array<U32>>,~putH:RH -> C.Column<S.Schema,Array<U32>> -> H,~describeH:RH -> D.Storage,+highWater:U32,p:P,h:H,op:D.Column,got:V & D.Column) -> S.Store<P,V,H> & D.Columns:
  match got:
    case (v,ov):columns_h(~P,~RP,~takeP,~putP,~describeP,~V,~RV,~takeV,~putV,~describeV,~H,~RH,~takeH,~putH,~describeH,p,v,op,ov,slot(~H,~RH,~takeH,~putH,~describeH,highWater,h))
def columns_p(~P:Type,~RP:Data,~takeP:P -> RP & C.Column<S.Schema,Array<U32>>,~putP:RP -> C.Column<S.Schema,Array<U32>> -> P,~describeP:RP -> D.Storage,~V:Type,~RV:Data,~takeV:V -> RV & C.Column<S.Schema,Array<U32>>,~putV:RV -> C.Column<S.Schema,Array<U32>> -> V,~describeV:RV -> D.Storage,~H:Type,~RH:Data,~takeH:H -> RH & C.Column<S.Schema,Array<U32>>,~putH:RH -> C.Column<S.Schema,Array<U32>> -> H,~describeH:RH -> D.Storage,+highWater:U32,v:V,h:H,got:P & D.Column) -> S.Store<P,V,H> & D.Columns:
  match got:
    case (p,op):columns_v(~P,~RP,~takeP,~putP,~describeP,~V,~RV,~takeV,~putV,~describeV,~H,~RH,~takeH,~putH,~describeH,highWater,p,h,op,slot(~V,~RV,~takeV,~putV,~describeV,highWater,v))
def columns(~P:Type,~RP:Data,~takeP:P -> RP & C.Column<S.Schema,Array<U32>>,~putP:RP -> C.Column<S.Schema,Array<U32>> -> P,~describeP:RP -> D.Storage,~V:Type,~RV:Data,~takeV:V -> RV & C.Column<S.Schema,Array<U32>>,~putV:RV -> C.Column<S.Schema,Array<U32>> -> V,~describeV:RV -> D.Storage,~H:Type,~RH:Data,~takeH:H -> RH & C.Column<S.Schema,Array<U32>>,~putH:RH -> C.Column<S.Schema,Array<U32>> -> H,~describeH:RH -> D.Storage,+highWater:U32,store:S.Store<P,V,H>) -> S.Store<P,V,H> & D.Columns:
  match store:
    case S.Store{p,v,h}:columns_p(~P,~RP,~takeP,~putP,~describeP,~V,~RV,~takeV,~putV,~describeV,~H,~RH,~takeH,~putH,~describeH,highWater,v,h,slot(~P,~RP,~takeP,~putP,~describeP,highWater,p))
def bits_tail(value:Bool,got:Array<Bool> & List<&2,Bool>) -> Array<Bool> & List<&2,Bool>:
  match got:
    case (live,tail):(live,value <> tail)
def bits_got(next:Array<Bool> -> Array<Bool> & List<&2,Bool>,got:Array<Bool> & Bool) -> Array<Bool> & List<&2,Bool>:
  match got:
    case (live,value):bits_tail(value,next(live))
def bits(count:Nat,+id:U32,live:Array<Bool>) -> Array<Bool> & List<&2,Bool>:
  match count:
    case 0n:(live,[])
    case 1n+rest:bits_got((live => bits(rest,(id + 1 : U32),live)),Array.get(Bool,live,id))
def world_columns(~P:Type,~RP:Data,~takeP:P -> RP & C.Column<S.Schema,Array<U32>>,~putP:RP -> C.Column<S.Schema,Array<U32>> -> P,~describeP:RP -> D.Storage,~V:Type,~RV:Data,~takeV:V -> RV & C.Column<S.Schema,Array<U32>>,~putV:RV -> C.Column<S.Schema,Array<U32>> -> V,~describeV:RV -> D.Storage,~H:Type,~RH:Data,~takeH:H -> RH & C.Column<S.Schema,Array<U32>>,~putH:RH -> C.Column<S.Schema,Array<U32>> -> H,~describeH:RH -> D.Storage,pendingCount:U32,liveBits:List<&2,Bool>,world:W.World<S.Schema,S.Store<P,V,H>,Unit,Unit>,observed:D.Columns) -> W.World<S.Schema,S.Store<P,V,H>,Unit,Unit> & D.WorldSnapshot:
  match world:
    case W.World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,+resource,+events,pending,+registrations,+nextSystemId,+clock}:
      (W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},D.WorldSnapshot{namespace,nextId,highWater,capacity,depth,liveBits,resource,events,pendingCount,registrations,nextSystemId,clock,observed})
def world_store(~P:Type,~RP:Data,~takeP:P -> RP & C.Column<S.Schema,Array<U32>>,~putP:RP -> C.Column<S.Schema,Array<U32>> -> P,~describeP:RP -> D.Storage,~V:Type,~RV:Data,~takeV:V -> RV & C.Column<S.Schema,Array<U32>>,~putV:RV -> C.Column<S.Schema,Array<U32>> -> V,~describeV:RV -> D.Storage,~H:Type,~RH:Data,~takeH:H -> RH & C.Column<S.Schema,Array<U32>>,~putH:RH -> C.Column<S.Schema,Array<U32>> -> H,~describeH:RH -> D.Storage,pendingCount:U32,liveBits:List<&2,Bool>,got:W.World<S.Schema,S.Store<P,V,H>,Unit,Unit> & D.Columns) -> W.World<S.Schema,S.Store<P,V,H>,Unit,Unit> & D.WorldSnapshot:
  match got:
    case (world,observed):world_columns(~P,~RP,~takeP,~putP,~describeP,~V,~RV,~takeV,~putV,~describeV,~H,~RH,~takeH,~putH,~describeH,pendingCount,liveBits,world,observed)
def live_seen(~Store:Type,~Out:Type,next:Array<Bool> -> List<&2,Bool> -> Store -> Out,store:Store,got:Array<Bool> & List<&2,Bool>) -> Out:
  match got:
    case (live,values):next(live,values,store)
def world_counted(~P:Type,~RP:Data,~takeP:P -> RP & C.Column<S.Schema,Array<U32>>,~putP:RP -> C.Column<S.Schema,Array<U32>> -> P,~describeP:RP -> D.Storage,~V:Type,~RV:Data,~takeV:V -> RV & C.Column<S.Schema,Array<U32>>,~putV:RV -> C.Column<S.Schema,Array<U32>> -> V,~describeV:RV -> D.Storage,~H:Type,~RH:Data,~takeH:H -> RH & C.Column<S.Schema,Array<U32>>,~putH:RH -> C.Column<S.Schema,Array<U32>> -> H,~describeH:RH -> D.Storage,got:W.World<S.Schema,S.Store<P,V,H>,Unit,Unit> & U32) -> W.World<S.Schema,S.Store<P,V,H>,Unit,Unit> & D.WorldSnapshot:
  match got:
    case (W.World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,+resource,+events,pending,+registrations,+nextSystemId,+clock},pendingCount):
      live_seen(~S.Store<P,V,H>,~(W.World<S.Schema,S.Store<P,V,H>,Unit,Unit> & D.WorldSnapshot),(live => values => store => world_store(~P,~RP,~takeP,~putP,~describeP,~V,~RV,~takeV,~putV,~describeV,~H,~RH,~takeH,~putH,~describeH,pendingCount,values,W.with_store(~S.Schema,~S.Store<P,V,H>,~Unit,~Unit,~D.Columns,(store => columns(~P,~RP,~takeP,~putP,~describeP,~V,~RV,~takeV,~putV,~describeV,~H,~RH,~takeH,~putH,~describeH,highWater,store)),W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock}))),store,bits(U32.to_nat(capacity),0,live))
def world(~P:Type,~RP:Data,~takeP:P -> RP & C.Column<S.Schema,Array<U32>>,~putP:RP -> C.Column<S.Schema,Array<U32>> -> P,~describeP:RP -> D.Storage,~V:Type,~RV:Data,~takeV:V -> RV & C.Column<S.Schema,Array<U32>>,~putV:RV -> C.Column<S.Schema,Array<U32>> -> V,~describeV:RV -> D.Storage,~H:Type,~RH:Data,~takeH:H -> RH & C.Column<S.Schema,Array<U32>>,~putH:RH -> C.Column<S.Schema,Array<U32>> -> H,~describeH:RH -> D.Storage,world:W.World<S.Schema,S.Store<P,V,H>,Unit,Unit>) -> W.World<S.Schema,S.Store<P,V,H>,Unit,Unit> & D.WorldSnapshot:
  world_counted(~P,~RP,~takeP,~putP,~describeP,~V,~RV,~takeV,~putV,~describeV,~H,~RH,~takeH,~putH,~describeH,W.pending_count(~S.Schema,~S.Store<P,V,H>,~Unit,~Unit,world))
