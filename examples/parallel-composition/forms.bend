import Base
import ./schema.bend as Schema
import ./feature-motion.bend as Motion
import ./feature-labels.bend as Labels
import ./observation.bend as Observe
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-composer-schema.bend as Init
import ../../src/ecs/execution-composer-service.bend as Service
import ../../src/ecs/persistence-declaration.bend as Persist
import ../../src/ecs/decode-data.bend as Decode
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/world.bend as W
import ../../test-fixtures/common/column-observation.bend as Common

def raw(value:Decode.Raw) -> String:
  match value:
    case Decode.BendvyText{value}:"text:" ++ value
    case Decode.Number{value}:"number:" ++ U32.show(value)
    case _:"other-raw"
def checked(value:Decode.Checked) -> String:
  match value:
    case Decode.Accepted{value}:"accepted:" ++ raw(value)
    case Decode.Rejected{Decode.Invalid{path,expected,actual}}:"rejected:" ++ path ++ ":" ++ expected ++ ":" ++ raw(actual)
    case Decode.Rejected{Decode.FuelExhausted{path}}:"exhausted:" ++ path
def receipt(value:Decode.Receipt<Labels.Label>) -> String:
  match value:
    case Decode.Receipt{owner,result}:checked(result) ++ "/owner=" ++ Common.projected(~Labels.Label,Labels.label(owner))
def validation() -> String:
  "valid=" ++ receipt(Persist.validate(~Schema.Nominal,~Labels.Label,~Schema.label_id(),~Labels.raw_label,Schema.label_form(),Labels.Label{ALeaf{"VALID-906"},"seed"})) ++ ";invalid=" ++ receipt(Persist.validate(~Schema.Nominal,~Labels.Label,~Schema.label_id(),~Labels.raw_label,Schema.label_form(),Labels.Label{ALeaf{"REJECT-907"},"bad"})) ++ ";optional-none=" ++ Common.projected(~Maybe<&1,Array<String>>,Schema.optional(None{})) ++ ";optional-some=" ++ Common.projected(~Maybe<&1,Array<String>>,Schema.optional(Some{ALeaf{"OPTIONAL-905"}}))
def view(owner:Array<U32>) -> Array<U32> & U32:Array.get(U32,owner,0)
def collision() -> Layout.Layout:Layout.LayoutPair{Layout.LayoutLeaf{Array<U32>,U32,view,"duplicate"},Layout.LayoutLeaf{Array<U32>,U32,view,"duplicate"}}
def raw_resources() -> Schema.Resources():
  Product.Owner{Layout.ResourceSlot{Layout.Viewed{Motion.Counter{ALeaf{301},0,Some{ALeaf{302}}},"STALE"}},Product.Owner{Layout.ResourceSlot{Layout.Viewed{Service.Provided{Labels.Host{ALeaf{"REFUSAL-HOST-904"},9}},Service.Status{Some{"STALE"}}}},Layout.ResourceSlot{Layout.Viewed{Some{ALeaf{"OPTIONAL-303"}},"STALE"}}}}
def refused(~components:Layout.Layout,result:Init.Initialized<Schema.Nominal,components,Schema.resources(),Unit>) -> String:
  match result:
    case Init.SchemaRefused{W.Factory{next},owners,error}:Observe.schema_error(error) ++ ";factory=" ++ U32.show(next) ++ ";" ++ Observe.resources(owners)
    case Init.NamespaceRefused{W.Factory{next},owners}:"namespace-refused;factory=" ++ U32.show(next) ++ ";" ++ Observe.resources(owners)
    case _:"unexpected-created"
def schema_refusal() -> String:refused(~collision(),Init.create(~Schema.Nominal,~collision(),~Schema.resources(),~Unit,W.factory(),raw_resources()))
def namespace_refusal() -> String:refused(~Schema.components(),Init.create(~Schema.Nominal,~Schema.components(),~Schema.resources(),~Unit,W.Factory{4294967295},raw_resources()))
