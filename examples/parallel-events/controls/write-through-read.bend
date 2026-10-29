import Base
import ./positive.bend as P
import ../../../src/ecs/execution-event-family.bend as Event
import ../../../src/ecs/execution-event-view.bend as View
import ../../../src/ecs/execution-event-ops.bend as Ops
import ../../../src/ecs/execution-access.bend as Access

def write(~H:Type,cap:Access.ResourceRead<H,View.View<P.SchemaA,Array<U32>,"events",U32>>) -> Ops.Writer<H,Array<U32>>:P.writer(~H,cap)
