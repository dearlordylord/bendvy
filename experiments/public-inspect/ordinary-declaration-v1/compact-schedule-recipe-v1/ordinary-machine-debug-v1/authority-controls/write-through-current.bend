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
def rejected(frame:I.Frame<Authority,Unit,Consumer.Resource<Authority>,U32>) -> I.Frame<Authority,Unit,Consumer.Resource<Authority>,U32>:
  Cap.value_set(~I.Frame<Authority,Unit,Consumer.Resource<Authority>,U32>,~M.QueueInput<U32>,~M.CurrentView<Authority,Consumer.Token,U32>,~OD.inspect(~Authority,~Consumer.Token,~U32,~Unit,~Consumer.Resource<Authority>,~U32,~Consumer.take(~Authority),~Consumer.declaration(~Authority)),frame,M.Set{8,False{}})
