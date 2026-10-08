import Base
import definition.bend as Meta
import witness.bend as Read
import binding-fixtures/workshop.bend as W
import binding-fixtures/garden.bend as G
import ../../bend-candidate/consumer.bend as A
import ../../bend-candidate/query-consumer.bend as B
import ../../bend-candidate/inspect.bend as I
# Owner preservation is generic in Extra:Type, not specialized to copyable cells.
type Owner<-P:Type,-Extra:Type> is Type:
  Owner{left:Array<U32>,right:Array<U32>,extra:Extra,plan:P}
def attach(~S:Data,~P:Type,~Extra:Type,left:Array<U32>,right:Array<U32>,extra:Extra,definition:Meta.Definition<S,P>) -> Meta.Definition<S,Owner<P,Extra>>:
  match definition:
    case Meta.Definition{metadata,plan}:Meta.Definition{metadata,Owner{left,right,extra,plan}}
def workshop(~Extra:Type,left:Array<U32>,right:Array<U32>,extra:Extra) -> Meta.Definition<A.Schema,Owner<I.Plan<A.Schema,A.Store,W.Resources,U32,W.Ops>,Extra>> & (Meta.Metadata<A.Schema> & Meta.Metadata<A.Schema>):
  Read.twice(~A.Schema,~Owner<I.Plan<A.Schema,A.Store,W.Resources,U32,W.Ops>,Extra>,attach(~A.Schema,~I.Plan<A.Schema,A.Store,W.Resources,U32,W.Ops>,~Extra,left,right,extra,W.canonical_definition()))
def garden(~Extra:Type,left:Array<U32>,right:Array<U32>,extra:Extra) -> Meta.Definition<B.Schema,Owner<I.Plan<B.Schema,B.Store,G.Resources,U32,G.Ops>,Extra>> & (Meta.Metadata<B.Schema> & Meta.Metadata<B.Schema>):
  Read.twice(~B.Schema,~Owner<I.Plan<B.Schema,B.Store,G.Resources,U32,G.Ops>,Extra>,attach(~B.Schema,~I.Plan<B.Schema,B.Store,G.Resources,U32,G.Ops>,~Extra,left,right,extra,G.canonical_definition()))
