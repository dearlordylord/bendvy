import Base
import ../consumer.bend as Consumer
import ../fixture.bend as F
import ../frontend.bend as Front
import ../scheduled.bend as Scheduled
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema-product.bend as Setup
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
type Authority is Data:
  Authority{}
type Other is Data:
  Other{}
def rejected(app:F.Application(~Authority),plan:SP.Plan<Other>) -> Scheduled.Attachment<F.Application(~Authority),Consumer.Application(~Authority)>:
  Scheduled.attach(~Authority,~Setup.store(~Authority,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.owners(~Authority),~Front.rows(~Authority),~Front.observe(~Authority),~Front.fold(~Authority),app,"ForeignPlan",plan)
