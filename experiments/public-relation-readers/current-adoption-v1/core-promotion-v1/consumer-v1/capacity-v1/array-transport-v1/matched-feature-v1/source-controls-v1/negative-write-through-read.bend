import Base
import ../../../../../../../../../src/ecs/capabilities.bend as Cap
import ../../../../../../../../../src/ecs/ordinary-query-declaration.bend as Query
import ./typed-api-fixture.bend as F

# Must be rejected: a Read grant has no write authority for Cap.set.
def bad_write_through_read(frame:F.frame_a()) -> F.frame_a():
  Cap.set(~F.frame_a(),~F.PayloadA,~F.ViewA,Query.grant(~F.SchemaA,~F.frame_a(),~Cap.Read<F.frame_a(),F.ViewA>,F.operational_read()),frame,F.PayloadA{0})
