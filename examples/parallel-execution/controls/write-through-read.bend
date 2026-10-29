import Base
import ../payloads.bend as Payload
import ../../../src/ecs/execution-access.bend as Access
import ../../../src/ecs/world.bend as W

type Schema is Data:
  Schema{}
def write(~H:Type,~cap:Access.ComponentRead<Schema,H,String>,scope:H,handle:W.Handle<Schema>) -> H & Maybe<&2,String>:
  Access.component_modify_field(~Schema,~H,~Payload.Position,~String,cap)(Payload.move,scope,handle)
