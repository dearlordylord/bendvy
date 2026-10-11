import Base
import ../consumer.bend as C
import ../../fixture.bend as F
import ../../resource-provision.bend as Provision
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-inspector-resource.bend as Resource
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def duplicated(~S:Data,owner:C.Frame(~S)) -> C.Frame(~S) & (C.Frame(~S) & U32):
  (owner,Resource.get(~S,~Array<U32>,~Provision.first_identity(~S),~C.Frame(~S),~U32,~Resource.grant(~S,~C.Frame(~S),~C.First(~S,~C.Frame(~S)),C.first(~S)),owner))
