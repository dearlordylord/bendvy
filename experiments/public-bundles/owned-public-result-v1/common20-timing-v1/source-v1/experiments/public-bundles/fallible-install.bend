import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/src/ecs/bundle-pack.bend as BPack
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/src/ecs/world.bend as W

type Restore<World:Type,P:Type,Q:Type> is Type:
  Restored{world:World,payload:P}
  Pending{world:World,recovery:Q,error:W.WorldError}
type Attempt<World:Type,P:Type,Q:Type> is Type:
  Installed{world:World,undo:World -> Restore<World,P,Q>}
  Refused{world:World,payload:P,error:W.WorldError}
  Quarantined{world:World,recovery:Q,error:W.WorldError}
type Recovery<World:Type,H:Type,HQ:Type,Tail:Type,TQ:Type> is Type:
  HeadPending{head:HQ,tail:Tail}
  TailPending{undoHead:World -> Restore<World,H,HQ>,tail:TQ}
def restored_head(~World:Type,~H:Type,~HQ:Type,~Tail:Type,~TQ:Type,result:Restore<World,H,HQ>,tail:Tail) -> Restore<World,BPack.Pack<H,Tail>,Recovery<World,H,HQ,Tail,TQ>>:
  match result:
    case Restored{world,head}: Restored{world,BPack.Pack{head,tail}}
    case Pending{world,head,error}: Pending{world,HeadPending{head,tail},error}
def restored_tail(~World:Type,~H:Type,~HQ:Type,~Tail:Type,~TQ:Type,undoHead:World -> Restore<World,H,HQ>,result:Restore<World,Tail,TQ>) -> Restore<World,BPack.Pack<H,Tail>,Recovery<World,H,HQ,Tail,TQ>>:
  match result:
    case Restored{world,tail}: restored_head(~World,~H,~HQ,~Tail,~TQ,undoHead(world),tail)
    case Pending{world,tail,error}: Pending{world,TailPending{undoHead,tail},error}
def refused_head(~World:Type,~H:Type,~HQ:Type,~Tail:Type,~TQ:Type,result:Restore<World,H,HQ>,tail:Tail,error:W.WorldError) -> Attempt<World,BPack.Pack<H,Tail>,Recovery<World,H,HQ,Tail,TQ>>:
  match result:
    case Restored{world,head}: Refused{world,BPack.Pack{head,tail},error}
    case Pending{world,head,restoreError}: Quarantined{world,HeadPending{head,tail},restoreError}
def installed_tail(~World:Type,~H:Type,~HQ:Type,~Tail:Type,~TQ:Type,undoHead:World -> Restore<World,H,HQ>,result:Attempt<World,Tail,TQ>) -> Attempt<World,BPack.Pack<H,Tail>,Recovery<World,H,HQ,Tail,TQ>>:
  match result:
    case Refused{world,tail,error}: refused_head(~World,~H,~HQ,~Tail,~TQ,undoHead(world),tail,error)
    case Quarantined{world,tail,error}: Quarantined{world,TailPending{undoHead,tail},error}
    case Installed{world,undoTail}: Installed{world,w => restored_tail(~World,~H,~HQ,~Tail,~TQ,undoHead,undoTail(w))}
def installed_head(~World:Type,~H:Type,~HQ:Type,~Tail:Type,~TQ:Type,~installTail:World -> Tail -> Attempt<World,Tail,TQ>,result:Attempt<World,H,HQ>,tail:Tail) -> Attempt<World,BPack.Pack<H,Tail>,Recovery<World,H,HQ,Tail,TQ>>:
  match result:
    case Refused{world,head,error}: Refused{world,BPack.Pack{head,tail},error}
    case Quarantined{world,head,error}: Quarantined{world,HeadPending{head,tail},error}
    case Installed{world,undo}: installed_tail(~World,~H,~HQ,~Tail,~TQ,undo,installTail(world,tail))
def install(~World:Type,~H:Type,~HQ:Type,~Tail:Type,~TQ:Type,~installHead:World -> H -> Attempt<World,H,HQ>,~installTail:World -> Tail -> Attempt<World,Tail,TQ>,world:World,payload:BPack.Pack<H,Tail>) -> Attempt<World,BPack.Pack<H,Tail>,Recovery<World,H,HQ,Tail,TQ>>:
  match payload:
    case BPack.Pack{head,tail}: installed_head(~World,~H,~HQ,~Tail,~TQ,~installTail,installHead(world,head),tail)
def terminal(~World:Type,world:World,payload:Unit) -> Attempt<World,Unit,Unit>:
  Installed{world,w => Restored{w,Unit{}}}
