import Base
import provider.bend as P
import ../../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../../src/ecs/capabilities.bend as Cap
import ../../../../../src/ecs/transaction.bend as T
# Shared resource payload type intentionally used by distinct declarations.
type Counter is Type:
  Counter{values:Array<U32>}
type Output is Type:
  Output{values:Array<U32>}
type Error is Data:
  Rollback{first:U32,second:U32,afterFirst:U32}
def counter(a:U32,b:U32,c:U32,d:U32) -> Counter:
  Counter{ANode{ANode{ALeaf{a},ALeaf{b}},ANode{ALeaf{c},ALeaf{d}}}}
def viewed(result:Array<U32> & U32) -> Counter & U32:
  match result:
    case (values,value):(Counter{values},value)
def view(value:Counter) -> Counter & U32:
  match value:
    case Counter{values}:viewed(Array.get(U32,values,0))
def Ops(~S:Data,~first:Schema.Resource<S,Counter>,~second:Schema.Resource<S,Counter>,H:Type) -> Type:
  Cap.Bundle<P.Write<S,Counter,first,H,U32>,P.Write<S,Counter,second,H,U32>>
def done(~H:Type,fail:Bool,+first:U32,+second:U32,+afterFirst:U32,owner:H) -> H & (T.Outcome<Error> & Output):
  match fail:
    case False{}:(owner,(T.Success{},Output{ANode{ANode{ALeaf{first},ALeaf{second}},ANode{ALeaf{afterFirst},ALeaf{(first+2:U32)}}}}))
    case True{}:(owner,(T.Failure{Rollback{first,second,afterFirst}},Output{ANode{ANode{ALeaf{first},ALeaf{second}},ANode{ALeaf{afterFirst},ALeaf{(first+2:U32)}}}}))
def observed_second(~S:Data,~firstIdentity:Schema.Resource<S,Counter>,~secondIdentity:Schema.Resource<S,Counter>,~H:Type,~caps:Ops(~S,~firstIdentity,~secondIdentity,H),fail:Bool,+first:U32,+afterFirst:U32,result:H & U32) -> H & (T.Outcome<Error> & Output):
  match result:
    case (owner,+second):done(~H,fail,first,second,afterFirst,P.set(~S,~Counter,~secondIdentity,~H,~U32,~Cap.second(~P.Write<S,Counter,firstIdentity,H,U32>,~P.Write<S,Counter,secondIdentity,H,U32>,caps),owner,counter((second+10:U32),(second+11:U32),(second+12:U32),(second+13:U32))))
def observed_first_write(~S:Data,~firstIdentity:Schema.Resource<S,Counter>,~secondIdentity:Schema.Resource<S,Counter>,~H:Type,~caps:Ops(~S,~firstIdentity,~secondIdentity,H),fail:Bool,+first:U32,result:H & U32) -> H & (T.Outcome<Error> & Output):
  match result:
    case (owner,+afterFirst):observed_second(~S,~firstIdentity,~secondIdentity,~H,~caps,fail,first,afterFirst,P.get(~S,~Counter,~secondIdentity,~H,~U32,~Cap.second(~P.Write<S,Counter,firstIdentity,H,U32>,~P.Write<S,Counter,secondIdentity,H,U32>,caps),P.set(~S,~Counter,~firstIdentity,~H,~U32,~Cap.first(~P.Write<S,Counter,firstIdentity,H,U32>,~P.Write<S,Counter,secondIdentity,H,U32>,caps),owner,counter((first+2:U32),(first+3:U32),(first+4:U32),(first+5:U32)))))
def observed_first(~S:Data,~firstIdentity:Schema.Resource<S,Counter>,~secondIdentity:Schema.Resource<S,Counter>,~H:Type,~caps:Ops(~S,~firstIdentity,~secondIdentity,H),fail:Bool,result:H & U32) -> H & (T.Outcome<Error> & Output):
  match result:
    case (owner,+first):observed_first_write(~S,~firstIdentity,~secondIdentity,~H,~caps,fail,first,P.get(~S,~Counter,~firstIdentity,~H,~U32,~Cap.first(~P.Write<S,Counter,firstIdentity,H,U32>,~P.Write<S,Counter,secondIdentity,H,U32>,caps),P.set(~S,~Counter,~firstIdentity,~H,~U32,~Cap.first(~P.Write<S,Counter,firstIdentity,H,U32>,~P.Write<S,Counter,secondIdentity,H,U32>,caps),owner,counter((first+1:U32),(first+101:U32),(first+102:U32),(first+103:U32)))))
def body(~S:Data,~firstIdentity:Schema.Resource<S,Counter>,~secondIdentity:Schema.Resource<S,Counter>,~H:Type,~caps:Ops(~S,~firstIdentity,~secondIdentity,H),fail:Bool,owner:H) -> H & (T.Outcome<Error> & Output):
  observed_first(~S,~firstIdentity,~secondIdentity,~H,~caps,fail,P.get(~S,~Counter,~firstIdentity,~H,~U32,~Cap.first(~P.Write<S,Counter,firstIdentity,H,U32>,~P.Write<S,Counter,secondIdentity,H,U32>,caps),owner))
def ReadOps(~S:Data,~first:Schema.Resource<S,Counter>,~second:Schema.Resource<S,Counter>,H:Type) -> Type:
  Cap.Bundle<P.Read<S,Counter,first,H,U32>,P.Read<S,Counter,second,H,U32>>
def read_second(~H:Type,+first:U32,result:H & U32) -> H & (T.Outcome<Error> & Output):
  match result:
    case (owner,+second):(owner,(T.Success{},Output{ANode{ANode{ALeaf{first},ALeaf{second}},ANode{ALeaf{first},ALeaf{second}}}}))
def read_first(~S:Data,~firstIdentity:Schema.Resource<S,Counter>,~secondIdentity:Schema.Resource<S,Counter>,~H:Type,~caps:ReadOps(~S,~firstIdentity,~secondIdentity,H),result:H & U32) -> H & (T.Outcome<Error> & Output):
  match result:
    case (owner,+first):read_second(~H,first,P.read_value(~S,~Counter,~secondIdentity,~H,~U32,~Cap.second(~P.Read<S,Counter,firstIdentity,H,U32>,~P.Read<S,Counter,secondIdentity,H,U32>,caps),owner))
def read_body(~S:Data,~firstIdentity:Schema.Resource<S,Counter>,~secondIdentity:Schema.Resource<S,Counter>,~H:Type,~caps:ReadOps(~S,~firstIdentity,~secondIdentity,H),fail:Bool,owner:H) -> H & (T.Outcome<Error> & Output):
  read_first(~S,~firstIdentity,~secondIdentity,~H,~caps,P.read_value(~S,~Counter,~firstIdentity,~H,~U32,~Cap.first(~P.Read<S,Counter,firstIdentity,H,U32>,~P.Read<S,Counter,secondIdentity,H,U32>,caps),owner))
