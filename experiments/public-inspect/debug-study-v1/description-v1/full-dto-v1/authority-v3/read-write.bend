import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as Check
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import ../owner-observation.bend as Owner
import ../definition-v2.bend as D
import ../registered-v2.bend as Reg
def invalid(cap:Cap.ValueRead<Check.Frame<Owner.Schema,Array<U32>,Owner.Owner,U32>,Owner.Observation>) -> Cap.ValueWrite<Check.Frame<Owner.Schema,Array<U32>,Owner.Owner,U32>,U32,Owner.Observation>:
  cap
