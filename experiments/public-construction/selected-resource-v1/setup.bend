import Base
import ./fixture.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W

def raw(namespace:U32,value:U32) -> D.Raw:D.Object{[D.Field{"value",D.Number{value}},D.Field{"handle",D.Handle{namespace,1}}]}
def payload(~S:Data,+namespace:U32,+value:U32,owned:Array<U32>) -> F.Payload<S>:F.Payload{raw(namespace,value),raw(namespace,value),F.Valid{},owned}
def resources(~S:Data) -> F.Resources(~S):Product.Owner{payload(~S,0,100,ANode{ALeaf{100},ALeaf{101}}),Product.Owner{payload(~S,0,800,ANode{ALeaf{800},ALeaf{801}}),F.Other{ANode{ALeaf{True{}},ALeaf{False{}}},"unlike"}}}
def reseed(~S:Data,+namespace:U32,value:F.Payload<S>) -> F.Payload<S>:
  match value:
    case F.Payload{_,_,mode,owned}:F.Payload{raw(namespace,100),raw(namespace,100),mode,owned}
def seed_resources(~S:Data,+namespace:U32,value:F.Resources(~S)) -> F.Resources(~S):
  match value:
    case Product.Owner{target,Product.Owner{F.Payload{_,_,mode,owned},other}}:Product.Owner{reseed(~S,namespace,target),Product.Owner{F.Payload{raw(namespace,800),raw(namespace,800),mode,owned},other}}
def command_returned(~S:Data,value:F.World(~S) & U32) -> F.World(~S):
  match value:
    case (world,_):world
def command(~S:Data,world:F.World(~S)) -> F.World(~S):command_returned(~S,W.advance_clock(~S,~Array<U32>,~F.Resources(~S),~Unit,world))
def queued(~S:Data,world:F.World(~S)) -> F.World(~S):W.enqueue(~S,~Array<U32>,~F.Resources(~S),~Unit,world,command(~S))
# Trusted setup reads the actual WorldIO namespace; request Raw never supplies it.
def prepare(~S:Data,world:F.World(~S)) -> F.World(~S) & F.Context<S>:
  match world:
    case W.World{+namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock}:(queued(~S,W.World{namespace,nextId,highWater,live,capacity,depth,store,seed_resources(~S,namespace,resource),events,pending,registrations,nextSystemId,clock}),F.context(~S,namespace))
def input(~S:Data,context:F.Context<S>,value:U32,mode:F.Mode,owned:Array<U32>) -> F.Input<S>:
  match context:
    case F.Context{namespace,_}:F.Input{raw(namespace,value),mode,owned}
def invalid_input(~S:Data,context:F.Context<S>,owned:Array<U32>) -> F.Input<S>:
  match context:
    case F.Context{namespace,_}:F.Input{D.Object{[D.Field{"value",D.Text{"invalid-input"}},D.Field{"handle",D.Handle{namespace,1}}]},F.Valid{},owned}
