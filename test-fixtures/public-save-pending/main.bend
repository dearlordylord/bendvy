import Base
import ../../src/ecs/execution-lifecycle-notices.bend as Notice
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/world.bend as W
import ../../src/ecs/entity-allocator.bend as Alloc
import ../../src/ecs/entity-key.bend as K
import ../../src/ecs/commands.bend as Cmd
import ../../src/ecs/transaction.bend as Tx
import ../../src/ecs/snapshot.bend as Save
import ../../src/ecs/snapshot-data.bend as Data
import ../../src/ecs/snapshot-schema.bend as Schema
import ../../src/ecs/ordinary-schema.bend as Ordinary
import ../../src/ecs/decode-data.bend as D
import ../../src/ecs/restore-graph-save.bend as GraphSave
import ../../src/ecs/restore-graph-data.bend as GraphData
import ../../src/ecs/relation-commands.bend as Rel
import ../../src/ecs/relation-types.bend as G
import ../../src/ecs/relation-failure-reader.bend as Decl
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/machine.bend as M

type S is Data:S{}
type Cell is Type:Cell{token:Array<U32>,calls:U32,log:List<&2,U32>}
type Machines is Type:Machines{token:Array<U32>,slot:M.Slot<S,Unit,U32>,calls:U32}
def cells(value:Array<U32>) -> List<&2,U32>:
  match value:
    case ALeaf{value}:[value]
    case ANode{left,right}:List.append(&2,U32,cells(left),cells(right))
def nums(values:List<&2,U32>) -> String:List.show(&2,U32,U32.show,values)
def cell_text(cell:Cell) -> String:
  match cell:
    case Cell{token,calls,log}:nums(cells(token))++"/"++U32.show(calls)++"/"++nums(log)
def raw_text(raw:D.Raw) -> String:
  match raw:
    case D.Number{value}:U32.show(value)
    case _:"unexpected-raw"
def field_text(field:D.Field) -> String:
  match field:
    case D.Field{name,value}:name++"="++raw_text(value)
def fields(values:List<&2,D.Field>) -> String:List.show(&2,D.Field,field_text,values)
def key_text(key:K.Key) -> String:
  match key:
    case K.EntityKey{index,generation}:U32.show(index)++":"++U32.show(generation)
def entity_text(entity:Data.Entity) -> String:
  match entity:
    case Data.Entity{key,values}:key_text(key)++fields(values)
def snapshot_text(snapshot:Data.Snapshot) -> String:
  match snapshot:
    case Data.Snapshot{version,next,entities,resources}:U32.show(version)++"/"++U32.show(next)++"/"++List.show(&2,Data.Entity,entity_text,entities)++"/"++fields(resources)
def outcome_text(outcome:Data.Outcome<Data.Snapshot>) -> String:
  match outcome:
    case Data.RefusedPending{}:"refused"
    case Data.Saved{snapshot}:"saved:"++snapshot_text(snapshot)
def projected(id:U32,calls:U32,log:List<&2,U32>,result:Array<U32> & U32) -> Cell & List<&2,D.Field>:
  match result:
    case (token,value):(Cell{token,U32.add(calls,1),log},[D.Field{"id",D.Number{id}},D.Field{"value",D.Number{value}}])
def component_fields(id:U32,cell:Cell) -> Cell & List<&2,D.Field>:
  match cell:
    case Cell{token,calls,log}:projected(id,calls,log,Array.get(U32,token,0))
def resource_fields(cell:Cell) -> Cell & List<&2,D.Field>:component_fields(0,cell)
# Explicit closed schema/projector setup isolates the admission boundary.
def schema() -> Schema.Schema<S,Cell,Cell,True{},component_fields,resource_fields>:Schema.Schema{Ordinary.Schema{[]}}
def populate_cell(payload:Array<U32>,cell:Cell) -> Cell & Unit:
  match cell:
    case Cell{token,calls,log}:(Cell{token,calls,List.append(&2,U32,log,cells(payload))},Unit{})
def populated(result:W.World<S,Cell,Cell,U32> & Unit) -> W.World<S,Cell,Cell,U32>:
  match result:
    case (world,_):world
def populate(world:W.World<S,Cell,Cell,U32>,handle:W.Handle<S>,payload:Array<U32>) -> W.World<S,Cell,Cell,U32>:
  populated(W.with_store(~S,~Cell,~Cell,~U32,~Unit,cell => populate_cell(payload,cell),world))
def spawn_done(result:Tx.Tx<W.World<S,Cell,Cell,U32>,U32> & W.Reservation<S>) -> Tx.Tx<W.World<S,Cell,Cell,U32>,U32>:
  match result:
    case (tx,_):tx
def spawn_second(result:Tx.Tx<W.World<S,Cell,Cell,U32>,U32> & W.Reservation<S>) -> Tx.Tx<W.World<S,Cell,Cell,U32>,U32>:
  match result:
    case (tx,_):spawn_done(Cmd.tx_spawn(~S,~Cell,~Cell,~U32,~Array<U32>,~populate,tx,ANode{ALeaf{21},ALeaf{22}}))
def committed(result:Tx.Returned<W.World<S,Cell,Cell,U32>,Unit>) -> W.World<S,Cell,Cell,U32>:
  match result:
    case Tx.Returned{world,_}:world
def stage(world:W.World<S,Cell,Cell,U32>) -> W.World<S,Cell,Cell,U32>:
  committed(Cmd.tx_finish(~S,~Cell,~Cell,~U32,~Unit,spawn_second(Cmd.tx_spawn(~S,~Cell,~Cell,~U32,~Array<U32>,~populate,Tx.begin(~W.World<S,Cell,Cell,U32>,~U32,world),ANode{ALeaf{11},ALeaf{12}})),Tx.Success{}))
def save_basic(world:W.World<S,Cell,Cell,U32>) -> W.World<S,Cell,Cell,U32> & Data.Outcome<Data.Snapshot>:
  Save.save(~S,~Cell,~Cell,~U32,~component_fields,~resource_fields,schema(),world)
def finish_basic(prefix:String,result:W.World<S,Cell,Cell,U32> & Data.Outcome<Data.Snapshot>) -> String:
  match result:
    case (W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,lifecycle},outcome):prefix++outcome_text(outcome)++" owners="++cell_text(store)++";"++cell_text(resource)++" clock="++Tick.show(Clock.now(clock))++"\n"
def refused_count(prefix:String,result:W.World<S,Cell,Cell,U32> & U32) -> String:
  match result:
    case (world,count):finish_basic(prefix++"pending="++U32.show(count)++" retry=",save_basic(W.barrier(~S,~Cell,~Cell,~U32,world)))
def refused_basic(result:W.World<S,Cell,Cell,U32> & Data.Outcome<Data.Snapshot>) -> String:
  match result:
    case (world,outcome):refused_count("basic="++outcome_text(outcome)++" ",W.pending_count(~S,~Cell,~Cell,~U32,world))
def basic_created(result:W.Creation<S,Cell,Cell,U32>) -> String:
  match result:
    case W.CreateRejected{_,_}:"create-rejected\n"
    case W.Created{_,world}:refused_basic(save_basic(stage(world)))
def basic() -> String:
  basic_created(W.create(~S,~Cell,~Cell,~U32,~(unit => Cell{ANode{ALeaf{101},ALeaf{102}},0,[]}),W.Factory{10},Cell{ANode{ALeaf{201},ALeaf{202}},0,[]}))
def zero_created(result:W.Creation<S,Cell,Cell,U32>) -> String:
  match result:
    case W.CreateRejected{_,_}:"create-rejected\n"
    case W.Created{_,world}:finish_basic("zero=",save_basic(world))
def zero() -> String:
  zero_created(W.create(~S,~Cell,~Cell,~U32,~(unit => Cell{ANode{ALeaf{101},ALeaf{102}},0,[]}),W.Factory{20},Cell{ANode{ALeaf{201},ALeaf{202}},0,[]}))

def machine_value(slot:M.Slot<S,Unit,U32>) -> List<&2,D.Field>:
  match slot:
    case M.Missing{}:[]
    case M.Present{current,_,_,_}:[D.Field{"mode",D.Number{current}}]
def machine_fields(machines:Machines) -> Machines & List<&2,D.Field>:
  match machines:
    case Machines{token,+slot,calls}:(Machines{token,slot,U32.add(calls,1)},machine_value(slot))
def graph_component_joined(graph:G.Graph<S>,result:Cell & List<&2,D.Field>) -> Rel.Store<S,Cell> & List<&2,D.Field>:
  match result:
    case (cell,fields):(Rel.Store{cell,graph},fields)
def graph_component(id:U32,store:Rel.Store<S,Cell>) -> Rel.Store<S,Cell> & List<&2,D.Field>:
  match store:
    case Rel.Store{cell,graph}:graph_component_joined(graph,component_fields(id,cell))
def graph_resource_joined(machines:Machines,result:Cell & List<&2,D.Field>) -> Product.Owner<Cell,Machines> & List<&2,D.Field>:
  match result:
    case (cell,fields):(Product.Owner{cell,machines},fields)
def graph_resource(owner:Product.Owner<Cell,Machines>) -> Product.Owner<Cell,Machines> & List<&2,D.Field>:
  match owner:
    case Product.Owner{cell,machines}:graph_resource_joined(machines,resource_fields(cell))
def graph_basic(world:W.World<S,Rel.Store<S,Cell>,Product.Owner<Cell,Machines>,U32>) -> W.World<S,Rel.Store<S,Cell>,Product.Owner<Cell,Machines>,U32> & Data.Outcome<Data.Snapshot>:
  Save.save(~S,~Rel.Store<S,Cell>,~Product.Owner<Cell,Machines>,~U32,~graph_component,~graph_resource,Schema.Schema{Ordinary.Schema{[]}},world)
def callback_called(owner:Product.Owner<Cell,Machines>) -> Product.Owner<Cell,Machines> & Unit:
  match owner:
    case Product.Owner{Cell{token,calls,log},machines}:(Product.Owner{Cell{token,U32.add(calls,100),log},machines},Unit{})
def callback_joined(result:W.World<S,Rel.Store<S,Cell>,Product.Owner<Cell,Machines>,U32> & Unit) -> W.World<S,Rel.Store<S,Cell>,Product.Owner<Cell,Machines>,U32> & Data.Outcome<Data.Snapshot>:
  match result:
    case (world,_):graph_basic(world)
def counted_basic(world:W.World<S,Rel.Store<S,Cell>,Product.Owner<Cell,Machines>,U32>) -> W.World<S,Rel.Store<S,Cell>,Product.Owner<Cell,Machines>,U32> & Data.Outcome<Data.Snapshot>:
  callback_joined(W.observe_resource(~S,~Rel.Store<S,Cell>,~Product.Owner<Cell,Machines>,~U32,~Unit,callback_called,world))
def descriptor() -> G.Descriptor<S>:G.Descriptor{7,"links","backlinks",G.Ordinary{}}
def save_graph(world:W.World<S,Rel.Store<S,Cell>,Product.Owner<Cell,Machines>,U32>) -> W.World<S,Rel.Store<S,Cell>,Product.Owner<Cell,Machines>,U32> & Data.Outcome<GraphData.Snapshot>:
  GraphSave.save(~S,~Cell,~Cell,~Machines,~U32,~machine_fields,~counted_basic,[Decl.Declaration{descriptor()}],world)
def group_text(group:GraphData.Group) -> String:
  match group:
    case GraphData.Group{target,sources}:key_text(target)++"<-"++List.show(&2,K.Key,key_text,sources)
def relation_text(relation:GraphData.Relation) -> String:
  match relation:
    case GraphData.Relation{name,groups}:name++List.show(&2,GraphData.Group,group_text,groups)
def graph_outcome(outcome:Data.Outcome<GraphData.Snapshot>) -> String:
  match outcome:
    case Data.RefusedPending{}:"refused"
    case Data.Saved{GraphData.Snapshot{basic,relations,machines}}:"saved:"++snapshot_text(basic)++" relations="++List.show(&2,GraphData.Relation,relation_text,relations)++" machines="++fields(machines)
def slot_text(slot:M.Slot<S,Unit,U32>) -> String:
  match slot:
    case M.Missing{}:"missing"
    case M.Present{current,M.NoPending{},_,_}:U32.show(current)++"/none"
    case M.Present{current,M.Queued{next,_},_,_}:U32.show(current)++"/"++U32.show(next)
def machines_text(machines:Machines) -> String:
  match machines:
    case Machines{token,slot,calls}:nums(cells(token))++"/"++U32.show(calls)++"/"++slot_text(slot)
def graph_finished(prefix:String,result:W.World<S,Rel.Store<S,Cell>,Product.Owner<Cell,Machines>,U32> & Data.Outcome<GraphData.Snapshot>) -> String:
  match result:
    case (W.World{_,_,Rel.Store{store,_},Product.Owner{resource,machines},_,_,_,_,_,lifecycle},outcome):prefix++graph_outcome(outcome)++" owners="++cell_text(store)++";"++cell_text(resource)++";"++machines_text(machines)++"\n"
def graph_after_refusal(result:W.World<S,Rel.Store<S,Cell>,Product.Owner<Cell,Machines>,U32> & Data.Outcome<GraphData.Snapshot>) -> String:
  match result:
    case (W.World{namespace,allocator,Rel.Store{store,graph},Product.Owner{resource,Machines{token,slot,+calls}},events,pending,registrations,nextSystemId,clock,lifecycle},outcome):graph_finished("graph="++graph_outcome(outcome)++" precalls="++U32.show(calls)++" retry=",save_graph(W.barrier(~S,~Rel.Store<S,Cell>,~Product.Owner<Cell,Machines>,~U32,W.World{namespace,allocator,Rel.Store{store,graph},Product.Owner{resource,Machines{token,slot,calls}},events,pending,registrations,nextSystemId,clock,lifecycle})))
# Trusted graph setup below isolates save traversal, not relation validation.
# The machine has committed value 4 and separately pending value 9.
def graph_world() -> W.World<S,Rel.Store<S,Cell>,Product.Owner<Cell,Machines>,U32>:
  W.World{30,Alloc.empty(),Rel.Store{Cell{ANode{ALeaf{101},ALeaf{102}},0,[]},G.Graph{[],[G.Inverse{descriptor(),K.EntityKey{1,0},[K.EntityKey{2,0},K.EntityKey{3,0}]}]}},Product.Owner{Cell{ANode{ALeaf{201},ALeaf{202}},0,[]},Machines{ANode{ALeaf{301},ALeaf{302}},M.Present{4,M.Queued{9,False{}},None{},False{}},0}},[],[],[],1,Clock.empty(),Notice.empty(~S,30)}
def graph() -> String:
  graph_after_refusal(save_graph(W.enqueue(~S,~Rel.Store<S,Cell>,~Product.Owner<Cell,Machines>,~U32,graph_world(),world => world)))
def refusing_basic(world:W.World<S,Rel.Store<S,Cell>,Product.Owner<Cell,Machines>,U32>) -> W.World<S,Rel.Store<S,Cell>,Product.Owner<Cell,Machines>,U32> & Data.Outcome<Data.Snapshot>:
  (world,Data.RefusedPending{})
def graph_refused() -> String:
  graph_finished("graph-basic=",GraphSave.save(~S,~Cell,~Cell,~Machines,~U32,~machine_fields,~refusing_basic,[Decl.Declaration{descriptor()}],graph_world()))
def main() -> IO(Unit):
  IO.write(basic()++zero()++graph()++graph_refused())
