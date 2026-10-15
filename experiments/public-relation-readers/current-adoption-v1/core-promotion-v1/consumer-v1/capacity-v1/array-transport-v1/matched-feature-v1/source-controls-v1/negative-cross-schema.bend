import Base
import ../../../../../../../../../src/ecs/ordinary-reader-query-parameter.bend as QParam
import ../../../../../../../../../src/ecs/component.bend as Cmp
import ./typed-api-fixture.bend as F

# Must be rejected: a SchemaA Param cannot validate/prepare in SchemaB context.
def bad_cross_schema(context:F.context_b(),parameter:F.parameter_a_type()) -> F.context_b() & (Unit & (QParam.Rows<F.SchemaB,Cmp.Access<F.ViewA>> & Unit)):
  F.declared_query_schema_b(context,parameter)
