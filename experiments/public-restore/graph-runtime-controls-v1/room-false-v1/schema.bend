import Base
import ../../basic-world-statefree-v1/factory.bend as Factory
import ./construction.bend as Construction
import ../../../../src/ecs/decode-data.bend as D
import ../../../../src/ecs/restore-data.bend as R
import ../../../../src/ecs/restore-schema.bend as Schema
import ../../../../src/ecs/restore-leaf.bend as Stage
import ../../../../src/ecs/restore-transient.bend as Transient
import ../../../../src/ecs/restore-product.bend as Product
import ../../../../src/ecs/restore-public.bend as Public
import ../../../../src/ecs/snapshot-leaf.bend as Leaf
import ../../../../src/ecs/owner-product.bend as Owner
import ../../../../src/ecs/owned-event-log.bend as Log
import ../../../../src/ecs/event-publication.bend as Publication
import ../../../../src/ecs/world.bend as W

def Events(~S:Data) -> Data:Publication.Publication<Nat,R.Change<S>>
def Logs() -> Type:Owner.Owner<Log.Log<Array<U32>>,Unit>
def ComponentStore(~S:Data) -> Type:Leaf.Component<S,Factory.Payload<S>,Factory.component_identity(~S),Factory.project(~S)>
def ComponentResources(~S:Data) -> Type:Unit
def ComponentState(~S:Data) -> Type:Stage.State<Factory.Context,Factory.Input<S>,Factory.Payload<S>>
def ComponentRecovery(~S:Data) -> Type:List<Factory.Input<S>>
def Component_stage(~S:Data) -> (ComponentState(~S) -> R.Position -> D.Field -> ComponentState(~S) & R.Dispatch<String>):
  Schema.component_stage(~S,~Factory.Context,~Factory.Input<S>,~Factory.Payload<S>,~String,~Factory.component_identity(~S),~Factory.project(~S),~Factory.incoming(~S),~Factory.build(~S),~Factory.component_factory(~S),~Factory.supply(~S))
def Component_release(~S:Data) -> (ComponentState(~S) -> ComponentState(~S)):
  Stage.release(~Factory.Context,~Factory.Input<S>,~Factory.Payload<S>)
def Component_clear(~S:Data) -> (ComponentStore(~S) -> W.Handle<S> -> ComponentStore(~S) & List<&2,R.Change<S>>):
  Schema.component_clear(~S,~Factory.Payload<S>,~Factory.component_identity(~S),~Factory.project(~S))
def Component_insert(~S:Data) -> (ComponentStore(~S) -> ComponentResources(~S) -> ComponentState(~S) -> List<&2,R.Binding<S>> -> U32 -> (ComponentStore(~S) & ComponentResources(~S)) & ComponentState(~S)):
  Schema.component_insert(~S,~Factory.Context,~Factory.Input<S>,~Factory.Payload<S>,~Factory.component_identity(~S),~Factory.project(~S))
def Component_commit(~S:Data) -> (ComponentState(~S) -> ComponentState(~S)):
  Stage.commit(~Factory.Context,~Factory.Input<S>,~Factory.Payload<S>)
def Component_take(~S:Data) -> (ComponentState(~S) -> ComponentState(~S) & ComponentRecovery(~S)):
  Stage.take_recovery(~Factory.Context,~Factory.Input<S>,~Factory.Payload<S>)
def ComponentSchema(~S:Data) -> Data:Schema.Schema<S,Leaf.Component<S,Factory.Payload<S>,Factory.component_identity(~S),Factory.project(~S)>,Unit,Stage.State<Factory.Context,Factory.Input<S>,Factory.Payload<S>>,String,Component_stage(~S),Component_release(~S),Component_clear(~S),Component_insert(~S),List<Factory.Input<S>>,Component_commit(~S),Component_take(~S)>
def Component_schema(~S:Data) -> ComponentSchema(~S):
  Schema.component(~S,~Factory.Context,~Factory.Input<S>,~Factory.Payload<S>,~String,~Factory.component_identity(~S),~Factory.project(~S),~Factory.incoming(~S),~Factory.build(~S),~Factory.component_factory(~S),~Factory.supply(~S))
def ResourceStore(~S:Data) -> Type:Unit
def ResourceResources(~S:Data) -> Type:Leaf.Resource<S,Factory.Payload<S>,Factory.resource_identity(~S),Factory.project(~S)>
def ResourceState(~S:Data) -> Type:Stage.State<Factory.Context,Factory.Input<S>,Factory.Payload<S>>
def ResourceRecovery(~S:Data) -> Type:List<Factory.Input<S>>
def Resource_stage(~S:Data) -> (ResourceState(~S) -> R.Position -> D.Field -> ResourceState(~S) & R.Dispatch<String>):
  Schema.resource_stage(~S,~Factory.Context,~Factory.Input<S>,~Factory.Payload<S>,~String,~Factory.resource_identity(~S),~Factory.project(~S),~Factory.incoming(~S),~Construction.build(~S),~Construction.factory(~S),~Factory.supply(~S))
def Resource_release(~S:Data) -> (ResourceState(~S) -> ResourceState(~S)):
  Stage.release(~Factory.Context,~Factory.Input<S>,~Factory.Payload<S>)
def Resource_clear(~S:Data) -> (ResourceStore(~S) -> W.Handle<S> -> ResourceStore(~S) & List<&2,R.Change<S>>):
  Schema.resource_clear(~S)
def Resource_insert(~S:Data) -> (ResourceStore(~S) -> ResourceResources(~S) -> ResourceState(~S) -> List<&2,R.Binding<S>> -> U32 -> (ResourceStore(~S) & ResourceResources(~S)) & ResourceState(~S)):
  Schema.resource_insert(~S,~Factory.Context,~Factory.Input<S>,~Factory.Payload<S>,~Factory.resource_identity(~S),~Factory.project(~S))
def Resource_commit(~S:Data) -> (ResourceState(~S) -> ResourceState(~S)):
  Stage.commit(~Factory.Context,~Factory.Input<S>,~Factory.Payload<S>)
def Resource_take(~S:Data) -> (ResourceState(~S) -> ResourceState(~S) & ResourceRecovery(~S)):
  Stage.take_recovery(~Factory.Context,~Factory.Input<S>,~Factory.Payload<S>)
def ResourceSchema(~S:Data) -> Data:Schema.Schema<S,Unit,Leaf.Resource<S,Factory.Payload<S>,Factory.resource_identity(~S),Factory.project(~S)>,Stage.State<Factory.Context,Factory.Input<S>,Factory.Payload<S>>,String,Resource_stage(~S),Resource_release(~S),Resource_clear(~S),Resource_insert(~S),List<Factory.Input<S>>,Resource_commit(~S),Resource_take(~S)>
def Resource_schema(~S:Data) -> ResourceSchema(~S):
  Schema.resource(~S,~Factory.Context,~Factory.Input<S>,~Factory.Payload<S>,~String,~Factory.resource_identity(~S),~Factory.project(~S),~Factory.incoming(~S),~Construction.build(~S),~Construction.factory(~S),~Factory.supply(~S))
def TransientStore(~S:Data) -> Type:Unit
def TransientResources(~S:Data) -> Type:Leaf.TransientResource<S,Array<U32>,Factory.transient_identity(~S)>
def TransientState(~S:Data) -> Type:Unit
def TransientRecovery(~S:Data) -> Type:Unit
def Transient_stage(~S:Data) -> (TransientState(~S) -> R.Position -> D.Field -> TransientState(~S) & R.Dispatch<String>):
  Transient.stage(~Unit,~String)
def Transient_release(~S:Data) -> (TransientState(~S) -> TransientState(~S)):
  Transient.release(~Unit)
def Transient_clear(~S:Data) -> (TransientStore(~S) -> W.Handle<S> -> TransientStore(~S) & List<&2,R.Change<S>>):
  Schema.resource_clear(~S)
def Transient_insert(~S:Data) -> (TransientStore(~S) -> TransientResources(~S) -> TransientState(~S) -> List<&2,R.Binding<S>> -> U32 -> (TransientStore(~S) & TransientResources(~S)) & TransientState(~S)):
  Transient.resource_insert(~S,~Array<U32>,~Factory.transient_identity(~S))
def Transient_commit(~S:Data) -> (TransientState(~S) -> TransientState(~S)):
  Transient.release(~Unit)
def Transient_take(~S:Data) -> (TransientState(~S) -> TransientState(~S) & TransientRecovery(~S)):
  Transient.take_recovery(~Unit)
def TransientSchema(~S:Data) -> Data:Schema.Schema<S,Unit,Leaf.TransientResource<S,Array<U32>,Factory.transient_identity(~S)>,Unit,String,Transient_stage(~S),Transient_release(~S),Transient_clear(~S),Transient_insert(~S),Unit,Transient_commit(~S),Transient_take(~S)>
def Transient_schema(~S:Data) -> TransientSchema(~S):
  Schema.transient_resource(~S,~Array<U32>,~String,~Factory.transient_identity(~S))
def ResourceGroupStore(~S:Data) -> Type:Owner.Owner<ResourceStore(~S),TransientStore(~S)>
def ResourceGroupResources(~S:Data) -> Type:Owner.Owner<ResourceResources(~S),TransientResources(~S)>
def ResourceGroupState(~S:Data) -> Type:Owner.Owner<ResourceState(~S),TransientState(~S)>
def ResourceGroupRecovery(~S:Data) -> Type:Owner.Owner<ResourceRecovery(~S),TransientRecovery(~S)>
def ResourceGroup_stage(~S:Data) -> (ResourceGroupState(~S) -> R.Position -> D.Field -> ResourceGroupState(~S) & R.Dispatch<String>):
  Schema.product_stage(~S,~ResourceStore(~S),~ResourceResources(~S),~TransientStore(~S),~TransientResources(~S),~ResourceState(~S),~TransientState(~S),~String,~Resource_stage(~S),~Resource_release(~S),~Resource_clear(~S),~Resource_insert(~S),~Transient_stage(~S),~Transient_release(~S),~Transient_clear(~S),~Transient_insert(~S))
def ResourceGroup_release(~S:Data) -> (ResourceGroupState(~S) -> ResourceGroupState(~S)):
  Product.release(~ResourceState(~S),~TransientState(~S),~Resource_release(~S),~Transient_release(~S))
def ResourceGroup_clear(~S:Data) -> (ResourceGroupStore(~S) -> W.Handle<S> -> ResourceGroupStore(~S) & List<&2,R.Change<S>>):
  Schema.product_clear(~S,~ResourceStore(~S),~TransientStore(~S),~Resource_clear(~S),~Transient_clear(~S))
def ResourceGroup_insert(~S:Data) -> (ResourceGroupStore(~S) -> ResourceGroupResources(~S) -> ResourceGroupState(~S) -> List<&2,R.Binding<S>> -> U32 -> (ResourceGroupStore(~S) & ResourceGroupResources(~S)) & ResourceGroupState(~S)):
  Schema.product_insert(~S,~ResourceStore(~S),~ResourceResources(~S),~TransientStore(~S),~TransientResources(~S),~ResourceState(~S),~TransientState(~S),~String,~Resource_stage(~S),~Resource_release(~S),~Resource_clear(~S),~Resource_insert(~S),~Transient_stage(~S),~Transient_release(~S),~Transient_clear(~S),~Transient_insert(~S))
def ResourceGroup_commit(~S:Data) -> (ResourceGroupState(~S) -> ResourceGroupState(~S)):
  Product.release(~ResourceState(~S),~TransientState(~S),~Resource_commit(~S),~Transient_commit(~S))
def ResourceGroup_take(~S:Data) -> (ResourceGroupState(~S) -> ResourceGroupState(~S) & ResourceGroupRecovery(~S)):
  Product.take_recovery(~ResourceState(~S),~TransientState(~S),~ResourceRecovery(~S),~TransientRecovery(~S),~Resource_take(~S),~Transient_take(~S))
def ResourceGroupSchema(~S:Data) -> Data:Schema.Schema<S,Owner.Owner<ResourceStore(~S),TransientStore(~S)>,Owner.Owner<ResourceResources(~S),TransientResources(~S)>,Owner.Owner<ResourceState(~S),TransientState(~S)>,String,ResourceGroup_stage(~S),ResourceGroup_release(~S),ResourceGroup_clear(~S),ResourceGroup_insert(~S),Owner.Owner<ResourceRecovery(~S),TransientRecovery(~S)>,ResourceGroup_commit(~S),ResourceGroup_take(~S)>
def ResourceGroup_schema(~S:Data) -> ResourceGroupSchema(~S):
  Schema.product(~S,~ResourceStore(~S),~ResourceResources(~S),~TransientStore(~S),~TransientResources(~S),~ResourceState(~S),~TransientState(~S),~String,~Resource_stage(~S),~Resource_release(~S),~Resource_clear(~S),~Resource_insert(~S),~Transient_stage(~S),~Transient_release(~S),~Transient_clear(~S),~Transient_insert(~S),~ResourceRecovery(~S),~TransientRecovery(~S),~Resource_commit(~S),~Transient_commit(~S),~Resource_take(~S),~Transient_take(~S),Resource_schema(~S),Transient_schema(~S))
def UserStore(~S:Data) -> Type:Owner.Owner<ComponentStore(~S),ResourceGroupStore(~S)>
def UserResources(~S:Data) -> Type:Owner.Owner<ComponentResources(~S),ResourceGroupResources(~S)>
def UserState(~S:Data) -> Type:Owner.Owner<ComponentState(~S),ResourceGroupState(~S)>
def UserRecovery(~S:Data) -> Type:Owner.Owner<ComponentRecovery(~S),ResourceGroupRecovery(~S)>
def User_stage(~S:Data) -> (UserState(~S) -> R.Position -> D.Field -> UserState(~S) & R.Dispatch<String>):
  Schema.product_stage(~S,~ComponentStore(~S),~ComponentResources(~S),~ResourceGroupStore(~S),~ResourceGroupResources(~S),~ComponentState(~S),~ResourceGroupState(~S),~String,~Component_stage(~S),~Component_release(~S),~Component_clear(~S),~Component_insert(~S),~ResourceGroup_stage(~S),~ResourceGroup_release(~S),~ResourceGroup_clear(~S),~ResourceGroup_insert(~S))
def User_release(~S:Data) -> (UserState(~S) -> UserState(~S)):
  Product.release(~ComponentState(~S),~ResourceGroupState(~S),~Component_release(~S),~ResourceGroup_release(~S))
def User_clear(~S:Data) -> (UserStore(~S) -> W.Handle<S> -> UserStore(~S) & List<&2,R.Change<S>>):
  Schema.product_clear(~S,~ComponentStore(~S),~ResourceGroupStore(~S),~Component_clear(~S),~ResourceGroup_clear(~S))
def User_insert(~S:Data) -> (UserStore(~S) -> UserResources(~S) -> UserState(~S) -> List<&2,R.Binding<S>> -> U32 -> (UserStore(~S) & UserResources(~S)) & UserState(~S)):
  Schema.product_insert(~S,~ComponentStore(~S),~ComponentResources(~S),~ResourceGroupStore(~S),~ResourceGroupResources(~S),~ComponentState(~S),~ResourceGroupState(~S),~String,~Component_stage(~S),~Component_release(~S),~Component_clear(~S),~Component_insert(~S),~ResourceGroup_stage(~S),~ResourceGroup_release(~S),~ResourceGroup_clear(~S),~ResourceGroup_insert(~S))
def User_commit(~S:Data) -> (UserState(~S) -> UserState(~S)):
  Product.release(~ComponentState(~S),~ResourceGroupState(~S),~Component_commit(~S),~ResourceGroup_commit(~S))
def User_take(~S:Data) -> (UserState(~S) -> UserState(~S) & UserRecovery(~S)):
  Product.take_recovery(~ComponentState(~S),~ResourceGroupState(~S),~ComponentRecovery(~S),~ResourceGroupRecovery(~S),~Component_take(~S),~ResourceGroup_take(~S))
def UserSchema(~S:Data) -> Data:Schema.Schema<S,Owner.Owner<ComponentStore(~S),ResourceGroupStore(~S)>,Owner.Owner<ComponentResources(~S),ResourceGroupResources(~S)>,Owner.Owner<ComponentState(~S),ResourceGroupState(~S)>,String,User_stage(~S),User_release(~S),User_clear(~S),User_insert(~S),Owner.Owner<ComponentRecovery(~S),ResourceGroupRecovery(~S)>,User_commit(~S),User_take(~S)>
def User_schema(~S:Data) -> UserSchema(~S):
  Schema.product(~S,~ComponentStore(~S),~ComponentResources(~S),~ResourceGroupStore(~S),~ResourceGroupResources(~S),~ComponentState(~S),~ResourceGroupState(~S),~String,~Component_stage(~S),~Component_release(~S),~Component_clear(~S),~Component_insert(~S),~ResourceGroup_stage(~S),~ResourceGroup_release(~S),~ResourceGroup_clear(~S),~ResourceGroup_insert(~S),~ComponentRecovery(~S),~ResourceGroupRecovery(~S),~Component_commit(~S),~ResourceGroup_commit(~S),~Component_take(~S),~ResourceGroup_take(~S),Component_schema(~S),ResourceGroup_schema(~S))
def FullStore(~S:Data) -> Type:UserStore(~S)
def FullResources(~S:Data) -> Type:Owner.Owner<UserResources(~S),Logs()>
def FullState(~S:Data) -> Type:UserState(~S)
def FullRecovery(~S:Data) -> Type:UserRecovery(~S)
def Full_stage(~S:Data) -> (FullState(~S) -> R.Position -> D.Field -> FullState(~S) & R.Dispatch<String>):
  User_stage(~S)
def Full_release(~S:Data) -> (FullState(~S) -> FullState(~S)):
  User_release(~S)
def Full_clear(~S:Data) -> (FullStore(~S) -> W.Handle<S> -> FullStore(~S) & List<&2,R.Change<S>>):
  User_clear(~S)
def Full_insert(~S:Data) -> (FullStore(~S) -> FullResources(~S) -> FullState(~S) -> List<&2,R.Binding<S>> -> U32 -> (FullStore(~S) & FullResources(~S)) & FullState(~S)):
  Schema.events_insert(~S,~UserStore(~S),~UserResources(~S),~Logs(),~UserState(~S),~String,~User_stage(~S),~User_release(~S),~User_clear(~S),~User_insert(~S))
def Full_commit(~S:Data) -> (FullState(~S) -> FullState(~S)):
  User_commit(~S)
def Full_take(~S:Data) -> (FullState(~S) -> FullState(~S) & FullRecovery(~S)):
  User_take(~S)
def FullSchema(~S:Data) -> Data:Schema.Schema<S,UserStore(~S),Owner.Owner<UserResources(~S),Logs()>,UserState(~S),String,Full_stage(~S),Full_release(~S),Full_clear(~S),Full_insert(~S),UserRecovery(~S),Full_commit(~S),Full_take(~S)>
def Full_schema(~S:Data) -> FullSchema(~S):
  Schema.with_events(~S,~UserStore(~S),~UserResources(~S),~Logs(),~UserState(~S),~String,~User_stage(~S),~User_release(~S),~User_clear(~S),~User_insert(~S),~UserRecovery(~S),~User_commit(~S),~User_take(~S),User_schema(~S))
def Owned(~S:Data) -> Type:Public.Owner<S,FullStore(~S),FullResources(~S),FullState(~S),String,Full_stage(~S),Full_release(~S),Full_clear(~S),Full_insert(~S),FullRecovery(~S),Full_commit(~S),Full_take(~S)>
def World(~S:Data) -> Type:W.World<S,FullStore(~S),FullResources(~S),Events(~S)>
def initial(~S:Data) -> Owned(~S):
  Public.Owner{Full_schema(~S),Owner.Owner{Stage.empty(~Factory.Context,~Factory.Input<S>,~Factory.Payload<S>,Factory.context(100)),Owner.Owner{Stage.empty(~Factory.Context,~Factory.Input<S>,~Factory.Payload<S>,Factory.context(200)),Unit{}}}}
