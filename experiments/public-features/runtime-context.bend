import Base
import ../../src/ecs/world.bend as W
import ../../src/ecs/system.bend as Sys
import ../../src/ecs/schema-fragments.bend as SF
import ../../src/ecs/schedule-provision.bend as P

type Schema is Data:
  Schema{}
type Declarations is Type:
  Declarations{core:Maybe<&2,SF.Entry<Schema>>,combat:Maybe<&2,SF.Entry<Schema>>}
type Trace is Type:
  Trace{calls:Array<U32>,trace:List<&2,String>}
def traced(world:W.World<Schema,Declarations,Trace,U32>,name:String) -> W.World<Schema,Declarations,Trace,U32>:
  match world:
    case W.World{ns,next,high,live,cap,depth,store,Trace{calls,trace},events,commands,regs,system,clock}: W.World{ns,next,high,live,cap,depth,store,Trace{calls,List.append(&2,String,trace,[name])},events,commands,regs,system,clock}
def phase(first:Bool,name:String) -> String:
  match first:
    case True{}: "bootstrap:" ++ name
    case False{}: "update:" ++ name
def counted_world(+index:U32,name:String,ns:U32,next:U32,high:U32,live:Array<Bool>,cap:U32,depth:Nat,store:Declarations,trace:List<&2,String>,events:List<&2,U32>,commands:List<(W.World<Schema,Declarations,Trace,U32> -> W.World<Schema,Declarations,Trace,U32>)>,regs:List<&2,W.RegistrationMeta>,system:U32,clock:U32,observed:Array<U32> & U32) -> W.World<Schema,Declarations,Trace,U32>:
  match observed:
    case (calls,+count): W.World{ns,next,high,live,cap,depth,store,Trace{Array.set(U32,calls,index,U32.add(count,1)),List.append(&2,String,trace,[phase(U32.is_eq(count,0),name)])},events,commands,regs,system,clock}
def tick(+index:U32,name:String,world:W.World<Schema,Declarations,Trace,U32>) -> W.World<Schema,Declarations,Trace,U32>:
  match world:
    case W.World{ns,next,high,live,cap,depth,store,Trace{calls,trace},events,commands,regs,system,clock}: counted_world(index,name,ns,next,high,live,cap,depth,store,trace,events,commands,regs,system,clock,Array.get(U32,calls,index))
def present(entry:Maybe<&2,SF.Entry<Schema>>,+key:String) -> Bool:
  match entry:
    case None{}: False{}
    case Some{SF.Entry{kind,k,n}}: Bool.and(SF.same_kind(kind,SF.Component{}),Bool.and(String.eq(k,key),String.eq(n,key)))
def granted(core:Bool,combat:Bool) -> List<&2,P.Requirement<Schema>>:
  match core combat:
    case True{} True{}: [P.Component{1},P.Component{2}]
    case True{} False{}: [P.Component{1}]
    case False{} True{}: [P.Component{2}]
    case False{} False{}: []
def grants(core:Maybe<&2,SF.Entry<Schema>>,combat:Maybe<&2,SF.Entry<Schema>>) -> List<&2,P.Requirement<Schema>>:
  granted(present(core,"core"),present(combat,"combat"))
def provision(world:W.World<Schema,Declarations,Trace,U32>) -> W.World<Schema,Declarations,Trace,U32> & List<&2,P.Requirement<Schema>>:
  match world:
    case W.World{ns,next,high,live,cap,depth,Declarations{+core,+combat},resources,events,commands,regs,system,clock}: (W.World{ns,next,high,live,cap,depth,Declarations{core,combat},resources,events,commands,regs,system,clock},grants(core,combat))
def fresh(+namespace:U32) -> W.World<Schema,Declarations,Trace,U32>:
  W.World{namespace,1,0,ALeaf{False{}},1,0n,Declarations{Some{SF.Entry{SF.Component{},"core","core"}},Some{SF.Entry{SF.Component{},"combat","combat"}}},Trace{ANode{ALeaf{0},ALeaf{0}},[]},[],[],[],1,0}
def empty_store(unit:Unit) -> Declarations:
  Declarations{Some{SF.Entry{SF.Component{},"core","core"}},Some{SF.Entry{SF.Component{},"combat","combat"}}}
def resource() -> Trace:
  Trace{ANode{ALeaf{0},ALeaf{0}},[]}
def array_join(left:Array<U32> & List<&2,U32>,right:Array<U32> & List<&2,U32>) -> Array<U32> & List<&2,U32>:
  match left right:
    case Tuple{left,lv} Tuple{right,rv}: (ANode{left,right},List.append(&2,U32,lv,rv))
def array_view(owner:Array<U32>) -> Array<U32> & List<&2,U32>:
  match owner:
    case ALeaf{+value}: (ALeaf{value},[value])
    case ANode{left,right}: array_join(array_view(left),array_view(right))
def bool_join(left:Array<Bool> & List<&2,Bool>,right:Array<Bool> & List<&2,Bool>) -> Array<Bool> & List<&2,Bool>:
  match left right:
    case Tuple{left,lv} Tuple{right,rv}: (ANode{left,right},List.append(&2,Bool,lv,rv))
def bool_view(owner:Array<Bool>) -> Array<Bool> & List<&2,Bool>:
  match owner:
    case ALeaf{+value}: (ALeaf{value},[value])
    case ANode{left,right}: bool_join(bool_view(left),bool_view(right))
def count_done(~T:Type,head:T,observed:List<T> & U32) -> List<T> & U32:
  match observed:
    case (tail,n): (head <> tail,U32.add(n,1))
def count_owned(~T:Type,items:List<T>) -> List<T> & U32:
  match items:
    case []: ([],0)
    case head <> tail: count_done(~T,head,count_owned(~T,tail))
