import Base
import ./execution-builder.bend as Build
import ./execution-declaration.bend as D
import ./execution-resource-admission.bend as Admission
import ./execution-resource-recipe.bend as Resources
import ./execution-query-schema.bend as Query
import ./execution-query-domain.bend as Domain
import ./execution-composer-layout.bend as L
import ./world.bend as W

# Serial retains the original World before clock entry or owner extraction.
# The ordinary executor threads that actual World through the two leaves.
type Mode is Data:
  Parallel{}
  Serial{}
def query_conflicts(+left:List<&2,Query.Entry>,+right:List<&2,Query.Entry>,pending:List<&2,Query.Entry>) -> Bool:
  match pending:
    case []:False{}
    case Query.Entry{+route,_} <> rest:Bool.or(Domain.conflicts(Query.entry_access(route,left),Query.entry_access(route,right)),query_conflicts(left,right,rest))
def classified(conflicts:Bool) -> Mode:
  match conflicts:
    case True{}:Serial{}
    case False{}:Parallel{}
def classify(~resources:L.Layout,+left:List<&2,Query.Entry>,right:List<&2,Query.Entry>,rl:List<&2,Resources.Entry>,rr:List<&2,Resources.Entry>) -> Mode:
  classified(Bool.or(query_conflicts(left,right,left),Bool.not(Resources.compatible(~resources,rl,rr))))
type Inspection<-S:Data,-components:L.Layout,-resources:L.Layout,-C:Type,-R:Type,-E:Data,-LeftOps:Data -> Type -> Type,-RightOps:Data -> Type -> Type,-leftProgram:Build.FrameworkProgram(~S,~L.columns(~S,components),~C,~R,~LeftOps),-rightProgram:Build.FrameworkProgram(~S,~L.columns(~S,components),~C,~R,~RightOps)> is Type:
  Admitted{world:W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,left:D.Compilation<S,L.columns(~S,components),C,R,LeftOps>,right:D.Compilation<S,L.columns(~S,components),C,R,RightOps>,leftEvidence:Admission.Evidence<S,components,resources,C,R,LeftOps,leftProgram>,rightEvidence:Admission.Evidence<S,components,resources,C,R,RightOps,rightProgram>,mode:Mode}
  Refused{world:W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,left:D.Compilation<S,L.columns(~S,components),C,R,LeftOps>,right:D.Compilation<S,L.columns(~S,components),C,R,RightOps>}
def right_inspected(~S:Data,~components:L.Layout,~resources:L.Layout,~C:Type,~R:Type,~E:Data,~LeftOps:Data -> Type -> Type,~RightOps:Data -> Type -> Type,~leftProgram:Build.FrameworkProgram(~S,~L.columns(~S,components),~C,~R,~LeftOps),~rightProgram:Build.FrameworkProgram(~S,~L.columns(~S,components),~C,~R,~RightOps),left:D.Compilation<S,L.columns(~S,components),C,R,LeftOps>,leftEvidence:Admission.Evidence<S,components,resources,C,R,LeftOps,leftProgram>,result:Admission.Inspection<S,components,resources,C,R,E,RightOps,rightProgram>) -> Inspection<S,components,resources,C,R,E,LeftOps,RightOps,leftProgram,rightProgram>:
  match leftEvidence result:
    case leftEvidence Admission.Refused{world,right}:Refused{world,left,right}
    case Admission.Evidence{ln,lh,lq,+lr,li,ls,lg,Query.Book{+lb},lrb} Admission.Admitted{world,right,Admission.Evidence{rn,rh,rq,+rr,ri,rs,rg,Query.Book{+rb},rrb}}:Admitted{world,left,right,Admission.Evidence{ln,lh,lq,lr,li,ls,lg,Query.Book{lb},lrb},Admission.Evidence{rn,rh,rq,rr,ri,rs,rg,Query.Book{rb},rrb},classify(~resources,lb,rb,lr,rr)}
def left_inspected(~S:Data,~components:L.Layout,~resources:L.Layout,~C:Type,~R:Type,~E:Data,~LeftOps:Data -> Type -> Type,~RightOps:Data -> Type -> Type,~leftProgram:Build.FrameworkProgram(~S,~L.columns(~S,components),~C,~R,~LeftOps),~rightProgram:Build.FrameworkProgram(~S,~L.columns(~S,components),~C,~R,~RightOps),right:D.Compilation<S,L.columns(~S,components),C,R,RightOps>,result:Admission.Inspection<S,components,resources,C,R,E,LeftOps,leftProgram>) -> Inspection<S,components,resources,C,R,E,LeftOps,RightOps,leftProgram,rightProgram>:
  match result:
    case Admission.Refused{world,left}:Refused{world,left,right}
    case Admission.Admitted{world,left,evidence}:right_inspected(~S,~components,~resources,~C,~R,~E,~LeftOps,~RightOps,~leftProgram,~rightProgram,left,evidence,Admission.inspect_with_compilation(~S,~components,~resources,~C,~R,~E,~RightOps,~rightProgram,right,world))
def inspect_with_compilations(~S:Data,~components:L.Layout,~resources:L.Layout,~C:Type,~R:Type,~E:Data,~LeftOps:Data -> Type -> Type,~RightOps:Data -> Type -> Type,~leftProgram:Build.FrameworkProgram(~S,~L.columns(~S,components),~C,~R,~LeftOps),~rightProgram:Build.FrameworkProgram(~S,~L.columns(~S,components),~C,~R,~RightOps),left:D.Compilation<S,L.columns(~S,components),C,R,LeftOps>,right:D.Compilation<S,L.columns(~S,components),C,R,RightOps>,world:W.World<S,L.columns(~S,components),L.resources(~S,resources),E>) -> Inspection<S,components,resources,C,R,E,LeftOps,RightOps,leftProgram,rightProgram>:
  left_inspected(~S,~components,~resources,~C,~R,~E,~LeftOps,~RightOps,~leftProgram,~rightProgram,right,Admission.inspect_with_compilation(~S,~components,~resources,~C,~R,~E,~LeftOps,~leftProgram,left,world))
