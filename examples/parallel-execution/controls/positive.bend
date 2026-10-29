import Base
import ../../../src/ecs/execution-access.bend as Access
import ../../../src/ecs/world.bend as W

type Schema is Data:
  Schema{}
def read(~H:Type,~cap:Access.ComponentRead<Schema,H,String>,scope:H,handle:W.Handle<Schema>) -> H & Maybe<&2,String>:
  Access.component_read_field(~Schema,~H,~String,cap)(scope,handle)
