import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as Check
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import ../owner-observation.bend as Owner
import ../definition-v2.bend as D
import ../registered-v2.bend as Reg
def invalid(value:String) -> List<&2,D.Component>:
  [value]
