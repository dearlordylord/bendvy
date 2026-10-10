import Base
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
# Only sequencing: individual callbacks own preparation/commit/failure contracts.
type PhasedMarker<-S:Data,-W:Type,-H:Type> is Type:
  PhasedMarker{apply:M.OwnedMarker<S,W,H>,exit:M.OwnedMarker<S,W,H>,transition:M.OwnedMarker<S,W,H>,enter:M.OwnedMarker<S,W,H>}
def next(~S:Data,~W:Type,~H:Type,marker:M.OwnedMarker<S,W,H>,pair:H & W) -> H & W:
  (owners,world)=pair
  M.run_owned_marker(~S,~W,~H,marker,owners,world)
def run(~S:Data,~W:Type,~H:Type,~flush:W -> W,marker:PhasedMarker<S,W,H>,owners:H,world:W) -> H & W:
  match marker:
    case PhasedMarker{apply,exit,transition,enter}:next(~S,~W,~H,enter,next(~S,~W,~H,transition,next(~S,~W,~H,exit,M.run_owned_marker(~S,~W,~H,apply,owners,flush(world)))))
