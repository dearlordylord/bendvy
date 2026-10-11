import Base
import ../consumer.bend as C
import ../../fixture.bend as F
import ../../resource-provision.bend as Provision
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-inspector-resource.bend as Resource
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def changed(~S:Data,owner:C.Frame(~S),replacement:Array<U32>) -> C.Frame(~S):
  Cap.value_write_field(~C.Frame(~S),~Array<U32>,~U32,Resource.grant(~S,~C.Frame(~S),~C.First(~S,~C.Frame(~S)),C.first(~S)))(owner)(replacement)
