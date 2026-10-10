import ./tree.bend as Tree
import ./leaves.bend as Leaves
import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Query
import ../operational-v1/dispatch.bend as Dispatch
import ../operational-v1/validation.bend as Validation
import ../operational-v1/dispatch-result.bend as DispatchResult
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v1/observable-resource.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-system.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy-worktrees/schedule-observation-v1/experiments/public-inspect/ordinary-declaration-v1/compact-observation-app-v1/recipes.bend as Compact
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/ordinary-mixed-app-opaque-registry-v1/declarations.bend as Recipe
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-system.bend as System
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/app.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as IQ
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-observable.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v1/bridge.bend as Result
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/presentation.bend as Presented
import ./registration-unit.bend as Registration

import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
def component_query(~S:Data,~C:Type,~R:Type,~E:Data,~COps:Type -> Type,~CV:Data,~component:Unit -> Presented.Declaration<S,Q.Frame<S,C,R,E>,COps(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,CV>) -> O.Declaration<S,Q.Frame<S,C,R,E>,COps(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,CV>:
  Presented.ordinary(~S,~Q.Frame<S,C,R,E>,~COps(Q.Frame<S,C,R,E>),~I.Frame<S,C,R,E>,~CV,component(Unit{}))
def component_presenter(~S:Data,~C:Type,~R:Type,~E:Data,~COps:Type -> Type,~CV:Data,~component:Unit -> Presented.Declaration<S,Q.Frame<S,C,R,E>,COps(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,CV>) -> CV -> String:
  Presented.display(~S,~Q.Frame<S,C,R,E>,~COps(Q.Frame<S,C,R,E>),~I.Frame<S,C,R,E>,~CV,component(Unit{}))
def register_unit_component_resource(~S:Data,~C:Type,~R:Type,~E:Data,~COps:Type -> Type,~CError:Data,~CV:Data,~component:Unit -> Presented.Declaration<S,Q.Frame<S,C,R,E>,COps(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,CV>,~componentBody:@-H:Type -> @-caps:COps(H) -> Unit -> H -> H & (T.Outcome<CError> & Unit),~ROps:Type -> Type,~RError:Data,~RV:Data,~declaration:D.Declaration<S,C,R,E,ROps,RV>,~resourceBody:@-H:Type -> @-caps:ROps(H) -> Unit -> H -> H & (T.Outcome<RError> & Unit),~firstCondition:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,~secondCondition:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,~available:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,~Output:Type,~done:@-query:O.Declaration<S,Q.Frame<S,C,R,E>,COps(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,CV> -> @-render:(CV -> String) -> @-declaration:D.Declaration<S,C,R,E,ROps,RV> -> @-crunner:(W.World<S,C,R,E> -> (Unit & U32) -> Sys.Outcome<W.World<S,C,R,E>,Q.Error<CError>,List<&2,Unit>>) -> @-rrunner:(W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,RError,Unit>) -> @-kind:Query.Mode -> List<(SP.Provisioned<S,C,R,E,(System.Owner<S,Sys.Registry<S,C,R,E,Unit & U32,Q.Error<CError>,List<&2,Unit>,crunner>> & P.Owner<S,Sys.Registry<S,C,R,E,Unit,RError,Unit,rrunner>,kind>)> -> W.World<S,C,R,E> -> SP.ProvisionResult<S,C,R,E,(System.Owner<S,Sys.Registry<S,C,R,E,Unit & U32,Q.Error<CError>,List<&2,Unit>,crunner>> & P.Owner<S,Sys.Registry<S,C,R,E,Unit,RError,Unit,rrunner>,kind>),DispatchResult.Error<Q.Error<CError>,RError>> & Maybe<DispatchResult.Arguments<Unit,Unit>>)> -> Compact.Application<S,W.World<S,C,R,E>,(System.Owner<S,Sys.Registry<S,C,R,E,Unit & U32,Q.Error<CError>,List<&2,Unit>,crunner>> & P.Owner<S,Sys.Registry<S,C,R,E,Unit,RError,Unit,rrunner>,kind>),DTO.Product<DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,CV>>>,RV>,Tree.Recipe<W.World<S,C,R,E>,DTO.Product<DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,CV>>>,RV>,Tree.observe_pair(~W.World<S,C,R,E>,~DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,CV>>>,~RV,~Leaves.component_observe(~S,~C,~R,~E,~COps,~CV,~query,~render),~Leaves.resource_observe(~S,~C,~R,~E,~ROps,~RV,~declaration))>> -> Output,~failed:@-Owners:Type -> W.World<S,C,R,E> -> Owners -> Output,world:W.World<S,C,R,E>,componentName:String,componentSlot:String,resourceName:String,resourceSlot:String) -> Output:
  Registration.register_component_resource(~S,~C,~R,~E,~COps,~CError,~CV,~component_query(~S,~C,~R,~E,~COps,~CV,~component),~component_presenter(~S,~C,~R,~E,~COps,~CV,~component),~componentBody,~ROps,~RError,~RV,~declaration,~resourceBody,~firstCondition,~secondCondition,~available,~Output,~done,~failed,world,componentName,componentSlot,resourceName,resourceSlot)
