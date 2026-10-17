import Base
import ../../../../src/ecs/owner-handoff.bend as Handoff
import ../../../../src/ecs/indexed-lifecycle.bend as Idx
import ../../../../src/ecs/entity-key.bend as Key
import schema-families.bend as D
import runtime-owners.bend as Consumer
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/lifecycle.bend as L
import ../../../../src/ecs/world.bend as W

def leaf(~T:Type,observed:T & String) -> Array<T> & String:
  (value,text)=observed
  (ALeaf{value},"leaf:" ++ text)
def node_join(~T:Type,leftObserved:Array<T> & String,rightObserved:Array<T> & String) -> Array<T> & String:
  (left,text)=leftObserved
  (right,other)=rightObserved
  (ANode{left,right},"node(" ++ text ++ "," ++ other ++ ")")
def array(~T:Type,~project:T -> T & String,value:Array<T>) -> Array<T> & String:
  match value:
    case ALeaf{value}:leaf(~T,project(value))
    case ANode{left,right}:node_join(~T,array(~T,~project,left),array(~T,~project,right))
def u32_data(+value:U32) -> U32 & String:
  (value,U32.show(value))
def u32_value(value:U32) -> U32 & String:
  u32_data(value)
def u32_array(value:Array<U32>) -> Array<U32> & String:
  array(~U32,~u32_value,value)
def bool_data(+value:Bool) -> Bool & String:
  (value,Bool.show(value))
def bool_value(value:Bool) -> Bool & String:
  bool_data(value)
def bool_array(value:Array<Bool>) -> Array<Bool> & String:
  array(~Bool,~bool_value,value)
def stock_done(observed:Array<U32> & String) -> D.Stock & String:
  (cells,text)=observed
  (D.Stock{cells},text)
def stock(value:D.Stock) -> D.Stock & String:
  match value:
    case D.Stock{cells}:stock_done(u32_array(cells))
def title_done(observed:Array<U32> & String) -> D.Title & String:
  (cells,text)=observed
  (D.Title{cells},text)
def title(value:D.Title) -> D.Title & String:
  match value:
    case D.Title{cells}:title_done(u32_array(cells))
def active_done(observed:Array<U32> & String) -> D.Active & String:
  (cells,text)=observed
  (D.Active{cells},text)
def active(value:D.Active) -> D.Active & String:
  match value:
    case D.Active{cells}:active_done(u32_array(cells))
def count_done(observed:Array<U32> & String) -> D.Count & String:
  (cells,text)=observed
  (D.Count{cells},text)
def count(value:D.Count) -> D.Count & String:
  match value:
    case D.Count{cells}:count_done(u32_array(cells))
def optional_done(~Payload:Type,observed:Payload & String) -> Maybe<&1,Payload> & String:
  (owner,text)=observed
  (Some{owner},"some(" ++ text ++ ")")
def optional(~Payload:Type,~project:Payload -> Payload & String,value:Maybe<&1,Payload>) -> Maybe<&1,Payload> & String:
  match value:
    case None{}:(None{},"none")
    case Some{owner}:optional_done(~Payload,project(owner))
def stamp(value:L.Stamp) -> String:
  match value:
    case L.Stamp{added,changed}:U32.show(added) ++ ":" ++ U32.show(changed)
def entry(value:L.Entry) -> String:
  match value:
    case L.Entry{id,value}:U32.show(id) ++ ":" ++ stamp(value)
def rows_join(~S:Data,~Payload:Type,+id:U32,head:Payload & String,rest:Handoff.PrototypeHandoffRows<S,Payload> & String) -> Handoff.PrototypeHandoffRows<S,Payload> & String:
  (owner,text)=head
  (tail,other)=rest
  (Handoff.HandoffCon{id,owner,tail},"con(" ++ U32.show(id) ++ "," ++ text ++ "," ++ other ++ ")")
def rows(~S:Data,~Payload:Type,~project:Payload -> Payload & String,value:Handoff.PrototypeHandoffRows<S,Payload>) -> Handoff.PrototypeHandoffRows<S,Payload> & String:
  match value:
    case Handoff.HandoffNil{}:(Handoff.HandoffNil{},"nil")
    case Handoff.HandoffCon{id,owner,rest}:rows_join(~S,~Payload,id,project(owner),rows(~S,~Payload,~project,rest))
def history_join(~S:Data,~Payload:Type,+id:U32,head:Maybe<&1,Payload> & String,rest:Col.History<S,Payload> & String) -> Col.History<S,Payload> & String:
  (owner,text)=head
  (tail,other)=rest
  (Col.HistoryCon{id,owner,tail},"con(" ++ U32.show(id) ++ "," ++ text ++ "," ++ other ++ ")")
def history(~S:Data,~Payload:Type,~project:Payload -> Payload & String,value:Col.History<S,Payload>) -> Col.History<S,Payload> & String:
  match value:
    case Col.HistoryNil{}:(Col.HistoryNil{},"nil")
    case Col.HistoryCon{id,owner,rest}:history_join(~S,~Payload,id,optional(~Payload,~project,owner),history(~S,~Payload,~project,rest))
def metadata_join(+capacity:U32,+depth:Nat,+exceptional:List<&2,L.Entry>,a:Array<U32> & String,b:Array<U32> & String) -> Idx.Metadata & String:
  (added,sa)=a
  (changed,sb)=b
  (Idx.Metadata{added,changed,capacity,depth,exceptional},"metadata{added=" ++ sa ++ ";changed=" ++ sb ++ ";capacity=" ++ U32.show(capacity) ++ ";depth=" ++ Nat.show(depth) ++ ";exceptional=" ++ List.show(&2,L.Entry,entry,exceptional) ++ "}")
def metadata(value:Idx.Metadata) -> Idx.Metadata & String:
  match value:
    case Idx.Metadata{added,changed,capacity,depth,exceptional}:metadata_join(capacity,depth,exceptional,u32_array(added),u32_array(changed))
def prepared_state_join(~S:Data,~Payload:Type,+stamps:List<&2,L.Entry>,+capacity:U32,+current:U32,a:Array<Maybe<&1,Payload>> & String,b:Maybe<&1,Payload> & String,c:Handoff.PrototypeHandoffRows<S,Payload> & String,d:Col.History<S,Payload> & String) -> Col.State<S,Payload> & String:
  (values,sa)=a
  (owner,sb)=b
  (remaining,sc)=c
  (past,sd)=d
  (Col.State{values,stamps,capacity,current,owner,remaining,past},"state{values=" ++ sa ++ ";stamps=" ++ List.show(&2,L.Entry,entry,stamps) ++ ";capacity=" ++ U32.show(capacity) ++ ";current=" ++ U32.show(current) ++ ";owner=" ++ sb ++ ";remaining=" ++ sc ++ ";past=" ++ sd ++ "}")
def prepared_state(~S:Data,~Payload:Type,~project:Payload -> Payload & String,value:Col.State<S,Payload>) -> Col.State<S,Payload> & String:
  match value:
    case Col.State{values,stamps,capacity,current,owner,remaining,past}:prepared_state_join(~S,~Payload,stamps,capacity,current,array(~Maybe<&1,Payload>,~optional(~Payload,~project),values),optional(~Payload,~project,owner),rows(~S,~Payload,~project,remaining),history(~S,~Payload,~project,past))
def owned_join(~S:Data,~Payload:Type,value:Col.State<S,Payload> & String) -> Col.Carrier<S,Payload> & String:
  (state,text)=value
  (Col.Owned{state},"owned(" ++ text ++ ")")
def wrapped_join(~S:Data,~Payload:Type,value:Col.Carrier<S,Payload> & String) -> Col.Carrier<S,Payload> & String:
  (inner,text)=value
  (Col.Wrapped{inner},"wrapped(" ++ text ++ ")")
def carrier(~S:Data,~Payload:Type,~project:Payload -> Payload & String,value:Col.Carrier<S,Payload>) -> Col.Carrier<S,Payload> & String:
  match value:
    case Col.Owned{state}:owned_join(~S,~Payload,prepared_state(~S,~Payload,~project,state))
    case Col.Wrapped{inner}:wrapped_join(~S,~Payload,carrier(~S,~Payload,~project,inner))
def indexed_state_join(~S:Data,~Payload:Type,a:Array<Maybe<&1,Payload>> & String,b:Idx.Metadata & String) -> Col.IndexedOrdinaryState<S,Payload> & String:
  (values,sa)=a
  (metadata,sb)=b
  (Col.IndexedOrdinaryState{values,metadata},"state{values=" ++ sa ++ ";" ++ sb ++ "}")
def indexed_state(~S:Data,~Payload:Type,~project:Payload -> Payload & String,value:Col.IndexedOrdinaryState<S,Payload>) -> Col.IndexedOrdinaryState<S,Payload> & String:
  match value:
    case Col.IndexedOrdinaryState{values,meta}:indexed_state_join(~S,~Payload,array(~Maybe<&1,Payload>,~optional(~Payload,~project),values),metadata(meta))
def indexed_owned_join(~S:Data,~Payload:Type,value:Col.IndexedOrdinaryState<S,Payload> & String) -> Col.IndexedOrdinaryCarrier<S,Payload> & String:
  (state,text)=value
  (Col.IndexedOrdinaryOwned{state},"owned(" ++ text ++ ")")
def indexed_wrapped_join(~S:Data,~Payload:Type,value:Col.IndexedOrdinaryCarrier<S,Payload> & String) -> Col.IndexedOrdinaryCarrier<S,Payload> & String:
  (inner,text)=value
  (Col.IndexedOrdinaryWrapped{inner},"wrapped(" ++ text ++ ")")
def indexed_carrier(~S:Data,~Payload:Type,~project:Payload -> Payload & String,value:Col.IndexedOrdinaryCarrier<S,Payload>) -> Col.IndexedOrdinaryCarrier<S,Payload> & String:
  match value:
    case Col.IndexedOrdinaryOwned{state}:indexed_owned_join(~S,~Payload,indexed_state(~S,~Payload,~project,state))
    case Col.IndexedOrdinaryWrapped{inner}:indexed_wrapped_join(~S,~Payload,indexed_carrier(~S,~Payload,~project,inner))
def prepared_indexed_state_join(~S:Data,~Payload:Type,+capacity:U32,+current:U32,a:Array<Maybe<&1,Payload>> & String,b:Idx.Metadata & String,c:Maybe<&1,Payload> & String,d:Handoff.PrototypeHandoffRows<S,Payload> & String,e:Col.History<S,Payload> & String) -> Col.IndexedPreparedState<S,Payload> & String:
  (values,sa)=a
  (metadata,sb)=b
  (owner,sc)=c
  (remaining,sd)=d
  (past,se)=e
  (Col.IndexedPreparedState{values,metadata,capacity,current,owner,remaining,past},"state{values=" ++ sa ++ ";" ++ sb ++ ";capacity=" ++ U32.show(capacity) ++ ";current=" ++ U32.show(current) ++ ";owner=" ++ sc ++ ";remaining=" ++ sd ++ ";past=" ++ se ++ "}")
def prepared_indexed_state(~S:Data,~Payload:Type,~project:Payload -> Payload & String,value:Col.IndexedPreparedState<S,Payload>) -> Col.IndexedPreparedState<S,Payload> & String:
  match value:
    case Col.IndexedPreparedState{values,meta,capacity,current,owner,remaining,past}:prepared_indexed_state_join(~S,~Payload,capacity,current,array(~Maybe<&1,Payload>,~optional(~Payload,~project),values),metadata(meta),optional(~Payload,~project,owner),rows(~S,~Payload,~project,remaining),history(~S,~Payload,~project,past))
def prepared_indexed_owned_join(~S:Data,~Payload:Type,value:Col.IndexedPreparedState<S,Payload> & String) -> Col.IndexedPreparedCarrier<S,Payload> & String:
  (state,text)=value
  (Col.IndexedPreparedOwned{state},"owned(" ++ text ++ ")")
def prepared_indexed_wrapped_join(~S:Data,~Payload:Type,value:Col.IndexedPreparedCarrier<S,Payload> & String) -> Col.IndexedPreparedCarrier<S,Payload> & String:
  (inner,text)=value
  (Col.IndexedPreparedWrapped{inner},"wrapped(" ++ text ++ ")")
def prepared_indexed_carrier(~S:Data,~Payload:Type,~project:Payload -> Payload & String,value:Col.IndexedPreparedCarrier<S,Payload>) -> Col.IndexedPreparedCarrier<S,Payload> & String:
  match value:
    case Col.IndexedPreparedOwned{state}:prepared_indexed_owned_join(~S,~Payload,prepared_indexed_state(~S,~Payload,~project,state))
    case Col.IndexedPreparedWrapped{inner}:prepared_indexed_wrapped_join(~S,~Payload,prepared_indexed_carrier(~S,~Payload,~project,inner))
def prepared_column_join(~S:Data,~Payload:Type,value:Col.Carrier<S,Payload> & String) -> Col.Column<S,Payload> & String:
  (carrier,text)=value
  (Col.Prepared{carrier},"prepared(" ++ text ++ ")")
def indexed_column_join(~S:Data,~Payload:Type,value:Col.IndexedOrdinaryCarrier<S,Payload> & String) -> Col.Column<S,Payload> & String:
  (carrier,text)=value
  (Col.Indexed{carrier},"indexed(" ++ text ++ ")")
def prepared_indexed_column_join(~S:Data,~Payload:Type,value:Col.IndexedPreparedCarrier<S,Payload> & String) -> Col.Column<S,Payload> & String:
  (carrier,text)=value
  (Col.PreparedIndexed{carrier},"prepared-indexed(" ++ text ++ ")")
def column_done(~S:Data,~Payload:Type,+stamps:List<&2,L.Entry>,observed:Array<Maybe<&1,Payload>> & String) -> Col.Column<S,Payload> & String:
  (values,text)=observed
  (Col.Column{values,stamps},text ++ ";stamps=" ++ List.show(&2,L.Entry,entry,stamps))
def column(~S:Data,~Payload:Type,~project:Payload -> Payload & String,value:Col.Column<S,Payload>) -> Col.Column<S,Payload> & String:
  match value:
    case Col.Column{values,stamps}:column_done(~S,~Payload,stamps,array(~Maybe<&1,Payload>,~optional(~Payload,~project),values))
    case Col.Prepared{state}:prepared_column_join(~S,~Payload,carrier(~S,~Payload,~project,state))
    case Col.Indexed{state}:indexed_column_join(~S,~Payload,indexed_carrier(~S,~Payload,~project,state))
    case Col.PreparedIndexed{state}:prepared_indexed_column_join(~S,~Payload,prepared_indexed_carrier(~S,~Payload,~project,state))
def store_3(~S:Data,a:Col.Column<S,D.Stock>,b:Col.Column<S,D.Title>,c:Col.Column<S,D.Active>,sa:String,sb:String,sc:String,observed:Col.Column<S,D.Count> & String) -> D.Store<S> & String:
  (d,sd)=observed
  (D.Store{a,b,c,d},"stock=" ++ sa ++ "|title=" ++ sb ++ "|active=" ++ sc ++ "|count=" ++ sd)
def store_2(~S:Data,a:Col.Column<S,D.Stock>,b:Col.Column<S,D.Title>,d:Col.Column<S,D.Count>,sa:String,sb:String,observed:Col.Column<S,D.Active> & String) -> D.Store<S> & String:
  (c,sc)=observed
  store_3(~S,a,b,c,sa,sb,sc,column(~S,~D.Count,~count,d))
def store_1(~S:Data,a:Col.Column<S,D.Stock>,c:Col.Column<S,D.Active>,d:Col.Column<S,D.Count>,sa:String,observed:Col.Column<S,D.Title> & String) -> D.Store<S> & String:
  (b,sb)=observed
  store_2(~S,a,b,d,sa,sb,column(~S,~D.Active,~active,c))
def store_0(~S:Data,b:Col.Column<S,D.Title>,c:Col.Column<S,D.Active>,d:Col.Column<S,D.Count>,observed:Col.Column<S,D.Stock> & String) -> D.Store<S> & String:
  (a,sa)=observed
  store_1(~S,a,c,d,sa,column(~S,~D.Title,~title,b))
def store(~S:Data,value:D.Store<S>) -> D.Store<S> & String:
  match value:
    case D.Store{a,b,c,d}:store_0(~S,b,c,d,column(~S,~D.Stock,~stock,a))
def extra_second(first:Array<U32>,text:String,observed:Array<U32> & String) -> Consumer.Extra & String:
  (second,other)=observed
  (Consumer.Extra{first,second},text ++ ";" ++ other)
def extra_first(second:Array<U32>,observed:Array<U32> & String) -> Consumer.Extra & String:
  (first,text)=observed
  extra_second(first,text,u32_array(second))
def extra(value:Consumer.Extra) -> Consumer.Extra & String:
  match value:
    case Consumer.Extra{first,second}:extra_first(second,u32_array(first))
def target(~S:Data,value:W.Handle<S>) -> String:
  match value:
    case W.Handle{namespace,+id}:U32.show(namespace) ++ ":" ++ U32.show(Key.index(id)) ++ ":" ++ U32.show(Key.generation(id))
def diagnostic(~S:Data,value:Consumer.Diagnostic<S>) -> String:
  match value:
    case Consumer.DiagnosticLink{next}:diagnostic(~S,next)
    case Consumer.Diagnostic{targets,record,before,after,same,allowed,checks,ran}:"targets=" ++ List.show(&2,W.Handle<S>,target(~S),targets) ++ "|record=" ++ record ++ "|before=" ++ before ++ "|after=" ++ after ++ "|same=" ++ Bool.show(same) ++ "|allowed=" ++ Bool.show(allowed) ++ "|checks=" ++ U32.show(checks) ++ "|ran=" ++ U32.show(ran)
def resource_extra(~S:Data,cells:Array<U32>,text:String,+state:Consumer.Diagnostic<S>,observed:Consumer.Extra & String) -> Consumer.Resource<S> & String:
  (owner,other)=observed
  (Consumer.Resource{cells,owner,state},text ++ ";" ++ other ++ ";" ++ diagnostic(~S,state))
def resource_cells(~S:Data,owner:Consumer.Extra,state:Consumer.Diagnostic<S>,observed:Array<U32> & String) -> Consumer.Resource<S> & String:
  (cells,text)=observed
  resource_extra(~S,cells,text,state,extra(owner))
def resource(~S:Data,value:Consumer.Resource<S>) -> Consumer.Resource<S> & String:
  match value:
    case Consumer.Resource{cells,owner,state}:resource_cells(~S,owner,state,u32_array(cells))
def main() -> Unit:
  Unit{}
