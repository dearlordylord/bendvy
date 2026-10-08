import Base
import ../multi-registered.bend as Application
import ../definition.bend as Declaration
import ../../../description-v1/full-dto-v1/owner-observation.bend as Owner
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as Check
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as Provision
def invalid() -> Provision.Requirement<Owner.Schema>:
  Application.resource(Application.ComponentPlain{})
