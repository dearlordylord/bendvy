import Base
import ./payloads.bend as P
import ./declarations.bend as D
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/execution-access.bend as A
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/world.bend as W

type Local<-S:Data> is Type:
  Local{token:Array<U32>,runs:U32,handle:W.Handle<S>}
def completion(failed:Bool) -> Sys.Completion<String,String>:
  match failed:
    case False{}:Sys.Success{"ok"}
    case True{}:Sys.BodyError{"after-write","partial"}
def counted(~S:Data,~H:Type,token:Array<U32>,+runs:U32,handle:W.Handle<S>,result:H & String) -> H & (Local<S> & Sys.Completion<String,String>):
  match result:
    case (scope,_):(scope,(Local{token,runs,handle},completion(U32.is_eq(runs,2))))
def moved(~S:Data,~H:Type,~counter:A.ResourceWrite<H,P.Counter,String>,token:Array<U32>,runs:U32,handle:W.Handle<S>,result:H & Maybe<&2,String>) -> H & (Local<S> & Sys.Completion<String,String>):
  match result:
    case (scope,_):counted(~S,~H,token,U32.add(runs,1),handle,A.resource_modify_field(~H,~P.Counter,~String,counter)(P.count,scope))
def run(~S:Data,~H:Type,~caps:D.Ops(~S)(H),scope:H,local:Local<S>) -> H & (Local<S> & Sys.Completion<String,String>):
  match local:
    case Local{token,runs,+handle}:moved(~S,~H,~Cap.second(~A.ComponentWrite<S,H,P.Position,String>,~A.ResourceWrite<H,P.Counter,String>,caps),token,runs,handle,A.component_modify_field(~S,~H,~P.Position,~String,Cap.first(~A.ComponentWrite<S,H,P.Position,String>,~A.ResourceWrite<H,P.Counter,String>,caps))(P.move,scope,handle))
