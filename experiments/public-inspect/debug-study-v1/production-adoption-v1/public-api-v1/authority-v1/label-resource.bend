import Base
import ../client/multi-registered.bend as Application
import ../candidate/src/ecs/debug-declaration.bend as Declaration
import ../client/owner-observation.bend as Owner
import ../candidate/src/ecs/world.bend as W
import ../candidate/src/ecs/check.bend as Check
import ../candidate/src/ecs/capabilities.bend as Cap
import ../candidate/src/ecs/schedule-provision.bend as Provision
def invalid() -> Provision.Requirement<Owner.Schema>:
  Application.resource("plain")
