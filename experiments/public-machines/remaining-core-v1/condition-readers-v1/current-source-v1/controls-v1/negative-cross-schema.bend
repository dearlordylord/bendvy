import Base
import fixture.bend as F
import ../../../../../../src/ecs/ordinary-condition-composition.bend as Comp
def rejected(condition:F.guard_type(~F.SchemaB),world:F.world_type(~F.SchemaA)) -> Comp.Returned<F.world_type(~F.SchemaB),F.changed_type(~F.SchemaB),Comp.changed_run(~F.SchemaB,~F.MachineKey<F.SchemaB>,~U32,~F.Resources<F.SchemaB>,~F.take(~F.SchemaB),~F.put(~F.SchemaB),~Array<U32>,~String)>:
  Comp.run(~F.world_type(~F.SchemaB),~F.changed_type(~F.SchemaB),~Comp.changed_run(~F.SchemaB,~F.MachineKey<F.SchemaB>,~U32,~F.Resources<F.SchemaB>,~F.take(~F.SchemaB),~F.put(~F.SchemaB),~Array<U32>,~String),condition,world)
