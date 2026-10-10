import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/bundle-pack.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/bundle-install.bend as F

# An explicitly requested restoration step; unchanged existing inverse order.
def resume(~World:Type,~H:Type,~HQ:Type,~Tail:Type,~TQ:Type,~head:World -> HQ -> F.Restore<World,H,HQ>,~tail:World -> TQ -> F.Restore<World,Tail,TQ>,world:World,recovery:F.Recovery<World,H,HQ,Tail,TQ>) -> F.Restore<World,B.Pack<H,Tail>,F.Recovery<World,H,HQ,Tail,TQ>>:
  match recovery:
    case F.HeadPending{pending,rest}:F.Pending{world,F.HeadPending{pending,rest},W.MissingEntity{}}
    case F.TailPending{undoHead,pending}:F.restored_tail(~World,~H,~HQ,~Tail,~TQ,undoHead,tail(world,pending))
