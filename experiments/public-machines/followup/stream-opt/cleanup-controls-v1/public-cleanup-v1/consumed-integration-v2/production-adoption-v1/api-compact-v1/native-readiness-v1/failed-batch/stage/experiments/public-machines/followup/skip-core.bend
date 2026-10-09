import Base
import ../provider.bend as P
import ../gameplay.bend as G
import ../context.bend as Ctx
import ../conditions.bend as C
import ../application.bend as A
import ../catalog.bend as Cat
import ../hooks.bend as H
import observations.bend as F

# Numeric TS states 0/1/2 map bijectively to Boot/Play/Pause in this control.
# Extra Level metadata and eager hook registrations are observed supplements.
def plans(~S: Data) -> List<&2,A.FramePlan<S>>:
  [A.FramePlan{"initial",[A.Body{1,"seed",G.Seed{}},A.Deferred{}]},
   A.FramePlan{"published",[A.Body{2,"publish",G.PlayRequest{}},A.Marker{False{}}]},
   A.FramePlan{"never-activated-skip",[A.GatedRead{10,"reader",C.Leaf{P.InFlow{P.Boot{}}}}]},
   A.FramePlan{"first-activation",[A.Body{3,"second",G.PauseRequest{}},A.Marker{False{}},A.Read{10,"reader",False{}}]},
   A.FramePlan{"empty-repeat",[A.Read{10,"reader",False{}}]}]

def provisioned(~S: Data,result: H.Provision<S,(world => operation => Ctx.hook_runner(~S,world,operation))>) -> String:
  match result:
    case H.Provisioned{world,hooks}:
      F.finish(~S,F.frames(~S,plans(~S),F.Observed{A.Owners{Cat.Catalog{[]},hooks,[],[],[],[],[]},world,[]}))
    case H.ProvisionFailed{_}: "HOOK_PROVISION_REJECTED"
