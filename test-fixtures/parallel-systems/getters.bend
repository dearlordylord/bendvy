import Base
import ./declarations.bend as D
import ./payloads.bend as P
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/execution-access.bend as A
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/world.bend as W

type Local<-S:Data> is Type:
  Local{token:Array<U32>,runs:U32,position:String,counter:String,handle:W.Handle<S>}
def position_get(~S:Data,~H:Type,cap:A.ComponentWrite<S,H,P.Position,String>) -> H -> W.Handle<S> -> H & Maybe<&2,String>:
  match cap:
    case A.ComponentWrite{get,_,_}:get
def counter_get(~H:Type,cap:A.ResourceWrite<H,P.Counter,String>) -> H -> H & String:
  match cap:
    case A.ResourceWrite{get,_,_,_}:get
def position_text(value:Maybe<&2,String>) -> String:
  match value:
    case None{}:"absent"
    case Some{value}:value
def counted(~S:Data,~H:Type,token:Array<U32>,+runs:U32,position:String,handle:W.Handle<S>,result:H & String) -> H & (Local<S> & Sys.Completion<String,String>):
  match result:
    case (scope,counter):(scope,(Local{token,runs,position,counter,handle},Sys.Success{U32.show(runs)}))
def position_read(~S:Data,~H:Type,~counter:A.ResourceWrite<H,P.Counter,String>,token:Array<U32>,runs:U32,handle:W.Handle<S>,result:H & Maybe<&2,String>) -> H & (Local<S> & Sys.Completion<String,String>):
  match result:
    case (scope,position):counted(~S,~H,token,U32.add(runs,1),position_text(position),handle,counter_get(~H,counter)(scope))
def left(~S:Data,~H:Type,~caps:D.LeftOps(~S)(H),scope:H,local:Local<S>) -> H & (Local<S> & Sys.Completion<String,String>):
  match local:
    case Local{token,runs,_,_,+handle}:position_read(~S,~H,~Cap.second(~A.ComponentWrite<S,H,P.Position,String>,~A.ResourceWrite<H,P.Counter,String>,caps),token,runs,handle,position_get(~S,~H,Cap.first(~A.ComponentWrite<S,H,P.Position,String>,~A.ResourceWrite<H,P.Counter,String>,caps))(scope,handle))
def observed_token(runs:U32,position:String,counter:String,result:Array<U32> & U32) -> String:
  match result:
    case (_,token):U32.show(token) ++ ":" ++ U32.show(runs) ++ ":" ++ position ++ ":" ++ counter
def observed(~S:Data,local:Local<S>) -> String:
  match local:
    case Local{token,runs,position,counter,_}:observed_token(runs,position,counter,Array.get(U32,token,0))
