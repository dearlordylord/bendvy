import Base
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v1/observable-resource.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-system.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy-worktrees/schedule-observation-v1/experiments/public-inspect/ordinary-declaration-v1/compact-observation-app-v1/recipes.bend as Compact
import /workspace/formal-proofs/bendvy-worktrees/schedule-observation-v1/experiments/public-inspect/ordinary-declaration-v1/compact-observation-app-v1/declarations.bend as Recipe
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-system.bend as System
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/app.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as IQ
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-observable.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v1/bridge.bend as Result
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/presentation.bend as Presented
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/ordinary-mixed-app-v1/production-factory-v1/registration.bend as Registration

def enable_debug(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~Recipes:Type,app:Compact.Application<S,World,Owners,Rows,Recipes>,enabled:Bool) -> Compact.Application<S,World,Owners,Rows,Recipes>:
  Registration.enable_debug(~S,~World,~Owners,~Rows,~Recipes,app,enabled)
def component_query(~S:Data,~C:Type,~R:Type,~E:Data,~COps:Type -> Type,~CV:Data,~component:Unit -> Presented.Declaration<S,Q.Frame<S,C,R,E>,COps(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,CV>) -> O.Declaration<S,Q.Frame<S,C,R,E>,COps(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,CV>:
  Presented.ordinary(~S,~Q.Frame<S,C,R,E>,~COps(Q.Frame<S,C,R,E>),~I.Frame<S,C,R,E>,~CV,component(Unit{}))
def component_presenter(~S:Data,~C:Type,~R:Type,~E:Data,~COps:Type -> Type,~CV:Data,~component:Unit -> Presented.Declaration<S,Q.Frame<S,C,R,E>,COps(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,CV>) -> CV -> String:
  Presented.display(~S,~Q.Frame<S,C,R,E>,~COps(Q.Frame<S,C,R,E>),~I.Frame<S,C,R,E>,~CV,component(Unit{}))
def register_component_resource(~S:Data,~C:Type,~R:Type,~E:Data,~COps:Type -> Type,~CArgs:Data,~CError:Data,~COut:Data,~CV:Data,~component:Unit -> Presented.Declaration<S,Q.Frame<S,C,R,E>,COps(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,CV>,~componentBody:@-H:Type -> @-caps:COps(H) -> CArgs -> H -> H & (T.Outcome<CError> & COut),~ROps:Type -> Type,~RArgs:Type,~RError:Data,~ROut:Type,~RV:Data,~declaration:D.Declaration<S,C,R,E,ROps,RV>,~resourceBody:@-H:Type -> @-caps:ROps(H) -> RArgs -> H -> H & (T.Outcome<RError> & ROut),~Output:Type,~done:@-Owners:Type -> @-Observed:Data -> @-Recipes:Type -> @-snapshot:(Compact.Application<S,W.World<S,C,R,E>,Owners,Observed,Recipes> -> Compact.Application<S,W.World<S,C,R,E>,Owners,Observed,Recipes> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Observed>>>) -> @-invoke:(Compact.Application<S,W.World<S,C,R,E>,Owners,Observed,Recipes> -> RArgs -> Result.RunResult<Compact.Application<S,W.World<S,C,R,E>,Owners,Observed,Recipes>,RArgs,RError,ROut>) -> Compact.Application<S,W.World<S,C,R,E>,Owners,Observed,Recipes> -> Output,~failed:@-Owners:Type -> W.World<S,C,R,E> -> Owners -> Output,world:W.World<S,C,R,E>,componentName:String,componentSlot:String,resourceName:String,resourceSlot:String) -> Output:
  Registration.register_component_resource(~S,~C,~R,~E,~COps,~CArgs,~CError,~COut,~CV,~component_query(~S,~C,~R,~E,~COps,~CV,~component),~component_presenter(~S,~C,~R,~E,~COps,~CV,~component),~componentBody,~ROps,~RArgs,~RError,~ROut,~RV,~declaration,~resourceBody,~Output,~done,~failed,world,componentName,componentSlot,resourceName,resourceSlot)
