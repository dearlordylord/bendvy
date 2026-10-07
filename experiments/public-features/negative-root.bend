import Base
import ../../src/ecs/schema-fragments.bend as SF
import feature.bend as F
import provider.bend as P
import recipe-app.bend as A
import recipe-other.bend as B
def identity(owner:Array<U32>) -> Array<U32>:
  owner
def bad(definition:F.Definition<B.Schema>,owner:Array<U32>) -> SF.Bound<A.Schema,Array<U32>,Array<U32>>:
  P.bind_feature(~A.Schema,~Array<U32>,~Array<U32>,~identity,definition,[],owner)
