import Base
import lifecycle.bend as L
import owner-handoff.bend as H
import indexed-lifecycle.bend as M

# Schema provisioning owns columns. Gameplay receives abstract providers instead.
# IDs are one-based; this bounded slice supports at most 131072 slots.
type History<-S:Data,-C:Type> is Type:
  HistoryNil{}
  HistoryCon{id:U32,value:Maybe<&1,C>,rest:History<S,C>}
type Auxiliary is Type:
  Auxiliary{}
type Marker is Data:
  Marker{}
type State<-S:Data,-C:Type> is Type:
  State{values:Array<Maybe<&1,C>>,stamps:List<&2,L.Entry>,capacity:U32,current:U32,owner:Maybe<&1,C>,remaining:H.PrototypeHandoffRows<S,C>,past:History<S,C>}
# Recursive ownership carrier prevents native union-wide field transport.
# Every constructor owns a State, directly or through its inner carrier.
type Carrier<-S:Data,-C:Type> is Type:
  Owned{state:State<S,C>}
  Wrapped{inner:Carrier<S,C>}
type IndexedOrdinaryState<-S:Data,-C:Type> is Type:
  IndexedOrdinaryState{values:Array<Maybe<&1,C>>,metadata:M.Metadata}
type IndexedOrdinaryCarrier<-S:Data,-C:Type> is Type:
  IndexedOrdinaryOwned{state:IndexedOrdinaryState<S,C>}
  IndexedOrdinaryWrapped{inner:IndexedOrdinaryCarrier<S,C>}
type IndexedPreparedState<-S:Data,-C:Type> is Type:
  IndexedPreparedState{values:Array<Maybe<&1,C>>,metadata:M.Metadata,capacity:U32,current:U32,owner:Maybe<&1,C>,remaining:H.PrototypeHandoffRows<S,C>,past:History<S,C>}
type IndexedPreparedCarrier<-S:Data,-C:Type> is Type:
  IndexedPreparedOwned{state:IndexedPreparedState<S,C>}
  IndexedPreparedWrapped{inner:IndexedPreparedCarrier<S,C>}
type Column<-S: Data, -C: Type> is Type:
  Column{values: Array<Maybe<&1,C>>,stamps: List<&2,L.Entry>}
  Prepared{state:Carrier<S,C>}
  Indexed{state:IndexedOrdinaryCarrier<S,C>}
  PreparedIndexed{state:IndexedPreparedCarrier<S,C>}
def indexed_prepared_unseal(~S:Data,~C:Type,carrier:IndexedPreparedCarrier<S,C>) -> IndexedPreparedState<S,C>:
  match carrier:
    case IndexedPreparedOwned{state}: state
    case IndexedPreparedWrapped{inner}: indexed_prepared_unseal(~S,~C,inner)
def indexed_unseal(~S:Data,~C:Type,carrier:IndexedOrdinaryCarrier<S,C>) -> IndexedOrdinaryState<S,C>:
  match carrier:
    case IndexedOrdinaryOwned{state}: state
    case IndexedOrdinaryWrapped{inner}: indexed_unseal(~S,~C,inner)
def indexed_wrap(~S:Data,~C:Type,values:Array<Maybe<&1,C>>,metadata:M.Metadata) -> Column<S,C>:
  Indexed{IndexedOrdinaryOwned{IndexedOrdinaryState{values,metadata}}}
def empty_indexed(~S:Data,~C:Type) -> Column<S,C>:
  indexed_wrap(~S,~C,ALeaf{None{}},M.empty())
def absent(~C: Type, +depth: Nat) -> Array<Maybe<&1,C>>:
  match depth:
    case 0n:
      ALeaf{None{}}
    case 1n+rest:
      ANode{absent(~C, rest), absent(~C, rest)}


def indexed_grow(~S:Data,~C:Type,fuel:Nat,values:Array<Maybe<&1,C>>,metadata:M.Metadata,+size:U32,+depth:Nat,+target:U32,enough:Bool) -> Column<S,C>:
  match fuel enough:
    case _ True{}: indexed_wrap(~S,~C,values,metadata)
    case 0n False{}: indexed_wrap(~S,~C,values,metadata)
    case 1n+rest False{}:
      +next = U32.shl(size)
      indexed_grow(~S,~C,rest,ANode{values,absent(~C,depth)},metadata,next,1n+depth,target,U32.is_le(target,next))
def indexed_ensure_sized(~S:Data,~C:Type,+target:U32,metadata:M.Metadata,result:Array<Maybe<&1,C>> & U32) -> Column<S,C>:
  match result:
    case (values,+size): indexed_grow(~S,~C,17n,values,metadata,size,U32.log2(size),target,U32.is_le(target,size))
def indexed_ensure_state(~S:Data,~C:Type,target:U32,state:IndexedOrdinaryState<S,C>) -> Column<S,C>:
  match state:
    case IndexedOrdinaryState{values,metadata}: indexed_ensure_sized(~S,~C,target,metadata,Array.size(Maybe<&1,C>,values))
def unseal(~S:Data,~C:Type,carrier:Carrier<S,C>) -> State<S,C>:
  match carrier:
    case Owned{state}: state
    case Wrapped{inner}: unseal(~S,~C,inner)

type SwapOutcome<-S: Data, -C: Type> is Type:
  Accepted{column: Column<S,C>, previous: Maybe<&1,C>}
  Rejected{column: Column<S,C>, incoming: Maybe<&1,C>}

def indexed_swapped(~S:Data,~C:Type,metadata:M.Metadata,result:Array<Maybe<&1,C>> & Maybe<&1,C>) -> SwapOutcome<S,C>:
  match result:
    case (values,previous): Accepted{indexed_wrap(~S,~C,values,metadata),previous}
def indexed_swap_checked(~S:Data,~C:Type,+id:U32,incoming:Maybe<&1,C>,metadata:M.Metadata,values:Array<Maybe<&1,C>>,valid:Bool) -> SwapOutcome<S,C>:
  match valid:
    case False{}: Rejected{indexed_wrap(~S,~C,values,metadata),incoming}
    case True{}: indexed_swapped(~S,~C,metadata,Array.swap(Maybe<&1,C>,values,U32.sub(id,1),incoming))
def indexed_swap_sized(~S:Data,~C:Type,+id:U32,incoming:Maybe<&1,C>,metadata:M.Metadata,result:Array<Maybe<&1,C>> & U32) -> SwapOutcome<S,C>:
  match result:
    case (values,size): indexed_swap_checked(~S,~C,id,incoming,metadata,values,U32.is_gt(id,0) && U32.is_le(id,size) && U32.is_le(id,131072))
def indexed_swap_state(~S:Data,~C:Type,+id:U32,incoming:Maybe<&1,C>,state:IndexedOrdinaryState<S,C>) -> SwapOutcome<S,C>:
  match state:
    case IndexedOrdinaryState{values,metadata}: indexed_swap_sized(~S,~C,id,incoming,metadata,Array.size(Maybe<&1,C>,values))
def indexed_view_restored(~S:Data,~C:Type,~V:Data,metadata:M.Metadata,projection:V,result:Array<Maybe<&1,C>> & Maybe<&1,C>) -> Column<S,C> & Maybe<&2,V>:
  match result:
    case (values,_): (indexed_wrap(~S,~C,values,metadata),Some{projection})
def indexed_view_projected(~S:Data,~C:Type,~V:Data,+id:U32,values:Array<Maybe<&1,C>>,metadata:M.Metadata,result:C & V) -> Column<S,C> & Maybe<&2,V>:
  match result:
    case (owner,projection): indexed_view_restored(~S,~C,~V,metadata,projection,Array.swap(Maybe<&1,C>,values,U32.sub(id,1),Some{owner}))
def indexed_view_taken(~S:Data,~C:Type,~V:Data,~project:C -> C & V,+id:U32,metadata:M.Metadata,result:Array<Maybe<&1,C>> & Maybe<&1,C>) -> Column<S,C> & Maybe<&2,V>:
  match result:
    case (values,None{}): (indexed_wrap(~S,~C,values,metadata),None{})
    case (values,Some{owner}): indexed_view_projected(~S,~C,~V,id,values,metadata,project(owner))
def indexed_view_checked(~S:Data,~C:Type,~V:Data,~project:C -> C & V,+id:U32,values:Array<Maybe<&1,C>>,metadata:M.Metadata,valid:Bool) -> Column<S,C> & Maybe<&2,V>:
  match valid:
    case False{}: (indexed_wrap(~S,~C,values,metadata),None{})
    case True{}: indexed_view_taken(~S,~C,~V,~project,id,metadata,Array.swap(Maybe<&1,C>,values,U32.sub(id,1),None{}))
def indexed_view_sized(~S:Data,~C:Type,~V:Data,~project:C -> C & V,+id:U32,metadata:M.Metadata,result:Array<Maybe<&1,C>> & U32) -> Column<S,C> & Maybe<&2,V>:
  match result:
    case (values,size): indexed_view_checked(~S,~C,~V,~project,id,values,metadata,U32.is_gt(id,0) && U32.is_le(id,size) && U32.is_le(id,131072))
def indexed_view_state(~S:Data,~C:Type,~V:Data,~project:C -> C & V,+id:U32,state:IndexedOrdinaryState<S,C>) -> Column<S,C> & Maybe<&2,V>:
  match state:
    case IndexedOrdinaryState{values,metadata}: indexed_view_sized(~S,~C,~V,~project,id,metadata,Array.size(Maybe<&1,C>,values))
def indexed_projected_state(~S:Data,~C:Type,~V:Data,+id:U32,result:C & V,state:IndexedOrdinaryState<S,C>) -> Column<S,C> & Maybe<&2,V>:
  match state:
    case IndexedOrdinaryState{values,metadata}: indexed_view_projected(~S,~C,~V,id,values,metadata,result)
def indexed_lifecycle_got(~S:Data,~C:Type,values:Array<Maybe<&1,C>>,result:M.Metadata & L.Stamp) -> Column<S,C> & L.Stamp:
  match result:
    case (metadata,stamp): (indexed_wrap(~S,~C,values,metadata),stamp)
def indexed_lifecycle_state(~S:Data,~C:Type,+id:U32,state:IndexedOrdinaryState<S,C>) -> Column<S,C> & L.Stamp:
  match state:
    case IndexedOrdinaryState{values,metadata}: indexed_lifecycle_got(~S,~C,values,M.get(metadata,id))
def indexed_restore_state(~S:Data,~C:Type,+id:U32,stamp:L.Stamp,state:IndexedOrdinaryState<S,C>) -> Column<S,C>:
  match state:
    case IndexedOrdinaryState{values,metadata}: indexed_wrap(~S,~C,values,M.set(metadata,id,stamp))
def indexed_mark_got(~S:Data,~C:Type,+id:U32,incoming:Bool,wasPresent:Bool,tick:U32,values:Array<Maybe<&1,C>>,result:M.Metadata & L.Stamp) -> Column<S,C>:
  match result:
    case (metadata,stamp): indexed_wrap(~S,~C,values,M.set(metadata,id,L.after_write(incoming,wasPresent,stamp,tick)))
def indexed_mark_state(~S:Data,~C:Type,+id:U32,incoming:Bool,wasPresent:Bool,tick:U32,state:IndexedOrdinaryState<S,C>) -> Column<S,C>:
  match state:
    case IndexedOrdinaryState{values,metadata}: indexed_mark_got(~S,~C,id,incoming,wasPresent,tick,values,M.get(metadata,id))
def indexed_clear_state(~S:Data,~C:Type,+id:U32,state:IndexedOrdinaryState<S,C>) -> Column<S,C>:
  match state:
    case IndexedOrdinaryState{values,metadata}: indexed_wrap(~S,~C,values,M.clear(metadata,id))

def empty(~S: Data, ~C: Type) -> Column<S,C>:
  Column{ALeaf{None{}},[]}

def grow(~S: Data, ~C: Type, fuel: Nat, values: Array<Maybe<&1,C>>, +stamps: List<&2,L.Entry>, +size: U32, +depth: Nat, +target: U32, enough: Bool) -> Column<S,C>:
  match fuel enough:
    case _ True{}:
      Column{values,stamps}
    case 0n False{}:
      Column{values,stamps}
    case 1n+rest False{}:
      +next = U32.shl(size)
      grow(~S, ~C, rest, ANode{values, absent(~C, depth)}, stamps, next, 1n+depth, target, U32.is_le(target, next))

def ensure_sized(~S: Data, ~C: Type, +target: U32, +stamps: List<&2,L.Entry>, sized: Array<Maybe<&1,C>> & U32) -> Column<S,C>:
  (values, +size) = sized
  grow(~S, ~C, 17n, values, stamps, size, U32.log2(size), target, U32.is_le(target, size))

# Recovery completes every evacuated owner before ordinary-array fallback.
def recover_past(~S:Data,~C:Type,past:History<S,C>,values:Array<Maybe<&1,C>>) -> Array<Maybe<&1,C>>:
  match past:
    case HistoryNil{}: values
    case HistoryCon{+id,owner,rest}: recover_past(~S,~C,rest,Array.set(Maybe<&1,C>,values,U32.sub(id,1),owner))
def recover_remaining(~S:Data,~C:Type,stamps:List<&2,L.Entry>,result:Array<Maybe<&1,C>> & List<&2,U32>) -> Column<S,C>:
  match result:
    case (values,_): Column{values,stamps}
# Partial evaluation of selected recovery's unused ID-list projection.
# Actual affine owners and ascending Array.set writes are unchanged.
def recover_selected_rows(-S:Data,-C:Type,rows:H.PrototypeHandoffRows<S,C>,values:Array<Maybe<&1,C>>) -> Array<Maybe<&1,C>>:
  match rows:
    case H.HandoffNil{}: values
    case H.HandoffCon{+id,owner,rest}: recover_selected_rows(S,C,rest,Array.set(Maybe<&1,C>,values,U32.sub(id,1),Some{owner}))
def recover_current(~S:Data,~C:Type,values:Array<Maybe<&1,C>>,+stamps:List<&2,L.Entry>,+current:U32,owner:Maybe<&1,C>,remaining:H.PrototypeHandoffRows<S,C>,past:History<S,C>,active:Bool) -> Column<S,C>:
  match active:
    case False{}: Column{recover_selected_rows(S,C,remaining,recover_past(~S,~C,past,values)),stamps}
    case True{}: Column{recover_selected_rows(S,C,remaining,recover_past(~S,~C,past,Array.set(Maybe<&1,C>,values,U32.sub(current,1),owner))),stamps}
def indexed_recover_current(~S:Data,~C:Type,values:Array<Maybe<&1,C>>,metadata:M.Metadata,+current:U32,owner:Maybe<&1,C>,remaining:H.PrototypeHandoffRows<S,C>,past:History<S,C>,active:Bool) -> Column<S,C>:
  match active:
    case False{}: indexed_wrap(~S,~C,recover_selected_rows(S,C,remaining,recover_past(~S,~C,past,values)),metadata)
    case True{}: indexed_wrap(~S,~C,recover_selected_rows(S,C,remaining,recover_past(~S,~C,past,Array.set(Maybe<&1,C>,values,U32.sub(current,1),owner))),metadata)
def recover_state(~S:Data,~C:Type,state:State<S,C>) -> Column<S,C>:
  match state:
    case State{values,stamps,_,+current,owner,remaining,past}: recover_current(~S,~C,values,stamps,current,owner,remaining,past,U32.is_gt(current,0))
def indexed_recover_state(~S:Data,~C:Type,state:IndexedPreparedState<S,C>) -> Column<S,C>:
  match state:
    case IndexedPreparedState{values,metadata,_,+current,owner,remaining,past}: indexed_recover_current(~S,~C,values,metadata,current,owner,remaining,past,U32.is_gt(current,0))
def recover(~S:Data,~C:Type,column:Column<S,C>) -> Column<S,C>:
  match column:
    case Column{values,stamps}: Column{values,stamps}
    case Prepared{carrier}: recover_state(~S,~C,unseal(~S,~C,carrier))
    case Indexed{carrier}: Indexed{carrier}
    case PreparedIndexed{carrier}: indexed_recover_state(~S,~C,indexed_prepared_unseal(~S,~C,carrier))
def prepared_return(~S:Data,~C:Type,stamps:List<&2,L.Entry>,capacity:U32,result:H.Rows<C,Auxiliary,Marker> & H.PrototypeHandoffRows<S,C>) -> Column<S,C>:
  match result:
    case (H.Rows{values,_,_,_,_,_},rows): Prepared{Owned{State{values,stamps,capacity,0,None{},rows,HistoryNil{}}}}
# Source partial evaluation of exact selected Required/all-live handoff producer.
# Every physical index is in bounds; synthetic Aux/flags/stamps were unused.
type EvacuationPhase<-S:Data,-C:Type> is Type:
  Fetch{fuel:Nat,id:U32,values:Array<Maybe<&1,C>>,rows:H.PrototypeHandoffRows<S,C>}
  Taken{fuel:Nat,id:U32,rows:H.PrototypeHandoffRows<S,C>,result:Array<Maybe<&1,C>> & Maybe<&1,C>}
def evacuate_phase(~S:Data,~C:Type,gas:Nat,phase:EvacuationPhase<S,C>) -> Array<Maybe<&1,C>> & H.PrototypeHandoffRows<S,C>:
  match gas phase:
    case _ Fetch{0n,_,values,rows}: (values,rows)
    case 0n Fetch{_,_,values,rows}: (values,rows)
    case 0n Taken{_,_,rows,(values,None{})}: (values,rows)
    case 0n Taken{_,id,rows,(values,Some{owner})}: (values,H.HandoffCon{id,owner,rows})
    case 1n+more Fetch{1n+rest,+id,values,rows}: evacuate_phase(~S,~C,more,Taken{rest,id,rows,Array.swap(Maybe<&1,C>,values,U32.sub(id,1),None{})})
    case 1n+more Taken{fuel,+id,rows,(values,None{})}: evacuate_phase(~S,~C,more,Fetch{fuel,U32.sub(id,1),values,rows})
    case 1n+more Taken{fuel,+id,rows,(values,Some{owner})}: evacuate_phase(~S,~C,more,Fetch{fuel,U32.sub(id,1),values,H.HandoffCon{id,owner,rows}})
# The pending swap tuple is already fetched; zero fuel still moves that owner.
def evacuate_pending(~S:Data,~C:Type,fuel:Nat,+id:U32,rows:H.PrototypeHandoffRows<S,C>,observed:Array<Maybe<&1,C>> & Maybe<&1,C>) -> Array<Maybe<&1,C>> & H.PrototypeHandoffRows<S,C>:
  match fuel observed:
    case 0n, (values,None{}): (values,rows)
    case 0n, (values,Some{owner}): (values,H.HandoffCon{id,owner,rows})
    case 1n+rest, (values,None{}):
      +nextId = U32.sub(id,1)
      evacuate_pending(~S,~C,rest,nextId,rows,Array.swap(Maybe<&1,C>,values,U32.sub(nextId,1),None{}))
    case 1n+rest, (values,Some{owner}):
      +nextId = U32.sub(id,1)
      evacuate_pending(~S,~C,rest,nextId,H.HandoffCon{id,owner,rows},Array.swap(Maybe<&1,C>,values,U32.sub(nextId,1),None{}))
def evacuate_start(~S:Data,~C:Type,fuel:Nat,+id:U32,values:Array<Maybe<&1,C>>,rows:H.PrototypeHandoffRows<S,C>) -> Array<Maybe<&1,C>> & H.PrototypeHandoffRows<S,C>:
  evacuate_pending(~S,~C,fuel,id,rows,Array.swap(Maybe<&1,C>,values,U32.sub(id,1),None{}))
# Keep the exact original exported reusable-fuel/affine-ID function type.
def evacuate(~S:Data,~C:Type,+fuel:Nat,id:U32,values:Array<Maybe<&1,C>>,rows:H.PrototypeHandoffRows<S,C>) -> Array<Maybe<&1,C>> & H.PrototypeHandoffRows<S,C>:
  match fuel:
    case 0n: (values,rows)
    case 1n+rest: evacuate_start(~S,~C,rest,id,values,rows)
def prepared_evacuated(~S:Data,~C:Type,stamps:List<&2,L.Entry>,capacity:U32,result:Array<Maybe<&1,C>> & H.PrototypeHandoffRows<S,C>) -> Column<S,C>:
  match result:
    case (values,rows): Prepared{Owned{State{values,stamps,capacity,0,None{},rows,HistoryNil{}}}}
def indexed_prepared_evacuated(~S:Data,~C:Type,metadata:M.Metadata,capacity:U32,result:Array<Maybe<&1,C>> & H.PrototypeHandoffRows<S,C>) -> Column<S,C>:
  match result:
    case (values,rows): PreparedIndexed{IndexedPreparedOwned{IndexedPreparedState{values,metadata,capacity,0,None{},rows,HistoryNil{}}}}
def prepare_sized(~S:Data,~C:Type,+stamps:List<&2,L.Entry>,result:Array<Maybe<&1,C>> & U32) -> Column<S,C>:
  match result:
    case (values,+size): prepared_evacuated(~S,~C,stamps,size,evacuate(~S,~C,U32.to_nat(size),size,values,H.HandoffNil{}))
def indexed_prepare_sized(~S:Data,~C:Type,metadata:M.Metadata,result:Array<Maybe<&1,C>> & U32) -> Column<S,C>:
  match result:
    case (values,+size): indexed_prepared_evacuated(~S,~C,metadata,size,evacuate(~S,~C,U32.to_nat(size),size,values,H.HandoffNil{}))
def indexed_prepare_state(~S:Data,~C:Type,state:IndexedOrdinaryState<S,C>) -> Column<S,C>:
  match state:
    case IndexedOrdinaryState{values,metadata}: indexed_prepare_sized(~S,~C,metadata,Array.size(Maybe<&1,C>,values))
def prepare(~S:Data,~C:Type,column:Column<S,C>) -> Column<S,C>:
  match column:
    case Column{values,stamps}: prepare_sized(~S,~C,stamps,Array.size(Maybe<&1,C>,values))
    case Prepared{carrier}: Prepared{carrier}
    case Indexed{carrier}: indexed_prepare_state(~S,~C,indexed_unseal(~S,~C,carrier))
    case PreparedIndexed{carrier}: PreparedIndexed{carrier}

def ensure_recovered(~S:Data,~C:Type,target:U32,column:Column<S,C>) -> Column<S,C>:
  match column:
    case Column{values,stamps}: ensure_sized(~S,~C,target,stamps,Array.size(Maybe<&1,C>,values))
    case Indexed{carrier}: indexed_ensure_state(~S,~C,target,indexed_unseal(~S,~C,carrier))
    case other: other
def ensure_prepared(~S:Data,~C:Type,+target:U32,column:Column<S,C>,fits:Bool) -> Column<S,C>:
  match fits:
    case True{}: column
    case False{}: ensure_recovered(~S,~C,target,recover(~S,~C,column))

def ensure_state(~S:Data,~C:Type,+target:U32,state:State<S,C>) -> Column<S,C>:
  match state:
    case State{values,stamps,+capacity,current,owner,remaining,past}: ensure_prepared(~S,~C,target,Prepared{Owned{State{values,stamps,capacity,current,owner,remaining,past}}},U32.is_le(target,capacity))
def indexed_prepared_ensure_state(~S:Data,~C:Type,+target:U32,state:IndexedPreparedState<S,C>) -> Column<S,C>:
  match state:
    case IndexedPreparedState{values,metadata,+capacity,current,owner,remaining,past}: ensure_prepared(~S,~C,target,PreparedIndexed{IndexedPreparedOwned{IndexedPreparedState{values,metadata,capacity,current,owner,remaining,past}}},U32.is_le(target,capacity))
def ensure_checked(~S: Data, ~C: Type, column: Column<S,C>, +target: U32, valid: Bool) -> Column<S,C>:
  match column valid:
    case _ False{}:
      column
    case Column{values,stamps} True{}:
      ensure_sized(~S, ~C, target, stamps, Array.size(Maybe<&1,C>, values))
    case Prepared{carrier} True{}: ensure_state(~S,~C,target,unseal(~S,~C,carrier))
    case Indexed{carrier} True{}: indexed_ensure_state(~S,~C,target,indexed_unseal(~S,~C,carrier))
    case PreparedIndexed{carrier} True{}: indexed_prepared_ensure_state(~S,~C,target,indexed_prepared_unseal(~S,~C,carrier))

def ensure(~S: Data, ~C: Type, column: Column<S,C>, +target: U32) -> Column<S,C>:
  ensure_checked(~S, ~C, column, target, U32.is_gt(target, 0) && U32.is_le(target, 131072))

def swapped(~S: Data, ~C: Type, result: Array<Maybe<&1,C>> & Maybe<&1,C>,stamps: List<&2,L.Entry>) -> SwapOutcome<S,C>:
  (values, previous) = result
  Accepted{Column{values,stamps}, previous}

def swap_checked(~S: Data, ~C: Type, values: Array<Maybe<&1,C>>,stamps: List<&2,L.Entry>, id: U32, incoming: Maybe<&1,C>, valid: Bool) -> SwapOutcome<S,C>:
  match valid:
    case False{}:
      Rejected{Column{values,stamps}, incoming}
    case True{}:
      swapped(~S, ~C, Array.swap(Maybe<&1,C>, values, U32.sub(id, 1), incoming),stamps)

def swap_sized(~S: Data, ~C: Type, +id: U32, incoming: Maybe<&1,C>, stamps: List<&2,L.Entry>, sized: Array<Maybe<&1,C>> & U32) -> SwapOutcome<S,C>:
  (values, size) = sized
  swap_checked(~S, ~C, values, stamps, id, incoming, U32.is_gt(id, 0) && U32.is_le(id, size) && U32.is_le(id, 131072))

def past_current(~S:Data,~C:Type,current:U32,owner:Maybe<&1,C>,past:History<S,C>,active:Bool) -> History<S,C>:
  match active:
    case False{}: past
    case True{}: HistoryCon{current,owner,past}
type SeekPhase is Data:
  Inspect{}
  Choice{equal:Bool,before:Bool}
def seek(~S:Data,~C:Type,fuel:Nat,values:Array<Maybe<&1,C>>,stamps:List<&2,L.Entry>,capacity:U32,+target:U32,incoming:Maybe<&1,C>,remaining:H.PrototypeHandoffRows<S,C>,past:History<S,C>,phase:SeekPhase) -> SwapOutcome<S,C>:
  match fuel remaining phase:
    case _ H.HandoffNil{} _: Accepted{Prepared{Owned{State{values,stamps,capacity,target,incoming,H.HandoffNil{},past}}},None{}}
    case 0n H.HandoffCon{id,owner,rest} _: Rejected{Prepared{Owned{State{values,stamps,capacity,0,None{},H.HandoffCon{id,owner,rest},past}}},incoming}
    case 1n+more H.HandoffCon{+id,owner,rest} Inspect{}: seek(~S,~C,more,values,stamps,capacity,target,incoming,H.HandoffCon{id,owner,rest},past,Choice{U32.is_eq(target,id),U32.is_lt(target,id)})
    case 1n+more H.HandoffCon{id,owner,rest} Choice{True{},_}: Accepted{Prepared{Owned{State{values,stamps,capacity,target,incoming,rest,past}}},Some{owner}}
    case 1n+more H.HandoffCon{id,owner,rest} Choice{False{},True{}}: Accepted{Prepared{Owned{State{values,stamps,capacity,target,incoming,H.HandoffCon{id,owner,rest},past}}},None{}}
    case 1n+more H.HandoffCon{id,owner,rest} Choice{False{},False{}}: seek(~S,~C,more,values,stamps,capacity,target,incoming,rest,HistoryCon{id,Some{owner},past},Inspect{})
def indexed_seek(~S:Data,~C:Type,fuel:Nat,values:Array<Maybe<&1,C>>,metadata:M.Metadata,capacity:U32,+target:U32,incoming:Maybe<&1,C>,remaining:H.PrototypeHandoffRows<S,C>,past:History<S,C>,phase:SeekPhase) -> SwapOutcome<S,C>:
  match fuel remaining phase:
    case _ H.HandoffNil{} _: Accepted{PreparedIndexed{IndexedPreparedOwned{IndexedPreparedState{values,metadata,capacity,target,incoming,H.HandoffNil{},past}}},None{}}
    case 0n H.HandoffCon{id,owner,rest} _: Rejected{PreparedIndexed{IndexedPreparedOwned{IndexedPreparedState{values,metadata,capacity,0,None{},H.HandoffCon{id,owner,rest},past}}},incoming}
    case 1n+more H.HandoffCon{+id,owner,rest} Inspect{}: indexed_seek(~S,~C,more,values,metadata,capacity,target,incoming,H.HandoffCon{id,owner,rest},past,Choice{U32.is_eq(target,id),U32.is_lt(target,id)})
    case 1n+more H.HandoffCon{id,owner,rest} Choice{True{},_}: Accepted{PreparedIndexed{IndexedPreparedOwned{IndexedPreparedState{values,metadata,capacity,target,incoming,rest,past}}},Some{owner}}
    case 1n+more H.HandoffCon{id,owner,rest} Choice{False{},True{}}: Accepted{PreparedIndexed{IndexedPreparedOwned{IndexedPreparedState{values,metadata,capacity,target,incoming,H.HandoffCon{id,owner,rest},past}}},None{}}
    case 1n+more H.HandoffCon{id,owner,rest} Choice{False{},False{}}: indexed_seek(~S,~C,more,values,metadata,capacity,target,incoming,rest,HistoryCon{id,Some{owner},past},Inspect{})
def swap_recovered(~S:Data,~C:Type,+id:U32,incoming:Maybe<&1,C>,column:Column<S,C>) -> SwapOutcome<S,C>:
  match column:
    case Column{values,stamps}: swap_sized(~S,~C,id,incoming,stamps,Array.size(Maybe<&1,C>,values))
    case Indexed{carrier}: indexed_swap_state(~S,~C,id,incoming,indexed_unseal(~S,~C,carrier))
    case other: Rejected{other,incoming}
def prepared_swap(~S:Data,~C:Type,values:Array<Maybe<&1,C>>,stamps:List<&2,L.Entry>,+capacity:U32,+current:U32,owner:Maybe<&1,C>,remaining:H.PrototypeHandoffRows<S,C>,past:History<S,C>,+id:U32,incoming:Maybe<&1,C>,valid:Bool,same:Bool,backwards:Bool) -> SwapOutcome<S,C>:
  match valid same backwards:
    case False{} _ _: Rejected{Prepared{Owned{State{values,stamps,capacity,current,owner,remaining,past}}},incoming}
    case True{} True{} _: Accepted{Prepared{Owned{State{values,stamps,capacity,current,incoming,remaining,past}}},owner}
    case True{} False{} True{}: swap_recovered(~S,~C,id,incoming,recover(~S,~C,Prepared{Owned{State{values,stamps,capacity,current,owner,remaining,past}}}))
    case True{} False{} False{}: seek(~S,~C,U32.to_nat(U32.add(U32.add(capacity,capacity),1)),values,stamps,capacity,id,incoming,remaining,past_current(~S,~C,current,owner,past,U32.is_gt(current,0)),Inspect{})
def indexed_prepared_swap(~S:Data,~C:Type,values:Array<Maybe<&1,C>>,metadata:M.Metadata,+capacity:U32,+current:U32,owner:Maybe<&1,C>,remaining:H.PrototypeHandoffRows<S,C>,past:History<S,C>,+id:U32,incoming:Maybe<&1,C>,valid:Bool,same:Bool,backwards:Bool) -> SwapOutcome<S,C>:
  match valid same backwards:
    case False{} _ _: Rejected{PreparedIndexed{IndexedPreparedOwned{IndexedPreparedState{values,metadata,capacity,current,owner,remaining,past}}},incoming}
    case True{} True{} _: Accepted{PreparedIndexed{IndexedPreparedOwned{IndexedPreparedState{values,metadata,capacity,current,incoming,remaining,past}}},owner}
    case True{} False{} True{}: swap_recovered(~S,~C,id,incoming,recover(~S,~C,PreparedIndexed{IndexedPreparedOwned{IndexedPreparedState{values,metadata,capacity,current,owner,remaining,past}}}))
    case True{} False{} False{}: indexed_seek(~S,~C,U32.to_nat(U32.add(U32.add(capacity,capacity),1)),values,metadata,capacity,id,incoming,remaining,past_current(~S,~C,current,owner,past,U32.is_gt(current,0)),Inspect{})
def swap_state(~S:Data,~C:Type,+id:U32,incoming:Maybe<&1,C>,state:State<S,C>) -> SwapOutcome<S,C>:
  match state:
    case State{values,stamps,+capacity,+current,owner,remaining,past}: prepared_swap(~S,~C,values,stamps,capacity,current,owner,remaining,past,id,incoming,U32.is_gt(id,0) && U32.is_le(id,capacity),U32.is_eq(id,current),U32.is_lt(id,current))
def indexed_prepared_swap_state(~S:Data,~C:Type,+id:U32,incoming:Maybe<&1,C>,state:IndexedPreparedState<S,C>) -> SwapOutcome<S,C>:
  match state:
    case IndexedPreparedState{values,metadata,+capacity,+current,owner,remaining,past}: indexed_prepared_swap(~S,~C,values,metadata,capacity,current,owner,remaining,past,id,incoming,U32.is_gt(id,0) && U32.is_le(id,capacity),U32.is_eq(id,current),U32.is_lt(id,current))
def swap(~S: Data, ~C: Type, column: Column<S,C>, +id: U32, incoming: Maybe<&1,C>) -> SwapOutcome<S,C>:
  match column:
    case Column{values,stamps}: swap_sized(~S,~C,id,incoming,stamps,Array.size(Maybe<&1,C>,values))
    case Prepared{carrier}: swap_state(~S,~C,id,incoming,unseal(~S,~C,carrier))
    case Indexed{carrier}: indexed_swap_state(~S,~C,id,incoming,indexed_unseal(~S,~C,carrier))
    case PreparedIndexed{carrier}: indexed_prepared_swap_state(~S,~C,id,incoming,indexed_prepared_unseal(~S,~C,carrier))

def remove(~S: Data, ~C: Type, column: Column<S,C>, id: U32) -> SwapOutcome<S,C>:
  swap(~S, ~C, column, id, None{})

def restored(~S: Data, ~C: Type, ~V: Data, result: Array<Maybe<&1,C>> & Maybe<&1,C>, projection: V,stamps: List<&2,L.Entry>) -> Column<S,C> & Maybe<&2,V>:
  (values, none) = result
  (Column{values,stamps}, Some{projection})

def viewed_return(~S:Data,~C:Type,~V:Data,view:V,result:SwapOutcome<S,C>) -> Column<S,C> & Maybe<&2,V>:
  match result:
    case Accepted{column,_}: (column,Some{view})
    case Rejected{column,_}: (column,None{})
def viewed(~S: Data, ~C: Type, ~V: Data, projected: C & V, column: Column<S,C>, id: U32) -> Column<S,C> & Maybe<&2,V>:
  match projected column:
    case (owner,result) Column{values,stamps}: restored(~S,~C,~V,Array.swap(Maybe<&1,C>,values,U32.sub(id,1),Some{owner}),result,stamps)
    case (owner,result) Prepared{carrier}: viewed_return(~S,~C,~V,result,swap(~S,~C,Prepared{carrier},id,Some{owner}))
    case (owner,result) Indexed{carrier}: indexed_projected_state(~S,~C,~V,id,(owner,result),indexed_unseal(~S,~C,carrier))
    case (owner,result) PreparedIndexed{carrier}: viewed_return(~S,~C,~V,result,swap(~S,~C,PreparedIndexed{carrier},id,Some{owner}))

def view_taken(~S: Data, ~C: Type, ~V: Data, ~project: C -> C & V, id: U32, outcome: SwapOutcome<S,C>) -> Column<S,C> & Maybe<&2,V>:
  match outcome:
    case Rejected{column, incoming}:
      (column, None{})
    case Accepted{column, None{}}:
      (column, None{})
    case Accepted{column, Some{owner}}:
      viewed(~S, ~C, ~V, project(owner), column, id)

# Ordinary columns retain direct affine Array projection/restoration. Preparing
# is opt-in; unused prepared storage must not add temporary swap-owner transport.
def plain_view_projected(~S:Data,~C:Type,~V:Data,values:Array<Maybe<&1,C>>,stamps:List<&2,L.Entry>,id:U32,result:C & V) -> Column<S,C> & Maybe<&2,V>:
  match result:
    case (owner,projection): restored(~S,~C,~V,Array.swap(Maybe<&1,C>,values,U32.sub(id,1),Some{owner}),projection,stamps)
def plain_view_taken(~S:Data,~C:Type,~V:Data,~project:C -> C & V,stamps:List<&2,L.Entry>,id:U32,result:Array<Maybe<&1,C>> & Maybe<&1,C>) -> Column<S,C> & Maybe<&2,V>:
  match result:
    case (values,None{}): (Column{values,stamps},None{})
    case (values,Some{owner}): plain_view_projected(~S,~C,~V,values,stamps,id,project(owner))
def plain_view_checked(~S:Data,~C:Type,~V:Data,~project:C -> C & V,values:Array<Maybe<&1,C>>,stamps:List<&2,L.Entry>,+id:U32,valid:Bool) -> Column<S,C> & Maybe<&2,V>:
  match valid:
    case False{}: (Column{values,stamps},None{})
    case True{}: plain_view_taken(~S,~C,~V,~project,stamps,id,Array.swap(Maybe<&1,C>,values,U32.sub(id,1),None{}))
def plain_view_sized(~S:Data,~C:Type,~V:Data,~project:C -> C & V,+id:U32,stamps:List<&2,L.Entry>,result:Array<Maybe<&1,C>> & U32) -> Column<S,C> & Maybe<&2,V>:
  match result:
    case (values,size): plain_view_checked(~S,~C,~V,~project,values,stamps,id,U32.is_gt(id,0) && U32.is_le(id,size) && U32.is_le(id,131072))
def prepared_view_projected(~S:Data,~C:Type,~V:Data,values:Array<Maybe<&1,C>>,stamps:List<&2,L.Entry>,capacity:U32,current:U32,remaining:H.PrototypeHandoffRows<S,C>,past:History<S,C>,result:C & V) -> Column<S,C> & Maybe<&2,V>:
  match result:
    case (owner,projection): (Prepared{Owned{State{values,stamps,capacity,current,Some{owner},remaining,past}}},Some{projection})
def indexed_prepared_view_projected(~S:Data,~C:Type,~V:Data,values:Array<Maybe<&1,C>>,metadata:M.Metadata,capacity:U32,current:U32,remaining:H.PrototypeHandoffRows<S,C>,past:History<S,C>,result:C & V) -> Column<S,C> & Maybe<&2,V>:
  match result:
    case (owner,projection): (PreparedIndexed{IndexedPreparedOwned{IndexedPreparedState{values,metadata,capacity,current,Some{owner},remaining,past}}},Some{projection})
def prepared_view_current(~S:Data,~C:Type,~V:Data,~project:C -> C & V,values:Array<Maybe<&1,C>>,stamps:List<&2,L.Entry>,capacity:U32,current:U32,owner:Maybe<&1,C>,remaining:H.PrototypeHandoffRows<S,C>,past:History<S,C>) -> Column<S,C> & Maybe<&2,V>:
  match owner:
    case None{}: (Prepared{Owned{State{values,stamps,capacity,current,None{},remaining,past}}},None{})
    case Some{owned}: prepared_view_projected(~S,~C,~V,values,stamps,capacity,current,remaining,past,project(owned))
def indexed_prepared_view_current(~S:Data,~C:Type,~V:Data,~project:C -> C & V,values:Array<Maybe<&1,C>>,metadata:M.Metadata,capacity:U32,current:U32,owner:Maybe<&1,C>,remaining:H.PrototypeHandoffRows<S,C>,past:History<S,C>) -> Column<S,C> & Maybe<&2,V>:
  match owner:
    case None{}: (PreparedIndexed{IndexedPreparedOwned{IndexedPreparedState{values,metadata,capacity,current,None{},remaining,past}}},None{})
    case Some{owned}: indexed_prepared_view_projected(~S,~C,~V,values,metadata,capacity,current,remaining,past,project(owned))
def prepared_view_taken_state(~S:Data,~C:Type,~V:Data,~project:C -> C & V,owner:C,state:State<S,C>) -> Column<S,C> & Maybe<&2,V>:
  match state:
    case State{values,stamps,capacity,current,_,remaining,past}: prepared_view_projected(~S,~C,~V,values,stamps,capacity,current,remaining,past,project(owner))
def indexed_prepared_view_taken_state(~S:Data,~C:Type,~V:Data,~project:C -> C & V,owner:C,state:IndexedPreparedState<S,C>) -> Column<S,C> & Maybe<&2,V>:
  match state:
    case IndexedPreparedState{values,metadata,capacity,current,_,remaining,past}: indexed_prepared_view_projected(~S,~C,~V,values,metadata,capacity,current,remaining,past,project(owner))
def prepared_view_taken(~S:Data,~C:Type,~V:Data,~project:C -> C & V,id:U32,result:SwapOutcome<S,C>) -> Column<S,C> & Maybe<&2,V>:
  match result:
    case Rejected{column,_}: (column,None{})
    case Accepted{column,None{}}: (column,None{})
    case Accepted{Column{values,stamps},Some{owner}}: viewed(~S,~C,~V,project(owner),Column{values,stamps},id)
    case Accepted{Prepared{carrier},Some{owner}}: prepared_view_taken_state(~S,~C,~V,~project,owner,unseal(~S,~C,carrier))
    case Accepted{Indexed{carrier},Some{owner}}: indexed_projected_state(~S,~C,~V,id,project(owner),indexed_unseal(~S,~C,carrier))
    case Accepted{PreparedIndexed{carrier},Some{owner}}: indexed_prepared_view_taken_state(~S,~C,~V,~project,owner,indexed_prepared_unseal(~S,~C,carrier))
# Read terminals project the actual row owner before constructing its carrier.
# Writer seek and the public low-fuel API remain unchanged.
def seek_view(~S:Data,~C:Type,~V:Data,~project:C -> C & V,fuel:Nat,values:Array<Maybe<&1,C>>,stamps:List<&2,L.Entry>,capacity:U32,+target:U32,remaining:H.PrototypeHandoffRows<S,C>,past:History<S,C>,phase:SeekPhase) -> Column<S,C> & Maybe<&2,V>:
  match fuel remaining phase:
    case _ H.HandoffNil{} _: (Prepared{Owned{State{values,stamps,capacity,target,None{},H.HandoffNil{},past}}},None{})
    case 0n H.HandoffCon{id,owner,rest} _: (Prepared{Owned{State{values,stamps,capacity,0,None{},H.HandoffCon{id,owner,rest},past}}},None{})
    case 1n+more H.HandoffCon{+id,owner,rest} Inspect{}: seek_view(~S,~C,~V,~project,more,values,stamps,capacity,target,H.HandoffCon{id,owner,rest},past,Choice{U32.is_eq(target,id),U32.is_lt(target,id)})
    case 1n+more H.HandoffCon{id,owner,rest} Choice{True{},_}: prepared_view_projected(~S,~C,~V,values,stamps,capacity,target,rest,past,project(owner))
    case 1n+more H.HandoffCon{id,owner,rest} Choice{False{},True{}}: (Prepared{Owned{State{values,stamps,capacity,target,None{},H.HandoffCon{id,owner,rest},past}}},None{})
    case 1n+more H.HandoffCon{id,owner,rest} Choice{False{},False{}}: seek_view(~S,~C,~V,~project,more,values,stamps,capacity,target,rest,HistoryCon{id,Some{owner},past},Inspect{})
def indexed_seek_view(~S:Data,~C:Type,~V:Data,~project:C -> C & V,fuel:Nat,values:Array<Maybe<&1,C>>,metadata:M.Metadata,capacity:U32,+target:U32,remaining:H.PrototypeHandoffRows<S,C>,past:History<S,C>,phase:SeekPhase) -> Column<S,C> & Maybe<&2,V>:
  match fuel remaining phase:
    case _ H.HandoffNil{} _: (PreparedIndexed{IndexedPreparedOwned{IndexedPreparedState{values,metadata,capacity,target,None{},H.HandoffNil{},past}}},None{})
    case 0n H.HandoffCon{id,owner,rest} _: (PreparedIndexed{IndexedPreparedOwned{IndexedPreparedState{values,metadata,capacity,0,None{},H.HandoffCon{id,owner,rest},past}}},None{})
    case 1n+more H.HandoffCon{+id,owner,rest} Inspect{}: indexed_seek_view(~S,~C,~V,~project,more,values,metadata,capacity,target,H.HandoffCon{id,owner,rest},past,Choice{U32.is_eq(target,id),U32.is_lt(target,id)})
    case 1n+more H.HandoffCon{id,owner,rest} Choice{True{},_}: indexed_prepared_view_projected(~S,~C,~V,values,metadata,capacity,target,rest,past,project(owner))
    case 1n+more H.HandoffCon{id,owner,rest} Choice{False{},True{}}: (PreparedIndexed{IndexedPreparedOwned{IndexedPreparedState{values,metadata,capacity,target,None{},H.HandoffCon{id,owner,rest},past}}},None{})
    case 1n+more H.HandoffCon{id,owner,rest} Choice{False{},False{}}: indexed_seek_view(~S,~C,~V,~project,more,values,metadata,capacity,target,rest,HistoryCon{id,Some{owner},past},Inspect{})
def prepared_view_different(~S:Data,~C:Type,~V:Data,~project:C -> C & V,+id:U32,values:Array<Maybe<&1,C>>,stamps:List<&2,L.Entry>,+capacity:U32,+current:U32,owner:Maybe<&1,C>,remaining:H.PrototypeHandoffRows<S,C>,past:History<S,C>,backwards:Bool) -> Column<S,C> & Maybe<&2,V>:
  match backwards:
    case True{}: view_taken(~S,~C,~V,~project,id,swap_recovered(~S,~C,id,None{},recover_current(~S,~C,values,stamps,current,owner,remaining,past,U32.is_gt(current,0))))
    case False{}: seek_view(~S,~C,~V,~project,U32.to_nat(U32.add(U32.add(capacity,capacity),1)),values,stamps,capacity,id,remaining,past_current(~S,~C,current,owner,past,U32.is_gt(current,0)),Inspect{})
def indexed_prepared_view_different(~S:Data,~C:Type,~V:Data,~project:C -> C & V,+id:U32,values:Array<Maybe<&1,C>>,metadata:M.Metadata,+capacity:U32,+current:U32,owner:Maybe<&1,C>,remaining:H.PrototypeHandoffRows<S,C>,past:History<S,C>,backwards:Bool) -> Column<S,C> & Maybe<&2,V>:
  match backwards:
    case True{}: view_taken(~S,~C,~V,~project,id,swap_recovered(~S,~C,id,None{},indexed_recover_current(~S,~C,values,metadata,current,owner,remaining,past,U32.is_gt(current,0))))
    case False{}: indexed_seek_view(~S,~C,~V,~project,U32.to_nat(U32.add(U32.add(capacity,capacity),1)),values,metadata,capacity,id,remaining,past_current(~S,~C,current,owner,past,U32.is_gt(current,0)),Inspect{})
def prepared_view_checked(~S:Data,~C:Type,~V:Data,~project:C -> C & V,+id:U32,values:Array<Maybe<&1,C>>,stamps:List<&2,L.Entry>,+capacity:U32,+current:U32,owner:Maybe<&1,C>,remaining:H.PrototypeHandoffRows<S,C>,past:History<S,C>,valid:Bool,same:Bool) -> Column<S,C> & Maybe<&2,V>:
  match valid same:
    case False{} _: (Prepared{Owned{State{values,stamps,capacity,current,owner,remaining,past}}},None{})
    case True{} True{}: prepared_view_current(~S,~C,~V,~project,values,stamps,capacity,current,owner,remaining,past)
    case True{} False{}: prepared_view_different(~S,~C,~V,~project,id,values,stamps,capacity,current,owner,remaining,past,U32.is_lt(id,current))
def indexed_prepared_view_checked(~S:Data,~C:Type,~V:Data,~project:C -> C & V,+id:U32,values:Array<Maybe<&1,C>>,metadata:M.Metadata,+capacity:U32,+current:U32,owner:Maybe<&1,C>,remaining:H.PrototypeHandoffRows<S,C>,past:History<S,C>,valid:Bool,same:Bool) -> Column<S,C> & Maybe<&2,V>:
  match valid same:
    case False{} _: (PreparedIndexed{IndexedPreparedOwned{IndexedPreparedState{values,metadata,capacity,current,owner,remaining,past}}},None{})
    case True{} True{}: indexed_prepared_view_current(~S,~C,~V,~project,values,metadata,capacity,current,owner,remaining,past)
    case True{} False{}: indexed_prepared_view_different(~S,~C,~V,~project,id,values,metadata,capacity,current,owner,remaining,past,U32.is_lt(id,current))
def prepared_view_state(~S:Data,~C:Type,~V:Data,~project:C -> C & V,+id:U32,state:State<S,C>) -> Column<S,C> & Maybe<&2,V>:
  match state:
    case State{values,stamps,+capacity,+current,owner,remaining,past}: prepared_view_checked(~S,~C,~V,~project,id,values,stamps,capacity,current,owner,remaining,past,U32.is_gt(id,0) && U32.is_le(id,capacity),U32.is_eq(id,current))
def indexed_prepared_view_state(~S:Data,~C:Type,~V:Data,~project:C -> C & V,+id:U32,state:IndexedPreparedState<S,C>) -> Column<S,C> & Maybe<&2,V>:
  match state:
    case IndexedPreparedState{values,metadata,+capacity,+current,owner,remaining,past}: indexed_prepared_view_checked(~S,~C,~V,~project,id,values,metadata,capacity,current,owner,remaining,past,U32.is_gt(id,0) && U32.is_le(id,capacity),U32.is_eq(id,current))
def view(~S: Data, ~C: Type, ~V: Data, ~project: C -> C & V, column: Column<S,C>, +id: U32) -> Column<S,C> & Maybe<&2,V>:
  match column:
    case Column{values,stamps}: plain_view_sized(~S,~C,~V,~project,id,stamps,Array.size(Maybe<&1,C>,values))
    case Prepared{carrier}: prepared_view_state(~S,~C,~V,~project,id,unseal(~S,~C,carrier))
    case Indexed{carrier}: indexed_view_state(~S,~C,~V,~project,id,indexed_unseal(~S,~C,carrier))
    case PreparedIndexed{carrier}: indexed_prepared_view_state(~S,~C,~V,~project,id,indexed_prepared_unseal(~S,~C,carrier))

def present(~C: Type, owner: C) -> C & Bool:
  (owner, True{})

def presence(~S: Data, ~C: Type, result: Column<S,C> & Maybe<&2,Bool>) -> Column<S,C> & Bool:
  match result:
    case (column, None{}):
      (column, False{})
    case (column, Some{found}):
      (column, found)

def has(~S: Data, ~C: Type, column: Column<S,C>, id: U32) -> Column<S,C> & Bool:
  presence(~S, ~C, view(~S, ~C, ~Bool, ~present(~C), column, id))

# Raw owner swaps/projection are metadata-neutral. Only the component world
# write seam advances stamps, and rollback restores a saved stamp explicitly.
def lifecycle_state(~S:Data,~C:Type,+id:U32,state:State<S,C>) -> Column<S,C> & L.Stamp:
  match state:
    case State{values,+stamps,capacity,current,owner,remaining,past}: (Prepared{Owned{State{values,stamps,capacity,current,owner,remaining,past}}},L.get(stamps,id))
def indexed_prepared_lifecycle_got(~S:Data,~C:Type,values:Array<Maybe<&1,C>>,capacity:U32,current:U32,owner:Maybe<&1,C>,remaining:H.PrototypeHandoffRows<S,C>,past:History<S,C>,result:M.Metadata & L.Stamp) -> Column<S,C> & L.Stamp:
  match result:
    case (metadata,stamp): (PreparedIndexed{IndexedPreparedOwned{IndexedPreparedState{values,metadata,capacity,current,owner,remaining,past}}},stamp)
def indexed_prepared_lifecycle_state(~S:Data,~C:Type,+id:U32,state:IndexedPreparedState<S,C>) -> Column<S,C> & L.Stamp:
  match state:
    case IndexedPreparedState{values,metadata,capacity,current,owner,remaining,past}: indexed_prepared_lifecycle_got(~S,~C,values,capacity,current,owner,remaining,past,M.get(metadata,id))
def lifecycle(~S: Data,~C: Type,column: Column<S,C>,+id: U32) -> Column<S,C> & L.Stamp:
  match column:
    case Column{values,+stamps}: (Column{values,stamps},L.get(stamps,id))
    case Prepared{carrier}: lifecycle_state(~S,~C,id,unseal(~S,~C,carrier))
    case Indexed{carrier}: indexed_lifecycle_state(~S,~C,id,indexed_unseal(~S,~C,carrier))
    case PreparedIndexed{carrier}: indexed_prepared_lifecycle_state(~S,~C,id,indexed_prepared_unseal(~S,~C,carrier))

def restore_state(~S:Data,~C:Type,+id:U32,stamp:L.Stamp,state:State<S,C>) -> Column<S,C>:
  match state:
    case State{values,stamps,capacity,current,owner,remaining,past}: Prepared{Owned{State{values,L.set(stamps,id,stamp),capacity,current,owner,remaining,past}}}
def indexed_prepared_restore_state(~S:Data,~C:Type,+id:U32,stamp:L.Stamp,state:IndexedPreparedState<S,C>) -> Column<S,C>:
  match state:
    case IndexedPreparedState{values,metadata,capacity,current,owner,remaining,past}: PreparedIndexed{IndexedPreparedOwned{IndexedPreparedState{values,M.set(metadata,id,stamp),capacity,current,owner,remaining,past}}}
def restore_stamp(~S: Data,~C: Type,column: Column<S,C>,+id: U32,stamp: L.Stamp) -> Column<S,C>:
  match column:
    case Column{values,stamps}: Column{values,L.set(stamps,id,stamp)}
    case Prepared{carrier}: restore_state(~S,~C,id,stamp,unseal(~S,~C,carrier))
    case Indexed{carrier}: indexed_restore_state(~S,~C,id,stamp,indexed_unseal(~S,~C,carrier))
    case PreparedIndexed{carrier}: indexed_prepared_restore_state(~S,~C,id,stamp,indexed_prepared_unseal(~S,~C,carrier))

def mark_state(~S:Data,~C:Type,+id:U32,incoming:Bool,wasPresent:Bool,tick:U32,state:State<S,C>) -> Column<S,C>:
  match state:
    case State{values,+stamps,capacity,current,owner,remaining,past}: Prepared{Owned{State{values,L.set(stamps,id,L.after_write(incoming,wasPresent,L.get(stamps,id),tick)),capacity,current,owner,remaining,past}}}
def indexed_prepared_mark_got(~S:Data,~C:Type,+id:U32,incoming:Bool,wasPresent:Bool,tick:U32,values:Array<Maybe<&1,C>>,capacity:U32,current:U32,owner:Maybe<&1,C>,remaining:H.PrototypeHandoffRows<S,C>,past:History<S,C>,result:M.Metadata & L.Stamp) -> Column<S,C>:
  match result:
    case (metadata,stamp): PreparedIndexed{IndexedPreparedOwned{IndexedPreparedState{values,M.set(metadata,id,L.after_write(incoming,wasPresent,stamp,tick)),capacity,current,owner,remaining,past}}}
def indexed_prepared_mark_state(~S:Data,~C:Type,+id:U32,incoming:Bool,wasPresent:Bool,tick:U32,state:IndexedPreparedState<S,C>) -> Column<S,C>:
  match state:
    case IndexedPreparedState{values,metadata,capacity,current,owner,remaining,past}: indexed_prepared_mark_got(~S,~C,id,incoming,wasPresent,tick,values,capacity,current,owner,remaining,past,M.get(metadata,id))
def mark(~S: Data,~C: Type,column: Column<S,C>,+id: U32,incoming: Bool,wasPresent: Bool,tick: U32) -> Column<S,C>:
  match column:
    case Column{values,+stamps}: Column{values,L.set(stamps,id,L.after_write(incoming,wasPresent,L.get(stamps,id),tick))}
    case Prepared{carrier}: mark_state(~S,~C,id,incoming,wasPresent,tick,unseal(~S,~C,carrier))
    case Indexed{carrier}: indexed_mark_state(~S,~C,id,incoming,wasPresent,tick,indexed_unseal(~S,~C,carrier))
    case PreparedIndexed{carrier}: indexed_prepared_mark_state(~S,~C,id,incoming,wasPresent,tick,indexed_prepared_unseal(~S,~C,carrier))

# Structural cleanup releases payload and associated lifecycle entry. Projection
# and journal swaps remain metadata-neutral; despawn must use this explicit seam.
def clear_state(~S:Data,~C:Type,+id:U32,state:State<S,C>) -> Column<S,C>:
  match state:
    case State{values,stamps,capacity,current,owner,remaining,past}: Prepared{Owned{State{values,L.clear(stamps,id),capacity,current,owner,remaining,past}}}
def indexed_prepared_clear_state(~S:Data,~C:Type,+id:U32,state:IndexedPreparedState<S,C>) -> Column<S,C>:
  match state:
    case IndexedPreparedState{values,metadata,capacity,current,owner,remaining,past}: PreparedIndexed{IndexedPreparedOwned{IndexedPreparedState{values,M.clear(metadata,id),capacity,current,owner,remaining,past}}}
def clear_stamp(~S: Data,~C: Type,column: Column<S,C>,+id: U32) -> Column<S,C>:
  match column:
    case Column{values,stamps}: Column{values,L.clear(stamps,id)}
    case Prepared{carrier}: clear_state(~S,~C,id,unseal(~S,~C,carrier))
    case Indexed{carrier}: indexed_clear_state(~S,~C,id,indexed_unseal(~S,~C,carrier))
    case PreparedIndexed{carrier}: indexed_prepared_clear_state(~S,~C,id,indexed_prepared_unseal(~S,~C,carrier))

def cleared(~S: Data,~C: Type,+id: U32,outcome: SwapOutcome<S,C>) -> SwapOutcome<S,C>:
  match outcome:
    case Accepted{column,previous}: Accepted{clear_stamp(~S,~C,column,id),previous}
    case Rejected{column,incoming}: Rejected{column,incoming}

def clear(~S: Data,~C: Type,column: Column<S,C>,+id: U32) -> SwapOutcome<S,C>:
  cleared(~S,~C,id,swap(~S,~C,column,id,None{}))
