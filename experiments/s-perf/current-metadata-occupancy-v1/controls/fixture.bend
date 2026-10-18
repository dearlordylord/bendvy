import Base
import ../subject/motion.bend as F
import ../subject/events.bend as E
import ../subject/payload.bend as P
import ../subject/render.bend as JSON
import ../private/src/ecs/world.bend as W
import ../private/src/ecs/entity-key.bend as K
import ../private/src/ecs/component.bend as Cmp
import ../private/src/ecs/commands.bend as Cmd
import ../private/src/ecs/transaction.bend as Tx
import ../private/src/ecs/column.bend as C
import ../private/src/ecs/indexed-lifecycle.bend as M
import ../private/src/ecs/lifecycle.bend as L
import ../private/src/ecs/owner-handoff.bend as H
import ../private/occupancy.bend as O
import ../subject/metadata-report.bend as Report
import ../subject/types.bend as T

type Payload is Type:
  Payload{tag:U32,token:Array<U32>,captured:Unit -> Array<U32>}
def pair(+a:U32,+b:U32) -> Array<U32>:ANode{ALeaf{a},ALeaf{b}}
def capture(owner:Array<U32>) -> Unit -> Array<U32>:_=>owner
def payload(+tag:U32) -> Payload:Payload{tag,pair(tag,U32.add(tag,100)),capture(pair(U32.add(tag,1000),U32.add(tag,2000)))}
def tail(values:List<&2,String>) -> String:
  match values:
    case []:"]"
    case head <> rest:"," ++ head ++ tail(rest)
def list(values:List<&2,String>) -> String:
  match values:
    case []:"[]"
    case head <> rest:"[" ++ head ++ tail(rest)
def cells(value:Array<U32>) -> List<&2,String>:
  match value:
    case ALeaf{value}:[U32.show(value)]
    case ANode{left,right}:List.append(&2,String,cells(left),cells(right))
def payload_text(value:Payload) -> String:
  match value:
    case Payload{tag,token,captured}:"{\"tag\":" ++ U32.show(tag) ++ ",\"token\":" ++ list(cells(token)) ++ ",\"captured\":" ++ list(cells(captured(Unit{}))) ++ "}"
def optional(value:Maybe<&1,Payload>) -> String:
  match value:
    case None{}:"null"
    case Some{owner}:payload_text(owner)
def owners(value:Array<Maybe<&1,Payload>>) -> List<&2,String>:
  match value:
    case ALeaf{value}:[optional(value)]
    case ANode{left,right}:List.append(&2,String,owners(left),owners(right))
def entry(value:L.Entry) -> String:
  match value:
    case L.Entry{id,L.Stamp{a,c}}:"[" ++ U32.show(id) ++ "," ++ U32.show(a) ++ "," ++ U32.show(c) ++ "]"
def entry_list(values:List<&2,L.Entry>) -> List<&2,String>:
  match values:
    case []:[]
    case head <> rest:entry(head) <> entry_list(rest)
def tree_node(~A:Type,left:Array<A> & String,right:Array<A> & String) -> Array<A> & String:
  match left right:
    case (left,a),(right,b):(ANode{left,right},"node(" ++ a ++ "," ++ b ++ ")")
def tree(~A:Type,value:Array<A>) -> Array<A> & String:
  match value:
    case ALeaf{owner}:(ALeaf{owner},"leaf")
    case ANode{left,right}:tree_node(~A,tree(~A,left),tree(~A,right))
def metadata_join(capacity:U32,depth:Nat,exceptional:List<&2,L.Entry>,added:Array<U32> & String,changed:Array<U32> & String) -> String:
  match added changed:
    case (added,a),(changed,c):"{\"addedTree\":\"" ++ a ++ "\",\"changedTree\":\"" ++ c ++ "\",\"added\":" ++ list(cells(added)) ++ ",\"changed\":" ++ list(cells(changed)) ++ ",\"capacity\":" ++ U32.show(capacity) ++ ",\"depth\":" ++ Nat.show(depth) ++ ",\"exceptional\":" ++ list(entry_list(exceptional)) ++ "}"
def metadata(value:M.Metadata) -> String:
  match value:
    case M.Metadata{added,changed,capacity,depth,exceptional}:metadata_join(capacity,depth,exceptional,tree(~U32,added),tree(~U32,changed))
def values(value:Array<Maybe<&1,Payload>> & String) -> String:
  match value:
    case (owner,text):"\"valuesTree\":\"" ++ text ++ "\",\"values\":" ++ list(owners(owner))
def indexed(value:C.IndexedOrdinaryCarrier<T.MotionSchema,Payload>) -> String:
  match value:
    case C.IndexedOrdinaryWrapped{inner}:indexed(inner)
    case C.IndexedOrdinaryOwned{C.IndexedOrdinaryState{owner,marks}}:"{" ++ values(tree(~Maybe<&1,Payload>,owner)) ++ ",\"metadata\":" ++ metadata(marks) ++ "}"
def column(value:C.Column<T.MotionSchema,Payload>) -> String:
  match value:
    case C.Column{owner,stamps}:"{" ++ values(tree(~Maybe<&1,Payload>,owner)) ++ ",\"stamps\":" ++ list(entry_list(stamps)) ++ "}"
    case C.Indexed{inner}:indexed(inner)
    case C.Monitored{inner,_}:column(inner)
    case _:"INVALID_UNRECOVERED"
def observed(value:C.Column<T.MotionSchema,Payload> & O.Snapshot) -> String:
  match value:
    case (owner,snapshot):"{\"snapshot\":" ++ Report.snapshot(snapshot) ++ ",\"returned\":" ++ column(owner) ++ "}"
def stamps() -> List<&2,L.Entry>:[L.Entry{1,L.Stamp{0,0}},L.Entry{2,L.Stamp{5,0}},L.Entry{3,L.Stamp{0,7}}]
def plain() -> String:observed(C.occupancy_observe(~T.MotionSchema,~Payload,C.Column{ALeaf{Some{payload(11)}},stamps()}))
def meta_observed(value:M.Metadata & O.MetadataStats) -> String:
  match value:
    case (owner,snapshot):"{\"snapshot\":" ++ Report.metadata(snapshot) ++ ",\"returned\":" ++ metadata(owner) ++ "}"
def exceptional() -> M.Metadata:M.set(M.set(M.empty(),0,L.Stamp{2,0}),131073,L.Stamp{0,3})
def exceptional_text() -> String:list([meta_observed(O.metadata(exceptional())),meta_observed(O.metadata(M.clear(exceptional(),0)))])
def unequal() -> String:list([meta_observed(O.metadata(M.Metadata{pair(1,0),ALeaf{2},8,3n,[]})),meta_observed(O.metadata(M.Metadata{ALeaf{0},pair(0,2),8,3n,[]}))])
def capacity_split() -> String:observed(C.occupancy_observe(~T.MotionSchema,~Payload,C.ensure(~T.MotionSchema,~Payload,C.empty_indexed(~T.MotionSchema,~Payload),8)))
def empty_values() -> Array<Maybe<&1,Payload>>:ANode{ANode{ALeaf{None{}},ALeaf{None{}}},ANode{ALeaf{None{}},ALeaf{None{}}}}
def remaining() -> H.PrototypeHandoffRows<T.MotionSchema,Payload>:H.HandoffCon{3,payload(33),H.HandoffCon{4,payload(44),H.HandoffNil{}}}
def past() -> C.History<T.MotionSchema,Payload>:C.HistoryCon{1,Some{payload(11)},C.HistoryNil{}}
def remaining_join(+id:U32,owner:Payload,result:H.PrototypeHandoffRows<T.MotionSchema,Payload> & List<&2,String>) -> H.PrototypeHandoffRows<T.MotionSchema,Payload> & List<&2,String>:
  match result:
    case (rest,ids):(H.HandoffCon{id,owner,rest},U32.show(id) <> ids)
def remaining_ids(value:H.PrototypeHandoffRows<T.MotionSchema,Payload>) -> H.PrototypeHandoffRows<T.MotionSchema,Payload> & List<&2,String>:
  match value:
    case H.HandoffNil{}:(H.HandoffNil{},[])
    case H.HandoffCon{id,owner,rest}:remaining_join(id,owner,remaining_ids(rest))
def past_join(+id:U32,owner:Maybe<&1,Payload>,result:C.History<T.MotionSchema,Payload> & List<&2,String>) -> C.History<T.MotionSchema,Payload> & List<&2,String>:
  match result:
    case (rest,ids):(C.HistoryCon{id,owner,rest},U32.show(id) <> ids)
def past_ids(value:C.History<T.MotionSchema,Payload>) -> C.History<T.MotionSchema,Payload> & List<&2,String>:
  match value:
    case C.HistoryNil{}:(C.HistoryNil{},[])
    case C.HistoryCon{id,owner,rest}:past_join(id,owner,past_ids(rest))
def owner_presence(value:Maybe<&1,Payload>) -> Maybe<&1,Payload> & String:
  match value:
    case None{}:(None{},"false")
    case Some{owner}:(Some{owner},"true")
def descriptor(+depth:Nat,+capacity:U32,+current:U32,owner:String,remaining:List<&2,String>,past:List<&2,String>) -> String:"{\"wrappers\":" ++ Nat.show(depth) ++ ",\"capacity\":" ++ U32.show(capacity) ++ ",\"current\":" ++ U32.show(current) ++ ",\"owner\":" ++ owner ++ ",\"remaining\":" ++ list(remaining) ++ ",\"past\":" ++ list(past) ++ "}"
def prepared_join(depth:Nat,values:Array<Maybe<&1,Payload>>,stamps:List<&2,L.Entry>,+capacity:U32,+current:U32,owner:Maybe<&1,Payload> & String,remaining:H.PrototypeHandoffRows<T.MotionSchema,Payload> & List<&2,String>,past:C.History<T.MotionSchema,Payload> & List<&2,String>) -> C.Carrier<T.MotionSchema,Payload> & String:
  match owner remaining past:
    case (owner,present),(remaining,ids),(past,previous):(C.Owned{C.State{values,stamps,capacity,current,owner,remaining,past}},descriptor(depth,capacity,current,present,ids,previous))
def prepared_wrap(result:C.Carrier<T.MotionSchema,Payload> & String) -> C.Carrier<T.MotionSchema,Payload> & String:
  match result:
    case (inner,text):(C.Wrapped{inner},text)
def prepared_state(value:C.Carrier<T.MotionSchema,Payload>,depth:Nat) -> C.Carrier<T.MotionSchema,Payload> & String:
  match value:
    case C.Wrapped{inner}:prepared_wrap(prepared_state(inner,1n+depth))
    case C.Owned{C.State{values,stamps,capacity,current,owner,remaining,past}}:prepared_join(depth,values,stamps,capacity,current,owner_presence(owner),remaining_ids(remaining),past_ids(past))
def indexed_prepared_join(depth:Nat,values:Array<Maybe<&1,Payload>>,metadata:M.Metadata,+capacity:U32,+current:U32,owner:Maybe<&1,Payload> & String,remaining:H.PrototypeHandoffRows<T.MotionSchema,Payload> & List<&2,String>,past:C.History<T.MotionSchema,Payload> & List<&2,String>) -> C.IndexedPreparedCarrier<T.MotionSchema,Payload> & String:
  match owner remaining past:
    case (owner,present),(remaining,ids),(past,previous):(C.IndexedPreparedOwned{C.IndexedPreparedState{values,metadata,capacity,current,owner,remaining,past}},descriptor(depth,capacity,current,present,ids,previous))
def indexed_prepared_wrap(result:C.IndexedPreparedCarrier<T.MotionSchema,Payload> & String) -> C.IndexedPreparedCarrier<T.MotionSchema,Payload> & String:
  match result:
    case (inner,text):(C.IndexedPreparedWrapped{inner},text)
def indexed_prepared_state(value:C.IndexedPreparedCarrier<T.MotionSchema,Payload>,depth:Nat) -> C.IndexedPreparedCarrier<T.MotionSchema,Payload> & String:
  match value:
    case C.IndexedPreparedWrapped{inner}:indexed_prepared_wrap(indexed_prepared_state(inner,1n+depth))
    case C.IndexedPreparedOwned{C.IndexedPreparedState{values,metadata,capacity,current,owner,remaining,past}}:indexed_prepared_join(depth,values,metadata,capacity,current,owner_presence(owner),remaining_ids(remaining),past_ids(past))
def prepared_return(snapshot:O.Snapshot,result:C.Carrier<T.MotionSchema,Payload> & String) -> String:
  match result:
    case (owner,text):"{\"snapshot\":" ++ Report.snapshot(snapshot) ++ ",\"state\":" ++ text ++ ",\"returned\":" ++ column(C.recover(~T.MotionSchema,~Payload,C.Prepared{owner})) ++ "}"
def indexed_prepared_return(snapshot:O.Snapshot,result:C.IndexedPreparedCarrier<T.MotionSchema,Payload> & String) -> String:
  match result:
    case (owner,text):"{\"snapshot\":" ++ Report.snapshot(snapshot) ++ ",\"state\":" ++ text ++ ",\"returned\":" ++ column(C.recover(~T.MotionSchema,~Payload,C.PreparedIndexed{owner})) ++ "}"
def prepared_observed(result:C.Column<T.MotionSchema,Payload> & O.Snapshot) -> String:
  match result:
    case (C.Prepared{owner},snapshot):prepared_return(snapshot,prepared_state(owner,0n))
    case (C.PreparedIndexed{owner},snapshot):indexed_prepared_return(snapshot,indexed_prepared_state(owner,0n))
    case _:"INVALID_CARRIER"
def prepared() -> String:prepared_observed(C.occupancy_observe(~T.MotionSchema,~Payload,C.Prepared{C.Wrapped{C.Wrapped{C.Owned{C.State{empty_values(),stamps(),4,2,Some{payload(22)},remaining(),past()}}}}}))
def prepared_indexed() -> String:prepared_observed(C.occupancy_observe(~T.MotionSchema,~Payload,C.PreparedIndexed{C.IndexedPreparedWrapped{C.IndexedPreparedWrapped{C.IndexedPreparedOwned{C.IndexedPreparedState{empty_values(),M.set(M.set(M.empty(),1,L.Stamp{1,2}),4,L.Stamp{0,3}),4,2,Some{payload(22)},remaining(),past()}}}}}))
def restored(value:C.Column<T.MotionSchema,Payload>) -> String:
  match value:
    case C.Monitored{inner,+history}:"{\"trace\":" ++ Report.samples(List.reverse(&2,O.Sample,history)) ++ ",\"returned\":" ++ column(inner) ++ "}"
    case _:"INVALID_MONITOR"
def restore() -> String:restored(C.restore_stamp(~T.MotionSchema,~Payload,C.mark(~T.MotionSchema,~Payload,C.empty_indexed(~T.MotionSchema,~Payload),1,True{},False{},5),1,L.Stamp{0,0}))
def position(value:Cmp.Access<T.PositionView>) -> String:
  match value:
    case Cmp.Found{view}:"{\"kind\":\"Found\",\"value\":" ++ JSON.render_position(view) ++ "}"
    case Cmp.ComponentAbsent{}:"{\"kind\":\"Absent\"}"
    case Cmp.MissingEntity{}:"{\"kind\":\"Missing\"}"
def outcome(value:Tx.Outcome<Unit>) -> String:
  match value:
    case Tx.Success{}:"Success"
    case Tx.Failure{_}:"Failure"
def handle(value:W.Handle<T.MotionSchema>) -> String:
  match value:
    case W.Handle{namespace,K.EntityKey{id,generation}}:"[" ++ U32.show(namespace) ++ "," ++ U32.show(id) ++ "," ++ U32.show(generation) ++ "]"
def rollback_clock(handleText:String,positionText:String,stamp:L.Stamp,outcomeText:String,trace:String,result:F.World() & U32) -> String:
  match stamp result:
    case L.Stamp{added,changed},(_,clock):"{\"outcome\":\"" ++ outcomeText ++ "\",\"handle\":" ++ handleText ++ ",\"position\":" ++ positionText ++ ",\"stamp\":[" ++ U32.show(added) ++ "," ++ U32.show(changed) ++ "],\"clock\":" ++ U32.show(clock) ++ ",\"trace\":" ++ trace ++ "}"
def rollback_trace(handleText:String,positionText:String,stamp:L.Stamp,outcomeText:String,result:F.World() & String) -> String:
  match result:
    case (world,trace):rollback_clock(handleText,positionText,stamp,outcomeText,trace,W.clock(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),world))
def rollback_stamp(handleText:String,positionText:String,outcomeText:String,result:F.World() & L.Stamp) -> String:
  match result:
    case (world,stamp):rollback_trace(handleText,positionText,stamp,outcomeText,Report.world(world))
def rollback_view(+entity:W.Handle<T.MotionSchema>,outcomeText:String,result:F.World() & Cmp.Access<T.PositionView>) -> String:
  match result:
    case (world,access):rollback_stamp(handle(entity),position(access),outcomeText,Cmp.lifecycle(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~F.Rest(),~T.Position,~T.PositionView,~T.PositionToken,~F.take_main,~F.put_main,~P.position_get,F.main_family(),world,entity))
def rollback_finished(+entity:W.Handle<T.MotionSchema>,result:Tx.Returned<F.World(),Unit>) -> String:
  match result:
    case Tx.Returned{world,status}:rollback_view(entity,outcome(status),Cmp.get(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~F.Rest(),~T.Position,~T.PositionView,~T.PositionToken,~F.take_main,~F.put_main,~P.position_get,F.main_family(),world,entity))
def rollback_written(entity:W.Handle<T.MotionSchema>,result:Cmp.SetResult<Tx.Tx<F.World(),E.event_type()>,T.Position>) -> String:
  match result:
    case Cmp.Written{tx}:rollback_finished(entity,Cmd.tx_finish(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~Unit,tx,Tx.Failure{Unit{}}))
    case _:"{\"error\":\"write refused\"}"
def rollback_seeded(result:F.Seeded) -> String:
  match result:
    case F.Seeded{world,W.Reserved{+entity} <> [],Tx.Success{}}:rollback_written(entity,Cmp.tx_set(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~F.Rest(),~T.Position,~T.PositionView,~T.PositionToken,~F.take_main,~F.put_main,~P.position_get,F.main_family(),Tx.begin(~F.World(),~E.event_type(),W.barrier(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),world)),entity,T.Position{F.quad(9,8,7,6),99}))
    case _:"{\"error\":\"seed refused\"}"
def rollback_created(result:W.Creation<T.MotionSchema,F.Store(),F.Resources(),E.event_type()>) -> String:
  match result:
    case W.Created{_,world}:rollback_seeded(F.seed(1,world))
    case _:"{\"error\":\"create refused\"}"
def rollback() -> String:rollback_created(W.create(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~F.empty,W.factory(),F.initial_resources()))
def result() -> String:"{\"plain\":" ++ plain() ++ ",\"exceptional\":" ++ exceptional_text() ++ ",\"unequal\":" ++ unequal() ++ ",\"capacitySplit\":" ++ capacity_split() ++ ",\"prepared\":" ++ prepared() ++ ",\"preparedIndexed\":" ++ prepared_indexed() ++ ",\"restore\":" ++ restore() ++ ",\"rollback\":" ++ rollback() ++ "}"
def main() -> IO(Unit):IO.print(result())
