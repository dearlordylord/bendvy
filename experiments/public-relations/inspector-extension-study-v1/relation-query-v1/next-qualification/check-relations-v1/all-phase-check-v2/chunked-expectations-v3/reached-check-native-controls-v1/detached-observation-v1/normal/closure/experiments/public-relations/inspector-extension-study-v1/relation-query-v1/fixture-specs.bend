import Base
import fixture-schema.bend as D
import core-v1/src/ecs/relation-query.bend as RQ

type RelationShape is Data:
  OptionalBoth{}
  RequiredOut{}
  RequiredIn{}
  RequiredBoth{}
  WithOut{}
  WithoutOut{}
  WithIn{}
  WithoutIn{}
def spec(~S:Data,shape:RelationShape) -> RQ.Spec<S>:
  match shape:
    case OptionalBoth{}:RQ.Spec{[RQ.optional_relation(~S,"out",D.link(~S)),RQ.optional_related(~S,"in",D.link(~S))]}
    case RequiredOut{}:RQ.Spec{[RQ.read_relation(~S,"out",D.link(~S))]}
    case RequiredIn{}:RQ.Spec{[RQ.read_related(~S,"in",D.link(~S))]}
    case RequiredBoth{}:RQ.Spec{[RQ.read_relation(~S,"out",D.link(~S)),RQ.read_related(~S,"in",D.link(~S))]}
    case WithOut{}:RQ.Spec{[RQ.with_relation(~S,D.link(~S))]}
    case WithoutOut{}:RQ.Spec{[RQ.without_relation(~S,D.link(~S))]}
    case WithIn{}:RQ.Spec{[RQ.with_related(~S,D.link(~S))]}
    case WithoutIn{}:RQ.Spec{[RQ.without_related(~S,D.link(~S))]}
