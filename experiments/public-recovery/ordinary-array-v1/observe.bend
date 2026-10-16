import Base
import ./fixture.bend as F
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/recoverable-array.bend as A

def scalar_shared(+value:U32) -> U32 & String:(value,U32.show(value))
def boolean_shared(+value:Bool) -> Bool & String:(value,Bool.show(value))
def scalar(value:U32) -> U32 & String:scalar_shared(value)
def boolean(value:Bool) -> Bool & String:boolean_shared(value)
def tree_join(~P:Type,left:Array<P> & String,right:Array<P> & String) -> Array<P> & String:
  match left right:
    case (a,x),(b,y):(ANode{a,b},"(" ++ x ++ "," ++ y ++ ")")
def leaf_join(~P:Type,value:P & String) -> Array<P> & String:
  (value,text) = value
  (ALeaf{value},text)
def tree(~P:Type,~view:P -> P & String,value:Array<P>) -> Array<P> & String:
  match value:
    case ALeaf{value}:leaf_join(~P,view(value))
    case ANode{left,right}:tree_join(~P,tree(~P,~view,left),tree(~P,~view,right))
def element(value:Array<U32>) -> Array<U32> & String:tree(~U32,~scalar,value)
def array(value:Array<Array<U32>>) -> Array<Array<U32>> & String:tree(~Array<U32>,~element,value)
def list_join(~P:Type,head:P & String,tail:List<P> & String) -> List<P> & String:
  match head tail:
    case (h,a),(t,b):(h <> t,a ++ ";" ++ b)
def items(~P:Type,~view:P -> P & String,value:List<P>) -> List<P> & String:
  match value:
    case []:([],"[]")
    case h <> t:list_join(~P,view(h),items(~P,~view,t))
def replaced(value:Array<Array<U32>> & String) -> A.Record<Array<U32>> & String:
  (value,text) = value
  (A.Replaced{value},"replaced:" ++ text)
def swapped(+index:U32,value:Array<U32> & String) -> A.Record<Array<U32>> & String:
  (value,text) = value
  (A.Swapped{index,value},"swapped:" ++ U32.show(index) ++ ":" ++ text)
def record(value:A.Record<Array<U32>>) -> A.Record<Array<U32>> & String:
  match value:
    case A.Replaced{value}:replaced(array(value))
    case A.Swapped{index,value}:swapped(index,element(value))
def records(value:List<A.Record<Array<U32>>>) -> List<A.Record<Array<U32>>> & String:items(~A.Record<Array<U32>>,~record,value)
def output_join(a:List<Array<Array<U32>>> & String,b:List<Array<U32>> & String) -> F.Output & String:
  match a b:
    case (a,x),(b,y):(F.Output{a,b},"arrays=" ++ x ++ ":elements=" ++ y)
def output(value:F.Output) -> F.Output & String:
  match value:
    case F.Output{a,b}:output_join(items(~Array<Array<U32>>,~array,a),items(~Array<U32>,~element,b))
def args_join(a:Array<Array<U32>> & String,b:Array<U32> & String,c:Array<Array<U32>> & String,d:Array<U32> & String,+fail:Bool) -> F.Args & String:
  match a b c d:
    case (a,x),(b,y),(c,z),(d,w):(F.Args{a,b,c,d,fail},x ++ ":" ++ y ++ ":" ++ z ++ ":" ++ w ++ ":fail=" ++ Bool.show(fail))
def args(value:F.Args) -> F.Args & String:
  match value:
    case F.Args{a,b,c,d,fail}:args_join(array(a),element(b),array(c),element(d),fail)
def text(value:String) -> String:value
def registration(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(~&2,~String,~text,access)
def registry(~S:Data,value:F.Registry(~S)) -> F.Registry(~S) & String:
  match value:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}:(Sys.Registry{ns,id,name,access,cursor},U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(~&2,~String,~text,access) ++ ":cursor=" ++ U32.show(cursor))
def world_join(~S:Data,+ns:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,+events:List<&2,Unit>,pending:List<(W.World<S,Unit,Array<Array<U32>>,Unit> -> W.World<S,Unit,Array<Array<U32>>,Unit>)>,+regs:List<&2,W.RegistrationMeta>,+sid:U32,+clock:U32,count:U32,live:Array<Bool> & String,resource:Array<Array<U32>> & String) -> W.World<S,Unit,Array<Array<U32>>,Unit> & String:
  match live resource:
    case (live,lt),(resource,rt):(W.World{ns,next,high,live,capacity,depth,Unit{},resource,events,pending,regs,sid,clock},"ns=" ++ U32.show(ns) ++ ":next=" ++ U32.show(next) ++ ":high=" ++ U32.show(high) ++ ":capacity=" ++ U32.show(capacity) ++ ":depth=" ++ Nat.show(depth) ++ ":live=" ++ lt ++ ":resource=" ++ rt ++ ":events=" ++ Nat.show(List.length(&2,Unit,events)) ++ ":pending=" ++ U32.show(count) ++ ":regs=" ++ List.show(~&2,~W.RegistrationMeta,~registration,regs) ++ ":sid=" ++ U32.show(sid) ++ ":clock=" ++ U32.show(clock))
def world_raw(~S:Data,count:U32,value:W.World<S,Unit,Array<Array<U32>>,Unit>) -> W.World<S,Unit,Array<Array<U32>>,Unit> & String:
  match value:
    case W.World{ns,next,high,live,capacity,depth,Unit{},resource,events,pending,regs,sid,clock}:world_join(~S,ns,next,high,capacity,depth,events,pending,regs,sid,clock,count,tree(~Bool,~boolean,live),array(resource))
def world_counted(~S:Data,value:W.World<S,Unit,Array<Array<U32>>,Unit> & U32) -> W.World<S,Unit,Array<Array<U32>>,Unit> & String:
  (world,count) = value
  world_raw(~S,count,world)
def world(~S:Data,value:W.World<S,Unit,Array<Array<U32>>,Unit>) -> W.World<S,Unit,Array<Array<U32>>,Unit> & String:
  world_counted(~S,W.pending_count(~S,~Unit,~Array<Array<U32>>,~Unit,value))
