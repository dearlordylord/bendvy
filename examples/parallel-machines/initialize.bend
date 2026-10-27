import Base
import ./declarations.bend as D
import ../../src/ecs/execution-machine-state.bend as State
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/world.bend as W
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/lifecycle.bend as Life

# Trusted app setup, matching Bevy init_state setup visibility and initial event:
# https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_state/src/app.rs#L94-L114
# No gameplay body receives this resource owner or chooses its clock.
def Resources(~S:Data) -> Type:Product.Owner<D.Resources(~S),Unit>
def World(~S:Data) -> Type:W.World<S,D.Store(~S),Resources(~S),Unit>
def initialized(~S:Data,namespace:U32,tick:Tick.Tick,cell:State.Cell<S,D.Key,D.Mode>) -> State.Cell<S,D.Key,D.Mode> & Unit:
  (State.initialize(~S,~D.Key,~D.Mode,State.bind(~S,~D.Key,~D.Mode,namespace,cell),D.Waiting{},tick),Unit{})
def rewritten(~S:Data,+tick:Tick.Tick,peer:Unit,result:Layout.stored(D.layout(~S),Layout.AtLeaf{}) & Unit) -> Resources(~S) & Unit:
  match result:
    case (stored,_):(Product.Owner{Layout.ResourceSlot{stored,Life.Stamp{Some{tick},Some{tick}}},peer},Unit{})
def resources(~S:Data,namespace:U32,+tick:Tick.Tick,resources:Resources(~S)) -> Resources(~S) & Unit:
  match resources:
    case Product.Owner{Layout.ResourceSlot{stored,_},peer}:rewritten(~S,tick,peer,Layout.rewrite(~D.layout(~S),~Layout.AtLeaf{},Unit,initialized(~S,namespace,tick),stored))
def joined(~S:Data,restore:Resources(~S) -> World(~S),result:Resources(~S) & Unit) -> World(~S):
  match result:
    case (resource,_):restore(resource)
def clocked(~S:Data,result:World(~S) & Tick.Tick) -> World(~S):
  match result:
    case (W.World{+namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,lifecycle},tick):
      joined(~S,resource => W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,lifecycle},resources(~S,namespace,tick,resource))
def setup(~S:Data,world:World(~S)) -> World(~S):clocked(~S,W.clock(~S,~D.Store(~S),~Resources(~S),~Unit,world))
