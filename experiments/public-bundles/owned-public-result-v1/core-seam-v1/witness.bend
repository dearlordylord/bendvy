import Base
import capability-leaf.bend as Owned
import ../../../../src/ecs/capabilities.bend as Legacy

type Packet<Head:Type,Tail:Type> is Type:
  Packet{head:Head,tail:Tail}
type Owner is Type:
  Owner{cells:Array<U32>}
def request(~P:Type,owner:Owner,input:P) -> Owner & P:
  (owner,input)
def body(~P:Type,~H:Type,~cap:Owned.OwnedRequest<H,P,P>,args:P,ctx:H) -> H & P:
  Owned.owned_request(~H,~P,~P,~cap,ctx,args)
def call(~P:Type,owner:Owner,input:P) -> Owner & P:
  Owned.invoke_owned(~h => Owned.OwnedRequest<h,P,P>,~P,~P,~body(~P),~Owner,~Owned.OwnedRequest{request(~P)},input,owner)
def arbitrary(~P:Type,~Q:Type,owner:Owner,input:Packet<P,Q>) -> Owner & Packet<P,Q>:
  call(~Packet<P,Q>,owner,input)
def legacy_request(owner:Owner,input:U32) -> Owner & U32:
  (owner,input)
def legacy_body(~H:Type,~cap:Legacy.Request<H,U32,U32>,args:U32,ctx:H) -> H & U32:
  Legacy.request(~H,~U32,~U32,~cap,ctx,args)
def legacy(owner:Owner,input:U32) -> Owner & U32:
  Legacy.invoke(~h => Legacy.Request<h,U32,U32>,~U32,~U32,~legacy_body,~Owner,~Legacy.Request{legacy_request},input,owner)
