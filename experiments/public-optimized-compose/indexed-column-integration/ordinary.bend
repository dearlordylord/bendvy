import Base
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/lifecycle.bend as L
import ../../../src/ecs/captured-column.bend as K
import ../../../src/ecs/indexed-lifecycle.bend as M
import ../refusal-control.bend as P

def changed(result:P.Payload & P.View) -> P.Payload & P.View:
  match result:
    case (P.Payload{values},P.View{+first,+second}): (P.Payload{Array.set(U32,values,0,U32.add(first,1))},P.View{first,second})
def mutate(owner:P.Payload) -> P.Payload & P.View:
  changed(P.project(owner))
def payload(a:U32,b:U32) -> P.Payload:
  P.Payload{ANode{ALeaf{a},ALeaf{b}}}
def make(indexed:Bool) -> Col.Column<P.Schema,P.Payload>:
  match indexed:
    case False{}: Col.empty(~P.Schema,~P.Payload)
    case True{}: Col.empty_indexed(~P.Schema,~P.Payload)
def stamp_next(next:Col.Column<P.Schema,P.Payload> -> List<&2,U32>,result:Col.Column<P.Schema,P.Payload> & L.Stamp) -> List<&2,U32>:
  match result:
    case (column,L.Stamp{a,c}): List.append(&2,U32,[a,c],next(column))
def stamps(fuel:Nat,+id:U32,column:Col.Column<P.Schema,P.Payload>) -> List<&2,U32>:
  match fuel:
    case 0n: []
    case 1n+rest: stamp_next((column => stamps(rest,U32.add(id,1),column)),Col.lifecycle(~P.Schema,~P.Payload,column,id))
def observed(next:Col.Column<P.Schema,P.Payload> -> List<&2,U32>,result:Col.Column<P.Schema,P.Payload> & Maybe<&2,P.View>) -> List<&2,U32>:
  match result:
    case (column,None{}): List.append(&2,U32,[999,999],next(column))
    case (column,Some{P.View{a,b}}): List.append(&2,U32,[a,b],next(column))
def values(fuel:Nat,+id:U32,column:Col.Column<P.Schema,P.Payload>) -> List<&2,U32>:
  match fuel:
    case 0n: stamps(5n,0,column)
    case 1n+rest: observed((column => values(rest,U32.add(id,1),column)),Col.view(~P.Schema,~P.Payload,~P.View,~P.project,column,id))
def owner_view(result:P.Payload & P.View) -> List<&2,U32>:
  match result:
    case (_,P.View{a,b}): [a,b]
def value_owner(owner:Maybe<&1,P.Payload>) -> List<&2,U32>:
  match owner:
    case None{}: [999,999]
    case Some{owner}: owner_view(P.project(owner))
def swapped(outcome:Col.SwapOutcome<P.Schema,P.Payload>) -> List<&2,U32>:
  match outcome:
    case Col.Accepted{column,old}: List.append(&2,U32,[0],List.append(&2,U32,value_owner(old),values(4n,1,column)))
    case Col.Rejected{column,incoming}: List.append(&2,U32,[1],List.append(&2,U32,value_owner(incoming),values(4n,1,column)))
def inserted(outcome:Col.SwapOutcome<P.Schema,P.Payload>) -> Col.Column<P.Schema,P.Payload>:
  match outcome:
    case Col.Accepted{column,_}: column
    case Col.Rejected{column,_}: column
def setup(indexed:Bool) -> Col.Column<P.Schema,P.Payload>:
  inserted(Col.swap(~P.Schema,~P.Payload,Col.ensure(~P.Schema,~P.Payload,make(indexed),4),1,Some{payload(3,7)}))
def seeded(indexed:Bool) -> Col.Column<P.Schema,P.Payload>:
  Col.restore_stamp(~P.Schema,~P.Payload,Col.restore_stamp(~P.Schema,~P.Payload,setup(indexed),3,L.Stamp{0,11}),0,L.Stamp{13,0})
def read_only(indexed:Bool,+id:U32) -> List<&2,U32>:
  observed((column => values(4n,1,column)),Col.view(~P.Schema,~P.Payload,~P.View,~mutate,seeded(indexed),id))
def swap_case(indexed:Bool,+id:U32) -> List<&2,U32>:
  swapped(Col.swap(~P.Schema,~P.Payload,seeded(indexed),id,Some{payload(17,19)}))
def mark_case(indexed:Bool,incoming:Bool,was:Bool) -> List<&2,U32>:
  values(4n,1,Col.mark(~P.Schema,~P.Payload,seeded(indexed),1,incoming,was,23))
def clear_case(indexed:Bool) -> List<&2,U32>:
  swapped(Col.clear(~P.Schema,~P.Payload,Col.restore_stamp(~P.Schema,~P.Payload,seeded(indexed),1,L.Stamp{5,9}),1))
def exceptional_next(column:Col.Column<P.Schema,P.Payload>) -> List<&2,U32>:
  stamp_next((column => stamp_next((column => values(4n,1,column)),Col.lifecycle(~P.Schema,~P.Payload,column,4294967295))),Col.lifecycle(~P.Schema,~P.Payload,column,131073))
def exceptional(indexed:Bool) -> List<&2,U32>:
  exceptional_next(Col.restore_stamp(~P.Schema,~P.Payload,Col.restore_stamp(~P.Schema,~P.Payload,seeded(indexed),4294967295,L.Stamp{29,31}),131073,L.Stamp{37,41}))
def high_next(column:Col.Column<P.Schema,P.Payload>) -> List<&2,U32>:
  stamp_next((column => values(4n,1,column)),Col.lifecycle(~P.Schema,~P.Payload,column,131072))
def high(indexed:Bool) -> List<&2,U32>:
  high_next(Col.restore_stamp(~P.Schema,~P.Payload,seeded(indexed),131072,L.Stamp{43,47}))
def prepared_identity() -> List<&2,U32>:
  values(4n,1,Col.recover(~P.Schema,~P.Payload,Col.prepare(~P.Schema,~P.Payload,seeded(True{}))))
def capture_unavailable(result:K.Capture<P.Schema,P.Payload>) -> List<&2,U32>:
  match result:
    case K.Unavailable{column}: List.append(&2,U32,[0],values(4n,1,column))
    case K.Captured{_,owner,stamp,restore}: List.append(&2,U32,[0],values(4n,1,restore(K.Slot{owner,stamp,False{}})))
def wrapped() -> List<&2,U32>:
  values(4n,1,Col.Indexed{Col.IndexedOrdinaryWrapped{Col.IndexedOrdinaryWrapped{Col.IndexedOrdinaryOwned{Col.IndexedOrdinaryState{ANode{ANode{ALeaf{Some{payload(3,7)}},ALeaf{None{}}},ANode{ALeaf{None{}},ALeaf{None{}}}},M.empty()}}}}})

def main() -> IO(Unit):
  IO.print(List.show(&2,List<&2,U32>,(xs => List.show(&2,U32,U32.show,xs)),[
    read_only(False{},0),
    read_only(True{},0),
    read_only(False{},1),
    read_only(True{},1),
    read_only(False{},2),
    read_only(True{},2),
    read_only(False{},5),
    read_only(True{},5),
    swap_case(False{},0),
    swap_case(True{},0),
    swap_case(False{},1),
    swap_case(True{},1),
    swap_case(False{},2),
    swap_case(True{},2),
    swap_case(False{},5),
    swap_case(True{},5),
    swap_case(False{},131073),
    swap_case(True{},131073),
    mark_case(False{},True{},False{}),
    mark_case(True{},True{},False{}),
    mark_case(False{},True{},True{}),
    mark_case(True{},True{},True{}),
    mark_case(False{},False{},True{}),
    mark_case(True{},False{},True{}),
    clear_case(False{}),
    clear_case(True{}),
    exceptional(False{}),
    exceptional(True{}),
    high(False{}),
    high(True{}),
    prepared_identity(),
    values(4n,1,seeded(True{})),
    capture_unavailable(K.capture(~P.Schema,~P.Payload,seeded(True{}),1)),
    wrapped(),
    values(4n,1,setup(True{}))
  ]))
