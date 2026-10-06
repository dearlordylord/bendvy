import Base
import ./host.bend as H
import ./audited-invoker.bend as IA
import ./types.bend as T
def bad(-Tx:Type,get:Tx -> T.PositionToken -> Tx & T.Access<T.PositionView>,owner:Tx) -> Tx:
  IA.prototype_slot_host_motion_set_main0(owner,T.PositionToken{},55)
