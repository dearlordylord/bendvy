import Base
import ../../../public-bundles/fallible-install.bend as F
import ../../../../src/ecs/world.bend as W

# Terminal finite observer: executes retained inverses against the actual owner.
# It consumes each returned typed cold owner into its authored observation.
# It neither repairs a missing entity nor fabricates an incoming payload.
def error_text(error:W.WorldError) -> String:
  match error:
    case W.MissingEntity{}: "MissingEntity"
    case W.CapacityExceeded{}: "CapacityExceeded"
    case error: "other-world-error"
def observed(~World:Type,~H:Type,~HQ:Type,~showH:H -> String,~showHQ:HQ -> String,tail:String,result:F.Restore<World,H,HQ>) -> World & String:
  match result:
    case F.Restored{world,head}: (world,"restored(" ++ showH(head) ++ ")|" ++ tail)
    case F.Pending{world,cold,error}: (world,"pending(" ++ showHQ(cold) ++ "," ++ error_text(error) ++ ")|" ++ tail)
def head(~World:Type,~H:Type,~HQ:Type,~showH:H -> String,~showHQ:HQ -> String,inverse:World -> F.Restore<World,H,HQ>,result:World & String) -> World & String:
  match result:
    case (world,tail): observed(~World,~H,~HQ,~showH,~showHQ,tail,inverse(world))
def collect(~World:Type,~H:Type,~HQ:Type,~Tail:Type,~TQ:Type,~showH:H -> String,~showHQ:HQ -> String,~showTail:Tail -> String,~drainTail:World -> TQ -> World & String,world:World,recovery:F.Recovery<World,H,HQ,Tail,TQ>) -> World & String:
  match recovery:
    case F.HeadPending{cold,tail}: (world,"head-pending(" ++ showHQ(cold) ++ ")|tail-payload(" ++ showTail(tail) ++ ")")
    case F.TailPending{inverse,tail}: head(~World,~H,~HQ,~showH,~showHQ,inverse,drainTail(world,tail))
