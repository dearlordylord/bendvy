import Base
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/execution-resource-access.bend as Resource
import ../../src/ecs/execution-resource-store.bend as Store
import ../../src/ecs/execution-reservation-task.bend as Task
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
def token_changed(text:String,result:Array<String> & String) -> Label & String:
  match result:
    case (token,id):label(Label{Array.set(String,token,0,id ++ "!"),text})
def change(owner:Label) -> Label & String:
  match owner:
    case Label{token,text}:token_changed(text,Array.get(String,token,0))
def Ops(~S:Data,Permit:Data,H:Type) -> Type:Cap.Bundle<Q.GeneralWriter<S,H,Label,String>,Resource.Writer<H,Service.Slot<Host>,Service.Status<String>>>
def Family(~S:Data) -> Data -> Type -> Type:Ops(~S)
def completion(error:Bool,value:String) -> Sys.Completion<String,String>:
  match error:
    case False{}:Sys.Success{value}
    case True{}:Sys.BodyError{"after-host-call",value}
def called(~S:Data,~Permit:Data,~H:Type,local:Local<S>,result:H & Store.Edit<Service.Slot<Host>,Service.Called<String>>) -> Task.Task<S,Permit,H & (Local<S> & Sys.Completion<String,String>)>:
  match local result:
    case Local{token,+runs,entity},(scope,Store.Edited{Service.Called{output}}):Task.TDone{(scope,(Local{token,U32.add(runs,1),entity},completion(U32.is_eq(runs,1),output)))}
    case local,(scope,_):Task.TDone{(scope,(local,Sys.BodyError{"unexpected-missing-host","none"}))}
def changed(~S:Data,~Permit:Data,~H:Type,service:Resource.Writer<H,Service.Slot<Host>,Service.Status<String>>,local:Local<S>,result:H & Q.GeneralEdit<Label,String>) -> Task.Task<S,Permit,H & (Local<S> & Sys.Completion<String,String>)>:
  match service result:
    case Resource.Writer{_,own,_},(scope,_):called(~S,~Permit,~H,local,own(Service.Called<String>,scope,Service.call(~Host,~String,~invoke)))
    case _,(scope,_):Task.TDone{(scope,(local,Sys.BodyError{"host unsupported","local retained"}))}
def body_caps(~S:Data,~Permit:Data,~H:Type,caps:Ops(~S,Unit,H),scope:H,local:Local<S>) -> Task.Task<S,Permit,H & (Local<S> & Sys.Completion<String,String>)>:
  match caps local:
    case Cap.Bundle{Q.GeneralWriter{_,modify,_},service} Local{token,runs,+entity}:changed(~S,~Permit,~H,service,Local{token,runs,entity},modify(String,scope,entity,change))
    case _ local:Task.TDone{(scope,(local,Sys.BodyError{"label unsupported","local retained"}))}
def body(~S:Data,~Permit:Data,~H:Type,~caps:Ops(~S,Permit,H),scope:H,local:Local<S>) -> Task.Task<S,Permit,H & (Local<S> & Sys.Completion<String,String>)>:
  body_caps(~S,~Permit,~H,caps,scope,local)
