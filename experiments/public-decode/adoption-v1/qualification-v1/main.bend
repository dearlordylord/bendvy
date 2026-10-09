import Base
import ../main.bend as Baseline
import ../admission.bend as Gate
import ../application.bend as App
import ../observation.bend as O
import selector.bend as Select
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/controls.bend as Input
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/declaration.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W

def Descriptor() -> Type: Select.Descriptor<Baseline.Schema,Input.Owner,App.resource_identity(~Baseline.Schema),Input.project>
def constructed(codec:D.Codec,decode:Maybe<&2,D.Codec>) -> Descriptor():
  Select.Constructed{Decl.constructed(~Baseline.Schema,~Input.Owner,~App.resource_identity(~Baseline.Schema),~Input.project,codec),decode}
def admitted(before:O.Snapshot,result:Gate.Returned<App.World(~Baseline.Schema),Input.Owner,App.Output<Baseline.Schema>>) -> Baseline.Observation:
  match result:
    case Gate.ValidationRefused{world,owner,error}: Baseline.observed_after(~Baseline.Schema,before,Baseline.ValidationRefused{Baseline.payload(owner),error},None{},None{},O.snapshot(~Baseline.Schema,world))
    case Gate.Admitted{world,value,canonical}: Baseline.observed_after(~Baseline.Schema,before,Baseline.output(~Baseline.Schema,value),Some{canonical},None{},O.snapshot(~Baseline.Schema,world))
def before(descriptor:Descriptor(),raw:D.Raw,result:App.World(~Baseline.Schema) & O.Snapshot) -> Baseline.Observation:
  match result:
    case (world,before): admitted(before,Select.initialize(~Baseline.Schema,~App.World(~Baseline.Schema),~Input.Owner,~App.Output<Baseline.Schema>,~App.resource_identity(~Baseline.Schema),~Input.project,~App.resource(~Baseline.Schema),descriptor,world,Input.Owner{raw,ANode{ALeaf{111},ALeaf{222}}}))
def created(descriptor:Descriptor(),raw:D.Raw,result:W.Creation<Baseline.Schema,App.Store(~Baseline.Schema),Input.Owner,Unit>) -> Baseline.Observation:
  match result:
    case W.Created{factory,world}: before(descriptor,raw,O.snapshot(~Baseline.Schema,W.enqueue(~Baseline.Schema,~App.Store(~Baseline.Schema),~Input.Owner,~Unit,Baseline.mark(~Baseline.Schema,world),Baseline.mark(~Baseline.Schema))))
    case W.CreateRejected{factory,resource}: Baseline.CreateRefused{Baseline.payload(resource)}
def initialize(descriptor:Descriptor(),raw:D.Raw) -> Baseline.Observation:
  created(descriptor,raw,W.create(~Baseline.Schema,~App.Store(~Baseline.Schema),~Input.Owner,~Unit,~Baseline.empty(~Baseline.Schema),W.factory(),Input.Owner{D.Text{"initial-resource"},ANode{ALeaf{555},ALeaf{666}}}))
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
