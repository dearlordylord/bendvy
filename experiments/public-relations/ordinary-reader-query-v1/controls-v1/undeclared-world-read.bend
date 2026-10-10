import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/relation-providers.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import ../fixture.bend as F
def body(~S:Data,-H:Type,caps:P.ReadOnly<H,S>,target:W.Handle<S>,owner:H) -> H & Maybe<&2,List<&2,U32>>:
  A.inverse(~S,~F.Components,~Array<U32>,~U32,owner,F.link(~S),target)
def main() -> Unit:Unit{}
