import Base
import owned-world.bend as O
import reorder-adapter.bend as R
import world-adapter.bend as A
def invalid(-H:Type,caps:R.Writable<H,O.Workshop>,args:R.Args<O.Other>,owner:H) -> H & A.QueueStatus:
  R.body(~O.Workshop,H,caps,args,owner)
