import Base
import ./extended-declarations.bend as Schema
import ../../src/ecs/execution-lifetime-scope-store.bend as Store
import ../../src/ecs/lifetime-scope.bend as Scope
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/entity-allocator.bend as Allocator
import ../../src/ecs/world.bend as W
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/lifecycle.bend as Life

def Slot(~S:Data) -> Type:Layout.resources(~S,Layout.subtree(Schema.resource_layout(~S),Layout.InRight{Layout.InRight{Layout.AtLeaf{}}}))
def projected(~S:Data,restore:Allocator.Allocator -> Slot(~S) -> Schema.World(~S),allocator:Allocator.Allocator,receipt:Store.Assignment<S>,stamp:Life.Stamp,result:Store.Store<S> & Store.View<S>) -> Schema.World(~S) & Store.Assignment<S>:
  match result:
    case (store,view):(restore(allocator,Layout.ResourceSlot{Layout.Viewed{store,view},stamp}),receipt)
def assigned(~S:Data,restore:Allocator.Allocator -> Slot(~S) -> Schema.World(~S),stamp:Life.Stamp,tick:Tick.Tick,result:Allocator.Allocator & (Store.Store<S> & Store.Assignment<S>)) -> Schema.World(~S) & Store.Assignment<S>:
  match result:
    case (allocator,(store,Store.Assigned{scope,handle})):projected(~S,restore,allocator,Store.Assigned{scope,handle},Life.after_write(True{},True{},stamp,tick),Store.project(~S,store))
    case (allocator,(store,Store.AssignmentRefused{scope,handle,reason})):projected(~S,restore,allocator,Store.AssignmentRefused{scope,handle,reason},stamp,Store.project(~S,store))
def clocked(~S:Data,name:String,handle:W.Handle<S>,result:Schema.World(~S) & Tick.Tick) -> Schema.World(~S) & Store.Assignment<S>:
  match result:
    case (W.World{+namespace,allocator,columns,Product.Owner{graph,Product.Owner{cell,Layout.ResourceSlot{Layout.Viewed{store,_},stamp}}},events,pending,registrations,nextSystem,clock,lifecycle},tick):assigned(~S,allocator => scope => W.World{namespace,allocator,columns,Product.Owner{graph,Product.Owner{cell,scope}},events,pending,registrations,nextSystem,clock,lifecycle},stamp,tick,Store.assign(~S,namespace,allocator,store,Scope.Scope{namespace,name},handle))
# Trusted provisioning uses the actual namespace and allocator. The canonical
# Store assignment checks both namespace and full-generation liveness.
def assign(~S:Data,name:String,handle:W.Handle<S>,world:Schema.World(~S)) -> Schema.World(~S) & Store.Assignment<S>:clocked(~S,name,handle,W.write_clock(~S,~Layout.columns(~S,Schema.components(~S)),~Schema.Resources(~S),~Unit,world))
