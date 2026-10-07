import Base
import refusal-control.bend as P
import ../../src/ecs/column.bend as Col
import ../../src/ecs/owner-handoff.bend as H
def cells(view:P.View) -> List<&2,U32>:
  match view:
    case P.View{first,second}: [first,second]
def physical_payload(next:Array<Maybe<&1,P.Payload>> -> List<&2,U32>,values:Array<Maybe<&1,P.Payload>>,result:P.Payload & P.View) -> List<&2,U32>:
  match result:
    case (_,view): List.append(&2,U32,cells(view),next(values))
def physical_taken(next:Array<Maybe<&1,P.Payload>> -> List<&2,U32>,result:Array<Maybe<&1,P.Payload>> & Maybe<&1,P.Payload>) -> List<&2,U32>:
  match result:
    case (values,None{}): List.append(&2,U32,[999,999],next(values))
    case (values,Some{owner}): physical_payload(next,values,P.project(owner))
def physical(fuel:Nat,+id:U32,values:Array<Maybe<&1,P.Payload>>) -> List<&2,U32>:
  match fuel:
    case 0n: []
    case 1n+rest: physical_taken((values => physical(rest,U32.add(id,1),values)),Array.swap(Maybe<&1,P.Payload>,values,U32.sub(id,1),None{}))
def recovered(+points:List<&2,U32>,column:Col.Column<P.Schema,P.Payload>) -> List<&2,U32>:
  match column:
    case Col.Column{values,_}: List.append(&2,U32,points,physical(4n,1,values))
    case _: []
def projected(+points:List<&2,U32>,column:Col.Column<P.Schema,P.Payload>,result:P.Payload & P.View) -> List<&2,U32>:
  match result:
    case (_,view): recovered(List.append(&2,U32,points,cells(view)),Col.recover(~P.Schema,~P.Payload,column))
def observed_view(result:Col.Column<P.Schema,P.Payload> & Maybe<&2,P.View>) -> List<&2,U32>:
  match result:
    case (column,None{}): recovered([1,999,999],Col.recover(~P.Schema,~P.Payload,column))
    case (column,Some{view}): recovered(List.append(&2,U32,[0],cells(view)),Col.recover(~P.Schema,~P.Payload,column))
def changed_projected(result:P.Payload & P.View) -> P.Payload & P.View:
  match result:
    case (P.Payload{values},P.View{+first,+second}): (P.Payload{Array.set(U32,values,0,U32.add(first,1))},P.View{first,second})
def changed_project(owner:P.Payload) -> P.Payload & P.View:
  changed_projected(P.project(owner))
def rows() -> H.PrototypeHandoffRows<P.Schema,P.Payload>:
  H.HandoffCon{1,P.Payload{ANode{ALeaf{3},ALeaf{7}}},H.HandoffCon{3,P.Payload{ANode{ALeaf{11},ALeaf{19}}},H.HandoffNil{}}}
def execute(~project:P.Payload -> P.Payload & P.View,legacy:Bool,+fuel:Nat,+target:U32) -> List<&2,U32>:
  match legacy:
    case True{}: observed_view(Col.view_taken(~P.Schema,~P.Payload,~P.View,~project,target,Col.seek(~P.Schema,~P.Payload,fuel,Col.absent(~P.Payload,2n),[],4,target,None{},rows(),Col.HistoryNil{},Col.Inspect{})))
    case False{}: observed_view(Col.seek_view(~P.Schema,~P.Payload,~P.View,~project,fuel,Col.absent(~P.Payload,2n),[],4,target,rows(),Col.HistoryNil{},Col.Inspect{}))
def probe(changes:Bool,legacy:Bool,+fuel:Nat,+target:U32) -> List<&2,U32>:
  match changes:
    case False{}: execute(~P.project,legacy,fuel,target)
    case True{}: execute(~changed_project,legacy,fuel,target)
def nil_probe(legacy:Bool,+fuel:Nat) -> List<&2,U32>:
  match legacy:
    case True{}: observed_view(Col.view_taken(~P.Schema,~P.Payload,~P.View,~changed_project,2,Col.seek(~P.Schema,~P.Payload,fuel,Col.absent(~P.Payload,2n),[],4,2,None{},H.HandoffNil{},Col.HistoryNil{},Col.Inspect{})))
    case False{}: observed_view(Col.seek_view(~P.Schema,~P.Payload,~P.View,~changed_project,fuel,Col.absent(~P.Payload,2n),[],4,2,H.HandoffNil{},Col.HistoryNil{},Col.Inspect{}))
def main() -> IO(Unit):
  IO.print(List.show(&2,List<&2,U32>,(xs => List.show(&2,U32,U32.show,xs)),[
    probe(False{},True{},0n,1),
    probe(False{},False{},0n,1),
    probe(False{},True{},0n,2),
    probe(False{},False{},0n,2),
    probe(False{},True{},0n,3),
    probe(False{},False{},0n,3),
    probe(False{},True{},0n,4),
    probe(False{},False{},0n,4),
    probe(False{},True{},1n,1),
    probe(False{},False{},1n,1),
    probe(False{},True{},1n,2),
    probe(False{},False{},1n,2),
    probe(False{},True{},1n,3),
    probe(False{},False{},1n,3),
    probe(False{},True{},1n,4),
    probe(False{},False{},1n,4),
    probe(False{},True{},2n,1),
    probe(False{},False{},2n,1),
    probe(False{},True{},2n,2),
    probe(False{},False{},2n,2),
    probe(False{},True{},2n,3),
    probe(False{},False{},2n,3),
    probe(False{},True{},2n,4),
    probe(False{},False{},2n,4),
    probe(False{},True{},3n,1),
    probe(False{},False{},3n,1),
    probe(False{},True{},3n,2),
    probe(False{},False{},3n,2),
    probe(False{},True{},3n,3),
    probe(False{},False{},3n,3),
    probe(False{},True{},3n,4),
    probe(False{},False{},3n,4),
    probe(False{},True{},4n,1),
    probe(False{},False{},4n,1),
    probe(False{},True{},4n,2),
    probe(False{},False{},4n,2),
    probe(False{},True{},4n,3),
    probe(False{},False{},4n,3),
    probe(False{},True{},4n,4),
    probe(False{},False{},4n,4),
    probe(False{},True{},5n,1),
    probe(False{},False{},5n,1),
    probe(False{},True{},5n,2),
    probe(False{},False{},5n,2),
    probe(False{},True{},5n,3),
    probe(False{},False{},5n,3),
    probe(False{},True{},5n,4),
    probe(False{},False{},5n,4),
    probe(True{},True{},0n,1),
    probe(True{},False{},0n,1),
    probe(True{},True{},0n,2),
    probe(True{},False{},0n,2),
    probe(True{},True{},0n,3),
    probe(True{},False{},0n,3),
    probe(True{},True{},0n,4),
    probe(True{},False{},0n,4),
    probe(True{},True{},1n,1),
    probe(True{},False{},1n,1),
    probe(True{},True{},1n,2),
    probe(True{},False{},1n,2),
    probe(True{},True{},1n,3),
    probe(True{},False{},1n,3),
    probe(True{},True{},1n,4),
    probe(True{},False{},1n,4),
    probe(True{},True{},2n,1),
    probe(True{},False{},2n,1),
    probe(True{},True{},2n,2),
    probe(True{},False{},2n,2),
    probe(True{},True{},2n,3),
    probe(True{},False{},2n,3),
    probe(True{},True{},2n,4),
    probe(True{},False{},2n,4),
    probe(True{},True{},3n,1),
    probe(True{},False{},3n,1),
    probe(True{},True{},3n,2),
    probe(True{},False{},3n,2),
    probe(True{},True{},3n,3),
    probe(True{},False{},3n,3),
    probe(True{},True{},3n,4),
    probe(True{},False{},3n,4),
    probe(True{},True{},4n,1),
    probe(True{},False{},4n,1),
    probe(True{},True{},4n,2),
    probe(True{},False{},4n,2),
    probe(True{},True{},4n,3),
    probe(True{},False{},4n,3),
    probe(True{},True{},4n,4),
    probe(True{},False{},4n,4),
    probe(True{},True{},5n,1),
    probe(True{},False{},5n,1),
    probe(True{},True{},5n,2),
    probe(True{},False{},5n,2),
    probe(True{},True{},5n,3),
    probe(True{},False{},5n,3),
    probe(True{},True{},5n,4),
    probe(True{},False{},5n,4),
    nil_probe(True{},0n),
    nil_probe(False{},0n),
    nil_probe(True{},1n),
    nil_probe(False{},1n),
    nil_probe(True{},5n),
    nil_probe(False{},5n)]))
