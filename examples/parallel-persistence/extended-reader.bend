import Base
import ./extended-declarations.bend as Schema
import ./extended-target.bend as Target
import ../../src/ecs/execution-relation-store.bend as Store
import ../../src/ecs/execution-relation-failure-channel.bend as Failure
import ../../src/ecs/execution-relation-failure-message.bend as Message
import ../../src/ecs/execution-stream-channel.bend as Channel
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/lifecycle.bend as Life
import ../../src/ecs/relation-types.bend as T
import ../../src/ecs/world.bend as W

def Reading(~S:Data) -> Type:Failure.Reading<S,Schema.hierarchy(~S),Schema.resource_layout(~S),Layout.InLeft{Layout.AtLeaf{}}>
def rebuilt(~S:Data,namespace:U32,graph:T.Graph<S>,sequence:Nat,nextReader:U32,view:Store.View<S,Schema.hierarchy(~S)>,stamp:Life.Stamp,cell:Layout.resources(~S,Layout.subtree(Schema.resource_layout(~S),Layout.InRight{Layout.AtLeaf{}})),result:Channel.Store<Message.Message<S,Schema.hierarchy(~S)>> & Reading(~S)) -> Schema.Resources(~S) & Reading(~S):
  match result:
    case (channel,reading):(Product.Owner{Layout.ResourceSlot{Layout.Viewed{Store.Store{namespace,graph,channel,sequence,nextReader},view},stamp},cell},reading)
def resources(~S:Data,tick:Tick.Tick,reader:Target.Reader(~S),resources:Schema.Resources(~S)) -> Schema.Resources(~S) & Reading(~S):
  match resources:
    case Product.Owner{Layout.ResourceSlot{Layout.Viewed{Store.Store{+namespace,graph,channel,+sequence,nextReader},view},stamp},cell}:rebuilt(~S,namespace,graph,sequence,nextReader,view,stamp,cell,Failure.read(~S,~Schema.hierarchy(~S),~Schema.resource_layout(~S),~Layout.InLeft{Layout.AtLeaf{}},namespace,sequence,tick,reader,channel))
# Read through the actual registered receiver Reader and actual retained channel.
# A read changes only that Reader cursor; the World/resource owners are returned.
def clocked(~S:Data,reader:Target.Reader(~S),result:Schema.World(~S) & Tick.Tick) -> Schema.World(~S) & Reading(~S):
  match result:
    case (W.World{namespace,allocator,columns,resource,events,pending,registrations,nextSystem,clock,lifecycle},tick):W.observe_resource_finish(~S,~Layout.columns(~S,Schema.components(~S)),~Schema.Resources(~S),~Unit,~Reading(~S),resources(~S,tick,reader,resource),namespace,allocator,columns,events,pending,registrations,nextSystem,clock,lifecycle)
def read(~S:Data,world:Schema.World(~S),reader:Target.Reader(~S)) -> Schema.World(~S) & Reading(~S):clocked(~S,reader,W.clock(~S,~Layout.columns(~S,Schema.components(~S)),~Schema.Resources(~S),~Unit,world))
