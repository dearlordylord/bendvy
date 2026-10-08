import Base
import ../multi-registered.bend as Application
import ../definition.bend as Declaration
import ../../../description-v1/full-dto-v1/owner-observation.bend as Owner
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as Check
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as Provision
def invalid(value:Cap.ValueRead<Check.Frame<Owner.Schema,Array<U32>,Owner.Owner,U32>,Owner.Observation>) -> Cap.ValueWrite<Check.Frame<Owner.Schema,Array<U32>,Owner.Owner,U32>,U32,Owner.Observation>:
  value
