import Base
import ../../../../../../../../../../../../../src/ecs/declared-family.bend as Family
import ../../../../../../../../../../../../../src/ecs/component.bend as Cmp
import ../../../../../../../../../../../../../src/ecs/persistence-declaration.bend as Decl
import ../../../../../../../../../../../../../src/ecs/snapshot-leaf.bend as Leaf
import ../../../../../../../../../../../../../src/ecs/snapshot-schema.bend as Schema
import ../../../../../../../../../../../../../src/ecs/snapshot-product.bend as Join
import ../../../../../../../../../../../../../src/ecs/snapshot.bend as Save
import ./legacy-fixture.bend as F
import ../../../../../../../../../../../../../src/ecs/snapshot-data.bend as Export
import ../../../../../../../../../../../../../src/ecs/decode-data.bend as D
import ../../../../../../../../../../../../../src/ecs/world.bend as W
import ../../../../../../../../../../../../../src/ecs/column.bend as Col
import ../../../../../../../../../../../../../src/ecs/ordinary-declaration.bend as Canonical
import ../../../../../../../../../../../../../src/ecs/owner-product.bend as Product

def scratch(~S:Data) -> Canonical.Declaration<S,F.Payload>:
  Canonical.component(~S,~F.Payload,"Scratch")
def settings(~S:Data) -> Canonical.Declaration<S,F.Payload>:
  Canonical.component(~S,~F.Payload,"Settings")
def scratch_settings(~S:Data) -> Canonical.Declaration<S,F.Payload>:
  Canonical.component(~S,~F.Payload,"ScratchSettings")
def Saved(~S:Data) -> Type:
  Leaf.Component<S,F.Payload,F.declaration(~S),F.project>
def Scratch(~S:Data) -> Type:
  Leaf.TransientComponent<S,F.Payload,scratch(~S)>
def Settings(~S:Data) -> Type:
  Leaf.Resource<S,F.Payload,settings(~S),F.project>
def ScratchSettings(~S:Data) -> Type:
  Leaf.TransientResource<S,F.Payload,scratch_settings(~S)>
def Components(~S:Data) -> Type:
  Product.Owner<Saved(~S),Scratch(~S)>
def Resources(~S:Data) -> Type:
  Product.Owner<Settings(~S),ScratchSettings(~S)>
def Store(~S:Data) -> Type:
  Product.Owner<Components(~S),Product.Owner<Unit,Unit>>
def ResourceStore(~S:Data) -> Type:
  Product.Owner<Product.Owner<Unit,Unit>,Resources(~S)>
def component_fields(~S:Data) -> U32 -> Components(~S) -> Components(~S) & List<&2,D.Field>:
  Join.product_components(~Saved(~S),~Scratch(~S),~Leaf.component_fields(~S,~F.Payload,~F.declaration(~S),~F.project),~Leaf.transient_component_fields(~S,~F.Payload,~scratch(~S)))
def resource_fields(~S:Data) -> Resources(~S) -> Resources(~S) & List<&2,D.Field>:
  Join.product_resources(~Settings(~S),~ScratchSettings(~S),~Leaf.resource_fields(~S,~F.Payload,~settings(~S),~F.project),~Leaf.transient_resource_fields(~S,~F.Payload,~scratch_settings(~S)))
def empty_components() -> U32 -> Product.Owner<Unit,Unit> -> Product.Owner<Unit,Unit> & List<&2,D.Field>:
  Join.product_components(~Unit,~Unit,~Schema.unit_component,~Schema.unit_component)
def empty_resources() -> Product.Owner<Unit,Unit> -> Product.Owner<Unit,Unit> & List<&2,D.Field>:
  Join.product_resources(~Unit,~Unit,~Schema.unit_resource,~Schema.unit_resource)
def all_components(~S:Data) -> U32 -> Store(~S) -> Store(~S) & List<&2,D.Field>:
  Join.product_components(~Components(~S),~Product.Owner<Unit,Unit>,~component_fields(~S),~empty_components())
def all_resources(~S:Data) -> ResourceStore(~S) -> ResourceStore(~S) & List<&2,D.Field>:
  Join.product_resources(~Product.Owner<Unit,Unit>,~Resources(~S),~empty_resources(),~resource_fields(~S))
def component_schema(~S:Data) -> Schema.Schema<S,Components(~S),Product.Owner<Unit,Unit>,True{},Join.product_components(~Saved(~S),~Scratch(~S),~Leaf.component_fields(~S,~F.Payload,~F.declaration(~S),~F.project),~Leaf.transient_component_fields(~S,~F.Payload,~scratch(~S))),Join.product_resources(~Unit,~Unit,~Schema.unit_resource,~Schema.unit_resource)>:
  Join.product(~S,~Saved(~S),~Unit,~Scratch(~S),~Unit,~True{},~True{},~Leaf.component_fields(~S,~F.Payload,~F.declaration(~S),~F.project),~Schema.unit_resource,~Leaf.transient_component_fields(~S,~F.Payload,~scratch(~S)),~Schema.unit_resource,Schema.component(~S,~F.Payload,~F.declaration(~S),~F.project),Schema.transient_component(~S,~F.Payload,~scratch(~S)))
def resource_schema(~S:Data) -> Schema.Schema<S,Product.Owner<Unit,Unit>,Resources(~S),True{},Join.product_components(~Unit,~Unit,~Schema.unit_component,~Schema.unit_component),Join.product_resources(~Settings(~S),~ScratchSettings(~S),~Leaf.resource_fields(~S,~F.Payload,~settings(~S),~F.project),~Leaf.transient_resource_fields(~S,~F.Payload,~scratch_settings(~S)))>:
  Join.product(~S,~Unit,~Settings(~S),~Unit,~ScratchSettings(~S),~True{},~True{},~Schema.unit_component,~Leaf.resource_fields(~S,~F.Payload,~settings(~S),~F.project),~Schema.unit_component,~Leaf.transient_resource_fields(~S,~F.Payload,~scratch_settings(~S)),Schema.resource(~S,~F.Payload,~settings(~S),~F.project),Schema.transient_resource(~S,~F.Payload,~scratch_settings(~S)))
def ordinary(~S:Data) -> Schema.Schema<S,Store(~S),ResourceStore(~S),True{},all_components(~S),all_resources(~S)>:
  Join.product(~S,~Components(~S),~Product.Owner<Unit,Unit>,~Product.Owner<Unit,Unit>,~Resources(~S),~True{},~True{},~component_fields(~S),~empty_resources(),~empty_components(),~resource_fields(~S),component_schema(~S),resource_schema(~S))
def save(~S:Data,world:W.World<S,Store(~S),ResourceStore(~S),Unit>) -> W.World<S,Store(~S),ResourceStore(~S),Unit> & Export.Snapshot:
  Save.save(~S,~Store(~S),~ResourceStore(~S),~Unit,~all_components(~S),~all_resources(~S),ordinary(~S),world)
def empty(~S:Data,_:Unit) -> Store(~S):
  Product.Owner{Product.Owner{Leaf.Component{Col.empty(~S,~F.Payload),Decl.constructed(~S,~F.Payload,~F.declaration(~S),~F.project,D.ArrayValue{D.Integer{}})},Leaf.TransientComponent{Col.empty(~S,~F.Payload),Decl.transient(~S,~F.Payload,~scratch(~S))}},Product.Owner{Unit{},Unit{}}}
def initial_resources(~S:Data) -> ResourceStore(~S):
  Product.Owner{Product.Owner{Unit{},Unit{}},Product.Owner{Leaf.Resource{F.payload(27,29),Decl.constructed(~S,~F.Payload,~settings(~S),~F.project,D.Nullable{D.ArrayValue{D.FiniteNumber{}}})},Leaf.TransientResource{F.payload(127,129),Decl.transient(~S,~F.Payload,~scratch_settings(~S))}}}
def take_saved(~S:Data,owner:Store(~S)) -> (Scratch(~S) & Product.Owner<Unit,Unit>) & Saved(~S):
  match owner:
    case Product.Owner{Product.Owner{saved,scratch},units}:((scratch,units),saved)
def put_saved(~S:Data,rest:Scratch(~S) & Product.Owner<Unit,Unit>,saved:Saved(~S)) -> Store(~S):
  match rest:
    case (scratch,units):Product.Owner{Product.Owner{saved,scratch},units}
def saved_family(~S:Data) -> Cmp.Family<S,Store(~S),(Scratch(~S) & Product.Owner<Unit,Unit>) & Decl.Constructed<S,F.Payload,F.declaration(~S),F.project>,F.Payload,D.Raw,S,Family.take_column(~S,~F.Payload,~Store(~S),~Scratch(~S) & Product.Owner<Unit,Unit>,~F.declaration(~S),~F.project,~take_saved(~S)),Family.put_column(~S,~F.Payload,~Store(~S),~Scratch(~S) & Product.Owner<Unit,Unit>,~F.declaration(~S),~F.project,~put_saved(~S)),F.project>:
  Family.family(~S,~F.Payload,~Store(~S),~Scratch(~S) & Product.Owner<Unit,Unit>,~D.Raw,~S,~F.declaration(~S),~F.project,~F.project,~take_saved(~S),~put_saved(~S))
def main() -> U32:
  0
