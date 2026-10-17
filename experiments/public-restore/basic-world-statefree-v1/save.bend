import Base
import model.bend as F
import factory.bend as Factory
import ../../../src/ecs/snapshot-schema.bend as Schema
import ../../../src/ecs/snapshot-leaf.bend as Leaf
import ../../../src/ecs/snapshot-product.bend as Product
import ../../../src/ecs/restore-save.bend as Lift
import ../../../src/ecs/snapshot.bend as Save
import ../../../src/ecs/snapshot-data.bend as Snapshot
import ../../../src/ecs/decode-data.bend as D
import ../../../src/ecs/owner-product.bend as Owner
def Component_components(~S:Data) -> (U32 -> F.ComponentStore(~S) -> F.ComponentStore(~S) & List<&2,D.Field>):Leaf.component_fields(~S,~Factory.Payload<S>,~Factory.component_identity(~S),~Factory.project(~S))
def Component_resources(~S:Data) -> (Unit -> Unit & List<&2,D.Field>):Schema.unit_resource
def ComponentSchema(~S:Data) -> Data:Schema.Schema<S,F.ComponentStore(~S),Unit,True{},Component_components(~S),Component_resources(~S)>
def Component_schema(~S:Data) -> ComponentSchema(~S):Schema.component(~S,~Factory.Payload<S>,~Factory.component_identity(~S),~Factory.project(~S))
def Resource_components(~S:Data) -> (U32 -> Unit -> Unit & List<&2,D.Field>):Schema.unit_component
def Resource_resources(~S:Data) -> (F.ResourceResources(~S) -> F.ResourceResources(~S) & List<&2,D.Field>):Leaf.resource_fields(~S,~Factory.Payload<S>,~Factory.resource_identity(~S),~Factory.project(~S))
def ResourceSchema(~S:Data) -> Data:Schema.Schema<S,Unit,F.ResourceResources(~S),True{},Resource_components(~S),Resource_resources(~S)>
def Resource_schema(~S:Data) -> ResourceSchema(~S):Schema.resource(~S,~Factory.Payload<S>,~Factory.resource_identity(~S),~Factory.project(~S))
def Transient_components(~S:Data) -> (U32 -> Unit -> Unit & List<&2,D.Field>):Schema.unit_component
def Transient_resources(~S:Data) -> (F.TransientResources(~S) -> F.TransientResources(~S) & List<&2,D.Field>):Leaf.transient_resource_fields(~S,~Array<U32>,~Factory.transient_identity(~S))
def TransientSchema(~S:Data) -> Data:Schema.Schema<S,Unit,F.TransientResources(~S),True{},Transient_components(~S),Transient_resources(~S)>
def Transient_schema(~S:Data) -> TransientSchema(~S):Schema.transient_resource(~S,~Array<U32>,~Factory.transient_identity(~S))
def ResourceGroup_components(~S:Data) -> (U32 -> Owner.Owner<Unit,Unit> -> Owner.Owner<Unit,Unit> & List<&2,D.Field>):Product.product_components(~Unit,~Unit,~Resource_components(~S),~Transient_components(~S))
def ResourceGroup_resources(~S:Data) -> (Owner.Owner<F.ResourceResources(~S),F.TransientResources(~S)> -> Owner.Owner<F.ResourceResources(~S),F.TransientResources(~S)> & List<&2,D.Field>):Product.product_resources(~F.ResourceResources(~S),~F.TransientResources(~S),~Resource_resources(~S),~Transient_resources(~S))
def ResourceGroupSchema(~S:Data) -> Data:Schema.Schema<S,Owner.Owner<Unit,Unit>,Owner.Owner<F.ResourceResources(~S),F.TransientResources(~S)>,True{},ResourceGroup_components(~S),ResourceGroup_resources(~S)>
def ResourceGroup_schema(~S:Data) -> ResourceGroupSchema(~S):Product.product(~S,~Unit,~F.ResourceResources(~S),~Unit,~F.TransientResources(~S),~True{},~True{},~Resource_components(~S),~Resource_resources(~S),~Transient_components(~S),~Transient_resources(~S),Resource_schema(~S),Transient_schema(~S))
def User_components(~S:Data) -> (U32 -> Owner.Owner<F.ComponentStore(~S),Owner.Owner<Unit,Unit>> -> Owner.Owner<F.ComponentStore(~S),Owner.Owner<Unit,Unit>> & List<&2,D.Field>):Product.product_components(~F.ComponentStore(~S),~Owner.Owner<Unit,Unit>,~Component_components(~S),~ResourceGroup_components(~S))
def User_resources(~S:Data) -> (Owner.Owner<Unit,Owner.Owner<F.ResourceResources(~S),F.TransientResources(~S)>> -> Owner.Owner<Unit,Owner.Owner<F.ResourceResources(~S),F.TransientResources(~S)>> & List<&2,D.Field>):Product.product_resources(~Unit,~Owner.Owner<F.ResourceResources(~S),F.TransientResources(~S)>,~Component_resources(~S),~ResourceGroup_resources(~S))
def UserSchema(~S:Data) -> Data:Schema.Schema<S,Owner.Owner<F.ComponentStore(~S),Owner.Owner<Unit,Unit>>,Owner.Owner<Unit,Owner.Owner<F.ResourceResources(~S),F.TransientResources(~S)>>,True{},User_components(~S),User_resources(~S)>
def User_schema(~S:Data) -> UserSchema(~S):Product.product(~S,~F.ComponentStore(~S),~Unit,~Owner.Owner<Unit,Unit>,~Owner.Owner<F.ResourceResources(~S),F.TransientResources(~S)>,~True{},~True{},~Component_components(~S),~Component_resources(~S),~ResourceGroup_components(~S),~ResourceGroup_resources(~S),Component_schema(~S),ResourceGroup_schema(~S))
def full_resources(~S:Data) -> (F.FullResources(~S) -> F.FullResources(~S) & List<&2,D.Field>):Lift.resources(~F.UserResources(~S),~F.Logs(),~User_resources(~S))
def schema(~S:Data) -> Schema.Schema<S,F.FullStore(~S),F.FullResources(~S),True{},User_components(~S),full_resources(~S)>:Lift.with_events(~S,~F.FullStore(~S),~F.UserResources(~S),~F.Logs(),~User_components(~S),~User_resources(~S),User_schema(~S))
def save(~S:Data,world:F.World(~S)) -> F.World(~S) & Snapshot.Snapshot:Save.save(~S,~F.FullStore(~S),~F.FullResources(~S),~F.Events(~S),~User_components(~S),~full_resources(~S),schema(~S),world)
