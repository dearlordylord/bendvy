import Base
import ../../src/ecs/column.bend as Col
type Schema is Data:
  Schema{}
type View is Data:
  View{first:U32,second:U32}
def view_show(view:View) -> String:
  match view:
    case View{first,second}: "[" ++ U32.show(first) ++ "," ++ U32.show(second) ++ "]"
type Payload is Type:
  Payload{values:Array<U32>}
def nested(depth:Nat,carrier:Col.Carrier<Schema,Payload>) -> Col.Carrier<Schema,Payload>:
  match depth:
    case 0n: carrier
    case 1n+rest: Col.Wrapped{nested(rest,carrier)}
def wrapped(column:Col.Column<Schema,Payload>) -> Col.Column<Schema,Payload>:
  match column:
    case Col.Prepared{carrier}: Col.Prepared{nested(64n,carrier)}
    case other: other
def projected(+first:U32,result:Array<U32> & U32) -> Payload & View:
  match result:
    case (values,second): (Payload{values},View{first,second})
def first_read(result:Array<U32> & U32) -> Payload & View:
  match result:
    case (values,first): projected(first,Array.get(U32,values,1))
def project(owner:Payload) -> Payload & View:
  match owner:
    case Payload{values}: first_read(Array.get(U32,values,0))
def val(value:Maybe<&2,View>) -> View:
  match value:
    case None{}: View{999,999}
    case Some{value}: value
def grown_second(+points:List<&2,View>,result:Col.Column<Schema,Payload> & Maybe<&2,View>) -> List<&2,View>:
  match result:
    case (_,value): List.append(&2,View,points,[val(value)])
def grown_first(+points:List<&2,View>,result:Col.Column<Schema,Payload> & Maybe<&2,View>) -> List<&2,View>:
  match result:
    case (column,value): grown_second(List.append(&2,View,points,[val(value)]),Col.view(~Schema,~Payload,~View,~project,column,2))
def after_growth(+points:List<&2,View>,result:Col.Column<Schema,Payload> & Maybe<&2,View>) -> List<&2,View>:
  match result:
    case (column,value): grown_first(List.append(&2,View,points,[val(value)]),Col.view(~Schema,~Payload,~View,~project,column,1))
def grow_written(+points:List<&2,View>,result:Col.SwapOutcome<Schema,Payload>) -> List<&2,View>:
  match result:
    case Col.Accepted{column,_}: after_growth(points,Col.view(~Schema,~Payload,~View,~project,Col.recover(~Schema,~Payload,column),4))
    case Col.Rejected{column,_}: []
def backwards_read(+points:List<&2,View>,result:Col.Column<Schema,Payload> & Maybe<&2,View>) -> List<&2,View>:
  match result:
    case (column,value): grow_written(List.append(&2,View,points,[val(value)]),Col.swap(~Schema,~Payload,Col.ensure(~Schema,~Payload,wrapped(Col.prepare(~Schema,~Payload,column)),4),4,Some{Payload{ANode{ALeaf{100},ALeaf{200}}}}))
def second_read(+points:List<&2,View>,result:Col.Column<Schema,Payload> & Maybe<&2,View>) -> List<&2,View>:
  match result:
    case (column,value): backwards_read(List.append(&2,View,points,[val(value)]),Col.view(~Schema,~Payload,~View,~project,column,1))
def restored_old(+points:List<&2,View>,result:Col.SwapOutcome<Schema,Payload>) -> List<&2,View>:
  match result:
    case Col.Accepted{column,_}: second_read(points,Col.view(~Schema,~Payload,~View,~project,column,2))
    case _: []
def alias_read(+points:List<&2,View>,original:Maybe<&1,Payload>,result:Col.Column<Schema,Payload> & Maybe<&2,View>) -> List<&2,View>:
  match result:
    case (column,value): restored_old(List.append(&2,View,points,[val(value)]),Col.swap(~Schema,~Payload,column,1,original))
def replaced(+points:List<&2,View>,result:Col.SwapOutcome<Schema,Payload>) -> List<&2,View>:
  match result:
    case Col.Accepted{column,original}: alias_read(points,original,Col.view(~Schema,~Payload,~View,~project,column,1))
    case _: []
def initial(result:Col.Column<Schema,Payload> & Maybe<&2,View>) -> List<&2,View>:
  match result:
    case (column,value): replaced([val(value)],Col.swap(~Schema,~Payload,column,1,Some{Payload{ANode{ALeaf{41},ALeaf{43}}}}))
def main() -> IO(Unit):
  column:Col.Column<Schema,Payload> = Col.Column{ANode{ALeaf{Some{Payload{ANode{ALeaf{3},ALeaf{7}}}}},ALeaf{Some{Payload{ANode{ALeaf{11},ALeaf{19}}}}}},[]}
  IO.print(List.show(&2,View,view_show,grown_first([],Col.view(~Schema,~Payload,~View,~project,Col.recover(~Schema,~Payload,wrapped(Col.prepare(~Schema,~Payload,column))),1))))
