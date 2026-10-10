import Base
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-retained-plan-v1/public-adoption-v1/normal/consumer.bend as Consumer
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-retained-plan-v1/fixture.bend as F
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-retained-plan-v1/frontend.bend as Front
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule.bend as Scheduled
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema-product.bend as Setup
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
type Authority is Data:
  Authority{}
type Other is Data:
  Other{}
def main() -> Consumer.Report:
  Consumer.Report{Consumer.scenario(~Other,0n),Consumer.scenario(~Other,2n)}
