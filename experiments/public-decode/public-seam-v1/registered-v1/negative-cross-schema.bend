import Base
import ./system.bend as System
import ./declaration.bend as Decl
import ../application.bend as App
import ../capability.bend as Public
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/controls.bend as Input
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/declaration.bend as Constructed

type Schema is Data: Schema{}
type OtherSchema is Data: OtherSchema{}
def body(-H:Type,cap:Cap.OwnedRequest<H,Public.Input<Schema,Input.Owner>,Public.Output<Schema,Input.Owner,App.Output<Schema>>>,input:Public.Input<OtherSchema,Input.Owner>,ctx:H) -> H & Public.Output<Schema,Input.Owner,App.Output<Schema>>:
  Public.gameplay(~Schema,~Input.Owner,~App.Output<Schema>,H,cap,input,ctx)
def Descriptor() -> Data: Decl.Declaration<Schema,App.Store(~Schema),Input.Owner,Unit,Input.Owner,App.Output<Schema>,App.resource_identity(~Schema),Input.project,App.resource_context(~Schema)>
def descriptor(codec:D.Codec) -> Descriptor():
  Decl.mutable(~Schema,~App.Store(~Schema),~Input.Owner,~Unit,~Input.Owner,~App.Output<Schema>,~App.resource_identity(~Schema),~Input.project,~App.resource_context(~Schema),Constructed.constructed(~Schema,~Input.Owner,~App.resource_identity(~Schema),~Input.project,codec))
def Registry() -> Type:
  Sys.Registry<Schema,App.Store(~Schema),Input.Owner,Unit,System.Invocation<Schema,Public.Input<Schema,Input.Owner>,Descriptor()>,Unit,Public.Output<Schema,Input.Owner,App.Output<Schema>>,System.runner(~Schema,~App.Store(~Schema),~Input.Owner,~Unit,~Input.Owner,~App.Output<Schema>,~App.resource_identity(~Schema),~Input.project,~App.resource_context(~Schema),~Public.Input<Schema,Input.Owner>,~Public.Output<Schema,Input.Owner,App.Output<Schema>>,~(H => cap => input => ctx => body(H,cap,input,ctx)))>
def Owner() -> Type: System.Owner<Schema,Registry(),Descriptor()>
def Returned() -> Type: System.Returned<Owner(),App.World(~Schema),System.Args<Schema,Public.Input<Schema,Input.Owner>>,Public.Output<Schema,Input.Owner,App.Output<Schema>>>
type Observation is Type:
  Observed{result:Returned()}
  RegistrationRefused{world:App.World(~Schema)}
  SetupRefused{world:App.World(~Schema),error:W.WorldError}
  CreationRefused{owner:Input.Owner}
def defined(+target:W.Handle<Schema>,result:System.Defined<App.World(~Schema),Owner()>) -> Observation:
  match result:
    case System.Rejected{world}:RegistrationRefused{world}
    case System.Defined{world,owner}:Observed{System.run(~Schema,~App.Store(~Schema),~Input.Owner,~Unit,~Input.Owner,~App.Output<Schema>,~App.resource_identity(~Schema),~Input.project,~App.resource_context(~Schema),~Public.Input<Schema,Input.Owner>,~Public.Output<Schema,Input.Owner,App.Output<Schema>>,~(H => cap => input => ctx => body(H,cap,input,ctx)),owner,world,System.Args{target,Public.Input{Input.Owner{D.Number{7},ANode{ALeaf{111},ALeaf{222}}}}})}
def reserved(result:App.World(~Schema) & W.Reservation<Schema>) -> Observation:
  match result:
    case (world,W.Reserved{+target}):defined(target,System.define(~Schema,~App.Store(~Schema),~Input.Owner,~Unit,~Input.Owner,~App.Output<Schema>,~App.resource_identity(~Schema),~Input.project,~App.resource_context(~Schema),~Public.Input<Schema,Input.Owner>,~Public.Output<Schema,Input.Owner,App.Output<Schema>>,~(H => cap => input => ctx => body(H,cap,input,ctx)),descriptor(D.Integer{}),world,"DecodeResource","Update"))
    case (world,W.ReservationRejected{error}):SetupRefused{world,error}
def empty(unit:Unit) -> App.Store(~Schema):Col.empty(~Schema,~Input.Owner)
def created(result:W.Creation<Schema,App.Store(~Schema),Input.Owner,Unit>) -> Observation:
  match result:
    case W.Created{factory,world}:reserved(W.reserve_id(~Schema,~App.Store(~Schema),~Input.Owner,~Unit,world))
    case W.CreateRejected{factory,resource}:CreationRefused{resource}
def main() -> Observation:
  created(W.create(~Schema,~App.Store(~Schema),~Input.Owner,~Unit,~empty,W.factory(),Input.Owner{D.Number{9},ALeaf{333}}))
