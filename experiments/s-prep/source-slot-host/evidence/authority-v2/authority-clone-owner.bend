import Base
import ./host.bend as H
import ./audited-invoker.bend as IA
import ./types.bend as T
def bad(-Tx:Type,owner:Tx) -> Tx & Tx:
  (owner,owner)
