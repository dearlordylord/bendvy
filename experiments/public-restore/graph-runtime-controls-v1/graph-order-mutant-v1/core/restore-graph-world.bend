import Base
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/ordinary-machine-initialization.bend as Init
import ../../../../../src/ecs/relation-types.bend as G
import ../../../../../src/ecs/relation-commands.bend as Relation
import ./restore-graph-mapping.bend as Mapping
import ../../../../../src/ecs/restore-data.bend as Basic
import ../../../../../src/ecs/owner-product.bend as Product
import ../../../../../src/ecs/decode-data.bend as D
import ../../../../../src/ecs/entity-key.bend as Key

type Installed<World:Type> is Type:
  Installed{world:World}
  MissingBinding{world:World,saved:Key.Key}
def store(~S:Data,~C:Type,graph:G.Graph<S>,owner:Relation.Store<S,C>) -> Relation.Store<S,C> & Unit:
  (Relation.graph_replace(~S,~C,owner,graph),Unit{})
def machines(~Resources:Type,~Machines:Type,~clear:Machines -> Machines,~install:Machines -> List<&2,D.Field> -> Machines,fields:List<&2,D.Field>,owner:Product.Owner<Resources,Machines>) -> Product.Owner<Resources,Machines> & Unit:
  match owner:
    case Product.Owner{resources,values}:(Product.Owner{resources,install(clear(values),fields)},Unit{})
def joined(~S:Data,~C:Type,~Resources:Type,~Machines:Type,~E:Data,result:W.World<S,Relation.Store<S,C>,Product.Owner<Resources,Machines>,E> & Unit) -> Installed<W.World<S,Relation.Store<S,C>,Product.Owner<Resources,Machines>,E>>:
  match result:
    case (world,_):Installed{world}
def graph_joined(~S:Data,~C:Type,~Resources:Type,~Machines:Type,~E:Data,~clear:Machines -> Machines,~install:Machines -> List<&2,D.Field> -> Machines,fields:List<&2,D.Field>,result:W.World<S,Relation.Store<S,C>,Product.Owner<Resources,Machines>,E> & Unit) -> Installed<W.World<S,Relation.Store<S,C>,Product.Owner<Resources,Machines>,E>>:
  match result:
    case (world,_):joined(~S,~C,~Resources,~Machines,~E,Init.with_resource(~S,~Relation.Store<S,C>,~Product.Owner<Resources,Machines>,~E,~Unit,(owner => machines(~Resources,~Machines,~clear,~install,fields,owner)),world))
def mapped(~S:Data,~C:Type,~Resources:Type,~Machines:Type,~E:Data,~clear:Machines -> Machines,~install:Machines -> List<&2,D.Field> -> Machines,world:W.World<S,Relation.Store<S,C>,Product.Owner<Resources,Machines>,E>,fields:List<&2,D.Field>,result:Mapping.Mapped<S>) -> Installed<W.World<S,Relation.Store<S,C>,Product.Owner<Resources,Machines>,E>>:
  match result:
    case Mapping.MissingBinding{saved}:MissingBinding{world,saved}
    case Mapping.Mapped{graph}:graph_joined(~S,~C,~Resources,~Machines,~E,~clear,~install,fields,W.with_store(~S,~Relation.Store<S,C>,~Product.Owner<Resources,Machines>,~E,~Unit,(owner => store(~S,~C,graph,owner)),world))
def install(~S:Data,~C:Type,~Resources:Type,~Machines:Type,~E:Data,~clear:Machines -> Machines,~install:Machines -> List<&2,D.Field> -> Machines,world:W.World<S,Relation.Store<S,C>,Product.Owner<Resources,Machines>,E>,graph:G.Graph<S>,fields:List<&2,D.Field>,bindings:List<&2,Basic.Binding<S>>) -> Installed<W.World<S,Relation.Store<S,C>,Product.Owner<Resources,Machines>,E>>:
  mapped(~S,~C,~Resources,~Machines,~E,~clear,~install,world,fields,Mapping.remap(~S,graph,bindings))
