import Base
import owned-world.bend as O
import reorder-adapter.bend as R
import providers.bend as P
import world-adapter.bend as A
def invalid(-H:Type,caps:P.ReadOnly<H,O.Workshop>,args:R.Args<O.Workshop>,owner:H) -> H & A.QueueStatus:
  R.body(~O.Workshop,H,caps,args,owner)
