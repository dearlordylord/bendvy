import Base
import owned-world.bend as O
import relation-reorder.bend as R
import relation-providers.bend as P
import relation-commands.bend as A
def invalid(-H:Type,caps:P.ReadOnly<H,O.Workshop>,args:R.Args<O.Workshop>,owner:H) -> H & A.QueueStatus:
  R.body(~O.Workshop,H,caps,args,owner)
