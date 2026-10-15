import Base
import ../schema.bend as Fixture
import ../../../../src/ecs/ordinary-machine-initialization.bend as Init
import ../../../../src/ecs/world.bend as W

# A SchemaA world cannot be initialized through SchemaB's nominal declaration.
def rejected(world:W.World<Fixture.SchemaA,Array<U32>,Fixture.Resources<Fixture.SchemaA>,String>) -> W.World<Fixture.SchemaA,Array<U32>,Fixture.Resources<Fixture.SchemaA>,String>:
  Init.init_state(~Fixture.SchemaA,~Fixture.MachineKey<Fixture.SchemaA>,~Fixture.MachineState,~Fixture.Resources<Fixture.SchemaA>,~Fixture.take_machine(~Fixture.SchemaA),~Fixture.put_machine(~Fixture.SchemaA),~Array<U32>,~String,~Fixture.declaration(~Fixture.SchemaB),~Fixture.make_default(~Fixture.SchemaA),world)
