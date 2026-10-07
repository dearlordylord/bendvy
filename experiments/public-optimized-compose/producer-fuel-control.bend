import Base
import refusal-control.bend as P
import ../../src/ecs/column.bend as Col
import ../../src/ecs/owner-handoff.bend as H
def slots() -> Array<Maybe<&1,P.Payload>>:
  ANode{ANode{ALeaf{Some{P.Payload{ANode{ALeaf{3},ALeaf{7}}}}},ALeaf{None{}}},ANode{ALeaf{Some{P.Payload{ANode{ALeaf{11},ALeaf{19}}}}},ALeaf{None{}}}}
def cells(view:P.View) -> List<&2,U32>:
  match view:
    case P.View{first,second}: [first,second]
def row_projected(+id:U32,next:Unit -> List<&2,U32>,result:P.Payload & P.View) -> List<&2,U32>:
  match result:
    case (_,view): List.append(&2,U32,id <> cells(view),next(Unit{}))
def row_values(rows:H.PrototypeHandoffRows<P.Schema,P.Payload>) -> List<&2,U32>:
  match rows:
    case H.HandoffNil{}: []
    case H.HandoffCon{id,owner,rest}: row_projected(id,(unit => row_values(rest)),P.project(owner))
def physical_projected(next:Array<Maybe<&1,P.Payload>> -> List<&2,U32>,values:Array<Maybe<&1,P.Payload>>,result:P.Payload & P.View) -> List<&2,U32>:
  match result:
    case (_,view): List.append(&2,U32,cells(view),next(values))
def physical_taken(next:Array<Maybe<&1,P.Payload>> -> List<&2,U32>,result:Array<Maybe<&1,P.Payload>> & Maybe<&1,P.Payload>) -> List<&2,U32>:
  match result:
    case (values,None{}): List.append(&2,U32,[999,999],next(values))
    case (values,Some{owner}): physical_projected(next,values,P.project(owner))
def physical(fuel:Nat,+id:U32,values:Array<Maybe<&1,P.Payload>>) -> List<&2,U32>:
  match fuel:
    case 0n: []
    case 1n+rest: physical_taken((values => physical(rest,U32.add(id,1),values)),Array.swap(Maybe<&1,P.Payload>,values,U32.sub(id,1),None{}))
def observed(result:Array<Maybe<&1,P.Payload>> & H.PrototypeHandoffRows<P.Schema,P.Payload>) -> List<&2,U32>:
  match result:
    case (values,rows): List.append(&2,U32,row_values(rows),777 <> physical(4n,1,values))
def initial() -> H.PrototypeHandoffRows<P.Schema,P.Payload>:
  H.HandoffCon{9,P.Payload{ANode{ALeaf{31},ALeaf{37}}},H.HandoffNil{}}
def original_function_type() -> @+fuel:Nat -> U32 -> Array<Maybe<&1,P.Payload>> -> H.PrototypeHandoffRows<P.Schema,P.Payload> -> Array<Maybe<&1,P.Payload>> & H.PrototypeHandoffRows<P.Schema,P.Payload>:
  Col.evacuate(~P.Schema,~P.Payload)
def probe(legacy:Bool,+fuel:Nat,+id:U32) -> List<&2,U32>:
  match legacy:
    case True{}: observed(Col.evacuate_phase(~P.Schema,~P.Payload,1n+Nat.add(fuel,fuel),Col.Fetch{fuel,id,slots(),initial()}))
    case False{}: observed(original_function_type()(fuel,id,slots(),initial()))
def main() -> IO(Unit):
  IO.print(List.show(&2,List<&2,U32>,(xs => List.show(&2,U32,U32.show,xs)),[
    probe(True{},0n,0),
    probe(False{},0n,0),
    probe(True{},0n,1),
    probe(False{},0n,1),
    probe(True{},0n,2),
    probe(False{},0n,2),
    probe(True{},0n,3),
    probe(False{},0n,3),
    probe(True{},0n,4),
    probe(False{},0n,4),
    probe(True{},0n,5),
    probe(False{},0n,5),
    probe(True{},1n,0),
    probe(False{},1n,0),
    probe(True{},1n,1),
    probe(False{},1n,1),
    probe(True{},1n,2),
    probe(False{},1n,2),
    probe(True{},1n,3),
    probe(False{},1n,3),
    probe(True{},1n,4),
    probe(False{},1n,4),
    probe(True{},1n,5),
    probe(False{},1n,5),
    probe(True{},2n,0),
    probe(False{},2n,0),
    probe(True{},2n,1),
    probe(False{},2n,1),
    probe(True{},2n,2),
    probe(False{},2n,2),
    probe(True{},2n,3),
    probe(False{},2n,3),
    probe(True{},2n,4),
    probe(False{},2n,4),
    probe(True{},2n,5),
    probe(False{},2n,5),
    probe(True{},3n,0),
    probe(False{},3n,0),
    probe(True{},3n,1),
    probe(False{},3n,1),
    probe(True{},3n,2),
    probe(False{},3n,2),
    probe(True{},3n,3),
    probe(False{},3n,3),
    probe(True{},3n,4),
    probe(False{},3n,4),
    probe(True{},3n,5),
    probe(False{},3n,5),
    probe(True{},4n,0),
    probe(False{},4n,0),
    probe(True{},4n,1),
    probe(False{},4n,1),
    probe(True{},4n,2),
    probe(False{},4n,2),
    probe(True{},4n,3),
    probe(False{},4n,3),
    probe(True{},4n,4),
    probe(False{},4n,4),
    probe(True{},4n,5),
    probe(False{},4n,5),
    probe(True{},5n,0),
    probe(False{},5n,0),
    probe(True{},5n,1),
    probe(False{},5n,1),
    probe(True{},5n,2),
    probe(False{},5n,2),
    probe(True{},5n,3),
    probe(False{},5n,3),
    probe(True{},5n,4),
    probe(False{},5n,4),
    probe(True{},5n,5),
    probe(False{},5n,5),
    probe(True{},6n,0),
    probe(False{},6n,0),
    probe(True{},6n,1),
    probe(False{},6n,1),
    probe(True{},6n,2),
    probe(False{},6n,2),
    probe(True{},6n,3),
    probe(False{},6n,3),
    probe(True{},6n,4),
    probe(False{},6n,4),
    probe(True{},6n,5),
    probe(False{},6n,5)]))
