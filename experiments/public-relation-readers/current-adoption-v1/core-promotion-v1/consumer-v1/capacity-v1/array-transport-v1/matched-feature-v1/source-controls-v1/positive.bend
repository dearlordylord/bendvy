import Base
import ./typed-api-fixture.bend as F
import ../../../../../../../../../src/ecs/ordinary-reader-query-parameter.bend as QParam
import ../../../../../../../../../src/ecs/component.bend as Cmp

# Same-schema and cross-schema descriptors each work with their declared world.
def positive_declared_query(context:F.context_a(),parameter:F.parameter_a_type()) -> F.context_a() & (Unit & (QParam.Rows<F.SchemaA,Cmp.Access<F.ViewA>> & Unit)):
  F.declared_query(context,parameter)
def positive_other_declared_query(context:F.context_a(),parameter:F.parameter_b_type()) -> F.context_a() & (Unit & (QParam.Rows<F.SchemaA,Cmp.Access<F.ViewB>> & Unit)):
  F.declared_query_b(context,parameter)
def positive_schema_b_query(context:F.context_b(),parameter:F.parameter_schema_b_type()) -> F.context_b() & (Unit & (QParam.Rows<F.SchemaB,Cmp.Access<F.ViewA>> & Unit)):
  F.declared_query_schema_b(context,parameter)

# Matching declarations allow reads and writes; the component payload remains Type.
def positive_read_grant(frame:F.frame_a()) -> F.frame_a() & Cmp.Access<F.ViewA>:
  F.read_with_declared_read(frame)
def positive_write_grant(frame:F.frame_a()) -> F.frame_a():
  F.write_with_declared_write(frame)

# Type owners cross the application boundary once.
def positive_provider_once(provider:F.core_provider_type()) -> F.core_provider_type():
  F.keep_provider(provider)
def positive_reader_owner_once(owner:F.core_reader_owner_type()) -> F.core_reader_owner_type():
  F.keep_reader_owner(owner)
