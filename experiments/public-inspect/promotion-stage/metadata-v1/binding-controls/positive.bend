import Base
import ../declaration-binding.bend as Bind
import ../binding-fixtures/workshop.bend as W
import ../../../bend-candidate/consumer.bend as A
import ../../../bend-candidate/inspect.bend as I
import ../definition.bend as Meta
import ../../../../../src/ecs/capabilities.bend as Cap
import ../binding-witness.bend as Witness

def nominal(bonus:Bind.Declaration<A.Schema,W.Resources,List<&2,U32>,W.BonusToken,W.project_bonus>) -> Meta.Definition<A.Schema,I.Plan<A.Schema,A.Store,W.Resources,U32,W.Ops>>:
  W.define("Matched",bonus,W.score())
def indexed(declaration:Bind.Declaration<A.Schema,W.Resources,List<&2,U32>,W.BonusToken,W.project_bonus>) -> Bind.BoundRead<A.Schema,I.Frame<A.Schema,A.Store,W.Resources,U32>,List<&2,U32>>:
  Bind.bind(~A.Schema,~A.Store,~W.Resources,~U32,~List<&2,U32>,~W.BonusToken,~W.project_bonus,declaration)
def declared(~H:Type,actual:W.Reads<H>) -> W.Reads<H>:
  actual
def owner(~S:Data,~P:Type,~Extra:Type,definition:Meta.Definition<S,Witness.Owner<P,Extra>>) -> Witness.Owner<P,Extra>:
  Meta.into_plan(~S,~Witness.Owner<P,Extra>,definition)
def read_authority(~H:Type,actual:W.Reads<H>) -> Cap.ValueRead<H,List<&2,U32>>:
  match actual:
    case W.Reads{_,_,score}:score
