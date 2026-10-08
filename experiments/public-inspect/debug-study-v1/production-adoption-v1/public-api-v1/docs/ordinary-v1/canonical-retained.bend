import Base
import ./canonical-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP

type Registered<-S:Data,-P:Type,-Q:Type,-layout:Schema.Layout<S,P,Q>,Registry:Type> is Type:
  Registered{registry:Registry,declaration:Schema.Params<S,P,Q,layout>,entries:List<&2,Schema.Entry<S>>,needs:List<&2,SP.Requirement<S>>}
type Defined<-S:Data,World:Type,Owner:Type> is Type:
  Defined{world:World,owner:Owner}
  Rejected{world:World}
