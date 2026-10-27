import Base
import ./extended-declarations.bend as Schema
import ../parallel-machines/declarations.bend as Modes
import ../../src/ecs/execution-machine-state.bend as Cell
import ../../src/ecs/machine.bend as M
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/lifecycle.bend as Life
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/world.bend as W

# Actual administrative transitions populate the receiver's event stream before
# restore. These events remain elapsed history; restore does not replay them.
def projected(~S:Data,graph:Layout.resources(~S,Layout.subtree(Schema.resource_layout(~S),Layout.InLeft{Layout.AtLeaf{}})),stamp:Life.Stamp,result:Cell.Cell<S,Modes.Key,Modes.Mode> & Cell.View<S,Modes.Key,Modes.Mode>) -> Schema.Resources(~S) & Unit:
  match result:
    case (cell,view):(Product.Owner{graph,Layout.ResourceSlot{Layout.Viewed{cell,view},stamp}},Unit{})
def requested(~S:Data,graph:Layout.resources(~S,Layout.subtree(Schema.resource_layout(~S),Layout.InLeft{Layout.AtLeaf{}})),stamp:Life.Stamp,+tick:Tick.Tick,result:Cell.Cell<S,Modes.Key,Modes.Mode> & Unit) -> Schema.Resources(~S) & Unit:
  match result:
    case (cell,_):projected(~S,graph,Life.after_write(True{},True{},stamp,tick),Cell.projected(S,Modes.Key,Modes.Mode,Cell.apply(~S,~Modes.Key,~Modes.Mode,~Modes.same,cell,tick)))
def resources(~S:Data,value:Modes.Mode,+tick:Tick.Tick,resources:Schema.Resources(~S)) -> Schema.Resources(~S) & Unit:
  match resources:
    case Product.Owner{graph,Layout.ResourceSlot{Layout.Viewed{cell,_},stamp}}:requested(~S,graph,stamp,tick,Cell.queued_at(~S,~Modes.Key,~Modes.Mode,~Modes.same,M.Set{value,False{}},tick,cell))
def finished(~S:Data,result:Schema.World(~S) & Unit) -> Schema.World(~S):
  match result:
    case (world,_):world
def clocked(~S:Data,value:Modes.Mode,result:Schema.World(~S) & Tick.Tick) -> Schema.World(~S):
  match result:
    case (W.World{namespace,allocator,columns,resource,events,pending,registrations,nextSystem,clock,lifecycle},tick):finished(~S,W.observe_resource_finish(~S,~Layout.columns(~S,Schema.components(~S)),~Schema.Resources(~S),~Unit,~Unit,resources(~S,value,tick,resource),namespace,allocator,columns,events,pending,registrations,nextSystem,clock,lifecycle))
def transition(~S:Data,value:Modes.Mode,world:Schema.World(~S)) -> Schema.World(~S):clocked(~S,value,W.write_clock(~S,~Layout.columns(~S,Schema.components(~S)),~Schema.Resources(~S),~Unit,world))
def source(~S:Data,world:Schema.World(~S)) -> Schema.World(~S):transition(~S,Modes.Waiting{},transition(~S,Modes.Running{},transition(~S,Modes.Waiting{},transition(~S,Modes.Running{},world))))
def receiver(~S:Data,world:Schema.World(~S)) -> Schema.World(~S):transition(~S,Modes.Running{},transition(~S,Modes.Waiting{},world))
