import Base
import fixture.bend as F
import ../../../../../../src/ecs/ordinary-condition-composition.bend as Comp
def rejected(condition:F.guard_type(~F.SchemaA),world:F.world_type(~F.SchemaA)) -> Comp.Returned<F.world_type(~F.SchemaA),F.changed_type(~F.SchemaA),Comp.changed_run(~F.SchemaA,~F.MachineKey<F.SchemaA>,~U32,~F.Resources<F.SchemaA>,~F.take(~F.SchemaA),~F.put(~F.SchemaA),~Array<U32>,~String)> & F.guard_type(~F.SchemaA):
  (Comp.run(~F.world_type(~F.SchemaA),~F.changed_type(~F.SchemaA),~Comp.changed_run(~F.SchemaA,~F.MachineKey<F.SchemaA>,~U32,~F.Resources<F.SchemaA>,~F.take(~F.SchemaA),~F.put(~F.SchemaA),~Array<U32>,~String),condition,world),condition)
