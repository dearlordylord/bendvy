import Base
import ../binding-witness.bend as Witness
import ../definition.bend as Meta
def bad(~S:Data,~P:Type,~Extra:Type,owner:Meta.Definition<S,Witness.Owner<P,Extra>>) -> Meta.Definition<S,Witness.Owner<P,Extra>> & Meta.Definition<S,Witness.Owner<P,Extra>>:
  (owner,owner)
