import Base
import ../consumer.bend as Consumer
import ../machine-app.bend as Machine
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-declaration.bend as OD
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
type Authority is Data:
  Authority{}
type Other is Data:
  Other{}
def duplicate(app:Consumer.Application(~Authority)) -> Consumer.Application(~Authority) & Consumer.Application(~Authority):
  (app,app)
