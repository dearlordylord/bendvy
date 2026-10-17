import Base
import ./restore-schema.bend as Basic
import ./snapshot-schema.bend as Save
import ./restore-data.bend as R
import ./relation-commands.bend as Relation
import ./relation-types.bend as G
import ./owner-product.bend as Product
import ./ordinary-schema.bend as Ordinary
import ./world.bend as W
import ./decode-data.bend as D
def cleared(~S:Data,~C:Type,graph:G.Graph<S>,result:C & List<&2,R.Change<S>>) -> Relation.Store<S,C> & List<&2,R.Change<S>>:
  match result:
    case (components,changes):(Relation.Store{components,graph},changes)
def clear(~S:Data,~C:Type,~clearBase:C -> W.Handle<S> -> C & List<&2,R.Change<S>>,store:Relation.Store<S,C>,handle:W.Handle<S>) -> Relation.Store<S,C> & List<&2,R.Change<S>>:
  match store:
    case Relation.Store{components,graph}:cleared(~S,~C,graph,clearBase(components,handle))
def inserted(~S:Data,~C:Type,~Resources:Type,~Machines:Type,~State:Type,graph:G.Graph<S>,machines:Machines,result:(C & Resources) & State) -> (Relation.Store<S,C> & Product.Owner<Resources,Machines>) & State:
  match result:
    case ((components,resources),state):((Relation.Store{components,graph},Product.Owner{resources,machines}),state)
def insert(~S:Data,~C:Type,~Resources:Type,~Machines:Type,~State:Type,~Custom:Data,~stage:State -> R.Position -> D.Field -> State & R.Dispatch<Custom>,~release:State -> State,~clearBase:C -> W.Handle<S> -> C & List<&2,R.Change<S>>,~insertBase:C -> Resources -> State -> List<&2,R.Binding<S>> -> U32 -> (C & Resources) & State,store:Relation.Store<S,C>,resources:Product.Owner<Resources,Machines>,state:State,bindings:List<&2,R.Binding<S>>,tick:U32) -> (Relation.Store<S,C> & Product.Owner<Resources,Machines>) & State:
  match store resources:
    case Relation.Store{components,graph} Product.Owner{resource,machines}:inserted(~S,~C,~Resources,~Machines,~State,graph,machines,insertBase(components,resource,state,bindings,tick))
def lift(~S:Data,~C:Type,~Resources:Type,~Machines:Type,~State:Type,~Custom:Data,~stage:State -> R.Position -> D.Field -> State & R.Dispatch<Custom>,~release:State -> State,~clearBase:C -> W.Handle<S> -> C & List<&2,R.Change<S>>,~insertBase:C -> Resources -> State -> List<&2,R.Binding<S>> -> U32 -> (C & Resources) & State,~Recovery:Type,~commit:State -> State,~takeRecovery:State -> State & Recovery,schema:Basic.Schema<S,C,Resources,State,Custom,stage,release,clearBase,insertBase,Recovery,commit,takeRecovery>) -> Basic.Schema<S,Relation.Store<S,C>,Product.Owner<Resources,Machines>,State,Custom,stage,release,clear(~S,~C,~clearBase),insert(~S,~C,~Resources,~Machines,~State,~Custom,~stage,~release,~clearBase,~insertBase),Recovery,commit,takeRecovery>:
  match schema:
    case Basic.Schema{Ordinary.Schema{entries}}:Basic.Schema{Ordinary.Schema{entries}}
def component_saved(~S:Data,~C:Type,graph:G.Graph<S>,result:C & List<&2,D.Field>) -> Relation.Store<S,C> & List<&2,D.Field>:
  match result:
    case (components,fields):(Relation.Store{components,graph},fields)
def save_components(~S:Data,~C:Type,~components:U32 -> C -> C & List<&2,D.Field>,id:U32,store:Relation.Store<S,C>) -> Relation.Store<S,C> & List<&2,D.Field>:
  match store:
    case Relation.Store{owner,graph}:component_saved(~S,~C,graph,components(id,owner))
def resource_saved(~Resources:Type,~Machines:Type,machines:Machines,result:Resources & List<&2,D.Field>) -> Product.Owner<Resources,Machines> & List<&2,D.Field>:
  match result:
    case (resources,fields):(Product.Owner{resources,machines},fields)
def save_resources(~Resources:Type,~Machines:Type,~resources:Resources -> Resources & List<&2,D.Field>,owner:Product.Owner<Resources,Machines>) -> Product.Owner<Resources,Machines> & List<&2,D.Field>:
  match owner:
    case Product.Owner{owner,machines}:resource_saved(~Resources,~Machines,machines,resources(owner))
def save_schema(~S:Data,~C:Type,~Resources:Type,~Machines:Type,~components:U32 -> C -> C & List<&2,D.Field>,~resources:Resources -> Resources & List<&2,D.Field>,schema:Save.Schema<S,C,Resources,True{},components,resources>) -> Save.Schema<S,Relation.Store<S,C>,Product.Owner<Resources,Machines>,True{},save_components(~S,~C,~components),save_resources(~Resources,~Machines,~resources)>:
  match schema:
    case Save.Schema{Ordinary.Schema{entries}}:Save.Schema{Ordinary.Schema{entries}}
