import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/relation-providers.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import ../fixture.bend as F
def body(-H:Type,caps:P.ReadOnly<H,F.Workshop>,foreign:W.Handle<F.Garden>,owner:H) -> H & Maybe<&2,List<&2,W.Handle<F.Workshop>>>:
  P.read_live(H,F.Workshop,caps,owner,foreign)
def main() -> Unit:Unit{}
