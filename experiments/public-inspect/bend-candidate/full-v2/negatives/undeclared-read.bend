import Base
import ../logs.bend as Logs
import ../retained-workshop.bend as A
import ../../consumer.bend as Model
import ../../inspect.bend as I
import ../../joint.bend as J
import ../../../../../src/ecs/capabilities.bend as Cap
import ../../../../../src/ecs/world.bend as W

# A callback with no declared lookup cannot turn trusted concrete setup into H.
def bad(~H:Type,ctx:H,target:W.Handle<Model.Schema>) -> H & I.Value<List<&2,U32>>:
  I.lookup(~H,~Model.Schema,~List<&2,U32>,~A.lookup_cap(~J.Frame<Model.Schema,Model.Store,Model.Resource,A.Message,Logs.Streams<Model.Schema,A.Family,A.Holders>>,J.caps(~Model.Schema,~Model.Store,~Model.Resource,~A.Message,~Logs.Streams<Model.Schema,A.Family,A.Holders>,~A.Ops,A.plan())),ctx,target)
