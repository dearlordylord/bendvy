import Base
import owned-world.bend as O
import relation-reorder.bend as R
import relation-types.bend as G
import relation-commands.bend as A
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/transaction.bend as X
def invalid(~ordinary:G.Descriptor<O.Workshop>,args:R.Args<O.Workshop>,tx:X.Tx<W.World<O.Workshop,A.Store<O.Workshop,O.Components<O.Workshop>>,U32,A.Notice<O.Workshop,U32>>,A.Notice<O.Workshop,U32>>) -> X.Tx<W.World<O.Workshop,A.Store<O.Workshop,O.Components<O.Workshop>>,U32,A.Notice<O.Workshop,U32>>,A.Notice<O.Workshop,U32>> & A.QueueStatus:
  R.invoke(~O.Workshop,~O.Components<O.Workshop>,~U32,~U32,~ordinary,~A.QueueStatus,~R.body(~O.Workshop),args,tx)
