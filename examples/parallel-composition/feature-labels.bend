import Base
import ../../src/ecs/execution-access.bend as Access
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-composer-service.bend as Service
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/world.bend as W
import ../../src/ecs/decode-data.bend as Decode

type Label is Type:Label{token:Array<String>,text:String}
type Host is Type:Host{token:Array<String>,calls:U32}
type Local<-S:Data> is Type:Local{token:Array<String>,runs:U32,entity:W.Handle<S>}
def label_seen(+text:String,result:Array<String> & String) -> Label & String:
  match result:
    case (token,id):(Label{token,text},id ++ ":" ++ text)
def label(owner:Label) -> Label & String:
  match owner:
    case Label{token,text}:label_seen(text,Array.get(String,token,0))
def raw_label(owner:Label) -> Label & Decode.Raw:
  match owner:
    case Label{token,+text}:(Label{token,text},Decode.BendvyText{text})
def host_seen(+calls:U32,result:Array<String> & String) -> Host & String:
  match result:
    case (token,id):(Host{token,calls},id ++ ":" ++ U32.show(calls))
def host(owner:Host) -> Host & String:
  match owner:
    case Host{token,calls}:host_seen(calls,Array.get(String,token,0))
def ready(owner:Service.Slot<Host>) -> Service.Slot<Host> & Service.Status<String>:Service.refresh(~Host,~String,~host,owner)
def invoke(owner:Host) -> Host & String:
  match owner:
    case Host{token,calls}:host(Host{token,U32.add(calls,1)})
def change(owner:Label) -> Label & String:
  match owner:
    case Label{token,text}:label(Label{token,text ++ "!"})
def Ops(~S:Data,H:Type) -> Type:Cap.Bundle<Access.ComponentWrite<S,H,Label,String>,Access.ResourceWrite<H,Service.Slot<Host>,Service.Status<String>>>
def Family(~S:Data) -> Type -> Type:Ops(~S)
def completion(error:Bool,value:String) -> Sys.Completion<String,String>:
  match error:
    case False{}:Sys.Success{value}
    case True{}:Sys.BodyError{"after-host-call",value}
def called(~S:Data,~H:Type,local:Local<S>,result:H & Service.Called<String>) -> H & (Local<S> & Sys.Completion<String,String>):
  match local result:
    case Local{token,+runs,entity},(scope,Service.Called{output}):(scope,(Local{token,U32.add(runs,1),entity},completion(U32.is_eq(runs,1),output)))
    case local,(scope,Service.Unavailable{}):(scope,(local,Sys.BodyError{"unexpected-missing-host","none"}))
def changed(~S:Data,~H:Type,~service:Access.ResourceWrite<H,Service.Slot<Host>,Service.Status<String>>,local:Local<S>,result:H & Maybe<&2,String>) -> H & (Local<S> & Sys.Completion<String,String>):
  match result:
    case (scope,_):called(~S,~H,local,Access.resource_own_field(~H,~Service.Slot<Host>,~Service.Status<String>,Service.Called<String>,service)(Service.call(~Host,~String,~invoke),scope))
def body(~S:Data,~H:Type,~caps:Ops(~S,H),scope:H,local:Local<S>) -> H & (Local<S> & Sys.Completion<String,String>):
  match local:
    case Local{token,runs,+entity}:changed(~S,~H,~Cap.second(~Access.ComponentWrite<S,H,Label,String>,~Access.ResourceWrite<H,Service.Slot<Host>,Service.Status<String>>,caps),Local{token,runs,entity},Access.component_modify_field(~S,~H,~Label,~String,Cap.first(~Access.ComponentWrite<S,H,Label,String>,~Access.ResourceWrite<H,Service.Slot<Host>,Service.Status<String>>,caps))(change,scope,entity))
