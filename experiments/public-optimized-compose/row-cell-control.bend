import Base
import refusal-control.bend as P
import ../../src/ecs/column.bend as Col
import ../../src/ecs/row-column.bend as R
import ../../src/ecs/lifecycle.bend as L

def cells(view:P.View) -> List<&2,U32>:
  match view:
    case P.View{a,b}: [a,b]
def incoming(points:List<&2,U32>,result:P.Payload & P.View) -> List<&2,U32>:
  match result:
    case (_,view): List.append(&2,U32,points,cells(view))
def previous(points:List<&2,U32>,owner:Maybe<&1,P.Payload>) -> List<&2,U32>:
  match owner:
    case None{}: List.append(&2,U32,points,[999,999])
    case Some{owner}: incoming(points,P.project(owner))
def physical_last(points:List<&2,U32>,result:Col.Column<P.Schema,P.Payload> & Maybe<&2,P.View>) -> List<&2,U32>:
  match result:
    case (_,view): List.append(&2,U32,points,cells(P.val(view)))
def physical_first(points:List<&2,U32>,result:Col.Column<P.Schema,P.Payload> & Maybe<&2,P.View>) -> List<&2,U32>:
  match result:
    case (column,view): physical_last(List.append(&2,U32,points,cells(P.val(view))),Col.view(~P.Schema,~P.Payload,~P.View,~P.project,column,2))
def physical_stamped(points:List<&2,U32>,result:Col.Column<P.Schema,P.Payload> & L.Stamp) -> List<&2,U32>:
  match result:
    case (column,L.Stamp{a,b}): physical_first(List.append(&2,U32,points,[a,b]),Col.view(~P.Schema,~P.Payload,~P.View,~P.project,Col.recover(~P.Schema,~P.Payload,column),1))
def observed(points:List<&2,U32>,result:Col.SwapOutcome<P.Schema,P.Payload>) -> List<&2,U32>:
  match result:
    case Col.Accepted{column,old}: physical_stamped(previous(List.append(&2,U32,points,[0]),old),Col.lifecycle(~P.Schema,~P.Payload,column,1))
    case Col.Rejected{column,held}: physical_stamped(previous(List.append(&2,U32,points,[1]),held),Col.lifecycle(~P.Schema,~P.Payload,column,1))
def changed(result:P.Payload & P.View) -> P.Payload & P.View:
  match result:
    case (P.Payload{values},P.View{+a,+b}): (P.Payload{Array.set(U32,values,0,U32.add(a,1))},P.View{a,b})
def mutate(owner:P.Payload) -> P.Payload & P.View:
  changed(P.project(owner))
def aliases_second(points:List<&2,U32>,result:R.Projected<P.Schema,P.Payload,P.View>) -> List<&2,U32>:
  match result:
    case R.Deferred{cell}: observed([777],R.attach(~P.Schema,~P.Payload,cell))
    case R.Projected{cell,view}: observed(List.append(&2,U32,points,cells(P.val(view))),R.attach(~P.Schema,~P.Payload,cell))
def aliases_first(result:R.Projected<P.Schema,P.Payload,P.View>) -> List<&2,U32>:
  match result:
    case R.Deferred{cell}: observed([777],R.attach(~P.Schema,~P.Payload,cell))
    case R.Projected{cell,view}: aliases_second(cells(P.val(view)),R.project(~P.Schema,~P.Payload,~P.View,~mutate,cell))
def wrap(fuel:Nat,cold:R.Cold<P.Schema,P.Payload>) -> R.Cold<P.Schema,P.Payload>:
  match fuel:
    case 0n: cold
    case 1n+rest: R.Wrapped{wrap(rest,cold)}
def wrapped(cell:R.Cell<P.Schema,P.Payload>) -> R.Cell<P.Schema,P.Payload>:
  match cell:
    case R.Taken{id,owner,stamp,dirty,cold}: R.Taken{id,owner,stamp,dirty,wrap(32n,cold)}
    case other: other
def second_write(points:List<&2,U32>,result:R.Replacement<P.Schema,P.Payload>) -> List<&2,U32>:
  match result:
    case R.Replaced{cell,old,L.Stamp{a,b}}: observed(previous(List.append(&2,U32,points,[a,b]),old),R.attach(~P.Schema,~P.Payload,cell))
    case R.Refused{cell,owner}: observed(incoming(points,P.project(owner)),R.attach(~P.Schema,~P.Payload,cell))
def first_write(result:R.Replacement<P.Schema,P.Payload>) -> List<&2,U32>:
  match result:
    case R.Replaced{cell,old,L.Stamp{a,b}}: second_write(previous([a,b],old),R.replace(~P.Schema,~P.Payload,cell,P.Payload{ANode{ALeaf{51},ALeaf{53}}},8))
    case R.Refused{cell,owner}: observed(incoming([],P.project(owner)),R.attach(~P.Schema,~P.Payload,cell))
def plain_column(hole:Bool) -> Col.Column<P.Schema,P.Payload>:
  match hole:
    case False{}: Col.Column{ANode{ALeaf{Some{P.Payload{ANode{ALeaf{3},ALeaf{7}}}}},ALeaf{Some{P.Payload{ANode{ALeaf{11},ALeaf{19}}}}}},[L.Entry{1,L.Stamp{5,9}}]}
    case True{}: Col.Column{ANode{ALeaf{Some{P.Payload{ANode{ALeaf{3},ALeaf{7}}}}},ALeaf{None{}}},[L.Entry{1,L.Stamp{5,9}}]}
def column(prepared:Bool,hole:Bool) -> Col.Column<P.Schema,P.Payload>:
  match prepared:
    case False{}: plain_column(hole)
    case True{}: Col.prepare(~P.Schema,~P.Payload,plain_column(hole))
def aliases(prepared:Bool,deep:Bool) -> List<&2,U32>:
  match deep:
    case False{}: aliases_first(R.project(~P.Schema,~P.Payload,~P.View,~mutate,R.detach(~P.Schema,~P.Payload,column(prepared,False{}),1)))
    case True{}: aliases_first(R.project(~P.Schema,~P.Payload,~P.View,~mutate,wrapped(R.detach(~P.Schema,~P.Payload,column(prepared,False{}),1))))
def write(prepared:Bool) -> List<&2,U32>:
  first_write(R.replace(~P.Schema,~P.Payload,R.detach(~P.Schema,~P.Payload,column(prepared,False{}),1),P.Payload{ANode{ALeaf{41},ALeaf{43}}},7))
def refusal(prepared:Bool,+id:U32) -> List<&2,U32>:
  observed([],R.attach(~P.Schema,~P.Payload,R.detach(~P.Schema,~P.Payload,column(prepared,False{}),id)))
def absent(prepared:Bool) -> List<&2,U32>:
  aliases_first(R.project(~P.Schema,~P.Payload,~P.View,~mutate,R.detach(~P.Schema,~P.Payload,column(prepared,True{}),2)))
def malformed(prepared:Bool,+id:U32,dirty:Bool) -> List<&2,U32>:
  observed([],R.attach(~P.Schema,~P.Payload,R.Taken{id,Some{P.Payload{ANode{ALeaf{41},ALeaf{43}}}},L.Stamp{5,17},dirty,R.Cold{column(prepared,False{})}}))
def partial_state(state:Col.State<P.Schema,P.Payload>) -> List<&2,U32>:
  match state:
    case Col.State{values,stamps,capacity,_,_,remaining,past}: observed([],R.attach(~P.Schema,~P.Payload,R.detached(~P.Schema,~P.Payload,1,L.Stamp{5,9},Col.seek(~P.Schema,~P.Payload,0n,values,stamps,capacity,1,Some{P.Payload{ANode{ALeaf{41},ALeaf{43}}}},remaining,past,Col.Inspect{}))))
def partial_column(column:Col.Column<P.Schema,P.Payload>) -> List<&2,U32>:
  match column:
    case Col.Prepared{carrier}: partial_state(Col.unseal(~P.Schema,~P.Payload,carrier))
    case _: []
def partial() -> List<&2,U32>:
  partial_column(column(True{},False{}))
def write_refusal() -> List<&2,U32>:
  first_write(R.replace(~P.Schema,~P.Payload,R.detach(~P.Schema,~P.Payload,column(True{},False{}),3),P.Payload{ANode{ALeaf{41},ALeaf{43}}},7))
def backward_view(result:Col.Column<P.Schema,P.Payload> & Maybe<&2,P.View>) -> List<&2,U32>:
  match result:
    case (column,view): physical_stamped(cells(P.val(view)),Col.lifecycle(~P.Schema,~P.Payload,column,1))
def backward_attached(result:Col.SwapOutcome<P.Schema,P.Payload>) -> List<&2,U32>:
  match result:
    case Col.Accepted{column,_}: backward_view(Col.view(~P.Schema,~P.Payload,~P.View,~P.project,column,1))
    case _: []
def backward() -> List<&2,U32>:
  backward_attached(R.attach(~P.Schema,~P.Payload,R.detach(~P.Schema,~P.Payload,column(True{},False{}),2)))
def main() -> IO(Unit):
  IO.print(List.show(&2,List<&2,U32>,(xs => List.show(&2,U32,U32.show,xs)),[aliases(False{},False{}),aliases(True{},False{}),aliases(True{},True{}),write(False{}),write(True{}),refusal(False{},0),refusal(True{},0),refusal(False{},3),refusal(True{},3),absent(False{}),absent(True{}),malformed(False{},0,False{}),malformed(True{},3,True{}),partial(),backward(),write_refusal(),malformed(False{},1,False{})]))
