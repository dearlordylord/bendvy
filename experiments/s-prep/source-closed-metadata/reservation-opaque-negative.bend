import Base
import /tmp/bendvy-fourhour-closed-reservation-v2-probe/experiments/s-integrate/storage.bend as S
import /tmp/bendvy-fourhour-closed-reservation-v2-probe/experiments/s-integrate/commands.bend as C
import /tmp/bendvy-fourhour-closed-reservation-v2-probe/experiments/s-integrate/types.bend as T
def bad(~Schema:Data,~M:Type,~A:Type,~F:Data,~L:Type,~Mode:Data,-P:Type,owner:P,bundle:S.Bundle<M,A,F>) -> T.Reservation<S.World<Schema,M,A,F,L,Mode>,S.Handle<Schema>,S.Bundle<M,A,F>>:
  C.prototype_closed_reserve(~M,~A,~F,Schema,L,Mode,owner,bundle)
def main() -> U32: 0
