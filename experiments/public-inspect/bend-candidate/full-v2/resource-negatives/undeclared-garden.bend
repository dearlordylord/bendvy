import Base
import ../resource-garden.bend as A
import ../../query-consumer.bend as Model
import ../../inspect.bend as I
import ../../../../../src/ecs/capabilities.bend as Cap
def bad(~H:Type,ctx:H) -> H & Maybe<&2,List<&2,U32>>:
  Cap.value_read(~H,~Maybe<&2,List<&2,U32>>,~A.score(~I.Frame<Model.Schema,Model.Store,A.Resources,U32>,A.grant()),ctx)
