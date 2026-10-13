import Base
import ../handle-application.bend as H
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/decode-constructed-resource.bend as ResourceConstruction
import /workspace/formal-proofs/bendvy/src/ecs/decode-declaration.bend as Declaration
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/decode-requests.bend as DecodeRequest
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/bundle-install.bend as Install

def invalid_result(~Owner:Type,applied:Owner & ResourceConstruction.Output<H.Payload<H.First>,H.Payload<H.First>>) -> Owner & Unit:
  match applied:
    case (owner,_):(owner,Unit{})

def invalid_body(~Owner:Type,~cap:Cap.Read<Owner,D.Raw>,unit:Unit,owner:Owner) -> Owner & Unit:
  invalid_result(~Owner,ResourceConstruction.apply(~H.First,~H.Payload<H.First>,~H.Payload<H.First>,~H.resource_identity(~H.First),~H.project(~H.First),~H.incoming(~H.First),~H.build(~H.First),~H.resource_factory(~H.First,1),~Owner,~cap,owner,H.Payload{ALeaf{1},"input",None{}}))

def install_refused(~S:Data,world:W.World<S,H.Store(~S),H.Payload<S>,U32>,handle:W.Handle<S>,packet:DecodeRequest.Packet<H.Payload<S>>) -> Install.Attempt<W.World<S,H.Store(~S),H.Payload<S>,U32>,DecodeRequest.Packet<H.Payload<S>>,Unit>:
  Install.Refused{world,packet,W.MissingEntity{}}

def invalid(~S:Data,frame:H.Frame(~S)) -> H.Frame(~S) & Unit:
  Declaration.invoke_readonly(~S,~H.Store(~S),~H.Payload<S>,~U32,~H.Payload<S>,~Unit,~D.Raw,~Unit,~H.Token,~H.identity(~S),~H.project(~S),~H.project(~S),~H.take(~S),~H.put(~S),~install_refused(~S),~Unit,~Unit,~(Owner => cap => unit => owner => invalid_body(~Owner,~cap,unit,owner)),frame,Unit{})
