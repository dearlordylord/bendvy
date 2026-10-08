import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as Check
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import ../owner-observation.bend as Owner
import ../definition-v2.bend as D
import ../registered-v2.bend as Reg
type OtherSchema is Data:
  OtherSchema{}
def own_schema(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,declaration:D.Definition<Owner.Schema>) -> Reg.Prepared:
  Reg.prepare(world,declaration)
def other_schema(value:D.Definition<OtherSchema>) -> D.Definition<OtherSchema>:
  value
def component_token(value:D.Component) -> List<&2,D.Component>:
  [value]
def labels(value:String) -> List<&2,String>:
  [value]
def read_capability() -> Cap.ValueRead<Check.Frame<Owner.Schema,Array<U32>,Owner.Owner,U32>,Owner.Observation>:
  Check.resource_grant(~Owner.Schema,~Array<U32>,~Owner.Owner,~U32,~Owner.Observation,~Owner.project)
def preserve(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>) -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>:
  world
def opaque(~H:Type,owner:H) -> H:
  owner
