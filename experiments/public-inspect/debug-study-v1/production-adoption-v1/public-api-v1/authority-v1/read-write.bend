import Base
import ../client/multi-registered.bend as Application
import ../candidate/src/ecs/debug-declaration.bend as Declaration
import ../client/owner-observation.bend as Owner
import ../candidate/src/ecs/world.bend as W
import ../candidate/src/ecs/check.bend as Check
import ../candidate/src/ecs/capabilities.bend as Cap
import ../candidate/src/ecs/schedule-provision.bend as Provision
def invalid(value:Cap.ValueRead<Check.Frame<Owner.Schema,Array<U32>,Owner.Owner,U32>,Owner.Observation>) -> Cap.ValueWrite<Check.Frame<Owner.Schema,Array<U32>,Owner.Owner,U32>,U32,Owner.Observation>:
  value
