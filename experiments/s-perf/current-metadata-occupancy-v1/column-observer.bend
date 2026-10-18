import Base
import ../../../src/ecs/column.bend as Col
import occupancy.bend as O
import ../../../src/ecs/owner-handoff.bend as H
import ../../../src/ecs/indexed-lifecycle.bend as M
import ../../../src/ecs/lifecycle.bend as L

type Shape is Data:
  Shape{leaves:Nat,nodes:Nat}
type Snapshot is Data:
  Plain{values:Shape,entries:O.EntryStats}
  Indexed{values:Shape,metadata:O.MetadataStats}
def leaf(~C:Type,value:C) -> Array<C> & Shape:(ALeaf{value},Shape{1n,0n})
def node(~C:Type,left:Array<C> & Shape,right:Array<C> & Shape) -> Array<C> & Shape:
  match left right:
    case (left,Shape{a,b}), (right,Shape{x,y}):(ANode{left,right},Shape{Nat.add(a,x),1n+Nat.add(b,y)})
def shape(~C:Type,value:Array<C>) -> Array<C> & Shape:
  match value:
    case ALeaf{value}:leaf(~C,value)
    case ANode{left,right}:node(~C,shape(~C,left),shape(~C,right))
def indexed_join(~S:Data,~C:Type,values:Array<Maybe<&1,C>> & Shape,metadata:M.Metadata & O.MetadataStats) -> Col.IndexedOrdinaryState<S,C> & Snapshot:
  match values metadata:
    case (values,vs), (metadata,ms):(Col.IndexedOrdinaryState{values,metadata},Indexed{vs,ms})
def indexed_state(~S:Data,~C:Type,state:Col.IndexedOrdinaryState<S,C>) -> Col.IndexedOrdinaryState<S,C> & Snapshot:
  match state:
    case Col.IndexedOrdinaryState{values,metadata}:indexed_join(~S,~C,shape(~Maybe<&1,C>,values),O.metadata(metadata))
def prepared_indexed_join(~S:Data,~C:Type,capacity:U32,current:U32,owner:Maybe<&1,C>,remaining:H.PrototypeHandoffRows<S,C>,past:Col.History<S,C>,values:Array<Maybe<&1,C>> & Shape,metadata:M.Metadata & O.MetadataStats) -> Col.IndexedPreparedState<S,C> & Snapshot:
  match values metadata:
    case (values,vs), (metadata,ms):(Col.IndexedPreparedState{values,metadata,capacity,current,owner,remaining,past},Indexed{vs,ms})
def prepared_indexed_state(~S:Data,~C:Type,state:Col.IndexedPreparedState<S,C>) -> Col.IndexedPreparedState<S,C> & Snapshot:
  match state:
    case Col.IndexedPreparedState{values,metadata,capacity,current,owner,remaining,past}:prepared_indexed_join(~S,~C,capacity,current,owner,remaining,past,shape(~Maybe<&1,C>,values),O.metadata(metadata))
def indexed_owned(~S:Data,~C:Type,result:Col.IndexedOrdinaryState<S,C> & Snapshot) -> Col.IndexedOrdinaryCarrier<S,C> & Snapshot:
  match result:
    case (state,snapshot):(Col.IndexedOrdinaryOwned{state},snapshot)
def indexed_wrapped(~S:Data,~C:Type,result:Col.IndexedOrdinaryCarrier<S,C> & Snapshot) -> Col.IndexedOrdinaryCarrier<S,C> & Snapshot:
  match result:
    case (inner,snapshot):(Col.IndexedOrdinaryWrapped{inner},snapshot)
def indexed(~S:Data,~C:Type,carrier:Col.IndexedOrdinaryCarrier<S,C>) -> Col.IndexedOrdinaryCarrier<S,C> & Snapshot:
  match carrier:
    case Col.IndexedOrdinaryOwned{state}:indexed_owned(~S,~C,indexed_state(~S,~C,state))
    case Col.IndexedOrdinaryWrapped{inner}:indexed_wrapped(~S,~C,indexed(~S,~C,inner))
def prepared_indexed_owned(~S:Data,~C:Type,result:Col.IndexedPreparedState<S,C> & Snapshot) -> Col.IndexedPreparedCarrier<S,C> & Snapshot:
  match result:
    case (state,snapshot):(Col.IndexedPreparedOwned{state},snapshot)
def prepared_indexed_wrapped(~S:Data,~C:Type,result:Col.IndexedPreparedCarrier<S,C> & Snapshot) -> Col.IndexedPreparedCarrier<S,C> & Snapshot:
  match result:
    case (inner,snapshot):(Col.IndexedPreparedWrapped{inner},snapshot)
def prepared_indexed(~S:Data,~C:Type,carrier:Col.IndexedPreparedCarrier<S,C>) -> Col.IndexedPreparedCarrier<S,C> & Snapshot:
  match carrier:
    case Col.IndexedPreparedOwned{state}:prepared_indexed_owned(~S,~C,prepared_indexed_state(~S,~C,state))
    case Col.IndexedPreparedWrapped{inner}:prepared_indexed_wrapped(~S,~C,prepared_indexed(~S,~C,inner))
def plain_state_join(~S:Data,~C:Type,+stamps:List<&2,L.Entry>,capacity:U32,current:U32,owner:Maybe<&1,C>,remaining:H.PrototypeHandoffRows<S,C>,past:Col.History<S,C>,result:Array<Maybe<&1,C>> & Shape) -> Col.State<S,C> & Snapshot:
  match result:
    case (values,vs):(Col.State{values,stamps,capacity,current,owner,remaining,past},Plain{vs,O.entries(stamps)})
def plain_state(~S:Data,~C:Type,state:Col.State<S,C>) -> Col.State<S,C> & Snapshot:
  match state:
    case Col.State{values,stamps,capacity,current,owner,remaining,past}:plain_state_join(~S,~C,stamps,capacity,current,owner,remaining,past,shape(~Maybe<&1,C>,values))
def prepared_owned(~S:Data,~C:Type,result:Col.State<S,C> & Snapshot) -> Col.Carrier<S,C> & Snapshot:
  match result:
    case (state,snapshot):(Col.Owned{state},snapshot)
def prepared_wrapped(~S:Data,~C:Type,result:Col.Carrier<S,C> & Snapshot) -> Col.Carrier<S,C> & Snapshot:
  match result:
    case (inner,snapshot):(Col.Wrapped{inner},snapshot)
def prepared(~S:Data,~C:Type,carrier:Col.Carrier<S,C>) -> Col.Carrier<S,C> & Snapshot:
  match carrier:
    case Col.Owned{state}:prepared_owned(~S,~C,plain_state(~S,~C,state))
    case Col.Wrapped{inner}:prepared_wrapped(~S,~C,prepared(~S,~C,inner))
def plain(~S:Data,~C:Type,+stamps:List<&2,L.Entry>,result:Array<Maybe<&1,C>> & Shape) -> Col.Column<S,C> & Snapshot:
  match result:
    case (values,vs):(Col.Column{values,stamps},Plain{vs,O.entries(stamps)})
def indexed_column(~S:Data,~C:Type,result:Col.IndexedOrdinaryCarrier<S,C> & Snapshot) -> Col.Column<S,C> & Snapshot:
  match result:
    case (carrier,snapshot):(Col.Indexed{carrier},snapshot)
def prepared_indexed_column(~S:Data,~C:Type,result:Col.IndexedPreparedCarrier<S,C> & Snapshot) -> Col.Column<S,C> & Snapshot:
  match result:
    case (carrier,snapshot):(Col.PreparedIndexed{carrier},snapshot)
def prepared_column(~S:Data,~C:Type,result:Col.Carrier<S,C> & Snapshot) -> Col.Column<S,C> & Snapshot:
  match result:
    case (carrier,snapshot):(Col.Prepared{carrier},snapshot)
def observe(~S:Data,~C:Type,column:Col.Column<S,C>) -> Col.Column<S,C> & Snapshot:
  match column:
    case Col.Column{values,stamps}:plain(~S,~C,stamps,shape(~Maybe<&1,C>,values))
    case Col.Indexed{carrier}:indexed_column(~S,~C,indexed(~S,~C,carrier))
    case Col.PreparedIndexed{carrier}:prepared_indexed_column(~S,~C,prepared_indexed(~S,~C,carrier))
    case Col.Prepared{carrier}:prepared_column(~S,~C,prepared(~S,~C,carrier))
