import Base
import types.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/machine-stream.bend as Stream
def take_first(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & M.Slot<S,T.FirstKey,T.First>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,+first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock}:(W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock},first)
def put_first(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,first:M.Slot<S,T.FirstKey,T.First>) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,_,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock}:W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock}
def publish_first(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,event:M.Transition<T.First>) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,+firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock}:W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,Stream.publish(~T.First,firstStream,firstTick,event),secondStream,firstReader,secondReader,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock}
def frame_first(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock}:W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,1n+firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock}
def queued_first(~S:Data,to:T.First,pair:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & M.Slot<S,T.FirstKey,T.First>) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>:
  (world,slot)=pair
  put_first(~S,world,M.queue(~S,~T.FirstKey,~T.First,slot,to,False{}))
def queue_first(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,to:T.First) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>:queued_first(~S,to,take_first(~S,world))
def take_second(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & M.Slot<S,T.SecondKey,T.Second>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,+second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock}:(W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock},second)
def put_second(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,second:M.Slot<S,T.SecondKey,T.Second>) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,_,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock}:W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock}
def publish_second(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,event:M.Transition<T.Second>) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,+secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock}:W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,Stream.publish(~T.Second,secondStream,secondTick,event),firstReader,secondReader,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock}
def frame_second(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock}:W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,1n+secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock}
def queued_second(~S:Data,to:T.Second,pair:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & M.Slot<S,T.SecondKey,T.Second>) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>:
  (world,slot)=pair
  put_second(~S,world,M.queue(~S,~T.SecondKey,~T.Second,slot,to,False{}))
def queue_second(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,to:T.Second) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>:queued_second(~S,to,take_second(~S,world))
