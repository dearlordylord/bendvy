import Base
import ../../../src/ecs/execution-query.bend as Query
import ../../../src/ecs/execution-access.bend as Access
import ../../../src/ecs/world.bend as World
type Schema is Data:
  Schema{}
def undeclared(~H:Type,~caps:Query.Each<Schema,H,String>,scope:H,handle:World.Handle<Schema>) -> H & Maybe<&2,String>:
  Access.component_read_field(~Schema,~H,~String,caps)(scope,handle)
