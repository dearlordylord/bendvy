import Base
import ./host.bend as H
import ./audited-invoker.bend as IA
import ./types.bend as T
def bad(-Tx:Type,set:Tx -> T.PositionToken -> U32 -> Tx,owner:Tx) -> Tx & T.Access<T.VitalsView>:
  IA.prototype_slot_host_health_read_main(owner,T.VitalsToken{})
