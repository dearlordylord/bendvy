import Base
import ../../../src/ecs/restore-leaf.bend as Stage
import ../../../src/ecs/snapshot-leaf.bend as Leaf
import bad-constructor.bend as Bad
import ../basic-world-statefree-v1/schema.bend as Original
import ../basic-world-statefree-v1/factory.bend as Factory
import ../../../src/ecs/restore-schema.bend as Schema
import ../../../src/ecs/restore-public.bend as Public
import ../../../src/ecs/restore-data.bend as R
import ../../../src/ecs/decode-data.bend as D
import ../../../src/ecs/owner-product.bend as Owner
import ../../../src/ecs/world.bend as W

def FullStore(~S:Data) -> Type:Original.FullStore(~S)
def FullResources(~S:Data) -> Type:Original.FullResources(~S)
def FullState(~S:Data) -> Type:Original.FullState(~S)
def FullRecovery(~S:Data) -> Type:Original.FullRecovery(~S)
def UserStore(~S:Data) -> Type:Original.UserStore(~S)
def UserResources(~S:Data) -> Type:Original.UserResources(~S)
def UserState(~S:Data) -> Type:Original.UserState(~S)
def UserRecovery(~S:Data) -> Type:Original.UserRecovery(~S)
def ComponentStore(~S:Data) -> Type:Original.ComponentStore(~S)
def ComponentResources(~S:Data) -> Type:Original.ComponentResources(~S)
def ComponentState(~S:Data) -> Type:Original.ComponentState(~S)
def ComponentRecovery(~S:Data) -> Type:Original.ComponentRecovery(~S)
def ResourceGroupStore(~S:Data) -> Type:Original.ResourceGroupStore(~S)
def ResourceGroupResources(~S:Data) -> Type:Original.ResourceGroupResources(~S)
def ResourceGroupState(~S:Data) -> Type:Original.ResourceGroupState(~S)
def ResourceGroupRecovery(~S:Data) -> Type:Original.ResourceGroupRecovery(~S)
def Events(~S:Data) -> Data:Original.Events(~S)
def Logs() -> Type:Original.Logs()
def Full_release(~S:Data) -> (FullState(~S) -> FullState(~S)):Original.Full_release(~S)
def Full_clear(~S:Data) -> (FullStore(~S) -> W.Handle<S> -> FullStore(~S) & List<&2,R.Change<S>>):Original.Full_clear(~S)
def Full_commit(~S:Data) -> (FullState(~S) -> FullState(~S)):Original.Full_commit(~S)
def Full_take(~S:Data) -> (FullState(~S) -> FullState(~S) & FullRecovery(~S)):Original.Full_take(~S)
def Component_stage(~S:Data) -> (ComponentState(~S) -> R.Position -> D.Field -> ComponentState(~S) & R.Dispatch<String>):
  Schema.component_stage(~S,~Factory.Context,~Factory.Input<S>,~Factory.Payload<S>,~String,~Factory.component_identity(~S),~Factory.project(~S),~Factory.incoming(~S),~Bad.build(~S),~Bad.factory(~S),~Factory.supply(~S))
def ComponentSchema(~S:Data) -> Data:Schema.Schema<S,Leaf.Component<S,Factory.Payload<S>,Factory.component_identity(~S),Factory.project(~S)>,Unit,Stage.State<Factory.Context,Factory.Input<S>,Factory.Payload<S>>,String,Component_stage(~S),Original.Component_release(~S),Original.Component_clear(~S),Original.Component_insert(~S),List<Factory.Input<S>>,Original.Component_commit(~S),Original.Component_take(~S)>
def Component_schema(~S:Data) -> ComponentSchema(~S):
  Schema.component(~S,~Factory.Context,~Factory.Input<S>,~Factory.Payload<S>,~String,~Factory.component_identity(~S),~Factory.project(~S),~Factory.incoming(~S),~Bad.build(~S),~Bad.factory(~S),~Factory.supply(~S))
def User_stage(~S:Data) -> (UserState(~S) -> R.Position -> D.Field -> UserState(~S) & R.Dispatch<String>):
  Schema.product_stage(~S,~ComponentStore(~S),~ComponentResources(~S),~ResourceGroupStore(~S),~ResourceGroupResources(~S),~ComponentState(~S),~ResourceGroupState(~S),~String,~Component_stage(~S),~Original.Component_release(~S),~Original.Component_clear(~S),~Original.Component_insert(~S),~Original.ResourceGroup_stage(~S),~Original.ResourceGroup_release(~S),~Original.ResourceGroup_clear(~S),~Original.ResourceGroup_insert(~S))
def User_insert(~S:Data) -> (UserStore(~S) -> UserResources(~S) -> UserState(~S) -> List<&2,R.Binding<S>> -> U32 -> (UserStore(~S) & UserResources(~S)) & UserState(~S)):
  Schema.product_insert(~S,~ComponentStore(~S),~ComponentResources(~S),~ResourceGroupStore(~S),~ResourceGroupResources(~S),~ComponentState(~S),~ResourceGroupState(~S),~String,~Component_stage(~S),~Original.Component_release(~S),~Original.Component_clear(~S),~Original.Component_insert(~S),~Original.ResourceGroup_stage(~S),~Original.ResourceGroup_release(~S),~Original.ResourceGroup_clear(~S),~Original.ResourceGroup_insert(~S))
def UserSchema(~S:Data) -> Data:Schema.Schema<S,Owner.Owner<ComponentStore(~S),ResourceGroupStore(~S)>,Owner.Owner<ComponentResources(~S),ResourceGroupResources(~S)>,Owner.Owner<ComponentState(~S),ResourceGroupState(~S)>,String,User_stage(~S),Original.User_release(~S),Original.User_clear(~S),User_insert(~S),Owner.Owner<ComponentRecovery(~S),ResourceGroupRecovery(~S)>,Original.User_commit(~S),Original.User_take(~S)>
def User_schema(~S:Data) -> UserSchema(~S):
  Schema.product(~S,~ComponentStore(~S),~ComponentResources(~S),~ResourceGroupStore(~S),~ResourceGroupResources(~S),~ComponentState(~S),~ResourceGroupState(~S),~String,~Component_stage(~S),~Original.Component_release(~S),~Original.Component_clear(~S),~Original.Component_insert(~S),~Original.ResourceGroup_stage(~S),~Original.ResourceGroup_release(~S),~Original.ResourceGroup_clear(~S),~Original.ResourceGroup_insert(~S),~ComponentRecovery(~S),~ResourceGroupRecovery(~S),~Original.Component_commit(~S),~Original.ResourceGroup_commit(~S),~Original.Component_take(~S),~Original.ResourceGroup_take(~S),Component_schema(~S),Original.ResourceGroup_schema(~S))
def Full_stage(~S:Data) -> (FullState(~S) -> R.Position -> D.Field -> FullState(~S) & R.Dispatch<String>):
  User_stage(~S)
def Full_insert(~S:Data) -> (FullStore(~S) -> FullResources(~S) -> FullState(~S) -> List<&2,R.Binding<S>> -> U32 -> (FullStore(~S) & FullResources(~S)) & FullState(~S)):
  Schema.events_insert(~S,~UserStore(~S),~UserResources(~S),~Logs(),~UserState(~S),~String,~User_stage(~S),~Original.User_release(~S),~Original.User_clear(~S),~User_insert(~S))
def FullSchema(~S:Data) -> Data:Schema.Schema<S,UserStore(~S),Owner.Owner<UserResources(~S),Logs()>,UserState(~S),String,Full_stage(~S),Original.Full_release(~S),Original.Full_clear(~S),Full_insert(~S),UserRecovery(~S),Original.Full_commit(~S),Original.Full_take(~S)>
def Full_schema(~S:Data) -> FullSchema(~S):
  Schema.with_events(~S,~UserStore(~S),~UserResources(~S),~Logs(),~UserState(~S),~String,~User_stage(~S),~Original.User_release(~S),~Original.User_clear(~S),~User_insert(~S),~UserRecovery(~S),~Original.User_commit(~S),~Original.User_take(~S),User_schema(~S))
def Owned(~S:Data) -> Type:Public.Owner<S,FullStore(~S),FullResources(~S),FullState(~S),String,Full_stage(~S),Original.Full_release(~S),Original.Full_clear(~S),Full_insert(~S),FullRecovery(~S),Original.Full_commit(~S),Original.Full_take(~S)>
def World(~S:Data) -> Type:W.World<S,FullStore(~S),FullResources(~S),Events(~S)>
def initial_state(~S:Data,value:Original.Owned(~S)) -> FullState(~S):
  match value:
    case Public.Owner{_,state}:state
def initial(~S:Data) -> Owned(~S):Public.Owner{Full_schema(~S),initial_state(~S,Original.initial(~S))}
