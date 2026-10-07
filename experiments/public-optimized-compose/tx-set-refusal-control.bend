import Base
import refusal-control.bend as P
import ../../src/ecs/column.bend as Col
import ../../src/ecs/component.bend as C
import ../../src/ecs/world.bend as W
import ../../src/ecs/transaction.bend as T
import ../../src/ecs/lifecycle.bend as L
type Token is Data:
  Token{}
def Store() -> Type:
  Col.Column<P.Schema,P.Payload>
def World() -> Type:
  W.World<P.Schema,Store(),Unit,Unit>
def take(store:Store()) -> Unit & Store():
  (Unit{},store)
def put(rest:Unit,store:Store()) -> Store():
  store
def error(error:W.WorldError) -> U32:
  match error:
    case W.MissingEntity{}: 1
    case _: 2
def cells(view:P.View) -> List<&2,U32>:
  match view:
    case P.View{first,second}: [first,second]
def observed(+points:List<&2,U32>,+stamp:L.Stamp,result:Store() & Maybe<&2,P.View>) -> List<&2,U32>:
  match stamp result:
    case L.Stamp{added,changed}, (_,view): List.append(&2,U32,points,List.append(&2,U32,cells(P.val(view)),[added,changed]))
def stamped(+points:List<&2,U32>,result:Store() & L.Stamp) -> List<&2,U32>:
  match result:
    case (column,stamp): observed(points,stamp,Col.view(~P.Schema,~P.Payload,~P.View,~P.project,Col.recover(~P.Schema,~P.Payload,column),1))
def incoming_view(+points:List<&2,U32>,column:Store(),result:P.Payload & P.View) -> List<&2,U32>:
  match result:
    case (_,view): stamped(List.append(&2,U32,points,cells(view)),Col.lifecycle(~P.Schema,~P.Payload,column,1))
def refused(+code:U32,incoming:P.Payload,tx:T.Tx<World(),Unit>) -> List<&2,U32>:
  match tx:
    case T.Tx{W.World{_,_,_,_,_,_,column,_,worldEvents,pending,_,_,clock},undo,commands,events}: incoming_view([code,clock,U32.from_nat(List.length(&1,(World() -> World()),undo)),U32.from_nat(List.length(&1,(World() -> World()),commands)),U32.from_nat(List.length(&2,Unit,events)),U32.from_nat(List.length(&1,(World() -> World()),pending)),U32.from_nat(List.length(&2,Unit,worldEvents))],column,P.project(incoming))
def result(outcome:C.SetResult<T.Tx<World(),Unit>,P.Payload>) -> List<&2,U32>:
  match outcome:
    case C.WriteRejected{tx,incoming,reason}: refused(error(reason),incoming,tx)
    case _: []
def execute(legacy:Bool,+namespace:U32,+id:U32,+family:C.Family<P.Schema,Store(),Unit,P.Payload,P.View,Token,take,put,P.project>,world:World()) -> List<&2,U32>:
  match legacy:
    case True{}: result(C.tx_set_stamped(~P.Schema,~Store(),~Unit,~Unit,~Unit,~P.Payload,~P.View,~Token,~take,~put,~P.project,family,W.Handle{namespace,id},[],[world => world],[Unit{}],P.Payload{ANode{ALeaf{41},ALeaf{43}}},C.lifecycle(~P.Schema,~Store(),~Unit,~Unit,~Unit,~P.Payload,~P.View,~Token,~take,~put,~P.project,family,world,W.Handle{namespace,id})))
    case False{}: result(C.tx_set(~P.Schema,~Store(),~Unit,~Unit,~Unit,~P.Payload,~P.View,~Token,~take,~put,~P.project,family,T.Tx{world,[],[world => world],[Unit{}]},W.Handle{namespace,id},P.Payload{ANode{ALeaf{41},ALeaf{43}}}))
def probe(legacy:Bool,+clock:U32,+namespace:U32,+id:U32,+depth:Nat) -> List<&2,U32>:
  column:Store() = Col.prepare(~P.Schema,~P.Payload,Col.Column{ALeaf{Some{P.Payload{ANode{ALeaf{3},ALeaf{7}}}}},[L.Entry{1,L.Stamp{5,9}}]})
  world:World() = W.World{1,131074,131073,Array.new(Bool,depth,True{}),262144,18n,column,Unit{},[Unit{}],[world => world],[],1,clock}
  +family:C.Family<P.Schema,Store(),Unit,P.Payload,P.View,Token,take,put,P.project> = C.Family{"payload"}
  execute(legacy,namespace,id,family,world)
def main() -> IO(Unit):
  IO.print(List.show(&2,List<&2,U32>,(xs => List.show(&2,U32,U32.show,xs)),[probe(False{},4294967295,2,1,1n),probe(True{},4294967295,2,1,1n),probe(False{},4294967295,1,1,1n),probe(True{},4294967295,1,1,1n),probe(False{},7,1,131073,18n),probe(True{},7,1,131073,18n)]))
