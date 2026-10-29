import Base
import ./payloads.bend as P
import ./declarations.bend as D
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/execution-access.bend as A
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/world.bend as W

type Local<-S:Data> is Type:
  Local{token:Array<U32>,runs:U32,handle:W.Handle<S>}
def complete(failed:Bool,runs:U32) -> Sys.Completion<String,String>:
  match failed:
    case False{}:Sys.Success{U32.show(runs)}
    case True{}:Sys.BodyError{"after-write",U32.show(runs)}
def completion(left:Bool,+runs:U32) -> Sys.Completion<String,String>:
  complete(Bool.and(left,U32.is_eq(runs,2)),runs)
def left_counted(~S:Data,~H:Type,token:Array<U32>,+runs:U32,handle:W.Handle<S>,result:H & String) -> H & (Local<S> & Sys.Completion<String,String>):
  match result:
    case (scope,_):(scope,(Local{token,runs,handle},completion(True{},runs)))
def left_moved(~S:Data,~H:Type,~counter:A.ResourceWrite<H,P.Counter,String>,token:Array<U32>,runs:U32,handle:W.Handle<S>,result:H & Maybe<&2,String>) -> H & (Local<S> & Sys.Completion<String,String>):
  match result:
    case (scope,_):left_counted(~S,~H,token,U32.add(runs,1),handle,A.resource_modify_field(~H,~P.Counter,~String,counter)(P.update_counter,scope))
def left(~S:Data,~H:Type,~caps:D.LeftOps(~S)(H),scope:H,local:Local<S>) -> H & (Local<S> & Sys.Completion<String,String>):
  match local:
    case Local{token,runs,+handle}:left_moved(~S,~H,~Cap.second(~A.ComponentWrite<S,H,P.Position,String>,~A.ResourceWrite<H,P.Counter,String>,caps),token,runs,handle,A.component_modify_field(~S,~H,~P.Position,~String,Cap.first(~A.ComponentWrite<S,H,P.Position,String>,~A.ResourceWrite<H,P.Counter,String>,caps))(P.update_position,scope,handle))
def right_counted(~S:Data,~H:Type,token:Array<U32>,+runs:U32,handle:W.Handle<S>,result:H & String) -> H & (Local<S> & Sys.Completion<String,String>):
  match result:
    case (scope,_):(scope,(Local{token,runs,handle},completion(False{},runs)))
def right_moved(~S:Data,~H:Type,~counter:A.ResourceWrite<H,P.Score,String>,token:Array<U32>,runs:U32,handle:W.Handle<S>,result:H & Maybe<&2,String>) -> H & (Local<S> & Sys.Completion<String,String>):
  match result:
    case (scope,_):right_counted(~S,~H,token,U32.add(runs,1),handle,A.resource_modify_field(~H,~P.Score,~String,counter)(P.update_score,scope))
def right(~S:Data,~H:Type,~caps:D.RightOps(~S)(H),scope:H,local:Local<S>) -> H & (Local<S> & Sys.Completion<String,String>):
  match local:
    case Local{token,runs,+handle}:right_moved(~S,~H,~Cap.second(~A.ComponentWrite<S,H,P.Health,String>,~A.ResourceWrite<H,P.Score,String>,caps),token,runs,handle,A.component_modify_field(~S,~H,~P.Health,~String,Cap.first(~A.ComponentWrite<S,H,P.Health,String>,~A.ResourceWrite<H,P.Score,String>,caps))(P.update_health,scope,handle))
