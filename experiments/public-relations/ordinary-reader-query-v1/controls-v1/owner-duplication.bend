import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/relation-providers.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import ../fixture.bend as F
def body(~S:Data,-H:Type,caps:P.ReadOnly<H,S>,target:W.Handle<S>,owner:H) -> (H & Maybe<&2,List<&2,W.Handle<S>>>) & H:
  (P.read_live(H,S,caps,owner,target),owner)
def main() -> Unit:Unit{}
