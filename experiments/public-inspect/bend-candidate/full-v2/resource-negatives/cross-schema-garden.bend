import Base
import ../resource-garden.bend as A
import ../../query-consumer.bend as Model
import ../../inspect.bend as I
import ../../../../../src/ecs/capabilities.bend as Cap
def bad(ctx:I.Frame<Model.OtherSchema,Model.Store,A.Resources,U32>) -> I.Frame<Model.OtherSchema,Model.Store,A.Resources,U32> & Maybe<&2,List<&2,U32>>:
  Cap.value_read(~I.Frame<Model.OtherSchema,Model.Store,A.Resources,U32>,~Maybe<&2,List<&2,U32>>,~A.score(~I.Frame<Model.Schema,Model.Store,A.Resources,U32>,A.grant()),ctx)
