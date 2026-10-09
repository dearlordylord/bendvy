import Base
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as SF
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sy

# Bind creates the actual existing registered owner, never a Ready/Bool permit.
# initialize is the same trusted closed initializer accepted by schema-fragments.
# Repeated execution uses Sy.run; dynamic declaration providers keep bind_declared.
def bind(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Sy.Outcome<W.World<S,C,R,E>,Error,Output>,~initialize:W.World<S,C,R,E> -> Sy.RegistrationResult<S,C,R,E,Args,Error,Output,runner>,fragment:SF.Fragment<S,W.World<S,C,R,E>>,required:List<&2,SF.Entry<S>>) -> SF.Bound<S,W.World<S,C,R,E>,Sy.RegistrationResult<S,C,R,E,Args,Error,Output,runner>>:
  SF.bind_declared(~S,~W.World<S,C,R,E>,~Sy.RegistrationResult<S,C,R,E,Args,Error,Output,runner>,~initialize,fragment,required)
