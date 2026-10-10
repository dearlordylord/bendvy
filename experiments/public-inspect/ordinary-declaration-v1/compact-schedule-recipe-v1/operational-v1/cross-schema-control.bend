import Base
import ./bridge.bend as B
import /workspace/formal-proofs/bendvy-worktrees/schedule-observation-v1/experiments/public-inspect/ordinary-declaration-v1/compact-observation-app-v1/recipes.bend as Compact
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/app.bend as DTO
type A is Data:
  A{}
type Other is Data:
  Other{}
def invalid(~H:Type,~Rows:Data,~Recipe:Type,app:Compact.Application<A,W.World<A,Unit,Unit,Unit>,H,Rows,Recipe>,plan:SP.Plan<Other>) -> DTO.Registration<Compact.Application<A,W.World<A,Unit,Unit,Unit>,H,Rows,Recipe>,B.ApplicationType<A,Unit,Unit,Unit,H,Rows,Recipe>>:
  B.attach(~A,~Unit,~Unit,~Unit,~H,~Rows,~Recipe,app,"Foreign",plan)
