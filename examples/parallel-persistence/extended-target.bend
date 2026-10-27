import Base
import ./extended-declarations.bend as Schema
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-relation-store.bend as Store
import ../../src/ecs/execution-relation-failure-channel.bend as Failure
import ../../src/ecs/execution-machine-state.bend as Cell
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/lifecycle.bend as Life
import ../../src/ecs/world.bend as W

def Reader(~S:Data) -> Type:Failure.Reader<S,Schema.hierarchy(~S),Schema.resource_layout(~S),Layout.InLeft{Layout.AtLeaf{}}>
def MachineSlot(~S:Data) -> Type:Layout.resources(~S,Layout.subtree(Schema.resource_layout(~S),Layout.InRight{Layout.AtLeaf{}}))
def projected(~S:Data,cell:MachineSlot(~S),stamp:Life.Stamp,reader:Maybe<&1,Reader(~S)>,result:Store.Store<S,Schema.hierarchy(~S)> & Store.View<S,Schema.hierarchy(~S)>) -> Schema.Resources(~S) & Maybe<&1,Reader(~S)>:
  match result:
    case (store,view):(Product.Owner{Layout.ResourceSlot{Layout.Viewed{store,view},stamp},cell},reader)
def registered(~S:Data,cell:MachineSlot(~S),stamp:Life.Stamp,result:Store.Registration<S,Schema.hierarchy(~S),Schema.resource_layout(~S),Layout.InLeft{Layout.AtLeaf{}}>) -> Schema.Resources(~S) & Maybe<&1,Reader(~S)>:
  match result:
    case Store.Registered{store,reader}:projected(~S,cell,stamp,Some{reader},Store.project(~S,~Schema.hierarchy(~S),store))
    case Store.RegistrationRefused{store}:projected(~S,cell,stamp,None{},Store.project(~S,~Schema.hierarchy(~S),store))
def resources(~S:Data,resources:Schema.Resources(~S)) -> Schema.Resources(~S) & Maybe<&1,Reader(~S)>:
  match resources:
    case Product.Owner{Layout.ResourceSlot{Layout.Viewed{store,_},stamp},cell}:registered(~S,cell,stamp,Store.register(~S,~Schema.hierarchy(~S),~Schema.resource_layout(~S),~Layout.InLeft{Layout.AtLeaf{}},store))
def register(~S:Data,world:Schema.World(~S)) -> Schema.World(~S) & Maybe<&1,Reader(~S)>:W.observe_resource(~S,~Layout.columns(~S,Schema.components(~S)),~Schema.Resources(~S),~Unit,~Maybe<&1,Reader(~S)>,~resources(~S),world)
def cell_namespace(expected:U32,value:Maybe<&2,U32>) -> Bool:
  match value:
    case None{}:True{}
    case Some{namespace}:U32.is_eq(expected,namespace)
def checked_resources(~S:Data,+expected:U32,resources:Schema.Resources(~S)) -> Schema.Resources(~S) & Bool:
  match resources:
    case Product.Owner{Layout.ResourceSlot{Layout.Viewed{Store.Store{+namespace,graph,failures,sequence,nextReader},view},stamp},Layout.ResourceSlot{Layout.Viewed{Cell.Cell{slot,stream,revision,cellStamp,nextStamp,cellSequence,initialPending,+cellNamespace,intent},cellView},resourceStamp}}:(Product.Owner{Layout.ResourceSlot{Layout.Viewed{Store.Store{namespace,graph,failures,sequence,nextReader},view},stamp},Layout.ResourceSlot{Layout.Viewed{Cell.Cell{slot,stream,revision,cellStamp,nextStamp,cellSequence,initialPending,cellNamespace,intent},cellView},resourceStamp}},Bool.and(U32.is_eq(expected,namespace),cell_namespace(expected,cellNamespace)))
def namespaces(~S:Data,world:Schema.World(~S)) -> Schema.World(~S) & Bool:
  match world:
    case W.World{+namespace,allocator,columns,resources,events,pending,registrations,nextSystem,clock,lifecycle}:W.observe_resource_finish(~S,~Layout.columns(~S,Schema.components(~S)),~Schema.Resources(~S),~Unit,~Bool,checked_resources(~S,namespace,resources),namespace,allocator,columns,events,pending,registrations,nextSystem,clock,lifecycle)
