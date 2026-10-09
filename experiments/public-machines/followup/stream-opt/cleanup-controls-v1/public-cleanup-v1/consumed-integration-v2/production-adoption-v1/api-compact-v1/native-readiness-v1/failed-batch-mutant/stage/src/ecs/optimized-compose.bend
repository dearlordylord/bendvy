import Base
import ../../experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/world.bend as W
import compose.bend as Q
import ../../experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/transaction.bend as T

# Trusted schema preparation/recovery declarations preserve arbitrary Store/Ops.
# The registered runner remains indexed by this closed provider selection.
def map_store(~S:Data,~Store:Type,~R:Type,~E:Data,~map:Store -> Store,world:W.World<S,Store,R,E>) -> W.World<S,Store,R,E>:
  match world:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock}: W.World{namespace,nextId,highWater,live,capacity,depth,map(store),resource,events,pending,registrations,nextSystemId,clock}
def recovered(~S:Data,~Store:Type,~R:Type,~E:Data,~U:Data,~Out:Data,~recover:Store -> Store,result:Q.Executed<W.World<S,Store,R,E>,Q.Error<U>,Out>) -> Q.Executed<W.World<S,Store,R,E>,Q.Error<U>,Out>:
  match result:
    case Q.Executed{world,outcome,values}: Q.Executed{map_store(~S,~Store,~R,~E,~recover,world),outcome,values}
def each(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~plan:Q.Plan<S,Store,R,E,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),~prepare:Store -> Store,~recover:Store -> Store,args:A,world:W.World<S,Store,R,E>) -> Q.Executed<W.World<S,Store,R,E>,Q.Error<U>,Out>:
  recovered(~S,~Store,~R,~E,~U,~Out,~recover,Q.each(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~plan,~body,args,map_store(~S,~Store,~R,~E,~prepare,world)))
def each_since(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~plan:Q.Plan<S,Store,R,E,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),~prepare:Store -> Store,~recover:Store -> Store,args:A,world:W.World<S,Store,R,E>,cursor:U32) -> Q.Executed<W.World<S,Store,R,E>,Q.Error<U>,Out>:
  recovered(~S,~Store,~R,~E,~U,~Out,~recover,Q.each_since(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~plan,~body,args,map_store(~S,~Store,~R,~E,~prepare,world),cursor))
