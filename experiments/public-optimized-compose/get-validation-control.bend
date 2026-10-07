import Base
import refusal-control.bend as P
import view-fuel-control.bend as V
import ../../src/ecs/component.bend as C
import ../../src/ecs/column.bend as Col
import ../../src/ecs/world.bend as W
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
def access(value:C.Access<P.View>) -> List<&2,U32>:
  match value:
    case C.MissingEntity{}: [2,999,999]
    case C.ComponentAbsent{}: [1,999,999]
    case C.Found{P.View{a,b}}: [0,a,b]
def flag_number(flag:Bool) -> U32:
  match flag:
    case True{}: 1
    case False{}: 0
def live_observed(+points:List<&2,U32>,column:Store(),observed:Array<Bool> & Bool) -> List<&2,U32>:
  match observed:
    case (_,flag): V.recovered(List.append(&2,U32,points,[flag_number(flag)]),Col.recover(~P.Schema,~P.Payload,column))
def observed(result:World() & C.Access<P.View>) -> List<&2,U32>:
  match result:
    case (W.World{ns,next,high,live,capacity,depth,column,_,events,pending,registrations,system,clock},value): live_observed(List.append(&2,U32,access(value),[ns,next,high,capacity,U32.from_nat(depth),U32.from_nat(List.length(&2,Unit,events)),U32.from_nat(List.length(&1,(World() -> World()),pending)),U32.from_nat(List.length(&2,W.RegistrationMeta,registrations)),system,clock]),column,Array.get(Bool,live,1))
def execute(~project:P.Payload -> P.Payload & P.View,legacy:Bool,world:World(),+handle:W.Handle<P.Schema>) -> List<&2,U32>:
  match legacy:
    case True{}: observed(C.get_allowed(~P.Schema,~Store(),~Unit,~Unit,~Unit,~P.Payload,~P.View,~Token,~take,~put,~project,W.valid(~P.Schema,~Store(),~Unit,~Unit,world,handle),handle))
    case False{}: observed(C.get(~P.Schema,~Store(),~Unit,~Unit,~Unit,~P.Payload,~P.View,~Token,~take,~put,~project,C.Family{"payload"},world,handle))
def prepare(prepared:Bool,column:Store()) -> Store():
  match prepared:
    case False{}: column
    case True{}: Col.prepare(~P.Schema,~P.Payload,column)
def choose(changed:Bool,legacy:Bool,world:World(),+handle:W.Handle<P.Schema>) -> List<&2,U32>:
  match changed:
    case False{}: execute(~P.project,legacy,world,handle)
    case True{}: execute(~V.changed_project,legacy,world,handle)
def probe_column(legacy:Bool,changed:Bool,+namespace:U32,+id:U32,live:Bool,column:Store()) -> List<&2,U32>:
  world:World() = W.World{1,4,3,Array.set(Bool,Array.new(Bool,2n,False{}),1,live),4,2n,column,Unit{},[Unit{},Unit{}],[world => world],[],7,13}
  choose(changed,legacy,world,W.Handle{namespace,id})
def probe(legacy:Bool,changed:Bool,prepared:Bool,+namespace:U32,+id:U32,live:Bool) -> List<&2,U32>:
  column:Store() = Col.Column{ANode{ANode{ALeaf{Some{P.Payload{ANode{ALeaf{3},ALeaf{7}}}}},ALeaf{None{}}},ANode{ALeaf{Some{P.Payload{ANode{ALeaf{11},ALeaf{19}}}}},ALeaf{None{}}}},[]}
  probe_column(legacy,changed,namespace,id,live,prepare(prepared,column))
def main() -> IO(Unit):
  IO.print(List.show(&2,List<&2,U32>,(xs => List.show(&2,U32,U32.show,xs)),[
    probe(True{},False{},False{},2,1,True{}),
    probe(False{},False{},False{},2,1,True{}),
    probe(True{},False{},False{},1,0,True{}),
    probe(False{},False{},False{},1,0,True{}),
    probe(True{},False{},False{},1,4,True{}),
    probe(False{},False{},False{},1,4,True{}),
    probe(True{},False{},False{},1,3,False{}),
    probe(False{},False{},False{},1,3,False{}),
    probe(True{},False{},False{},1,1,False{}),
    probe(False{},False{},False{},1,1,False{}),
    probe(True{},False{},False{},1,1,True{}),
    probe(False{},False{},False{},1,1,True{}),
    probe(True{},True{},False{},2,1,True{}),
    probe(False{},True{},False{},2,1,True{}),
    probe(True{},True{},False{},1,0,True{}),
    probe(False{},True{},False{},1,0,True{}),
    probe(True{},True{},False{},1,4,True{}),
    probe(False{},True{},False{},1,4,True{}),
    probe(True{},True{},False{},1,3,False{}),
    probe(False{},True{},False{},1,3,False{}),
    probe(True{},True{},False{},1,1,False{}),
    probe(False{},True{},False{},1,1,False{}),
    probe(True{},True{},False{},1,1,True{}),
    probe(False{},True{},False{},1,1,True{}),
    probe(True{},False{},True{},2,1,True{}),
    probe(False{},False{},True{},2,1,True{}),
    probe(True{},False{},True{},1,0,True{}),
    probe(False{},False{},True{},1,0,True{}),
    probe(True{},False{},True{},1,4,True{}),
    probe(False{},False{},True{},1,4,True{}),
    probe(True{},False{},True{},1,3,False{}),
    probe(False{},False{},True{},1,3,False{}),
    probe(True{},False{},True{},1,1,False{}),
    probe(False{},False{},True{},1,1,False{}),
    probe(True{},False{},True{},1,1,True{}),
    probe(False{},False{},True{},1,1,True{}),
    probe(True{},True{},True{},2,1,True{}),
    probe(False{},True{},True{},2,1,True{}),
    probe(True{},True{},True{},1,0,True{}),
    probe(False{},True{},True{},1,0,True{}),
    probe(True{},True{},True{},1,4,True{}),
    probe(False{},True{},True{},1,4,True{}),
    probe(True{},True{},True{},1,3,False{}),
    probe(False{},True{},True{},1,3,False{}),
    probe(True{},True{},True{},1,1,False{}),
    probe(False{},True{},True{},1,1,False{}),
    probe(True{},True{},True{},1,1,True{}),
    probe(False{},True{},True{},1,1,True{})]))
