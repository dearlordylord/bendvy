import Base
import owned-world.bend as O
import ../../../src/ecs/relation-reorder.bend as R
import ../../../src/ecs/relation-providers.bend as P
import ../../../src/ecs/relation-commands.bend as A
def invalid(-H:Type,caps:P.ReadOnly<H,O.Workshop>,args:R.Args<O.Workshop>,owner:H) -> H & A.QueueStatus:
  R.body(~O.Workshop,H,caps,args,owner)
