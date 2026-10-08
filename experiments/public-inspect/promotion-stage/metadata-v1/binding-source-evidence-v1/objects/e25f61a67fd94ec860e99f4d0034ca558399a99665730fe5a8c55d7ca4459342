import Base
import ../binding-witness.bend as Witness
import ../definition.bend as Meta
def bad(~S:Data,~P:Type,~Extra:Type,owner:Meta.Definition<S,Witness.Owner<P,Extra>>) -> String:
  Meta.into_plan(~S,~Witness.Owner<P,Extra>,owner)
