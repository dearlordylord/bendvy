import Base
import ../declaration-binding.bend as Bind
import ../binding-fixtures/workshop.bend as W
import ../binding-fixtures/garden.bend as G
import ../../../bend-candidate/consumer.bend as A
import ../../../bend-candidate/query-consumer.bend as B
import ../../../bend-candidate/inspect.bend as I
import ../definition.bend as Meta
def bad(bonus:Bind.Declaration<B.Schema,G.Resources,List<&2,U32>,G.BonusToken,G.project_bonus>) -> Meta.Definition<A.Schema,I.Plan<A.Schema,A.Store,W.Resources,U32,W.Ops>>:
  W.define("Cross",bonus,W.score())
