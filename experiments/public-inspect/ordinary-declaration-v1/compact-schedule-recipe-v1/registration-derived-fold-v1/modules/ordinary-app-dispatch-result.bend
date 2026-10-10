import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys

# Private generated transport: heterogenous arguments and results keep their
# affine owners. Registration refusal is not a transaction failure.
type Arguments<Component:Data,Resource:Type> is Type:
  ComponentArgs{value:Component & U32}
  ResourceArgs{value:Resource}
type Error<Component:Data,Resource:Data> is Data:
  ComponentError{value:Component}
  ResourceError{value:Resource}
type Output<Component:Data,Resource:Type> is Type:
  ComponentOutput{value:List<&2,Component>}
  ResourceOutput{value:Resource}
type DispatchResult<S:Data,C:Type,R:Type,E:Data,H:Type,Args:Type,Failure:Data,Out:Type> is Type:
  Completed{owners:H,outcome:Sys.Outcome<W.World<S,C,R,E>,Failure,Out>}
  RegistrationRejected{owners:H,world:W.World<S,C,R,E>,args:Args}
  UnknownSystem{owners:H,world:W.World<S,C,R,E>,id:U32}
