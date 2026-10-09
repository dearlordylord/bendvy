import Base
import ./typed-registered.bend as Typed
import /workspace/formal-proofs/bendvy/src/ecs/local.bend as Local
import ./main.bend as Baseline
import /workspace/formal-proofs/bendvy/experiments/public-decode/adoption-v1/admission.bend as Gate
import ./application.bend as App
import ./observation.bend as O
import /workspace/formal-proofs/bendvy/experiments/public-decode/adoption-v1/qualification-v1/selector.bend as Select
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/controls.bend as Input
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/declaration.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W

def Descriptor() -> Type: Select.Descriptor<Baseline.Schema,Input.Owner,App.resource_identity(~Baseline.Schema),Input.project>
def constructed(codec:D.Codec,decode:Maybe<&2,D.Codec>) -> Descriptor():
  Select.Constructed{Decl.constructed(~Baseline.Schema,~Input.Owner,~App.resource_identity(~Baseline.Schema),~Input.project,codec),decode}
def value_observed(before:O.Snapshot,world:App.World(~Baseline.Schema),canonical:D.Raw,value:App.Output<Baseline.Schema>) -> Baseline.Observation:
  match value:
    case App.Replaced{original,previous,target}:Baseline.observed_after(~Baseline.Schema,before,Baseline.Replaced{original,Baseline.option(previous),Baseline.handle(~Baseline.Schema,target)},Some{canonical},None{},O.snapshot(~Baseline.Schema,world))
    case App.OperationRefused{original,incoming,error}:Baseline.observed_after(~Baseline.Schema,before,Baseline.OperationRefused{original,Baseline.option(incoming),error},Some{canonical},None{},O.snapshot(~Baseline.Schema,world))
    case App.TypedAborted{packets,error}:Baseline.abort_packets(~Baseline.Schema,before,world,O.packets(packets))
def typed_observed(before:O.Snapshot,canonical:D.Raw,context:Typed.Context<Baseline.Schema>,value:Typed.Output<Baseline.Schema>) -> Baseline.Observation:
  match context value:
    case Typed.Context{world,instance} Typed.Completed{output}:value_observed(before,world,canonical,output)
    case Typed.Context{world,instance} Typed.RegistrationRefused{owner,_}:Baseline.RegistrationRunRefused{Baseline.payload(owner)}
    case Typed.Context{world,instance} Typed.SystemFailed{error}:Baseline.RegistrationRefused{}
def admitted(before:O.Snapshot,result:Gate.Returned<Typed.Context<Baseline.Schema>,Input.Owner,Typed.Output<Baseline.Schema>>) -> Baseline.Observation:
  match result:
    case Gate.ValidationRefused{Typed.Context{world,instance},owner,error}:Baseline.observed_after(~Baseline.Schema,before,Baseline.ValidationRefused{Some{Baseline.payload(owner)},error},None{},None{},O.snapshot(~Baseline.Schema,world))
    case Gate.Admitted{context,value,canonical}:typed_observed(before,canonical,context,value)
def before(descriptor:Descriptor(),raw:D.Raw,instance:Typed.Instance(~Baseline.Schema),result:App.World(~Baseline.Schema) & O.Snapshot) -> Baseline.Observation:
  match result:
    case (world,before):admitted(before,Select.initialize(~Baseline.Schema,~Typed.Context<Baseline.Schema>,~Input.Owner,~Typed.Output<Baseline.Schema>,~App.resource_identity(~Baseline.Schema),~Input.project,~Typed.request(~Baseline.Schema),descriptor,Typed.Context{world,instance},Input.Owner{raw,ANode{ALeaf{111},ALeaf{222}}}))
def defined(descriptor:Descriptor(),raw:D.Raw,result:Local.Registered<Baseline.Schema,App.Store(~Baseline.Schema),App.Mail<Baseline.Schema>,Unit,Unit,Typed.Args,Unit,App.Output<Baseline.Schema>,Typed.runner(~Baseline.Schema)>) -> Baseline.Observation:
  match result:
    case Local.Registered{world,instance}:before(descriptor,raw,instance,O.snapshot(~Baseline.Schema,world))
    case Local.RegistrationRejected{world,local}:Baseline.RegistrationRefused{}
def created(descriptor:Descriptor(),raw:D.Raw,result:W.Creation<Baseline.Schema,App.Store(~Baseline.Schema),App.Mail<Baseline.Schema>,Unit>) -> Baseline.Observation:
  match result:
    case W.Created{factory,world}: defined(descriptor,raw,Typed.define(~Baseline.Schema,W.enqueue(~Baseline.Schema,~App.Store(~Baseline.Schema),~App.Mail<Baseline.Schema>,~Unit,Baseline.mark(~Baseline.Schema,world),Baseline.mark(~Baseline.Schema))))
    case W.CreateRejected{factory,resource}: Baseline.create_refused(~Baseline.Schema,O.mail(~Baseline.Schema,resource))
def initialize(descriptor:Descriptor(),raw:D.Raw) -> Baseline.Observation:
  created(descriptor,raw,W.create(~Baseline.Schema,~App.Store(~Baseline.Schema),~App.Mail<Baseline.Schema>,~Unit,~Baseline.empty(~Baseline.Schema),W.factory(),App.initial(~Baseline.Schema,Input.Owner{D.Text{"initial-resource"},ANode{ALeaf{555},ALeaf{666}}})))
def load(codec:D.Codec,decode:Maybe<&2,D.Codec>,raw:D.Raw) -> Input.Observation:
  Input.observed(Select.load(~Baseline.Schema,~Input.Owner,~App.resource_identity(~Baseline.Schema),~Input.project,Decl.constructed(~Baseline.Schema,~Input.Owner,~App.resource_identity(~Baseline.Schema),~Input.project,codec),decode,Input.Owner{raw,ANode{ALeaf{111},ALeaf{222}}}))
def target_codec() -> D.Codec: D.Struct{[D.NamedCodec{"target",D.HandleValue{1}}]}
type Extension is Data: Extension{plain:Baseline.Observation,transient:Baseline.Observation,resultRejectsDecodeAccepts:Baseline.Observation,resultAccepts:Baseline.Observation,decodeOverrides:Input.Observation,decodeFallsBack:Input.Observation,literalAccepts:Baseline.Observation,literalRejects:Baseline.Observation,handleAccepts:Baseline.Observation,handleForeign:Baseline.Observation,handleZero:Baseline.Observation,handleWrongType:Baseline.Observation}
def extensions() -> Extension:
  Extension{
    initialize(Select.Plain{Decl.plain(~Baseline.Schema,~Input.Owner,~App.resource_identity(~Baseline.Schema))},D.Text{"plain-value"}),
    initialize(Select.Transient{Decl.transient(~Baseline.Schema,~Input.Owner,~App.resource_identity(~Baseline.Schema))},D.Boolean{False{}}),
    initialize(constructed(D.Integer{},Some{D.BoolValue{}}),D.Boolean{True{}}),
    initialize(constructed(D.Integer{},Some{D.BoolValue{}}),D.Number{7}),
    load(D.Integer{},Some{D.BoolValue{}},D.Boolean{True{}}),load(D.Integer{},None{},D.Boolean{True{}}),
    initialize(constructed(D.Struct{[D.NamedCodec{"kind",D.Literal{D.Text{"ready"}}}]},None{}),D.Object{[D.Field{"kind",D.Text{"ready"}},D.Field{"extra",D.Number{99}}]}),
    initialize(constructed(D.Struct{[D.NamedCodec{"kind",D.Literal{D.Text{"ready"}}}]},None{}),D.Object{[D.Field{"kind",D.Text{"busy"}}]}),
    initialize(constructed(target_codec(),None{}),D.Object{[D.Field{"target",D.Handle{1,1}}]}),
    initialize(constructed(target_codec(),None{}),D.Object{[D.Field{"target",D.Handle{2,1}}]}),
    initialize(constructed(target_codec(),None{}),D.Object{[D.Field{"target",D.Handle{1,0}}]}),
    initialize(constructed(target_codec(),None{}),D.Object{[D.Field{"target",D.Text{"not-handle"}}]})}
type Report is Data: Report{baseline:Baseline.Report,extension:Extension}
def main() -> Report: Report{Baseline.main(),extensions()}
