import Base
import bundle.bend as B
import resources.bend as R
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/relation-query.bend as RQ
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-declaration.bend as MD
import /workspace/formal-proofs/bendvy/src/ecs/inspector-relation-projection.bend as RP
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as IQ
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col

def parent() -> G.Descriptor<B.Scene>: G.Descriptor{1,"Parent","Children",G.Hierarchy{}}
def related() -> G.Descriptor<B.Scene>: G.Descriptor{2,"Link","LinkedBy",G.Ordinary{}}
def relations() -> RQ.Spec<B.Scene>:
  RQ.Spec{[RQ.optional_relation(~B.Scene,"parent",parent()),RQ.optional_related(~B.Scene,"children",parent()),RQ.optional_relation(~B.Scene,"link",related())]}
def phase() -> MD.Declaration<B.Scene,R.PhaseToken,U32,R.Resources(),R.phase>:
  MD.Declaration{"ScenePhase"}
type Selected is Data:
  Selected{cursor:U32,phase:M.CurrentView<B.Scene,R.PhaseToken,U32>,rows:List<&2,IQ.ProjectedRow<B.Scene,Q.Product<Unit,List<&2,RQ.Cell<B.Scene>>>>>,scalar:I.Value<U32>}
def scalar_cap() -> I.Lookup<I.Frame<B.Scene,B.Store(),R.Resources(),A.Notice<B.Scene,U32>>,B.Scene,U32>:
  I.read_family(~B.Scene,~B.Store(),~R.Resources(),~A.Notice<B.Scene,U32>,~(G.Graph<B.Scene> & Col.Column<B.Scene,Array<U32>>),~U32,~U32,~B.ScalarToken,~B.take_scalar,~B.put_scalar,~B.project_scalar,~B.scalar_family())
def scalar_body(~H:Type,~cap:I.Lookup<H,B.Scene,U32>,target:W.Handle<B.Scene>,owner:H) -> H & I.Value<U32>:
  I.lookup(~H,~B.Scene,~U32,~cap,owner,target)
def scalar_done(phase:M.CurrentView<B.Scene,R.PhaseToken,U32>,rows:List<&2,IQ.ProjectedRow<B.Scene,Q.Product<Unit,List<&2,RQ.Cell<B.Scene>>>>>,result:I.Frame<B.Scene,B.Store(),R.Resources(),A.Notice<B.Scene,U32>> & I.Value<U32>) -> B.World(R.Resources()) & Selected:
  match result:
    case (I.Frame{world,cursor},scalar): (world,Selected{cursor,phase,rows,scalar})
def rows_done(target:W.Handle<B.Scene>,phase:M.CurrentView<B.Scene,R.PhaseToken,U32>,result:I.Frame<B.Scene,B.Store(),R.Resources(),A.Notice<B.Scene,U32>> & List<&2,IQ.ProjectedRow<B.Scene,Q.Product<Unit,List<&2,RQ.Cell<B.Scene>>>>>) -> B.World(R.Resources()) & Selected:
  match result:
    case (frame,rows):scalar_done(phase,rows,scalar_body(~I.Frame<B.Scene,B.Store(),R.Resources(),A.Notice<B.Scene,U32>>,~scalar_cap(),target,frame))
def phase_done(target:W.Handle<B.Scene>,result:I.Frame<B.Scene,B.Store(),R.Resources(),A.Notice<B.Scene,U32>> & M.CurrentView<B.Scene,R.PhaseToken,U32>) -> B.World(R.Resources()) & Selected:
  match result:
    case (frame,phase):rows_done(target,phase,IQ.each_composed(~I.Frame<B.Scene,B.Store(),R.Resources(),A.Notice<B.Scene,U32>>,~B.Scene,~Q.Product<Unit,List<&2,RQ.Cell<B.Scene>>>,~RP.grant(~B.Scene,~B.Components,~R.Resources(),~U32,~Unit,~Q.empty(~I.Frame<B.Scene,B.Store(),R.Resources(),A.Notice<B.Scene,U32>>,~B.Scene),~relations()),frame))
def snapshot(world:B.World(R.Resources()),target:W.Handle<B.Scene>) -> B.World(R.Resources()) & Selected:
  phase_done(target,MD.get(~I.Frame<B.Scene,B.Store(),R.Resources(),A.Notice<B.Scene,U32>>,~B.Scene,~R.PhaseToken,~U32,~MD.inspect(~B.Scene,~R.PhaseToken,~U32,~B.Store(),~R.Resources(),~A.Notice<B.Scene,U32>,~R.phase,~phase()),I.Frame{world,0}))
