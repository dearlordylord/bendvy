import Base
import ../recipe-tree-v1/tree.bend as Tree
import ../recipe-tree-v1/leaves.bend as Leaves
import ../recipe-tree-v1/schedule-view.bend as View
import ../operational-v1/bridge.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-system.bend as System
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-system.bend as ResourceSystem
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as IQ
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-observable.bend as O
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v1/observable-resource.bend as D
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/app.bend as DTO
# Canonical same-declaration metadata generation; no caller adapter argument.
# Generic observation accepts affine Args/Out but never executes/disposes them.
def snapshot(~S:Data,~C:Type,~R:Type,~E:Data,~CArgs:Type,~CError:Data,~COut:Type,~crunner:W.World<S,C,R,E> -> CArgs -> Sys.Outcome<W.World<S,C,R,E>,CError,COut>,~RArgs:Type,~RError:Data,~ROut:Type,~rrunner:W.World<S,C,R,E> -> RArgs -> Sys.Outcome<W.World<S,C,R,E>,RError,ROut>,~kind:Query.Mode,~COps:Type -> Type,~CV:Data,~query:O.Declaration<S,Q.Frame<S,C,R,E>,COps(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,CV>,~render:CV -> String,~ROps:Type -> Type,~RV:Data,~declaration:D.Declaration<S,C,R,E,ROps,RV>,app:B.ApplicationType<S,C,R,E,(System.Owner<S,Sys.Registry<S,C,R,E,CArgs,CError,COut,crunner>> & ResourceSystem.Owner<S,Sys.Registry<S,C,R,E,RArgs,RError,ROut,rrunner>,kind>),DTO.Product<DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,CV>>>,RV>,Tree.Recipe<W.World<S,C,R,E>,DTO.Product<DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,CV>>>,RV>,Tree.observe_pair(~W.World<S,C,R,E>,~DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,CV>>>,~RV,~Leaves.component_observe(~S,~C,~R,~E,~COps,~CV,~query,~render),~Leaves.resource_observe(~S,~C,~R,~E,~ROps,~RV,~declaration))>>) -> B.ApplicationType<S,C,R,E,(System.Owner<S,Sys.Registry<S,C,R,E,CArgs,CError,COut,crunner>> & ResourceSystem.Owner<S,Sys.Registry<S,C,R,E,RArgs,RError,ROut,rrunner>,kind>),DTO.Product<DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,CV>>>,RV>,Tree.Recipe<W.World<S,C,R,E>,DTO.Product<DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,CV>>>,RV>,Tree.observe_pair(~W.World<S,C,R,E>,~DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,CV>>>,~RV,~Leaves.component_observe(~S,~C,~R,~E,~COps,~CV,~query,~render),~Leaves.resource_observe(~S,~C,~R,~E,~ROps,~RV,~declaration))>> & Maybe<&2,DTO.Product<DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<DTO.Product<DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,CV>>>,RV>>>,B.ScheduleDescription<S>>>:
  View.snapshot(~S,~C,~R,~E,~(System.Owner<S,Sys.Registry<S,C,R,E,CArgs,CError,COut,crunner>> & ResourceSystem.Owner<S,Sys.Registry<S,C,R,E,RArgs,RError,ROut,rrunner>,kind>),~DTO.Product<DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,CV>>>,RV>,~Tree.observe_pair(~W.World<S,C,R,E>,~DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,CV>>>,~RV,~Leaves.component_observe(~S,~C,~R,~E,~COps,~CV,~query,~render),~Leaves.resource_observe(~S,~C,~R,~E,~ROps,~RV,~declaration)),Tree.describe_pair(~S,~System.Owner<S,Sys.Registry<S,C,R,E,CArgs,CError,COut,crunner>>,~ResourceSystem.Owner<S,Sys.Registry<S,C,R,E,RArgs,RError,ROut,rrunner>,kind>,~Leaves.component_describe(~S,~C,~R,~E,~CArgs,~CError,~COut,~crunner),~Leaves.resource_describe(~S,~C,~R,~E,~RArgs,~RError,~ROut,~rrunner,~kind)),app)
