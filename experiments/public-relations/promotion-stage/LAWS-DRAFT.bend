import Base
import ../../../src/ecs/relation-types.bend as T
import graph-spec.bend as S
import ../../../src/ecs/relation-graph.bend as C

# DRAFT ONLY. No human approval, no proof definitions, not imported by runtime.
# This deliberately narrow executable projection does not assert refinement of
# arbitrary malformed maintained tables or equality of affine World owners.
type Observation<Schema: Data> is Data:
  Observation{target: Maybe<&2,U32>,sources: List<&2,U32>,error: Maybe<&2,T.Error>}
def slow_observe(~Schema: Data,result: T.SpecResult<Schema>,+descriptor: T.Descriptor<Schema>,source: U32,target: U32) -> Observation<Schema>:
  match result:
    case T.SpecResult{+g,e}: Observation{S.target(~Schema,g,descriptor,source),S.inverse(~Schema,g,descriptor,target),e}
def maintained_observe(~Schema: Data,result: T.CoreResult<Schema>,+descriptor: T.Descriptor<Schema>,source: U32,target: U32) -> Observation<Schema>:
  match result:
    case T.CoreResult{+g,e}: Observation{C.target(~Schema,g,descriptor,source),C.inverse(~Schema,g,descriptor,target),e}
# Exact first-operation agreement, including source/target/self failures.
# Empty-table premise avoids assuming an unapproved arbitrary graph invariant.
law first_operation_agreement:
  for ~Schema: Data
  for +d: T.Descriptor<Schema>
  for +source: U32
  for +target: U32
  for +sourceLive: Bool
  for +targetLive: Bool
  {maintained_observe(~Schema,C.relate(~Schema,T.Graph{[],[]},d,source,target,sourceLive,targetLive),d,source,target) == slow_observe(~Schema,S.relate(~Schema,T.SpecGraph{[]},d,source,target,sourceLive,targetLive),d,source,target) : Observation<Schema>}
