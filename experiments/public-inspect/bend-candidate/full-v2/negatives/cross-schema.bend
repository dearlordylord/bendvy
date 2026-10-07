import Base
import ../retained-workshop.bend as A
import ../../consumer.bend as Model
import ../../inspect.bend as I
import ../../../../../src/ecs/world.bend as W

def bad(~H:Type,~caps:A.Reads<H>,ctx:H,target:W.Handle<Model.OtherSchema>) -> H & I.Value<List<&2,U32>>:
  I.lookup(~H,~Model.OtherSchema,~List<&2,U32>,~A.lookup_cap(~H,caps),ctx,target)
