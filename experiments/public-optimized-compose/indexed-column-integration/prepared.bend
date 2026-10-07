import Base
import ordinary.bend as O
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/captured-column.bend as K
import ../../../src/ecs/indexed-lifecycle.bend as M
import ../../../src/ecs/lifecycle.bend as L
import ../../../src/ecs/owner-handoff.bend as H
import ../refusal-control.bend as P

def route(indexed:Bool) -> Col.Column<P.Schema,P.Payload>:
  Col.prepare(~P.Schema,~P.Payload,O.seeded(indexed))
def viewed(indexed:Bool,+id:U32) -> List<&2,U32>:
  O.observed((column => O.values(4n,1,Col.recover(~P.Schema,~P.Payload,column))),Col.view(~P.Schema,~P.Payload,~P.View,~O.mutate,route(indexed),id))
def backwards_first(+id:U32,result:Col.Column<P.Schema,P.Payload> & Maybe<&2,P.View>) -> List<&2,U32>:
  match result:
    case (column,_): O.observed((column => O.values(4n,1,Col.recover(~P.Schema,~P.Payload,column))),Col.view(~P.Schema,~P.Payload,~P.View,~O.mutate,column,id))
def backwards(indexed:Bool) -> List<&2,U32>:
  backwards_first(1,Col.view(~P.Schema,~P.Payload,~P.View,~P.project,route(indexed),3))
def swapped(indexed:Bool,+id:U32) -> List<&2,U32>:
  O.swapped(Col.swap(~P.Schema,~P.Payload,route(indexed),id,Some{O.payload(17,19)}))
def grown(indexed:Bool) -> List<&2,U32>:
  O.swapped(Col.swap(~P.Schema,~P.Payload,Col.ensure(~P.Schema,~P.Payload,route(indexed),8),8,Some{O.payload(43,47)}))
def invalid_grow(indexed:Bool,+target:U32) -> List<&2,U32>:
  O.values(4n,1,Col.recover(~P.Schema,~P.Payload,Col.ensure(~P.Schema,~P.Payload,route(indexed),target)))
def captured_changed(+id:U32,stamp:L.Stamp,restore:K.Slot<P.Payload> -> Col.Column<P.Schema,P.Payload>,dirty:Bool,result:P.Payload & P.View) -> List<&2,U32>:
  match result:
    case (owner,P.View{a,b}): List.append(&2,U32,[id,a,b],O.values(4n,1,Col.recover(~P.Schema,~P.Payload,restore(K.Slot{Some{owner},stamp,dirty}))))
def captured(perturb:Bool,dirty:Bool,result:K.Capture<P.Schema,P.Payload>) -> List<&2,U32>:
  match perturb result:
    case _ K.Unavailable{column}: List.append(&2,U32,[999],O.values(4n,1,Col.recover(~P.Schema,~P.Payload,column)))
    case _ K.Captured{+id,None{},stamp,restore}: List.append(&2,U32,[id,999,999],O.values(4n,1,Col.recover(~P.Schema,~P.Payload,restore(K.Slot{None{},stamp,dirty}))))
    case False{} K.Captured{+id,Some{owner},stamp,restore}: captured_changed(id,stamp,restore,dirty,P.project(owner))
    case True{} K.Captured{+id,Some{owner},_,restore}: captured_changed(id,L.Stamp{53,59},restore,dirty,O.mutate(owner))
def capture_case(indexed:Bool,prepared:Bool,perturb:Bool,dirty:Bool,+id:U32) -> List<&2,U32>:
  match prepared:
    case False{}: captured(perturb,dirty,K.capture(~P.Schema,~P.Payload,O.seeded(indexed),id))
    case True{}: captured(perturb,dirty,K.capture(~P.Schema,~P.Payload,route(indexed),id))
def input_metadata() -> M.Metadata:
  M.set(M.set(M.empty(),3,L.Stamp{0,11}),0,L.Stamp{13,0})
def partial(indexed:Bool,+fuel:Nat,+target:U32,phase:Col.SeekPhase,rows:H.PrototypeHandoffRows<P.Schema,P.Payload>) -> List<&2,U32>:
  match indexed:
    case False{}: O.swapped(Col.seek(~P.Schema,~P.Payload,fuel,Col.absent(~P.Payload,2n),[L.Entry{3,L.Stamp{0,11}},L.Entry{0,L.Stamp{13,0}}],4,target,Some{O.payload(17,19)},rows,Col.HistoryCon{1,Some{O.payload(3,7)},Col.HistoryNil{}},phase))
    case True{}: O.swapped(Col.indexed_seek(~P.Schema,~P.Payload,fuel,Col.absent(~P.Payload,2n),input_metadata(),4,target,Some{O.payload(17,19)},rows,Col.HistoryCon{1,Some{O.payload(3,7)},Col.HistoryNil{}},phase))
def rows() -> H.PrototypeHandoffRows<P.Schema,P.Payload>:
  H.HandoffCon{2,O.payload(11,13),H.HandoffCon{4,O.payload(23,29),H.HandoffNil{}}}
def partial_case(indexed:Bool,+fuel:Nat,+target:U32) -> List<&2,U32>:
  partial(indexed,fuel,target,Col.Inspect{},rows())
def wrapped(indexed:Bool) -> List<&2,U32>:
  match indexed:
    case False{}: O.values(4n,1,Col.recover(~P.Schema,~P.Payload,Col.Prepared{Col.Wrapped{Col.Wrapped{Col.Owned{Col.State{Col.absent(~P.Payload,2n),[L.Entry{3,L.Stamp{0,11}},L.Entry{0,L.Stamp{13,0}}],4,1,Some{O.payload(3,7)},rows(),Col.HistoryNil{}}}}}}))
    case True{}: O.values(4n,1,Col.recover(~P.Schema,~P.Payload,Col.PreparedIndexed{Col.IndexedPreparedWrapped{Col.IndexedPreparedWrapped{Col.IndexedPreparedOwned{Col.IndexedPreparedState{Col.absent(~P.Payload,2n),input_metadata(),4,1,Some{O.payload(3,7)},rows(),Col.HistoryNil{}}}}}}))
def marked(indexed:Bool) -> List<&2,U32>:
  O.values(4n,1,Col.recover(~P.Schema,~P.Payload,Col.clear_stamp(~P.Schema,~P.Payload,Col.mark(~P.Schema,~P.Payload,route(indexed),1,True{},True{},61),3)))
def exceptional(indexed:Bool) -> List<&2,U32>:
  O.exceptional_next(Col.recover(~P.Schema,~P.Payload,Col.restore_stamp(~P.Schema,~P.Payload,Col.restore_stamp(~P.Schema,~P.Payload,route(indexed),4294967295,L.Stamp{29,31}),131073,L.Stamp{37,41})))

def main() -> IO(Unit):
  IO.print(List.show(&2,List<&2,U32>,(xs => List.show(&2,U32,U32.show,xs)),[
    viewed(False{},0),
    viewed(True{},0),
    viewed(False{},1),
    viewed(True{},1),
    viewed(False{},2),
    viewed(True{},2),
    viewed(False{},3),
    viewed(True{},3),
    viewed(False{},5),
    viewed(True{},5),
    backwards(False{}),
    backwards(True{}),
    swapped(False{},0),
    swapped(True{},0),
    swapped(False{},1),
    swapped(True{},1),
    swapped(False{},3),
    swapped(True{},3),
    swapped(False{},5),
    swapped(True{},5),
    grown(False{}),
    grown(True{}),
    invalid_grow(False{},0),
    invalid_grow(True{},0),
    invalid_grow(False{},131073),
    invalid_grow(True{},131073),
    wrapped(False{}),
    wrapped(True{}),
    marked(False{}),
    marked(True{}),
    exceptional(False{}),
    exceptional(True{}),
    capture_case(False{},False{},False{},False{},0),
    capture_case(True{},False{},False{},False{},0),
    capture_case(False{},False{},False{},False{},1),
    capture_case(True{},False{},False{},False{},1),
    capture_case(False{},False{},False{},False{},2),
    capture_case(True{},False{},False{},False{},2),
    capture_case(False{},False{},False{},False{},5),
    capture_case(True{},False{},False{},False{},5),
    capture_case(False{},False{},True{},False{},0),
    capture_case(True{},False{},True{},False{},0),
    capture_case(False{},False{},True{},False{},1),
    capture_case(True{},False{},True{},False{},1),
    capture_case(False{},False{},True{},False{},2),
    capture_case(True{},False{},True{},False{},2),
    capture_case(False{},False{},True{},False{},5),
    capture_case(True{},False{},True{},False{},5),
    capture_case(False{},False{},True{},True{},0),
    capture_case(True{},False{},True{},True{},0),
    capture_case(False{},False{},True{},True{},1),
    capture_case(True{},False{},True{},True{},1),
    capture_case(False{},False{},True{},True{},2),
    capture_case(True{},False{},True{},True{},2),
    capture_case(False{},False{},True{},True{},5),
    capture_case(True{},False{},True{},True{},5),
    capture_case(False{},True{},False{},False{},0),
    capture_case(True{},True{},False{},False{},0),
    capture_case(False{},True{},False{},False{},1),
    capture_case(True{},True{},False{},False{},1),
    capture_case(False{},True{},False{},False{},2),
    capture_case(True{},True{},False{},False{},2),
    capture_case(False{},True{},False{},False{},5),
    capture_case(True{},True{},False{},False{},5),
    capture_case(False{},True{},True{},False{},0),
    capture_case(True{},True{},True{},False{},0),
    capture_case(False{},True{},True{},False{},1),
    capture_case(True{},True{},True{},False{},1),
    capture_case(False{},True{},True{},False{},2),
    capture_case(True{},True{},True{},False{},2),
    capture_case(False{},True{},True{},False{},5),
    capture_case(True{},True{},True{},False{},5),
    capture_case(False{},True{},True{},True{},0),
    capture_case(True{},True{},True{},True{},0),
    capture_case(False{},True{},True{},True{},1),
    capture_case(True{},True{},True{},True{},1),
    capture_case(False{},True{},True{},True{},2),
    capture_case(True{},True{},True{},True{},2),
    capture_case(False{},True{},True{},True{},5),
    capture_case(True{},True{},True{},True{},5),
    partial_case(False{},0n,1),
    partial_case(True{},0n,1),
    partial_case(False{},0n,2),
    partial_case(True{},0n,2),
    partial_case(False{},0n,3),
    partial_case(True{},0n,3),
    partial_case(False{},0n,4),
    partial_case(True{},0n,4),
    partial_case(False{},1n,1),
    partial_case(True{},1n,1),
    partial_case(False{},1n,2),
    partial_case(True{},1n,2),
    partial_case(False{},1n,3),
    partial_case(True{},1n,3),
    partial_case(False{},1n,4),
    partial_case(True{},1n,4),
    partial_case(False{},2n,1),
    partial_case(True{},2n,1),
    partial_case(False{},2n,2),
    partial_case(True{},2n,2),
    partial_case(False{},2n,3),
    partial_case(True{},2n,3),
    partial_case(False{},2n,4),
    partial_case(True{},2n,4),
    partial_case(False{},3n,1),
    partial_case(True{},3n,1),
    partial_case(False{},3n,2),
    partial_case(True{},3n,2),
    partial_case(False{},3n,3),
    partial_case(True{},3n,3),
    partial_case(False{},3n,4),
    partial_case(True{},3n,4),
    partial_case(False{},8n,1),
    partial_case(True{},8n,1),
    partial_case(False{},8n,2),
    partial_case(True{},8n,2),
    partial_case(False{},8n,3),
    partial_case(True{},8n,3),
    partial_case(False{},8n,4),
    partial_case(True{},8n,4)
  ]))
