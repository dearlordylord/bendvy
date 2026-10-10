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
def rejected(app:F.Application(~Authority),plan:SP.Plan<Other>) -> Scheduled.Attachment<F.Application(~Authority),Consumer.Application(~Authority)>:
  Scheduled.attach(~Authority,~Setup.store(~Authority,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.owners(~Authority),~Front.rows(~Authority),~Front.observe(~Authority),~Front.fold(~Authority),app,"ForeignPlan",plan)
