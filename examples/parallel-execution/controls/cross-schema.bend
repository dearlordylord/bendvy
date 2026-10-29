import Base
import ../payloads.bend as Payload
import ../../../src/ecs/execution-access.bend as Access
import ../../../src/ecs/world.bend as W

type SchemaA is Data:
  SchemaA{}
type SchemaB is Data:
  SchemaB{}
def write(~H:Type,~cap:Access.ComponentWrite<SchemaA,H,Payload.Position,String>,scope:H,handle:W.Handle<SchemaB>) -> H & Maybe<&2,String>:
  Access.component_modify_field(~SchemaA,~H,~Payload.Position,~String,cap)(Payload.move,scope,handle)
