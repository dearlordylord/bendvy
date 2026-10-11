import Base
import /workspace/formal-proofs/bendvy/experiments/public-inspect/ordinary-declaration-v1/caller.bend as Caller
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as N
import /workspace/formal-proofs/bendvy/src/ecs/lifecycle.bend as L

def u32(+x:U32) -> U32 & String:(x,U32.show(x))
def boolean(+x:Bool) -> Bool & String:(x,Bool.show(x))
def leaf(~T:Type,result:T & String) -> Array<T> & String:
  match result:
    case (value,text):(ALeaf{value},"ALeaf{" ++ text ++ "}")
def node(~T:Type,left:Array<T> & String,right:Array<T> & String) -> Array<T> & String:
  match left right:
    case (l,lt) (r,rt):(ANode{l,r},"ANode{" ++ lt ++ "," ++ rt ++ "}")
def array(~T:Type,~f:T -> T & String,value:Array<T>) -> Array<T> & String:
  match value:
    case ALeaf{value}:leaf(~T,f(value))
    case ANode{left,right}:node(~T,array(~T,~f,left),array(~T,~f,right))
def payload_join(value:Array<U32> & String) -> Caller.Payload & String:
  match value:
    case (value,text):(Caller.Payload{value},"Payload{" ++ text ++ "}")
def payload(value:Caller.Payload) -> Caller.Payload & String:
  match value:
    case Caller.Payload{values}:payload_join(array(~U32,~u32,values))
def some(value:Caller.Payload & String) -> Maybe<&1,Caller.Payload> & String:
  match value:
    case (value,text):(Some{value},"Some{" ++ text ++ "}")
def maybe(value:Maybe<&1,Caller.Payload>) -> Maybe<&1,Caller.Payload> & String:
  match value:
    case None{}:(None{},"None{}")
    case Some{value}:some(payload(value))
def stamp(value:L.Entry) -> String:
  match value:
    case L.Entry{id,L.Stamp{added,changed}}:"Entry{" ++ U32.show(id) ++ ",Stamp{" ++ U32.show(added) ++ "," ++ U32.show(changed) ++ "}}"
def column_join(~S:Data,+stamps:List<L.Entry>,result:Array<Maybe<&1,Caller.Payload>> & String) -> Col.Column<S,Caller.Payload> & String:
  match result:
    case (values,text):(Col.Column{values,stamps},"Column{" ++ text ++ "," ++ List.show(~&2,~L.Entry,~stamp,stamps) ++ "}")
def column(~S:Data,value:Col.Column<S,Caller.Payload>) -> Col.Column<S,Caller.Payload> & String:
  match value:
    case Col.Column{values,stamps}:column_join(~S,stamps,array(~Maybe<&1,Caller.Payload>,~maybe,values))
    case Col.Prepared{state}:(Col.Prepared{state},"UNEXPECTED:Prepared")
    case Col.Indexed{state}:(Col.Indexed{state},"UNEXPECTED:Indexed")
    case Col.PreparedIndexed{state}:(Col.PreparedIndexed{state},"UNEXPECTED:PreparedIndexed")
def count_join(~T:Type,head:T,result:List<T> & U32) -> List<T> & U32:
  match result:
    case (tail,n):(head <> tail,1+n)
def count(~T:Type,value:List<T>) -> List<T> & U32:
  match value:
    case []:([],0)
    case head <> tail:count_join(~T,head,count(~T,tail))
def access(value:C.Access<U32>) -> String:
  match value:
    case C.Found{x}:"Found{" ++ U32.show(x) ++ "}"
    case C.ComponentAbsent{}:"ComponentAbsent{}"
    case C.MissingEntity{}:"MissingEntity{}"
def row(~S:Data,value:P.Row<S,U32>) -> String:
  match value:
    case P.Row{W.Handle{ns,id},I.Value{value,added,changed}}:"Row{Handle{" ++ U32.show(ns) ++ "," ++ U32.show(id) ++ "},Value{" ++ access(value) ++ "," ++ Bool.show(added) ++ "," ++ Bool.show(changed) ++ "}}"
def mode(value:N.Mode) -> String:
  match value:
    case N.Read{}:"Read{}"
    case N.Write{}:"Write{}"
    case N.Optional{}:"Optional{}"
    case N.With{}:"With{}"
    case N.Without{}:"Without{}"
    case N.Added{}:"Added{}"
    case N.Changed{}:"Changed{}"
def clause(~S:Data,value:N.Clause<S>) -> String:
  match value:
    case N.Clause{name,value}:"Clause{" ++ name ++ "," ++ mode(value) ++ "}"
def text(x:String) -> String:x
def registration(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:"Registration{" ++ U32.show(id) ++ "," ++ name ++ "," ++ List.show(~&2,~String,~text,access) ++ "}"
def world_join(~S:Data,+ns:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,+events:List<U32>,+registrations:List<W.RegistrationMeta>,+system:U32,+clock:U32,live:Array<Bool> & String,store:Col.Column<S,Caller.Payload> & String,resource:Array<U32> & String,pending:List<(W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>)> & U32) -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & String:
  match live store resource pending:
    case (live,lt) (store,st) (resource,rt) (pending,n):
      (W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,registrations,system,clock},"World{namespace=" ++ U32.show(ns) ++ ",nextId=" ++ U32.show(next) ++ ",highWater=" ++ U32.show(high) ++ ",live=" ++ lt ++ ",capacity=" ++ U32.show(capacity) ++ ",depth=" ++ Nat.show(depth) ++ ",store=" ++ st ++ ",resource=" ++ rt ++ ",events=" ++ List.show(~&2,~U32,~U32.show,events) ++ ",pending=" ++ U32.show(n) ++ ",registrations=" ++ List.show(~&2,~W.RegistrationMeta,~registration,registrations) ++ ",nextSystemId=" ++ U32.show(system) ++ ",clock=" ++ U32.show(clock) ++ "}")
def world(~S:Data,value:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>) -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & String:
  match value:
    case W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,registrations,system,clock}:world_join(~S,ns,next,high,capacity,depth,events,registrations,system,clock,array(~Bool,~boolean,live),column(~S,store),array(~U32,~u32,resource),count(~(W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>),pending))
def frame_join(~S:Data,+cursor:U32,value:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & String) -> I.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & String:
  match value:
    case (world,text):(I.Frame{world,cursor},"Frame{cursor=" ++ U32.show(cursor) ++ "," ++ text ++ "}")
def frame(~S:Data,value:I.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>) -> I.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & String:
  match value:
    case I.Frame{value,cursor}:frame_join(~S,cursor,world(~S,value))
def delivered(~S:Data,+next:U32,+rows:List<P.Row<S,U32>>,+clauses:List<N.Clause<S>>,+value:C.Access<U32>,+events:List<U32>,owner:I.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & String,previous:Maybe<&1,Caller.Payload> & String,undo:List<(W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>)> & U32,commands:List<(W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>)> & U32) -> Caller.Delivery<S> & String:
  match owner previous undo commands:
    case (owner,ot) (previous,pt) (undo,u) (commands,c):
      (Caller.Delivered{W.Factory{next},owner,rows,clauses,value,previous,undo,commands,events},"Delivered{factory=" ++ U32.show(next) ++ "," ++ ot ++ ",rows=" ++ List.show(~&2,~P.Row<S,U32>,~row(~S),rows) ++ ",clauses=" ++ List.show(~&2,~N.Clause<S>,~clause(~S),clauses) ++ ",access=" ++ access(value) ++ ",previous=" ++ pt ++ ",undo=" ++ U32.show(u) ++ ",commands=" ++ U32.show(c) ++ ",events=" ++ List.show(~&2,~U32,~U32.show,events) ++ "}")
def delivery(~S:Data,value:Caller.Delivery<S>) -> Caller.Delivery<S> & String:
  match value:
    case Caller.Delivered{W.Factory{next},owner,rows,clauses,value,previous,undo,commands,events}:delivered(~S,next,rows,clauses,value,events,frame(~S,owner),maybe(previous),count(~(W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>),undo),count(~(W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>),commands))
    case Caller.SetupRefused{factory,world,incoming,error}:(Caller.SetupRefused{factory,world,incoming,error},"UNEXPECTED:SetupRefused")
    case Caller.Refused{factory,resource}:(Caller.Refused{factory,resource},"UNEXPECTED:Refused")
# Terminal test fixture disposal occurs only after both complete owner-returning observations.
def detached(a:Caller.Delivery<Caller.A> & String,b:Caller.Delivery<Caller.Other> & String) -> String:
  match a b:
    case (_,at) (_,bt):"A=" ++ at ++ "\nOther=" ++ bt
def main() -> String:detached(delivery(~Caller.A,Caller.run(~Caller.A)),delivery(~Caller.Other,Caller.run(~Caller.Other)))
