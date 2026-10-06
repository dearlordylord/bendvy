import Base
import ./host.bend as H
import ./audited-invoker.bend as IA
import ./types.bend as T
def good(-Tx:Type,get:Tx -> T.PositionToken -> Tx & T.Access<T.PositionView>,owner:Tx) -> Tx & T.Access<T.PositionView>:
  get(owner,T.PositionToken{})
