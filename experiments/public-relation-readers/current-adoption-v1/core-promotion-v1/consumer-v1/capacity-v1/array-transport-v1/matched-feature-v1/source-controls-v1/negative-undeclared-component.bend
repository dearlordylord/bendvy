import Base
import ../../../../../../../../../src/ecs/ordinary-reader-query-parameter.bend as QParam
import ../../../../../../../../../src/ecs/component.bend as Cmp
import ./typed-api-fixture.bend as F

# Must be rejected: a PayloadA descriptor cannot prepare PayloadB rows.
def bad_undeclared_component(context:F.context_a(),parameter:F.parameter_a_type()) -> F.context_a() & (Unit & (QParam.Rows<F.SchemaA,Cmp.Access<F.ViewB>> & Unit)):
  F.declared_query_b(context,parameter)
