import Base
import ../consumer.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Cmp
type OtherSchema is Data:
  OtherSchema{}
def body(~H:Type,~caps:C.ReadOps(H),target:W.Handle<OtherSchema>,owner:H) -> H & I.Value<U32>:I.lookup(~H,~C.S,~U32,~caps,owner,target)
def consume(world:C.World()) -> I.Frame<C.S,C.Store,Array<U32>,U32> & I.Value<U32>:Cap.invoke(~C.ReadOps,~W.Handle<OtherSchema>,~I.Value<U32>,~body,~I.Frame<C.S,C.Store,Array<U32>,U32>,~I.Lookup{C.first_lookup},W.Handle{1,1},I.Frame{world,0})
def main() -> List<&2,String>:C.main()
