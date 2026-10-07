import Base
import row-cell-control.bend as P
import refusal-control.bend as F
import ../../src/ecs/captured-column.bend as C
import ../../src/ecs/column.bend as Col
import ../../src/ecs/owner-handoff.bend as H
import ../../src/ecs/lifecycle.bend as L

def restored(+id:U32,points:List<&2,U32>,column:Col.Column<F.Schema,F.Payload>) -> List<&2,U32>:
  P.physical_stamped(points,Col.lifecycle(~F.Schema,~F.Payload,column,id))
def captured(+id:U32,result:C.Capture<F.Schema,F.Payload>) -> List<&2,U32>:
  match result:
    case C.Unavailable{column}: restored(id,[1],column)
    case C.Captured{key,owner,L.Stamp{a,b},restore}: restored(id,P.previous([0,key,a,b],owner),restore(C.Slot{None{},L.Stamp{5,17},False{}}))
def unchanged(+id:U32,result:C.Capture<F.Schema,F.Payload>) -> List<&2,U32>:
  match result:
    case C.Unavailable{column}: restored(id,[1],column)
    case C.Captured{key,owner,L.Stamp{+a,+b},restore}: restored(id,[0,key,a,b],restore(C.Slot{owner,L.Stamp{a,b},False{}}))
def mutated(result:F.Payload & F.View,restore:C.Slot<F.Payload> -> Col.Column<F.Schema,F.Payload>,stamp:L.Stamp) -> List<&2,U32>:
  match result:
    case (owner,view): restored(1,P.cells(view),restore(C.Slot{Some{owner},stamp,False{}}))
def projection(result:C.Capture<F.Schema,F.Payload>) -> List<&2,U32>:
  match result:
    case C.Captured{_,Some{owner},stamp,restore}: mutated(P.mutate(owner),restore,stamp)
    case C.Captured{id,None{},stamp,restore}: restored(id,[999,999],restore(C.Slot{None{},stamp,False{}}))
    case C.Unavailable{column}: restored(1,[1],column)
def dirty(result:C.Capture<F.Schema,F.Payload>) -> List<&2,U32>:
  match result:
    case C.Captured{id,owner,stamp,restore}: restored(id,P.previous([],owner),restore(C.Slot{Some{F.Payload{ANode{ALeaf{41},ALeaf{43}}}},L.Stamp{5,17},True{}}))
    case C.Unavailable{column}: restored(1,[1],column)
def seek_new(+fuel:Nat,+id:U32,state:Col.State<F.Schema,F.Payload>) -> List<&2,U32>:
  match state:
    case Col.State{values,stamps,capacity,_,_,remaining,past}: captured(id,C.capture_seek(~F.Schema,~F.Payload,fuel,values,stamps,capacity,id,remaining,past,Col.Inspect{}))
def old_result(+id:U32,stamp:L.Stamp,result:Col.SwapOutcome<F.Schema,F.Payload>) -> List<&2,U32>:
  match stamp result:
    case _ Col.Rejected{column,_}: restored(id,[1],column)
    case L.Stamp{a,b} Col.Accepted{column,owner}: restored(id,P.previous([0,id,a,b],owner),column)
def seek_old(+fuel:Nat,+id:U32,state:Col.State<F.Schema,F.Payload>) -> List<&2,U32>:
  match state:
    case Col.State{values,+stamps,capacity,_,_,remaining,past}: old_result(id,L.get(stamps,id),Col.seek(~F.Schema,~F.Payload,fuel,values,stamps,capacity,id,None{},remaining,past,Col.Inspect{}))
def seek_control(+fuel:Nat,+id:U32,isnew:Bool,column:Col.Column<F.Schema,F.Payload>) -> List<&2,U32>:
  match isnew column:
    case True{} Col.Prepared{carrier}: seek_new(fuel,id,Col.unseal(~F.Schema,~F.Payload,carrier))
    case False{} Col.Prepared{carrier}: seek_old(fuel,id,Col.unseal(~F.Schema,~F.Payload,carrier))
    case _ _: []
def seek_pair(+fuel:Nat,+id:U32) -> List<&2,List<&2,U32>>:
  [seek_control(fuel,id,False{},P.column(True{},False{})),seek_control(fuel,id,True{},P.column(True{},False{}))]
def wrap(fuel:Nat,carrier:Col.Carrier<F.Schema,F.Payload>) -> Col.Carrier<F.Schema,F.Payload>:
  match fuel:
    case 0n: carrier
    case 1n+rest: Col.Wrapped{wrap(rest,carrier)}
def deep(column:Col.Column<F.Schema,F.Payload>) -> Col.Column<F.Schema,F.Payload>:
  match column:
    case Col.Prepared{carrier}: Col.Prepared{wrap(32n,carrier)}
    case other: other
def backward(result:Col.Column<F.Schema,F.Payload> & Maybe<&2,F.View>) -> List<&2,U32>:
  match result:
    case (column,_): unchanged(1,C.capture(~F.Schema,~F.Payload,column,1))
def main() -> IO(Unit):
  IO.print(List.show(&2,List<&2,U32>,(xs => List.show(&2,U32,U32.show,xs)),List.append(&2,List<&2,U32>,[unchanged(1,C.capture(~F.Schema,~F.Payload,deep(P.column(True{},False{})),1)),backward(Col.view(~F.Schema,~F.Payload,~F.View,~F.project,P.column(True{},False{}),2)),unchanged(1,C.capture(~F.Schema,~F.Payload,P.column(False{},False{}),1)),unchanged(1,C.capture(~F.Schema,~F.Payload,P.column(True{},False{}),1)),projection(C.capture(~F.Schema,~F.Payload,P.column(False{},False{}),1)),projection(C.capture(~F.Schema,~F.Payload,P.column(True{},False{}),1)),dirty(C.capture(~F.Schema,~F.Payload,P.column(False{},False{}),1)),dirty(C.capture(~F.Schema,~F.Payload,P.column(True{},False{}),1)),unchanged(0,C.capture(~F.Schema,~F.Payload,P.column(True{},False{}),0)),unchanged(3,C.capture(~F.Schema,~F.Payload,P.column(False{},False{}),3)),projection(C.capture(~F.Schema,~F.Payload,P.column(True{},True{}),2))],List.append(&2,List<&2,U32>,seek_pair(0n,1),List.append(&2,List<&2,U32>,seek_pair(1n,1),List.append(&2,List<&2,U32>,seek_pair(2n,1),List.append(&2,List<&2,U32>,seek_pair(3n,2),List.append(&2,List<&2,U32>,seek_pair(4n,2),seek_pair(5n,3)))))))))
