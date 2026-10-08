import Base
import ../multi-registered.bend as Application
import ../definition.bend as Declaration
import ../../../description-v1/full-dto-v1/owner-observation.bend as Owner
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as Check
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as Provision
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
