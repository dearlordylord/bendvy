import Base
import ../../src/ecs/execution-access.bend as Access
import ../../src/ecs/execution-declaration.bend as D
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/world.bend as W

type Position is Type:Position{token:Array<U32>,x:U32}
type Counter is Type:Counter{token:Array<U32>,count:U32,optional:Maybe<&1,Array<U32>>}
type Local<-S:Data> is Type:Local{token:Array<U32>,runs:U32,entity:W.Handle<S>}
def position_seen(+x:U32,result:Array<U32> & U32) -> Position & String:
  match result:
    case (token,id):(Position{token,x},U32.show(id) ++ ":" ++ U32.show(x))
def position(owner:Position) -> Position & String:
  match owner:
    case Position{token,x}:position_seen(x,Array.get(U32,token,0))
def counter_seen(+count:U32,optional:Maybe<&1,Array<U32>>,result:Array<U32> & U32) -> Counter & String:
  match result:
    case (token,id):(Counter{token,count,optional},U32.show(id) ++ ":" ++ U32.show(count))
def counter(owner:Counter) -> Counter & String:
  match owner:
    case Counter{token,count,optional}:counter_seen(count,optional,Array.get(U32,token,0))
def move(owner:Position) -> Position & String:
  match owner:
    case Position{token,x}:position(Position{token,U32.add(x,1)})
def increment(owner:Counter) -> Counter & String:
  match owner:
    case Counter{token,count,optional}:counter(Counter{token,U32.add(count,1),optional})
def Ops(~S:Data,H:Type) -> Type:Cap.Bundle<Access.ComponentWrite<S,H,Position,String>,Access.ResourceWrite<H,Counter,String>>
def Family(~S:Data) -> Type -> Type:Ops(~S)
def result_text(value:Maybe<&2,String>) -> String:
  match value:
    case None{}:"absent"
    case Some{text}:text
def finished(~S:Data,~H:Type,local:Local<S>,result:H & Maybe<&2,String>) -> H & (Local<S> & Sys.Completion<String,String>):
  match result:
    case (scope,value):(scope,(local,Sys.Success{result_text(value)}))
def counted(~S:Data,~H:Type,positions:Access.ComponentWrite<S,H,Position,String>,local:Local<S>,result:H & String) -> H & (Local<S> & Sys.Completion<String,String>):
  match local result:
    case Local{token,runs,+entity},(scope,_):finished(~S,~H,Local{token,U32.add(runs,1),entity},Access.component_modify_field(~S,~H,~Position,~String,positions)(move,scope,entity))
def body(~S:Data,~H:Type,~caps:Ops(~S,H),scope:H,local:Local<S>) -> H & (Local<S> & Sys.Completion<String,String>):
  counted(~S,~H,Cap.first(~Access.ComponentWrite<S,H,Position,String>,~Access.ResourceWrite<H,Counter,String>,caps),local,Access.resource_modify_field(~H,~Counter,~String,Cap.second(~Access.ComponentWrite<S,H,Position,String>,~Access.ResourceWrite<H,Counter,String>,caps))(increment,scope))
