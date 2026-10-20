import Base
import ./restore-graph-data.bend as R
import ./world.bend as W
import ./relation-commands.bend as Relation
import ./owner-product.bend as Product
import ./decode-data.bend as D
import ./snapshot-data.bend as Basic
import ./entity-key.bend as Key
import ./relation-types.bend as G
import ./relation-graph.bend as Graph
import ./relation-failure-reader.bend as Ordinary

def included(found:Bool,target:Key.Key,sources:List<&2,Key.Key>,rest:List<&2,R.Group>) -> List<&2,R.Group>:
  match found:
    case True{}:R.Group{target,sources} <> rest
    case False{}:rest
def groups(~S:Data,entries:List<&2,G.Inverse<S>>,+descriptor:G.Descriptor<S>) -> List<&2,R.Group>:
  match entries:
    case []:[]
    case G.Inverse{other,target,sources} <> rest:included(U32.is_eq(Graph.key(~S,descriptor),Graph.key(~S,other)),target,sources,groups(~S,rest,descriptor))
def relations(~S:Data,declarations:List<&2,Ordinary.Declaration<S>>,+graph:G.Graph<S>) -> List<&2,R.Relation>:
  match declarations graph:
    case [] _:[]
    case Ordinary.Declaration{+descriptor} <> rest G.Graph{+edges,+inverses}:R.Relation{Graph.name(~S,descriptor),groups(~S,inverses,descriptor)} <> relations(~S,rest,G.Graph{edges,inverses})
def machine_read_joined(~Resources:Type,~Machines:Type,resource:Resources,result:Machines & List<&2,D.Field>) -> Product.Owner<Resources,Machines> & List<&2,D.Field>:
  match result:
    case (machines,fields):(Product.Owner{resource,machines},fields)
def machine_read(~Resources:Type,~Machines:Type,~readMachines:Machines -> Machines & List<&2,D.Field>,resource:Product.Owner<Resources,Machines>) -> Product.Owner<Resources,Machines> & List<&2,D.Field>:
  match resource:
    case Product.Owner{resource,machines}:machine_read_joined(~Resources,~Machines,resource,readMachines(machines))
def machine_joined(~S:Data,~C:Type,~Resources:Type,~Machines:Type,~E:Data,~readMachines:Machines -> Machines & List<&2,D.Field>,basic:Basic.Snapshot,relations:List<&2,R.Relation>,result:W.World<S,Relation.Store<S,C>,Product.Owner<Resources,Machines>,E> & List<&2,D.Field>) -> W.World<S,Relation.Store<S,C>,Product.Owner<Resources,Machines>,E> & Basic.Outcome<R.Snapshot>:
  match result:
    case (world,machines):(world,Basic.Saved{R.Snapshot{basic,relations,machines}})
def graph_joined(~S:Data,~C:Type,~Resources:Type,~Machines:Type,~E:Data,~readMachines:Machines -> Machines & List<&2,D.Field>,basic:Basic.Snapshot,declarations:List<&2,Ordinary.Declaration<S>>,result:W.World<S,Relation.Store<S,C>,Product.Owner<Resources,Machines>,E> & G.Graph<S>) -> W.World<S,Relation.Store<S,C>,Product.Owner<Resources,Machines>,E> & Basic.Outcome<R.Snapshot>:
  match result:
    case (world,graph):machine_joined(~S,~C,~Resources,~Machines,~E,~readMachines,basic,relations(~S,declarations,graph),W.observe_resource(~S,~Relation.Store<S,C>,~Product.Owner<Resources,Machines>,~E,~List<&2,D.Field>,~machine_read(~Resources,~Machines,~readMachines),world))
def basic_joined(~S:Data,~C:Type,~Resources:Type,~Machines:Type,~E:Data,~readMachines:Machines -> Machines & List<&2,D.Field>,declarations:List<&2,Ordinary.Declaration<S>>,result:W.World<S,Relation.Store<S,C>,Product.Owner<Resources,Machines>,E> & Basic.Outcome<Basic.Snapshot>) -> W.World<S,Relation.Store<S,C>,Product.Owner<Resources,Machines>,E> & Basic.Outcome<R.Snapshot>:
  match result:
    case (world,Basic.RefusedPending{}):(world,Basic.RefusedPending{})
    case (world,Basic.Saved{basic}):graph_joined(~S,~C,~Resources,~Machines,~E,~readMachines,basic,declarations,W.with_store(~S,~Relation.Store<S,C>,~Product.Owner<Resources,Machines>,~E,~G.Graph<S>,Relation.graph_read(~S,~C),world))
def save_ready(~S:Data,~C:Type,~Resources:Type,~Machines:Type,~E:Data,~readMachines:Machines -> Machines & List<&2,D.Field>,~saveBasic:W.World<S,Relation.Store<S,C>,Product.Owner<Resources,Machines>,E> -> W.World<S,Relation.Store<S,C>,Product.Owner<Resources,Machines>,E> & Basic.Outcome<Basic.Snapshot>,declarations:List<&2,Ordinary.Declaration<S>>,result:W.World<S,Relation.Store<S,C>,Product.Owner<Resources,Machines>,E> & Bool) -> W.World<S,Relation.Store<S,C>,Product.Owner<Resources,Machines>,E> & Basic.Outcome<R.Snapshot>:
  match result:
    case (world,False{}):(world,Basic.RefusedPending{})
    case (world,True{}):basic_joined(~S,~C,~Resources,~Machines,~E,~readMachines,declarations,saveBasic(world))
# Save graph and committed machine values only after structural admission.
# RefusedPending preserves World and skips even saveBasic/readMachines callbacks.
# Separate queued machine transitions remain outside this committed-value snapshot;
# this operation neither rejects them nor applies a machine marker/barrier.
def save(~S:Data,~C:Type,~Resources:Type,~Machines:Type,~E:Data,~readMachines:Machines -> Machines & List<&2,D.Field>,~saveBasic:W.World<S,Relation.Store<S,C>,Product.Owner<Resources,Machines>,E> -> W.World<S,Relation.Store<S,C>,Product.Owner<Resources,Machines>,E> & Basic.Outcome<Basic.Snapshot>,declarations:List<&2,Ordinary.Declaration<S>>,world:W.World<S,Relation.Store<S,C>,Product.Owner<Resources,Machines>,E>) -> W.World<S,Relation.Store<S,C>,Product.Owner<Resources,Machines>,E> & Basic.Outcome<R.Snapshot>:
  save_ready(~S,~C,~Resources,~Machines,~E,~readMachines,~saveBasic,declarations,Basic.ready(~S,~Relation.Store<S,C>,~Product.Owner<Resources,Machines>,~E,world))
