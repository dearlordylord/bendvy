import Base
import ./positive.bend as P
import ../../../src/ecs/execution-event-ops.bend as Ops

def read(~H:Type,cap:Unit) -> Ops.Reader<P.SchemaA,H,Array<U32>,"events",U32>:P.reader(~H,cap)
