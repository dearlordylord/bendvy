import Base
import ../../../src/ecs/captured-column.bend as C
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/owner-handoff.bend as H
import ../../../src/ecs/lifecycle.bend as L

type Schema is Data:
  Schema{}
type Payload is Type:
  Payload{cells:Array<U32>}
def owner(+value:U32) -> Payload:
  Payload{ANode{ALeaf{value},ALeaf{(value + 100 : U32)}}}
def cell_last(first:U32,result:Array<U32> & U32) -> Payload & String:
  (cells,last)=result
  (Payload{cells},"[" ++ U32.show(first) ++ "," ++ U32.show(last) ++ "]")
def cell_first(result:Array<U32> & U32) -> Payload & String:
  (cells,first)=result
  cell_last(first,Array.get(U32,cells,1))
def payload(value:Payload) -> Payload & String:
  match value:
    case Payload{cells}: cell_first(Array.get(U32,cells,0))
def some_projected(value:Payload & String) -> Maybe<&1,Payload> & String:
  (value,text)=value
  (Some{value},text)
def optional(value:Maybe<&1,Payload>) -> Maybe<&1,Payload> & String:
  match value:
    case None{}: (None{},"-")
    case Some{value}: some_projected(payload(value))
def row_join(+id:U32,head:Payload & String,tail:H.PrototypeHandoffRows<Schema,Payload> & String) -> H.PrototypeHandoffRows<Schema,Payload> & String:
  (head,a)=head
  (tail,b)=tail
  (H.HandoffCon{id,head,tail},U32.show(id) ++ ":" ++ a ++ ";" ++ b)
def rows(value:H.PrototypeHandoffRows<Schema,Payload>) -> H.PrototypeHandoffRows<Schema,Payload> & String:
  match value:
    case H.HandoffNil{}: (H.HandoffNil{},"")
    case H.HandoffCon{id,head,tail}: row_join(id,payload(head),rows(tail))
def history_join(+id:U32,head:Maybe<&1,Payload> & String,tail:Col.History<Schema,Payload> & String) -> Col.History<Schema,Payload> & String:
  (head,a)=head
  (tail,b)=tail
  (Col.HistoryCon{id,head,tail},U32.show(id) ++ ":" ++ a ++ ";" ++ b)
def history(value:Col.History<Schema,Payload>) -> Col.History<Schema,Payload> & String:
  match value:
    case Col.HistoryNil{}: (Col.HistoryNil{},"")
    case Col.HistoryCon{id,head,tail}: history_join(id,optional(head),history(tail))
def stamps(entries:List<&2,L.Entry>) -> String:
  match entries:
    case []: ""
    case L.Entry{id,L.Stamp{a,b}} <> rest: U32.show(id) ++ ":" ++ U32.show(a) ++ "," ++ U32.show(b) ++ ";" ++ stamps(rest)
def dropped_optional(result:Maybe<&1,Payload> & String) -> String:
  (owner,text)=result
  text
def array_cells(values:List<Maybe<&1,Payload>>) -> String:
  match values:
    case []: ""
    case first <> rest: dropped_optional(optional(first)) ++ ";" ++ array_cells(rest)
def physical(column:Col.Column<Schema,Payload>) -> String:
  match column:
    case Col.Column{values,entries}: "physical=" ++ array_cells(Array.to_list(Maybe<&1,Payload>,values)) ++ "stamps=" ++ stamps(entries)
    case Col.Prepared{_}: "RECOVERY_FAILED"
    case Col.Indexed{_}: "UNEXPECTED_INDEXED_REPRESENTATION"
    case Col.PreparedIndexed{_}: "UNEXPECTED_INDEXED_REPRESENTATION"
def state_join(values:Array<Maybe<&1,Payload>>,+entries:List<&2,L.Entry>,+capacity:U32,+current:U32,currentOwner:Maybe<&1,Payload> & String,left:H.PrototypeHandoffRows<Schema,Payload> & String,past:Col.History<Schema,Payload> & String) -> String:
  (currentOwner,a)=currentOwner
  (left,b)=left
  (past,c)=past
  "current=" ++ U32.show(current) ++ ":" ++ a ++ ";capacity=" ++ U32.show(capacity) ++ ";remaining=" ++ b ++ ";history=" ++ c ++ ";" ++ physical(Col.recover(~Schema,~Payload,Col.Prepared{Col.Owned{Col.State{values,entries,capacity,current,currentOwner,left,past}}}))
def state(value:Col.State<Schema,Payload>) -> String:
  match value:
    case Col.State{values,entries,capacity,current,currentOwner,left,past}: state_join(values,entries,capacity,current,optional(currentOwner),rows(left),history(past))
def column(value:Col.Column<Schema,Payload>) -> String:
  match value:
    case Col.Prepared{carrier}: state(Col.unseal(~Schema,~Payload,carrier))
    case other: physical(other)
def old_result(+target:U32,stamp:L.Stamp,result:Col.SwapOutcome<Schema,Payload>) -> String:
  match stamp result:
    case _ Col.Rejected{value,incoming}: "rejected;incoming=" ++ dropped_optional(optional(incoming)) ++ ";" ++ column(value)
    case L.Stamp{a,b} Col.Accepted{value,previous}: "accepted;target=" ++ U32.show(target) ++ ";stamp=" ++ U32.show(a) ++ "," ++ U32.show(b) ++ ";previous=" ++ dropped_optional(optional(previous)) ++ ";" ++ column(value)
def new_result(result:C.Capture<Schema,Payload>) -> String:
  match result:
    case C.Unavailable{value}: "rejected;incoming=-;" ++ column(value)
    case C.Captured{target,previous,L.Stamp{a,b},restore}: "accepted;target=" ++ U32.show(target) ++ ";stamp=" ++ U32.show(a) ++ "," ++ U32.show(b) ++ ";previous=" ++ dropped_optional(optional(previous)) ++ ";" ++ column(restore(C.Slot{None{},L.Stamp{0,0},False{}}))
def input_values() -> Array<Maybe<&1,Payload>>:
  ANode{ANode{ANode{ALeaf{None{}},ALeaf{None{}}},ANode{ALeaf{None{}},ALeaf{None{}}}},ANode{ANode{ALeaf{Some{owner(15)}},ALeaf{Some{owner(16)}}},ANode{ALeaf{None{}},ALeaf{Some{owner(18)}}}}}
def input_rows(kind:U32) -> H.PrototypeHandoffRows<Schema,Payload>:
  match kind:
    case 0: H.HandoffNil{}
    case 1: H.HandoffCon{2,owner(12),H.HandoffNil{}}
    case _: H.HandoffCon{2,owner(12),H.HandoffCon{4,owner(14),H.HandoffNil{}}}
def input_history(kind:U32) -> Col.History<Schema,Payload>:
  match kind:
    case 0: Col.HistoryNil{}
    case 1: Col.HistoryCon{1,Some{owner(11)},Col.HistoryCon{3,None{},Col.HistoryNil{}}}
    case _: Col.HistoryCon{3,None{},Col.HistoryCon{1,Some{owner(11)},Col.HistoryNil{}}}
def phase(kind:U32) -> Col.SeekPhase:
  match kind:
    case 0: Col.Inspect{}
    case 1: Col.Choice{False{},False{}}
    case 2: Col.Choice{False{},True{}}
    case 3: Col.Choice{True{},False{}}
    case _: Col.Choice{True{},True{}}
def input_stamps() -> List<&2,L.Entry>:
  [L.Entry{1,L.Stamp{2,3}},L.Entry{2,L.Stamp{4,5}},L.Entry{4,L.Stamp{8,9}},L.Entry{5,L.Stamp{10,11}}]
def old(+target:U32,fuel:Nat,mode:U32,rowKind:U32,pastKind:U32) -> String:
  old_result(target,L.get(input_stamps(),target),Col.seek(~Schema,~Payload,fuel,input_values(),input_stamps(),8,target,None{},input_rows(rowKind),input_history(pastKind),phase(mode)))
def newer(target:U32,fuel:Nat,mode:U32,rowKind:U32,pastKind:U32) -> String:
  new_result(C.capture_seek(~Schema,~Payload,fuel,input_values(),input_stamps(),8,target,input_rows(rowKind),input_history(pastKind),phase(mode)))
def observation(+index:U32) -> String:
  +target=(index % 6 : U32)
  +fuel=U32.to_nat((U32.div(index,6) % 9 : U32))
  +mode=(U32.div(index,54) % 5 : U32)
  +rowKind=(U32.div(index,270) % 3 : U32)
  +pastKind=(U32.div(index,810) % 3 : U32)
  U32.show(index) ++ "|" ++ old(target,fuel,mode,rowKind,pastKind) ++ "|" ++ newer(target,fuel,mode,rowKind,pastKind)
def loop(fuel:Nat,+index:U32) -> IO(Unit):
  match fuel:
    case 0n: IO.pure(Unit,Unit{})
    case 1n+rest: IO.bind(Unit,Unit,IO.print(observation(index)),u => loop(rest,(index + 1 : U32)))
