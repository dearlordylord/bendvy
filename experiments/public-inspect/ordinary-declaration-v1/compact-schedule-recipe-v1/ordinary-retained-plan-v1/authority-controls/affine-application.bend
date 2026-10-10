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
def duplicate(app:Consumer.Application(~Authority)) -> Consumer.Application(~Authority) & Consumer.Application(~Authority):
  (app,app)
