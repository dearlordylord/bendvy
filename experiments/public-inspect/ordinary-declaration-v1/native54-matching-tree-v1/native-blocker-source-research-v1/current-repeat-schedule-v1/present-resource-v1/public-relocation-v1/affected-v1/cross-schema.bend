import Base
import ../consumer.bend as C
import ../../fixture.bend as F
import ../../resource-provision.bend as Provision
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-inspector-resource.bend as Resource
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def crossed(owner:C.Frame(~F.Other)) -> C.Frame(~F.Other) & U32:
  Resource.get(~F.A,~Array<U32>,~Provision.first_identity(~F.A),~C.Frame(~F.A),~U32,~Resource.grant(~F.A,~C.Frame(~F.A),~C.First(~F.A,~C.Frame(~F.A)),C.first(~F.A)),owner)
