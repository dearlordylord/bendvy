import Base
import ./positive.bend as P
import ../../../src/ecs/execution-event-family.bend as Event
import ../../../src/ecs/execution-event-ops.bend as Ops

def foreign(~H:Type,~cap:Ops.Reader<P.SchemaA,H,Array<U32>,"events",U32>,scope:H,reader:Event.Reader<P.SchemaB,Array<U32>,"events">) -> H & Event.Reading<P.SchemaA,Array<U32>,"events",U32>:
  P.read_field(~P.SchemaA,~H,cap)(reader,scope)
