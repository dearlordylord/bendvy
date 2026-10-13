import Base
import ../handle-application.bend as H
import ../handle-controls.bend as HandleControls
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/commands.bend as WorldCommands
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Component
import /workspace/formal-proofs/bendvy/src/ecs/decode-capabilities.bend as Admission
import /workspace/formal-proofs/bendvy/src/ecs/decode-declaration.bend as Declaration
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/decode-frame.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/decode-requests.bend as DecodeRequest
import /workspace/formal-proofs/bendvy/src/ecs/bundle-install.bend as Install
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as SF
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W

def entry(~S:Data) -> SF.Entry<S>:
  SF.Entry{SF.Component{},Identity.key(~S,~H.Payload<S>,H.identity(~S)),Identity.key(~S,~H.Payload<S>,H.identity(~S))}

def required(~S:Data) -> List<&2,SF.Entry<S>>:
  [entry(~S)]

def launch(owners:Unit) -> String:
  "launched"

def missing_binding(~S:Data) -> SF.Bound<S,Unit,String>:
  Admission.provision_declared(~S,~Unit,~String,~launch,SF.Fragment{[],Unit{}},required(~S))

def present_binding(~S:Data) -> SF.Bound<S,Unit,String>:
  Admission.provision_declared(~S,~Unit,~String,~launch,SF.Fragment{required(~S),Unit{}},required(~S))

def kind_text(kind:SF.RegistryKind) -> String:
  match kind:
    case SF.Component{}:"Component"
    case SF.Resource{}:"Resource"
    case SF.Event{}:"Event"
    case SF.Relation{}:"Relation"
    case SF.Service{}:"Service"

def persistence_text(kind:SF.PersistenceKind) -> String:
  match kind:
    case SF.Plain{}:"Plain"
    case SF.Transient{}:"Transient"
    case SF.Constructed{}:"Constructed"

def entry_text(~S:Data,value:SF.Entry<S>) -> String:
  match value:
    case SF.Entry{kind,key,name}:"Entry{kind=" ++ kind_text(kind) ++ ",key=" ++ key ++ ",name=" ++ name ++ "}"
    case SF.Classified{kind,key,name,persistence}:"Classified{kind=" ++ kind_text(kind) ++ ",key=" ++ key ++ ",name=" ++ name ++ ",persistence=" ++ persistence_text(persistence) ++ "}"

def entries_text(~S:Data,values:List<&2,SF.Entry<S>>) -> String:
  match values:
    case []:""
    case value <> []:entry_text(~S,value)
    case value <> rest:entry_text(~S,value) ++ ";" ++ entries_text(~S,rest)

def fragment_text(~S:Data,value:SF.Fragment<S,Unit>) -> String:
  match value:
    case SF.Fragment{entries,_}:"Fragment{entries=[" ++ entries_text(~S,entries) ++ "],owners=Unit{}}"

def binding_error_text(error:SF.Error) -> String:
  match error:
    case SF.DuplicateKey{kind,key}:"DuplicateKey{kind=" ++ kind_text(kind) ++ ",key=" ++ key ++ "}"
    case SF.DuplicateName{kind,name}:"DuplicateName{kind=" ++ kind_text(kind) ++ ",name=" ++ name ++ "}"
    case SF.UndeclaredDescriptor{kind,key,name}:"UndeclaredDescriptor{kind=" ++ kind_text(kind) ++ ",key=" ++ key ++ ",name=" ++ name ++ "}"

def binding_text(~S:Data,result:SF.Bound<S,Unit,String>) -> String:
  match result:
    case SF.BindRejected{error,fragment}:"BindRejected{error=" ++ binding_error_text(error) ++ ",fragment=" ++ fragment_text(~S,fragment) ++ "}"
    case SF.Built{output}:"Built{output=" ++ output ++ "}"

def read_text(~Owner:Type,observed:Owner & Component.Access<D.Raw>) -> Owner & String:
  match observed:
    case (owner,Component.Found{value}):(owner,"Found{value=" ++ HandleControls.raw(value) ++ "}")
    case (owner,Component.ComponentAbsent{}):(owner,"ComponentAbsent{}")
    case (owner,Component.MissingEntity{}):(owner,"MissingEntity{}")

def read_body(~Owner:Type,~cap:Cap.Read<Owner,D.Raw>,unit:Unit,owner:Owner) -> Owner & String:
  read_text(~Owner,Cap.read(~Owner,~D.Raw,cap,owner))

def install_refused(~S:Data,world:W.World<S,H.Store(~S),H.Payload<S>,U32>,handle:W.Handle<S>,packet:DecodeRequest.Packet<H.Payload<S>>) -> Install.Attempt<W.World<S,H.Store(~S),H.Payload<S>,U32>,DecodeRequest.Packet<H.Payload<S>>,Unit>:
  Install.Refused{world,packet,W.MissingEntity{}}

def invoke_readonly(~S:Data,frame:H.Frame(~S)) -> H.Frame(~S) & String:
  Declaration.invoke_readonly(~S,~H.Store(~S),~H.Payload<S>,~U32,~H.Payload<S>,~Unit,~D.Raw,~Unit,~H.Token,~H.identity(~S),~H.project(~S),~H.project(~S),~H.take(~S),~H.put(~S),~install_refused(~S),~Unit,~String,~(Owner => cap => unit => owner => read_body(~Owner,~cap,unit,owner)),frame,Unit{})

def frame_handle(~S:Data,frame:H.Frame(~S),handle:W.Handle<S>) -> H.Frame(~S):
  match frame:
    case F.Frame{owner,_,error,cursor,receipts,pending}:F.Frame{owner,handle,error,cursor,receipts,pending}

def populate_world(~S:Data,world:H.World(~S),handle:W.Handle<S>,payload:H.Payload<S>) -> H.World(~S):
  H.populate(~S,world,handle,payload)

def read_returned(~S:Data,result:H.Frame(~S) & String) -> String:
  match result:
    case (_,result):result

def read_frame(~S:Data,world:H.World(~S),handle:W.Handle<S>) -> String:
  read_returned(~S,invoke_readonly(~S,frame_handle(~S,H.frame_at(~S,1,world),handle)))

def first_handle(~S:Data) -> W.Handle<S>:
  W.Handle{1,1}

def spawn_and_read(~S:Data,world:H.World(~S)) -> String:
  read_frame(~S,WorldCommands.spawn_apply(~S,~H.Store(~S),~H.Payload<S>,~U32,~H.Payload<S>,~populate_world(~S),world,first_handle(~S),H.Payload{ANode{ALeaf{7},ALeaf{8}},"seed",None{}}),first_handle(~S))

def reserve_and_read(~S:Data,reserved:H.World(~S) & W.Reservation<S>) -> String:
  match reserved:
    case (world,W.Reserved{_}):spawn_and_read(~S,world)
    case (_,W.ReservationRejected{_}):"reservation-rejected"

def world_read(~S:Data,result:W.Creation<S,H.Store(~S),H.Payload<S>,U32>) -> String:
  match result:
    case W.Created{_,world}:
      reserved = W.reserve_id(~S,~H.Store(~S),~H.Payload<S>,~U32,world)
      reserve_and_read(~S,reserved)
    case W.CreateRejected{_,_}:"creation-rejected"

def read_probe(~S:Data) -> String:
  world_read(~S,W.create(~S,~H.Store(~S),~H.Payload<S>,~U32,~H.empty(~S),W.factory(),H.Payload{ANode{ALeaf{100},ALeaf{101}},"resource",None{}}))

def main() -> IO(Unit):
  IO.print(
    "first-missing=" ++ binding_text(~H.First,missing_binding(~H.First)) ++ "\n" ++
    "first-present=" ++ binding_text(~H.First,present_binding(~H.First)) ++ "\n" ++
    "second-missing=" ++ binding_text(~H.Second,missing_binding(~H.Second)) ++ "\n" ++
    "second-present=" ++ binding_text(~H.Second,present_binding(~H.Second)) ++ "\n" ++
    "first-read=" ++ read_probe(~H.First) ++ "\n" ++
    "second-read=" ++ read_probe(~H.Second) ++ "\n")
