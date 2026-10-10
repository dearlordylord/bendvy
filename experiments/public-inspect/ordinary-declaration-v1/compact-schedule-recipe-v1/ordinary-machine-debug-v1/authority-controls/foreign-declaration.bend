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
def rejected(~foreign:OD.Declaration<Other,Consumer.Token,U32,Consumer.Resource<Other>,Consumer.take(~Other)>,world:Consumer.World(~Authority)) -> Consumer.Application(~Authority):
  Machine.attach(~Authority,~Consumer.Token,~U32,~Unit,~Consumer.Resource<Authority>,~U32,~Consumer.take(~Authority),~foreign,~U32.show,~Unit,~Unit,~Build.empty_observe(~Consumer.World(~Authority)),~Leaf.empty(~Authority),Build.empty(~Authority,~Consumer.World(~Authority),world))
