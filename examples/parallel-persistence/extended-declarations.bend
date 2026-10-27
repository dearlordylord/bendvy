import Base
import ./declarations.bend as O
import ../parallel-machines/declarations.bend as Modes
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/execution-resource-policy.bend as Policy
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-relation-store.bend as Graph
import ../../src/ecs/execution-machine-state.bend as Cell
import ../../src/ecs/execution-machine-stream.bend as Stream
import ../../src/ecs/execution-lifetime-scope-store.bend as Scope
import ../../src/ecs/machine.bend as M
import ../../src/ecs/relation-types.bend as T
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/persistence-declaration.bend as Decl
import ../../src/ecs/world.bend as W
import ../../src/ecs/world-io.bend as WorldIO
import ../../src/ecs/world-namespace.bend as Namespace
import ../../src/ecs/execution-composer-schema.bend as Schema

def hierarchy(~S:Data) -> T.Descriptor<S>:T.Descriptor{92,"restore-parent","restore-children",T.Hierarchy{}}
def resources(~S:Data) -> Plan.Plan:
  Plan.Pair{Plan.Transient{Graph.Store<S,hierarchy(~S)>,Graph.View<S,hierarchy(~S)>,Graph.project(~S,~hierarchy(~S)),"restore-hierarchy",Policy.ProtectedRelation{S,hierarchy(~S)}},Plan.Pair{Plan.Transient{Cell.Cell<S,Modes.Key,Modes.Mode>,Cell.View<S,Modes.Key,Modes.Mode>,Cell.projected(S,Modes.Key,Modes.Mode),"restore-mode",Policy.Ordinary{}},Plan.Transient{Scope.Store<S>,Scope.View<S>,Scope.project(~S),"restore-scopes",Policy.ProtectedLifetimeScope{S}}}}
def components(~S:Data) -> Layout.Layout:Plan.layout(O.components(~S))
def resource_layout(~S:Data) -> Layout.Layout:Plan.layout(resources(~S))
def Resources(~S:Data) -> Type:Layout.resources(~S,resource_layout(~S))
def World(~S:Data) -> Type:W.World<S,Layout.columns(~S,components(~S)),Resources(~S),Unit>
def schema_from(~S:Data,schema:Plan.Schema<S,O.components(~S),O.resources(~S)>) -> Plan.Schema<S,O.components(~S),resources(~S)>:
  match schema:
    case Plan.Schema{components,_}:Plan.Schema{components,Product.Owner{Decl.Transient{},Product.Owner{Decl.Transient{},Decl.Transient{}}}}
def schema(~S:Data) -> Plan.Schema<S,O.components(~S),resources(~S)>:schema_from(~S,O.schema(~S))
def initial_cell(~S:Data,namespace:U32,value:Modes.Mode,revision:Nat) -> Cell.Cell<S,Modes.Key,Modes.Mode>:
  Cell.Cell{M.Present{value,M.NoPending{},None{},False{}},Stream.empty(~Modes.Mode),revision,None{},None{},0n,False{},Some{namespace},Cell.Idle{}}
def owners(~S:Data,+namespace:U32,value:Modes.Mode,revision:Nat) -> Resources(~S):
  Product.Owner{Layout.ResourceSlot{Layout.initialize(resource_layout(~S),Layout.InLeft{Layout.AtLeaf{}},Graph.fresh(~S,~hierarchy(~S),namespace)),Layout.unknown_stamp()},Product.Owner{Layout.ResourceSlot{Layout.initialize(resource_layout(~S),Layout.InRight{Layout.InLeft{Layout.AtLeaf{}}},initial_cell(~S,namespace,value,revision)),Layout.unknown_stamp()},Layout.ResourceSlot{Layout.initialize(resource_layout(~S),Layout.InRight{Layout.InRight{Layout.AtLeaf{}}},Scope.fresh(~S,namespace)),Layout.unknown_stamp()}}}
def initialized(~S:Data,result:WorldIO.Creation<S,Layout.columns(~S,components(~S)),Resources(~S),Unit>) -> WorldIO.Creation<S,Layout.columns(~S,components(~S)),Resources(~S),Unit>:
  match result:
    case WorldIO.Created{world}:WorldIO.Created{Schema.initialized_world(~S,~components(~S),~resource_layout(~S),~Unit,world)}
    case other:other
# The actual host namespace allocator supplies the Store and Cell namespace at
# creation. No fabricated namespace or live owner conversion is used.
def namespace(~S:Data,value:Modes.Mode,revision:Nat,+namespace:U32) -> IO(WorldIO.Creation<S,Layout.columns(~S,components(~S)),Resources(~S),Unit>):
  IO.bind(WorldIO.Creation<S,Layout.columns(~S,components(~S)),Resources(~S),Unit>,WorldIO.Creation<S,Layout.columns(~S,components(~S)),Resources(~S),Unit>,WorldIO.with_namespace(~S,~Layout.columns(~S,components(~S)),~Resources(~S),~Unit,~O.empty(~S),namespace,owners(~S,namespace,value,revision)),result => IO.pure(WorldIO.Creation<S,Layout.columns(~S,components(~S)),Resources(~S),Unit>,initialized(~S,result)))
def create(~S:Data,value:Modes.Mode,revision:Nat) -> IO(WorldIO.Creation<S,Layout.columns(~S,components(~S)),Resources(~S),Unit>):IO.bind(U32,WorldIO.Creation<S,Layout.columns(~S,components(~S)),Resources(~S),Unit>,Namespace.fresh(),ns => namespace(~S,value,revision,ns))
