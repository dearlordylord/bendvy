import Base
import ./common.bend as C
import ../../../../src/ecs/capabilities.bend as Cap
import ../../../../src/ecs/transaction.bend as T
# The supplied public Local body's Ops contains ValueRead, not ValueWrite.
def wrong(~H:Type,~caps:C.Ops(H),local:C.Cell,args:C.Cell,ctx:H) -> H & (C.Cell & (T.Outcome<String> & C.Cell)):
  (Cap.value_set(~H,~C.Cell,~U32,~caps,ctx,args),(local,(T.Success{},C.Cell{ALeaf{0}})))
