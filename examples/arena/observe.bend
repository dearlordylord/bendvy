import Base
import ../../src/ecs/chunk-partition.bend as Part
import ./owners.bend as Owners
import ./spawn.bend as Spawn
import ./system.bend as Step
import ../parallel-query/observation.bend as Text
import ../../src/ecs/chunk-column.bend as Col
import ../../src/ecs/entity-allocator.bend as A
import ../../src/ecs/entity-key.bend as Key
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/execution-lifecycle-notices.bend as Notice
import ../../src/ecs/deferred-command.bend as Deferred
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-query-schema.bend as Schema
import ./schema.bend as D
import ./gameplay.bend as G
import ./root.bend as Root
import ../../src/ecs/inspector.bend as I
import ../../src/ecs/inspector-query.bend as Query
import ../../src/ecs/inspector-query-projection.bend as Rows
import ../../src/ecs/execution-inspector-component.bend as Columns
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/component.bend as Component
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/execution-generalized-root-application.bend as General
import ../../src/ecs/execution-parallel-root-application.bend as Scheduled
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/world.bend as W

def Ops(H:Type) -> Type:Query.ReadQuery<H,D.Schema,G.Body>
def plan() -> I.Plan<D.Schema,D.Columns(),D.Resources(),Unit,Ops>:
  I.Plan{Columns.query(~D.Schema,~D.Columns(),~D.Resources(),~Unit,~D.components(),~L.AtLeaf{},~{==},~{==},~Rows.Required{})}
def values(rows:List<&2,Rows.Row<D.Schema,G.Body>>,found:List<&2,G.Body>) -> List<&2,G.Body>:
  match rows:
    case []:List.reverse(&2,G.Body,found)
    case Rows.Row{_,I.Value{Component.Found{body},_,_}} <> rest:values(rest,body <> found)
    case _ <> rest:values(rest,found)
def selected(~H:Type,result:H & List<&2,Rows.Row<D.Schema,G.Body>>) -> H & Result<&2,&2,Unit,List<&2,G.Body>>:
  match result:
    case (frame,rows):(frame,Done{values(rows,[])})
def read(~H:Type,caps:Ops(H)) -> H -> H & List<&2,Rows.Row<D.Schema,G.Body>>:
  match caps:
    case Query.ReadQuery{Cap.ValueRead{read},_,_}:read
def body(~H:Type,~caps:Ops(H),_:Unit,frame:H) -> H & Result<&2,&2,Unit,List<&2,G.Body>>:selected(~H,read(~H,caps)(frame))
def observed(rebuild:D.World() -> Root.Application(),result:I.Observed<D.Schema,D.Columns(),D.Resources(),Unit,Unit,List<&2,G.Body>>) -> Root.Application() & Result<&2,&2,Unit,List<&2,G.Body>>:
  match result:
    case I.Observed{world,_,result}:(rebuild(world),result)
def storage(rebuild:General.Storage<D.Schema,D.components(),D.resources(),Unit> -> Root.Application(),storage:General.Storage<D.Schema,D.components(),D.resources(),Unit>) -> Root.Application() & Result<&2,&2,Unit,List<&2,G.Body>>:
  match storage:
    case General.Present{world,displaced}:observed(world => rebuild(General.Present{world,displaced}),I.passive(~D.Schema,~D.Columns(),~D.Resources(),~Unit,~Ops,~Unit,~Unit,~List<&2,G.Body>,~plan(),~body,I.Fresh{},Unit{},world))
    case storage:(rebuild(storage),Fail{Unit{}})
def snapshot(app:Root.Application()) -> Root.Application() & Result<&2,&2,Unit,List<&2,G.Body>>:
  match app:
    case Scheduled.Scheduled{App.State{world,nodes,guards,handler,stateBindings},plan,bindings,rules,deferred}:storage(world => Scheduled.Scheduled{App.State{world,nodes,guards,handler,stateBindings},plan,bindings,rules,deferred},world)

# Complete finite fixture observation, separate from the gameplay projection.
def viewed(value:L.Viewed<G.Body,G.Body>) -> L.Viewed<G.Body,G.Body> & String:
  match value:
    case L.Viewed{+owner,+cache}:(L.Viewed{owner,cache},Owners.body_text(owner) ++ "@cache=" ++ Owners.body_text(cache))
def column_done(size:U32,result:Col.Column<D.Schema,L.Viewed<G.Body,G.Body>> & String) -> D.Columns() & String:
  match result:
    case (column,text):(L.ColumnSlot{column},"capacity=" ++ U32.show(size) ++ "[" ++ text ++ "]")
def column_sized(result:Col.Column<D.Schema,L.Viewed<G.Body,G.Body>> & U32) -> D.Columns() & String:
  match result:
    case (column,+size):column_done(size,Text.slots(~D.Schema,~L.Viewed<G.Body,G.Body>,~viewed,U32.to_nat(size),0,(column,"")))
def component_snapshot(columns:D.Columns()) -> D.Columns() & String:
  match columns:
    case L.ColumnSlot{column}:column_sized(Col.capacity(~D.Schema,~L.Viewed<G.Body,G.Body>,column))
def allocator_value(prefix:String,result:Array<A.Slot> & A.Slot) -> Array<A.Slot> & String:
  match result:
    case (slots,value):(slots,prefix ++ Text.allocator_slot(value) ++ ";")
def allocator_slots(fuel:Nat,+index:U32,result:Array<A.Slot> & String) -> Array<A.Slot> & String:
  match fuel result:
    case 0n result:result
    case 1n+rest, (slots,prefix):allocator_slots(rest,U32.add(index,1),allocator_value(prefix,Array.get(A.Slot,slots,index)))
def allocator_done(+next:U32,+high:U32,+capacity:U32,+depth:Nat,+free:List<&2,U32>,+order:List<&2,Key.Key>,result:Array<A.Slot> & String) -> A.Allocator & String:
  match result:
    case (slots,text):(A.Allocator{next,high,slots,capacity,depth,free,order},"next=" ++ U32.show(next) ++ ",high=" ++ U32.show(high) ++ ",capacity=" ++ U32.show(capacity) ++ ",depth=" ++ Nat.show(depth) ++ ",slots=[" ++ text ++ "],free=" ++ List.show(&2,U32,U32.show,free) ++ ",order=" ++ List.show(&2,Key.Key,Text.key,order))
def allocator_snapshot(allocator:A.Allocator) -> A.Allocator & String:
  match allocator:
    case A.Allocator{next,high,slots,+capacity,depth,free,order}:allocator_done(next,high,capacity,depth,free,order,allocator_slots(U32.to_nat(capacity),0,(slots,"")))
def journal_snapshot(value:Notice.Journal<D.Schema>) -> Notice.Journal<D.Schema> & String:
  match value:
    case Notice.Journal{+namespace,+channels,+nextReader,+active}:(Notice.Journal{namespace,channels,nextReader,active},Text.journal(~D.Schema,Notice.Journal{namespace,channels,nextReader,active}))
def pending_snapshot(value:Deferred.Command<D.World()>) -> Deferred.Command<D.World()> & String:
  match value:
    case Deferred.Raw{apply}:(Deferred.Raw{apply},"raw")
    case Deferred.Observed{apply}:(Deferred.Observed{apply},"observed")
def world_done(+namespace:U32,resource:D.Resources(),+events:List<&2,Unit>,pending:List<Deferred.Command<D.World()>> & String,+registrations:List<&2,W.RegistrationMeta>,+next:U32,+clock:Clock.State,journal:Notice.Journal<D.Schema> & String,allocator:A.Allocator & String,components:D.Columns() & String) -> D.World() & String:
  match pending journal allocator components:
    case (pending,pt), (journal,jt), (allocator,at), (components,ct):(W.World{namespace,allocator,components,resource,events,pending,registrations,next,clock,journal},"namespace=" ++ U32.show(namespace) ++ ";allocator={" ++ at ++ "};components=" ++ ct ++ ";resource=Unit;events=" ++ Nat.show(List.length(&2,Unit,events)) ++ ";pending=[" ++ pt ++ "];registrations=" ++ List.show(&2,W.RegistrationMeta,Text.registration,registrations) ++ ";nextSystem=" ++ U32.show(next) ++ ";clock=" ++ Text.clock(clock) ++ ";lifecycle={" ++ jt ++ "}")
def world_snapshot(world:D.World()) -> D.World() & String:
  match world:
    case W.World{namespace,allocator,components,resource,events,pending,registrations,next,clock,journal}:world_done(namespace,resource,events,Owners.owned_list(~Deferred.Command<D.World()>,~pending_snapshot,pending),registrations,next,clock,journal_snapshot(journal),allocator_snapshot(allocator),component_snapshot(components))
def displaced_cell(value:Part.Cell<L.Viewed<G.Body,G.Body>>) -> Part.Cell<L.Viewed<G.Body,G.Body>> & String:
  match value:
    case Part.Cell{+offset,None{},+stamp}:(Part.Cell{offset,None{},stamp},U32.show(offset) ++ "=none@" ++ Text.stamp(Some{stamp}))
    case Part.Cell{+offset,Some{value},+stamp}:Owners.named(~Part.Cell<L.Viewed<G.Body,G.Body>>,~L.Viewed<G.Body,G.Body>,value=>Part.Cell{offset,Some{value},stamp},U32.show(offset) ++ "@" ++ Text.stamp(Some{stamp}) ++ "=",viewed(value))
def displacement(value:Schema.displacements(~D.Schema,D.components())) -> Schema.displacements(~D.Schema,D.components()) & String:
  Owners.owned_list(~Part.Cell<L.Viewed<G.Body,G.Body>>,~displaced_cell,value)
def storage_done(displaced:List<&1,Schema.displacements(~D.Schema,D.components())> & String,result:D.World() & String) -> General.Storage<D.Schema,D.components(),D.resources(),Unit> & String:
  match displaced result:
    case (displaced,dt), (world,text):(General.Present{world,displaced},text ++ ";displaced=[" ++ dt ++ "]")
def full_storage(storage:General.Storage<D.Schema,D.components(),D.resources(),Unit>) -> General.Storage<D.Schema,D.components(),D.resources(),Unit> & String:
  match storage:
    case General.Present{world,displaced}:storage_done(Owners.owned_list(~Schema.displacements(~D.Schema,D.components()),~displacement,displaced),world_snapshot(world))
    case storage:(storage,"unexpected-unavailable-world")
def full_nodes(left:Spawn.Node() & String,right:Step.Node() & String) -> Root.Nodes() & String:
  match left right:
    case (left,lt), (right,rt):(Product.Owner{left,right},"spawn={" ++ lt ++ "};step={" ++ rt ++ "}")
def nodes_snapshot(nodes:Root.Nodes()) -> Root.Nodes() & String:
  match nodes:
    case Product.Owner{left,right}:full_nodes(Owners.spawn_snapshot_node(left),Owners.step_snapshot_node(right))
def full_done(rebuild:General.Storage<D.Schema,D.components(),D.resources(),Unit> -> Root.Nodes() -> Root.Application(),world:General.Storage<D.Schema,D.components(),D.resources(),Unit> & String,nodes:Root.Nodes() & String) -> Root.Application() & String:
  match world nodes:
    case (world,wt), (nodes,nt):(rebuild(world,nodes),"world={" ++ wt ++ "};nodes={" ++ nt ++ "}")
def full(app:Root.Application()) -> Root.Application() & String:
  match app:
    case Scheduled.Scheduled{App.State{world,nodes,guards,handler,stateBindings},plan,bindings,rules,deferred}:full_done(world=>nodes=>Scheduled.Scheduled{App.State{world,nodes,guards,handler,stateBindings},plan,bindings,rules,deferred},full_storage(world),nodes_snapshot(nodes))
