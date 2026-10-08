import Base
import ../declaration-binding.bend as Bind
import ../binding-fixtures/workshop.bend as W
import ../../../bend-candidate/consumer.bend as A
import ../../../bend-candidate/inspect.bend as I
def bad(declaration:Bind.Declaration<A.Schema,W.Resources,List<&2,U32>,W.BonusToken,W.project_bonus>) -> Bind.BoundRead<A.Schema,I.Frame<A.Schema,A.Store,W.Resources,U32>,List<&2,U32>>:
  Bind.bind(~A.Schema,~A.Store,~W.Resources,~U32,~List<&2,U32>,~W.BonusToken,~W.project_score,declaration)
