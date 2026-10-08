import Base
import ../client/multi-registered.bend as Application
import ../candidate/src/ecs/debug-declaration.bend as Declaration
import ../client/owner-observation.bend as Owner
import ../candidate/src/ecs/world.bend as W
import ../candidate/src/ecs/check.bend as Check
import ../candidate/src/ecs/capabilities.bend as Cap
import ../candidate/src/ecs/schedule-provision.bend as Provision
def same_schema() -> Declaration.Definition<Owner.Schema,Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken>:
  Application.reader()
def nominal_resource() -> Provision.Requirement<Owner.Schema>:
  Application.resource(Application.Plain{})
def nominal_service() -> Provision.Requirement<Owner.Schema>:
  Application.service(Application.ServicePlain{})
def read_cap(value:Cap.ValueRead<Check.Frame<Owner.Schema,Array<U32>,Owner.Owner,U32>,Owner.Observation>) -> Cap.ValueRead<Check.Frame<Owner.Schema,Array<U32>,Owner.Owner,U32>,Owner.Observation>:
  value
def write_cap(value:Cap.ValueWrite<Check.Frame<Owner.Schema,Array<U32>,Owner.Owner,U32>,U32,Owner.Observation>) -> Cap.ValueWrite<Check.Frame<Owner.Schema,Array<U32>,Owner.Owner,U32>,U32,Owner.Observation>:
  value
def whole_world(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>) -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>:
  world
