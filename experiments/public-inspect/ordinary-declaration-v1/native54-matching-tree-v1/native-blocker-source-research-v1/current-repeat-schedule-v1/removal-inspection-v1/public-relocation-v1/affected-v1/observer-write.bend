import Base
import ./consumer-write.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-removal-provision.bend as Provision
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/removals.bend as Rm
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/lifecycle.bend as L
def u32(+x:U32) -> U32 & String:(x,U32.show(x))
def boolean(+x:Bool) -> Bool & String:(x,Bool.show(x))
def u32_value(x:U32) -> U32 & String:u32(x)
def bool_value(x:Bool) -> Bool & String:boolean(x)
def leaf(~T:Type,result:T & String) -> Array<T> & String:
  match result:
    case (value,text):(ALeaf{value},"ALeaf{" ++ text ++ "}")
def node(~T:Type,left:Array<T> & String,right:Array<T> & String) -> Array<T> & String:
  match left right:
    case (l,lt), (r,rt):(ANode{l,r},"ANode{" ++ lt ++ "," ++ rt ++ "}")
def array(~T:Type,~f:T -> T & String,value:Array<T>) -> Array<T> & String:
  match value:
    case ALeaf{value}:leaf(~T,f(value))
    case ANode{left,right}:node(~T,array(~T,~f,left),array(~T,~f,right))
def payload_join(value:Array<U32> & String) -> C.Payload & String:
  match value:
    case (value,text):(C.Payload{value},"Payload{" ++ text ++ "}")
def payload(value:C.Payload) -> C.Payload & String:
  match value:
    case C.Payload{values}:payload_join(array(~U32,~u32_value,values))
def some(value:C.Payload & String) -> Maybe<&1,C.Payload> & String:
  match value:
    case (value,text):(Some{value},"Some{" ++ text ++ "}")
def maybe(value:Maybe<&1,C.Payload>) -> Maybe<&1,C.Payload> & String:
  match value:
    case None{}:(None{},"None{}")
    case Some{value}:some(payload(value))
def stamp(value:L.Entry) -> String:
  match value:
    case L.Entry{id,L.Stamp{added,changed}}:"Entry{" ++ U32.show(id) ++ ",Stamp{" ++ U32.show(added) ++ "," ++ U32.show(changed) ++ "}}"
def column_join(~S:Data,+stamps:List<&2,L.Entry>,result:Array<Maybe<&1,C.Payload>> & String) -> Col.Column<S,C.Payload> & String:
  match result:
    case (values,text):(Col.Column{values,stamps},"Column{" ++ text ++ "," ++ List.show(~&2,~L.Entry,~stamp,stamps) ++ "}")
def column(~S:Data,value:Col.Column<S,C.Payload>) -> Col.Column<S,C.Payload> & String:
  match value:
    case Col.Column{values,stamps}:column_join(~S,stamps,array(~Maybe<&1,C.Payload>,~maybe,values))
    case Col.Prepared{state}:(Col.Prepared{state},"UNEXPECTED:Prepared")
    case Col.Indexed{state}:(Col.Indexed{state},"UNEXPECTED:Indexed")
    case Col.PreparedIndexed{state}:(Col.PreparedIndexed{state},"UNEXPECTED:PreparedIndexed")
def count_join(~T:Type,head:T,result:List<T> & U32) -> List<T> & U32:
  match result:
    case (tail,n):(head <> tail,U32.add(1,n))
def count(~T:Type,value:List<T>) -> List<T> & U32:
  match value:
    case []:([],0)
    case head <> tail:count_join(~T,head,count(~T,tail))
def text(x:String) -> String:x
def registration(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:"Registration{" ++ U32.show(id) ++ "," ++ name ++ "," ++ List.show(~&2,~String,~text,access) ++ "}"
def record(~S:Data,value:Rm.Record<S,Identity.Declaration<S,C.Payload>>) -> String:
  match value:
    case Rm.Removed{W.Handle{ns,id},Identity.Declaration{key}}:"Removed{Handle{" ++ U32.show(ns) ++ "," ++ U32.show(id) ++ "},Declaration{" ++ key ++ "}}"
    case Rm.Despawned{W.Handle{ns,id}}:"Despawned{Handle{" ++ U32.show(ns) ++ "," ++ U32.show(id) ++ "}}"
def event(~S:Data,value:Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>) -> String:
  match value:
    case Provision.Left{value}:"Left{" ++ record(~S,value) ++ "}"
    case Provision.Right{value}:"Right{" ++ record(~S,value) ++ "}"
def projection(~S:Data,value:Maybe<&2,List<&2,Rm.Record<S,Identity.Declaration<S,C.Payload>>>>) -> String:
  match value:
    case None{}:"None{}"
    case Some{values}:"Some{" ++ List.show(~&2,~Rm.Record<S,Identity.Declaration<S,C.Payload>>,~record(~S),values) ++ "}"
def store_join(~S:Data,left:Col.Column<S,C.Payload> & String,right:Col.Column<S,C.Payload> & String) -> Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>> & String:
  (left,lt)=left
  (right,rt)=right
  (Product.Owner{left,right},"Owner{" ++ lt ++ "," ++ rt ++ "}")
def store_text(~S:Data,value:Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>) -> Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>> & String:
  match value:
    case Product.Owner{left,right}:store_join(~S,column(~S,left),column(~S,right))
def world_join(~S:Data,+ns:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,+events:List<&2,Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>>,+registrations:List<&2,W.RegistrationMeta>,+system:U32,+clock:U32,live:Array<Bool> & String,store:Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>> & String,resource:Array<U32> & String,pending:List<(W.World<S,Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,Array<U32>,Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>> -> W.World<S,Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,Array<U32>,Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>>)> & U32) -> W.World<S,Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,Array<U32>,Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>> & String:
  (live,lt)=live
  (store,st)=store
  (resource,rt)=resource
  (pending,n)=pending
  (W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,registrations,system,clock},"World{namespace=" ++ U32.show(ns) ++ ",nextId=" ++ U32.show(next) ++ ",highWater=" ++ U32.show(high) ++ ",live=" ++ lt ++ ",capacity=" ++ U32.show(capacity) ++ ",depth=" ++ Nat.show(depth) ++ ",store=" ++ st ++ ",resource=" ++ rt ++ ",events=" ++ List.show(~&2,~Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,~event(~S),events) ++ ",pending=" ++ U32.show(n) ++ ",registrations=" ++ List.show(~&2,~W.RegistrationMeta,~registration,registrations) ++ ",nextSystemId=" ++ U32.show(system) ++ ",clock=" ++ U32.show(clock) ++ "}")
def world_text(~S:Data,value:W.World<S,Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,Array<U32>,Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>>) -> W.World<S,Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,Array<U32>,Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>> & String:
  match value:
    case W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,registrations,system,clock}:world_join(~S,ns,next,high,capacity,depth,events,registrations,system,clock,array(~Bool,~bool_value,live),store_text(~S,store),array(~U32,~u32_value,resource),count(~(W.World<S,Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,Array<U32>,Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>> -> W.World<S,Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,Array<U32>,Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>>),pending))
def fixture_join(~S:Data,+factoryNext:U32,+readerNamespace:U32,+readerId:U32,+name:String,+cursor:Nat,+projected:Maybe<&2,List<&2,Rm.Record<S,Identity.Declaration<S,C.Payload>>>>,+status:String,+output:String,value:W.World<S,Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,Array<U32>,Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>> & String) -> C.Fixture<S> & String:
  (world,wt)=value
  (C.Fixture{W.Factory{factoryNext},world,Rm.Reader{readerNamespace,readerId,name,cursor},projected,status,output},"Fixture{factory=" ++ U32.show(factoryNext) ++ "," ++ wt ++ ",Reader{" ++ U32.show(readerNamespace) ++ "," ++ U32.show(readerId) ++ "," ++ name ++ "," ++ Nat.show(cursor) ++ "},projection=" ++ projection(~S,projected) ++ ",status=" ++ status ++ ",output=" ++ output ++ "}")
def observe(~S:Data,value:C.Fixture<S>) -> C.Fixture<S> & String:
  match value:
    case C.Fixture{W.Factory{factoryNext},world,Rm.Reader{readerNamespace,readerId,name,cursor},projected,status,output}:fixture_join(~S,factoryNext,readerNamespace,readerId,name,cursor,projected,status,output,world_text(~S,world))
    case value:(value,"UNEXPECTED:Refused")
