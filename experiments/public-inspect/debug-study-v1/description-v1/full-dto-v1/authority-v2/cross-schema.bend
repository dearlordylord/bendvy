import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as Check
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import ../owner-observation.bend as Owner
import ../definition-v2.bend as D
import ../registered-v2.bend as Reg
type OtherSchema is Data:
  OtherSchema{}
def invalid(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,declaration:D.Definition<OtherSchema>) -> Reg.Prepared:
  Reg.prepare(world,declaration)
