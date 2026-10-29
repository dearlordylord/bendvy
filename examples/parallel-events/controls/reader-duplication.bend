import Base
import ./positive.bend as P
import ../../../src/ecs/execution-event-family.bend as Event

def duplicate(reader:Event.Reader<P.SchemaA,Array<U32>,"events">) -> Event.Reader<P.SchemaA,Array<U32>,"events"> & Event.Reader<P.SchemaA,Array<U32>,"events">:(reader,reader)
