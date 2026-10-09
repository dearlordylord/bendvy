import Base
import ./types.bend as T
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/scenario-observation.bend as Observe
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
type Snapshot is Data:
  Snapshot{namespace:U32,nextId:U32,highWater:U32,capacity:U32,depth:Nat,liveBits:List<&2,Bool>,store:Unit,resource:T.ResourceView,events:List<&2,Unit>,pendingCount:U32,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32}
def bits_seen(resourceView:T.ResourceView,pendingCount:U32,+namespace:U32,+nextId:U32,+highWater:U32,+capacity:U32,+depth:Nat,+store:Unit,resource:T.Resources,+events:List<&2,Unit>,pending:List<(W.World<T.Tag,Unit,T.Resources,Unit> -> W.World<T.Tag,Unit,T.Resources,Unit>)>,+registrations:List<&2,W.RegistrationMeta>,+nextSystemId:U32,+clock:U32,got:Array<Bool> & List<&2,Bool>) -> W.World<T.Tag,Unit,T.Resources,Unit> & Snapshot:
  match got:
    case (live,bits):(W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},Snapshot{namespace,nextId,highWater,capacity,depth,bits,store,resourceView,events,pendingCount,registrations,nextSystemId,clock})
def counted(resourceView:T.ResourceView,got:W.World<T.Tag,Unit,T.Resources,Unit> & U32) -> W.World<T.Tag,Unit,T.Resources,Unit> & Snapshot:
  match got:
    case (W.World{+namespace,+nextId,+highWater,live,+capacity,+depth,+store,resource,+events,pending,+registrations,+nextSystemId,+clock},pendingCount):bits_seen(resourceView,pendingCount,namespace,nextId,highWater,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock,Observe.bits(U32.to_nat(capacity),0,live))
def projected(got:W.World<T.Tag,Unit,T.Resources,Unit> & T.ResourceView) -> W.World<T.Tag,Unit,T.Resources,Unit> & Snapshot:
  match got:
    case (world,resourceView):counted(resourceView,W.pending_count(~T.Tag,~Unit,~T.Resources,~Unit,world))
def snapshot(world:W.World<T.Tag,Unit,T.Resources,Unit>) -> W.World<T.Tag,Unit,T.Resources,Unit> & Snapshot:
  projected(W.observe_resource(~T.Tag,~Unit,~T.Resources,~Unit,~T.ResourceView,~T.view,world))
