import Base
import ../schema.bend as Fixture
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/ordinary-machine-transition-reader.bend as Reader
def reader_type() -> Type:Reader.instance_type(~Fixture.SchemaA,~Fixture.MachineKey<Fixture.SchemaA>,~Fixture.MachineState,~Array<U32>,~Fixture.Resources<Fixture.SchemaA>,~String,~Bool,~String,~Fixture.TransitionReadOutput,~Fixture.reader_take(~Fixture.SchemaA),~Fixture.reader_put(~Fixture.SchemaA),~Fixture.transition_reader_callback(~Fixture.SchemaA))
def world_type() -> Type:W.World<Fixture.SchemaA,Array<U32>,Fixture.Resources<Fixture.SchemaA>,String>
def rejected(reader:reader_type()) -> reader_type() & reader_type():
  (reader,reader)
