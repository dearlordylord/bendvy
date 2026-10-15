import Base
import fixture.bend as F
# Both instantiate canonical leaves, lazy composition, real registry identity,
# binding attachment and scheduled execution with affine resource/gameplay fields.
def first(world:F.world_type(~F.SchemaA),condition:F.changed_type(~F.SchemaA),owner:F.Gameplay<F.SchemaA>) -> F.result_type(~F.SchemaA):F.positive(~F.SchemaA,world,condition,owner)
def second(world:F.world_type(~F.SchemaB),condition:F.changed_type(~F.SchemaB),owner:F.Gameplay<F.SchemaB>) -> F.result_type(~F.SchemaB):F.positive(~F.SchemaB,world,condition,owner)
