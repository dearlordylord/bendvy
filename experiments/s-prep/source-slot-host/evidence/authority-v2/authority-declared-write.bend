import Base
import ./host.bend as H
import ./audited-invoker.bend as IA
import ./types.bend as T
def good(-Tx:Type,set:Tx -> T.PositionToken -> U32 -> Tx,owner:Tx) -> Tx:
  set(owner,T.PositionToken{},55)
