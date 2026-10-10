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
def recovered(result:Scheduled.Attachment<F.Application(~Authority),Consumer.Application(~Authority)>) -> F.Application(~Authority):
  match result:
    case Scheduled.Invalid{app}:app
    case Scheduled.Attached{Scheduled.Application{app,_,_,_,_,_}}:app
def recover(app:F.Application(~Authority)) -> F.Application(~Authority):
  recovered(Scheduled.attach(~Authority,~Setup.store(~Authority,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.owners(~Authority),~Front.rows(~Authority),~Front.observe(~Authority),~Front.fold(~Authority),app,"InvalidPlan",SP.Entry{Sch.System{999,1},[]}))
