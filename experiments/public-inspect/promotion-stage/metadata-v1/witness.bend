import Base
import definition.bend as Meta
import ../../bend-candidate/consumer.bend as Workshop
import ../../bend-candidate/query-consumer.bend as Garden
import ../../bend-candidate/inspect.bend as I
import ../cardinality-workshop.bend as W
import ../cardinality-garden.bend as G

# The opaque owner contains two actual affine Arrays and the typed read Plan.
# Neither metadata read can inspect, copy or reconstruct any of these fields.
type Owner<-S:Data,-Store:Type,-R:Type,-Ops:Type -> Type> is Type:
  Owner{left:Array<U32>,right:Array<U32>,plan:I.Plan<S,Store,R,U32,Ops>}
def twice_second(~S:Data,~Plan:Type,first:Meta.Metadata<S>,result:Meta.Definition<S,Plan> & Meta.Metadata<S>) -> Meta.Definition<S,Plan> & (Meta.Metadata<S> & Meta.Metadata<S>):
  (definition,second)=result
  (definition,(first,second))
def twice_first(~S:Data,~Plan:Type,result:Meta.Definition<S,Plan> & Meta.Metadata<S>) -> Meta.Definition<S,Plan> & (Meta.Metadata<S> & Meta.Metadata<S>):
  (definition,first)=result
  twice_second(~S,~Plan,first,Meta.read(~S,~Plan,definition))
def twice(~S:Data,~Plan:Type,definition:Meta.Definition<S,Plan>) -> Meta.Definition<S,Plan> & (Meta.Metadata<S> & Meta.Metadata<S>):
  twice_first(~S,~Plan,Meta.read(~S,~Plan,definition))
def workshop(left:Array<U32>,right:Array<U32>) -> Meta.Definition<Workshop.Schema,Owner<Workshop.Schema,Workshop.Store,Workshop.Resource,W.Ops>> & (Meta.Metadata<Workshop.Schema> & Meta.Metadata<Workshop.Schema>):
  twice(~Workshop.Schema,~Owner<Workshop.Schema,Workshop.Store,Workshop.Resource,W.Ops>,Meta.make(~Workshop.Schema,~Owner<Workshop.Schema,Workshop.Store,Workshop.Resource,W.Ops>,"Workshop/Read",[Meta.Resource{1,"Score"},Meta.Resource{1,"Alias"},Meta.Resource{2,"Second"}],Owner{left,right,W.plan()}))
def garden(left:Array<U32>,right:Array<U32>) -> Meta.Definition<Garden.Schema,Owner<Garden.Schema,Garden.Store,Garden.Resource,G.Ops>> & (Meta.Metadata<Garden.Schema> & Meta.Metadata<Garden.Schema>):
  twice(~Garden.Schema,~Owner<Garden.Schema,Garden.Store,Garden.Resource,G.Ops>,Meta.make(~Garden.Schema,~Owner<Garden.Schema,Garden.Store,Garden.Resource,G.Ops>,"Garden/Read",[Meta.Resource{1,"Score"},Meta.Resource{1,"Alias"},Meta.Resource{2,"Second"}],Owner{left,right,G.plan()}))
