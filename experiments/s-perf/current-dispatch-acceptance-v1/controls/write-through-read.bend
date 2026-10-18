import Base
import ../subject/body.bend as B
import ../../canonical-api-v1/dense-runtime-v1/types.bend as T
import ../../../public-captures/ordinary-owner-v1/payload.bend as P
import ../../../../src/ecs/capabilities.bend as Cap
import ../../../../src/ecs/transaction.bend as Tx
def refused(~H:Type,~cap:Cap.Read<H,T.PositionView>,capture:P.Pack,args:B.Args,owner:H) -> H & (P.Pack & (Tx.Outcome<Unit> & U32)):
  B.body(~H,~cap,capture,args,owner)
