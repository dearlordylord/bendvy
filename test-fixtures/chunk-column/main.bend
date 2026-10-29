import Base
import ../../src/ecs/chunk-column.bend as C

type Schema is Data:
  Schema{}
type Payload is Type:
  Payload{token:Array<U32>,value:U32}
def payload(token:U32,value:U32) -> Payload:
  Payload{ALeaf{token},value}
def projected(+value:U32,result:Array<U32> & U32) -> Payload & String:
  match result:
    case (token,+id): (Payload{token,value},U32.show(id) ++ ":" ++ U32.show(value))
def project(owner:Payload) -> Payload & String:
  match owner:
    case Payload{token,+value}: projected(value,Array.get(U32,token,0))
def increment(owner:Payload) -> Payload & String:
  match owner:
    case Payload{token,+value}: projected(U32.add(value,1),Array.get(U32,token,0))
def inserted(result:C.SwapOutcome<Schema,Payload>) -> C.Column<Schema,Payload>:
  match result:
    case C.Accepted{column,_}: column
    case C.Rejected{column,_}: column
def observed(result:C.Column<Schema,Payload> & Maybe<&2,String>) -> C.Column<Schema,Payload> & String:
  match result:
    case (column,None{}): (column,"empty")
    case (column,Some{text}): (column,text)
def snapshots_empty(first:String,second:String,result:C.Column<Schema,Payload> & String) -> String:
  match result:
    case (column,missing): first ++ "," ++ second ++ "," ++ missing
def snapshots_second(first:String,result:C.Column<Schema,Payload> & String) -> String:
  match result:
    case (column,second): snapshots_empty(first,second,observed(C.view(~Schema,~Payload,~String,~project,column,8)))
def snapshots_first(result:C.Column<Schema,Payload> & String) -> String:
  match result:
    case (column,first): snapshots_second(first,observed(C.view(~Schema,~Payload,~String,~project,column,17)))
def snapshots(column:C.Column<Schema,Payload>) -> String:
  snapshots_first(observed(C.view(~Schema,~Payload,~String,~project,column,1)))
def changed(result:C.Column<Schema,Payload> & Maybe<&2,String>) -> String:
  match result:
    case (column,_): snapshots(column)
def main() -> IO(Unit):
  IO.print(changed(C.modify(~Schema,~Payload,~String,~increment,inserted(C.swap(~Schema,~Payload,inserted(C.swap(~Schema,~Payload,C.ensure(~Schema,~Payload,C.empty(~Schema,~Payload),24),1,Some{payload(101,10)})),17,Some{payload(202,20)})),17)))
