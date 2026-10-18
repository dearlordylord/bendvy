import Base
import column.bend as Col
import owner-handoff.bend as H
import lifecycle.bend as L
import indexed-lifecycle.bend as M

# Provisioning captures a restoration closure only after accepted extraction.
# Gameplay never receives its captured column/index or a replacement restore target.
type Slot<-C:Type> is Type:
  Slot{owner:Maybe<&1,C>,stamp:L.Stamp,dirty:Bool}
type Capture<-S:Data,-C:Type> is Type:
  Captured{id:U32,owner:Maybe<&1,C>,stamp:L.Stamp,restore:Slot<C> -> Col.Column<S,C>}
  Unavailable{column:Col.Column<S,C>}

def stamped(~S:Data,~C:Type,+id:U32,column:Col.Column<S,C>,stamp:L.Stamp,dirty:Bool) -> Col.Column<S,C>:
  match dirty:
    case False{}: column
    case True{}: Col.restore_stamp(~S,~C,column,id,stamp)
def restore_plain(~S:Data,~C:Type,+id:U32,values:Array<Maybe<&1,C>>,stamps:List<&2,L.Entry>,slot:Slot<C>) -> Col.Column<S,C>:
  match slot:
    case Slot{owner,stamp,dirty}: stamped(~S,~C,id,Col.Column{Array.set(Maybe<&1,C>,values,U32.sub(id,1),owner),stamps},stamp,dirty)
def indexed_restore_plain(~S:Data,~C:Type,+id:U32,values:Array<Maybe<&1,C>>,metadata:M.Metadata,slot:Slot<C>) -> Col.Column<S,C>:
  match slot:
    case Slot{owner,stamp,dirty}: stamped(~S,~C,id,Col.indexed_wrap(~S,~C,Array.set(Maybe<&1,C>,values,U32.sub(id,1),owner),metadata),stamp,dirty)
def indexed_plain_got(~S:Data,~C:Type,+id:U32,values:Array<Maybe<&1,C>>,owner:Maybe<&1,C>,result:M.Metadata & L.Stamp) -> Capture<S,C>:
  match result:
    case (metadata,stamp): Captured{id,owner,stamp,slot => indexed_restore_plain(~S,~C,id,values,metadata,slot)}
def indexed_plain_taken(~S:Data,~C:Type,+id:U32,metadata:M.Metadata,result:Array<Maybe<&1,C>> & Maybe<&1,C>) -> Capture<S,C>:
  match result:
    case (values,owner): indexed_plain_got(~S,~C,id,values,owner,M.get(metadata,id))
def indexed_plain_checked(~S:Data,~C:Type,+id:U32,metadata:M.Metadata,values:Array<Maybe<&1,C>>,valid:Bool) -> Capture<S,C>:
  match valid:
    case False{}: Unavailable{Col.indexed_wrap(~S,~C,values,metadata)}
    case True{}: indexed_plain_taken(~S,~C,id,metadata,Array.swap(Maybe<&1,C>,values,U32.sub(id,1),None{}))
def indexed_plain_sized(~S:Data,~C:Type,+id:U32,metadata:M.Metadata,sized:Array<Maybe<&1,C>> & U32) -> Capture<S,C>:
  match sized:
    case (values,size): indexed_plain_checked(~S,~C,id,metadata,values,U32.is_gt(id,0) && U32.is_le(id,size) && U32.is_le(id,131072))
def indexed_plain_state(~S:Data,~C:Type,+id:U32,state:Col.IndexedOrdinaryState<S,C>) -> Capture<S,C>:
  match state:
    case Col.IndexedOrdinaryState{values,metadata}: indexed_plain_sized(~S,~C,id,metadata,Array.size(Maybe<&1,C>,values))
def restore_prepared(~S:Data,~C:Type,+id:U32,values:Array<Maybe<&1,C>>,stamps:List<&2,L.Entry>,capacity:U32,remaining:H.PrototypeHandoffRows<S,C>,past:Col.History<S,C>,slot:Slot<C>) -> Col.Column<S,C>:
  match slot:
    case Slot{owner,stamp,dirty}: stamped(~S,~C,id,Col.Prepared{Col.Owned{Col.State{values,stamps,capacity,id,owner,remaining,past}}},stamp,dirty)
def indexed_restore_prepared(~S:Data,~C:Type,+id:U32,values:Array<Maybe<&1,C>>,metadata:M.Metadata,capacity:U32,remaining:H.PrototypeHandoffRows<S,C>,past:Col.History<S,C>,slot:Slot<C>) -> Col.Column<S,C>:
  match slot:
    case Slot{owner,stamp,dirty}: stamped(~S,~C,id,Col.PreparedIndexed{Col.IndexedPreparedOwned{Col.IndexedPreparedState{values,metadata,capacity,id,owner,remaining,past}}},stamp,dirty)
def captured_prepared(~S:Data,~C:Type,+id:U32,values:Array<Maybe<&1,C>>,+stamps:List<&2,L.Entry>,capacity:U32,owner:Maybe<&1,C>,remaining:H.PrototypeHandoffRows<S,C>,past:Col.History<S,C>) -> Capture<S,C>:
  Captured{id,owner,L.get(stamps,id),slot => restore_prepared(~S,~C,id,values,stamps,capacity,remaining,past,slot)}
# Exact constant-None specialization of Col.seek: phase and fuel remain observable.
def indexed_captured_got(~S:Data,~C:Type,+id:U32,values:Array<Maybe<&1,C>>,capacity:U32,owner:Maybe<&1,C>,remaining:H.PrototypeHandoffRows<S,C>,past:Col.History<S,C>,result:M.Metadata & L.Stamp) -> Capture<S,C>:
  match result:
    case (metadata,stamp): Captured{id,owner,stamp,slot => indexed_restore_prepared(~S,~C,id,values,metadata,capacity,remaining,past,slot)}
def indexed_captured_prepared(~S:Data,~C:Type,+id:U32,values:Array<Maybe<&1,C>>,metadata:M.Metadata,capacity:U32,owner:Maybe<&1,C>,remaining:H.PrototypeHandoffRows<S,C>,past:Col.History<S,C>) -> Capture<S,C>:
  indexed_captured_got(~S,~C,id,values,capacity,owner,remaining,past,M.get(metadata,id))
def capture_seek(~S:Data,~C:Type,fuel:Nat,values:Array<Maybe<&1,C>>,stamps:List<&2,L.Entry>,capacity:U32,+target:U32,remaining:H.PrototypeHandoffRows<S,C>,past:Col.History<S,C>,phase:Col.SeekPhase) -> Capture<S,C>:
  match fuel remaining phase:
    case _ H.HandoffNil{} _: captured_prepared(~S,~C,target,values,stamps,capacity,None{},H.HandoffNil{},past)
    case 0n H.HandoffCon{id,owner,rest} _: Unavailable{Col.Prepared{Col.Owned{Col.State{values,stamps,capacity,0,None{},H.HandoffCon{id,owner,rest},past}}}}
    case 1n+more H.HandoffCon{+id,owner,rest} Col.Inspect{}: capture_seek(~S,~C,more,values,stamps,capacity,target,H.HandoffCon{id,owner,rest},past,Col.Choice{U32.is_eq(target,id),U32.is_lt(target,id)})
    case 1n+more H.HandoffCon{id,owner,rest} Col.Choice{True{},_}: captured_prepared(~S,~C,target,values,stamps,capacity,Some{owner},rest,past)
    case 1n+more H.HandoffCon{id,owner,rest} Col.Choice{False{},True{}}: captured_prepared(~S,~C,target,values,stamps,capacity,None{},H.HandoffCon{id,owner,rest},past)
    case 1n+more H.HandoffCon{id,owner,rest} Col.Choice{False{},False{}}: capture_seek(~S,~C,more,values,stamps,capacity,target,rest,Col.HistoryCon{id,Some{owner},past},Col.Inspect{})
def indexed_capture_seek(~S:Data,~C:Type,fuel:Nat,values:Array<Maybe<&1,C>>,metadata:M.Metadata,capacity:U32,+target:U32,remaining:H.PrototypeHandoffRows<S,C>,past:Col.History<S,C>,phase:Col.SeekPhase) -> Capture<S,C>:
  match fuel remaining phase:
    case _ H.HandoffNil{} _: indexed_captured_prepared(~S,~C,target,values,metadata,capacity,None{},H.HandoffNil{},past)
    case 0n H.HandoffCon{id,owner,rest} _: Unavailable{Col.PreparedIndexed{Col.IndexedPreparedOwned{Col.IndexedPreparedState{values,metadata,capacity,0,None{},H.HandoffCon{id,owner,rest},past}}}}
    case 1n+more H.HandoffCon{+id,owner,rest} Col.Inspect{}: indexed_capture_seek(~S,~C,more,values,metadata,capacity,target,H.HandoffCon{id,owner,rest},past,Col.Choice{U32.is_eq(target,id),U32.is_lt(target,id)})
    case 1n+more H.HandoffCon{id,owner,rest} Col.Choice{True{},_}: indexed_captured_prepared(~S,~C,target,values,metadata,capacity,Some{owner},rest,past)
    case 1n+more H.HandoffCon{id,owner,rest} Col.Choice{False{},True{}}: indexed_captured_prepared(~S,~C,target,values,metadata,capacity,None{},H.HandoffCon{id,owner,rest},past)
    case 1n+more H.HandoffCon{id,owner,rest} Col.Choice{False{},False{}}: indexed_capture_seek(~S,~C,more,values,metadata,capacity,target,rest,Col.HistoryCon{id,Some{owner},past},Col.Inspect{})
def plain_taken(~S:Data,~C:Type,+id:U32,+stamps:List<&2,L.Entry>,result:Array<Maybe<&1,C>> & Maybe<&1,C>) -> Capture<S,C>:
  match result:
    case (values,owner): Captured{id,owner,L.get(stamps,id),slot => restore_plain(~S,~C,id,values,stamps,slot)}
def plain_checked(~S:Data,~C:Type,+id:U32,stamps:List<&2,L.Entry>,values:Array<Maybe<&1,C>>,valid:Bool) -> Capture<S,C>:
  match valid:
    case False{}: Unavailable{Col.Column{values,stamps}}
    case True{}: plain_taken(~S,~C,id,stamps,Array.swap(Maybe<&1,C>,values,U32.sub(id,1),None{}))
def plain_sized(~S:Data,~C:Type,+id:U32,stamps:List<&2,L.Entry>,sized:Array<Maybe<&1,C>> & U32) -> Capture<S,C>:
  match sized:
    case (values,size): plain_checked(~S,~C,id,stamps,values,U32.is_gt(id,0) && U32.is_le(id,size) && U32.is_le(id,131072))
def recovered_capture(~S:Data,~C:Type,+id:U32,column:Col.Column<S,C>) -> Capture<S,C>:
  match column:
    case Col.Column{values,stamps}: plain_sized(~S,~C,id,stamps,Array.size(Maybe<&1,C>,values))
    case Col.Indexed{carrier}: indexed_plain_state(~S,~C,id,Col.indexed_unseal(~S,~C,carrier))
    case other: Unavailable{other}
def prepared_checked(~S:Data,~C:Type,+id:U32,values:Array<Maybe<&1,C>>,stamps:List<&2,L.Entry>,+capacity:U32,+current:U32,owner:Maybe<&1,C>,remaining:H.PrototypeHandoffRows<S,C>,past:Col.History<S,C>,valid:Bool,same:Bool,backwards:Bool) -> Capture<S,C>:
  match valid same backwards:
    case False{} _ _: Unavailable{Col.Prepared{Col.Owned{Col.State{values,stamps,capacity,current,owner,remaining,past}}}}
    case True{} True{} _: captured_prepared(~S,~C,id,values,stamps,capacity,owner,remaining,past)
    case True{} False{} True{}: recovered_capture(~S,~C,id,Col.recover(~S,~C,Col.Prepared{Col.Owned{Col.State{values,stamps,capacity,current,owner,remaining,past}}}))
    case True{} False{} False{}: capture_seek(~S,~C,U32.to_nat(U32.add(U32.add(capacity,capacity),1)),values,stamps,capacity,id,remaining,Col.past_current(~S,~C,current,owner,past,U32.is_gt(current,0)),Col.Inspect{})
def indexed_prepared_checked(~S:Data,~C:Type,+id:U32,values:Array<Maybe<&1,C>>,metadata:M.Metadata,+capacity:U32,+current:U32,owner:Maybe<&1,C>,remaining:H.PrototypeHandoffRows<S,C>,past:Col.History<S,C>,valid:Bool,same:Bool,backwards:Bool) -> Capture<S,C>:
  match valid same backwards:
    case False{} _ _: Unavailable{Col.PreparedIndexed{Col.IndexedPreparedOwned{Col.IndexedPreparedState{values,metadata,capacity,current,owner,remaining,past}}}}
    case True{} True{} _: indexed_captured_prepared(~S,~C,id,values,metadata,capacity,owner,remaining,past)
    case True{} False{} True{}: recovered_capture(~S,~C,id,Col.recover(~S,~C,Col.PreparedIndexed{Col.IndexedPreparedOwned{Col.IndexedPreparedState{values,metadata,capacity,current,owner,remaining,past}}}))
    case True{} False{} False{}: indexed_capture_seek(~S,~C,U32.to_nat(U32.add(U32.add(capacity,capacity),1)),values,metadata,capacity,id,remaining,Col.past_current(~S,~C,current,owner,past,U32.is_gt(current,0)),Col.Inspect{})
def prepared_state(~S:Data,~C:Type,+id:U32,state:Col.State<S,C>) -> Capture<S,C>:
  match state:
    case Col.State{values,stamps,+capacity,+current,owner,remaining,past}: prepared_checked(~S,~C,id,values,stamps,capacity,current,owner,remaining,past,U32.is_gt(id,0) && U32.is_le(id,capacity),U32.is_eq(id,current),U32.is_lt(id,current))
def indexed_prepared_state(~S:Data,~C:Type,+id:U32,state:Col.IndexedPreparedState<S,C>) -> Capture<S,C>:
  match state:
    case Col.IndexedPreparedState{values,metadata,+capacity,+current,owner,remaining,past}: indexed_prepared_checked(~S,~C,id,values,metadata,capacity,current,owner,remaining,past,U32.is_gt(id,0) && U32.is_le(id,capacity),U32.is_eq(id,current),U32.is_lt(id,current))
def capture(~S:Data,~C:Type,column:Col.Column<S,C>,+id:U32) -> Capture<S,C>:
  match column:
    case Col.Column{values,stamps}: plain_sized(~S,~C,id,stamps,Array.size(Maybe<&1,C>,values))
    case Col.Prepared{carrier}: prepared_state(~S,~C,id,Col.unseal(~S,~C,carrier))
    case Col.Indexed{carrier}: indexed_plain_state(~S,~C,id,Col.indexed_unseal(~S,~C,carrier))
    case Col.PreparedIndexed{carrier}: indexed_prepared_state(~S,~C,id,Col.indexed_prepared_unseal(~S,~C,carrier))
