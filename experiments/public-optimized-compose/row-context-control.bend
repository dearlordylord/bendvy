import Base
import extracted/row-context.bend as Row
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/component.bend as Cmp
type Payload is Type:
  Payload{values:Array<U32>}
type Rest is Type:
  Rest{values:Array<U32>}
type View is Data:
  View{first:U32,second:U32}
type Grants<-H:Type> is Type:
  Grants{write:Cap.Write<H,Payload,View>,alias:Cap.Read<H,View>}
def Ops(H:Type) -> Type:
  Grants<H>
def writer(~H:Type,grants:Grants<H>) -> Cap.Write<H,Payload,View>:
  match grants:
    case Grants{write,_}: write
def alias(~H:Type,grants:Grants<H>) -> Cap.Read<H,View>:
  match grants:
    case Grants{_,read}: read
def projected(first:U32,result:Array<U32> & U32) -> Payload & View:
  match result:
    case (values,second): (Payload{values},View{first,second})
def first_read(result:Array<U32> & U32) -> Payload & View:
  match result:
    case (values,first): projected(first,Array.get(U32,values,1))
def project(payload:Payload) -> Payload & View:
  match payload:
    case Payload{values}: first_read(Array.get(U32,values,0))
def alias_result(~H:Type,result:H & Cmp.Access<View>) -> H & U32:
  match result:
    case (ctx,Cmp.Found{View{first,second}}): (ctx,(first + second : U32))
    case (ctx,_): (ctx,0)
def body(~H:Type,~grants:Grants<H>,args:Unit,ctx:H) -> H & U32:
  next=Cap.set(~H,~Payload,~View,~writer(~H,grants),ctx,Payload{ANode{ALeaf{41},ALeaf{43}}})
  alias_result(~H,Cap.read(~H,~View,~alias(~H,grants),next))
def print_rest(alias_sum:U32,first:U32,second:U32,result:Array<U32> & U32) -> IO(Unit):
  match result:
    case (_,rest): IO.print(U32.show(alias_sum) ++ "," ++ U32.show(first) ++ "," ++ U32.show(second) ++ "," ++ U32.show(rest))
def print_project(alias_sum:U32,rest:Array<U32>,result:Payload & View) -> IO(Unit):
  match result:
    case (_,View{first,second}): print_rest(alias_sum,first,second,Array.get(U32,rest,1))
def finished(alias_sum:U32,result:Payload & Rest) -> IO(Unit):
  match result:
    case (owner,Rest{rest}): print_project(alias_sum,rest,project(owner))
def invoked(result:Row.Context<Payload,Rest> & U32) -> IO(Unit):
  match result:
    case (context,alias_sum): finished(alias_sum,Row.rollback(~Payload,~Rest,context))
def main() -> IO(Unit):
  invoked(Row.invoke(~Payload,~Rest,~Ops,~Unit,~U32,~body,~Grants{Row.write(~Payload,~Rest,~View,~project),Row.read(~Payload,~Rest,~View,~project)},Unit{},Payload{ANode{ALeaf{3},ALeaf{7}}},Rest{ANode{ALeaf{11},ALeaf{19}}}))
