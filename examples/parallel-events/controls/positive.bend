import Base
import ../scenario.bend as D
import ../../../src/ecs/execution-event-family.bend as Event
import ../../../src/ecs/execution-event-view.bend as View
import ../../../src/ecs/execution-event-ops.bend as Ops
import ../../../src/ecs/execution-access.bend as Access

type SchemaA is Data:SchemaA{}
type SchemaB is Data:SchemaB{}
def project(owner:Array<U32>) -> Array<U32> & U32:Array.get(U32,owner,0)
def read_field(~S:Data,~H:Type,cap:Ops.Reader<S,H,Array<U32>,"events",U32>) -> Event.Reader<S,Array<U32>,"events"> -> H -> H & Event.Reading<S,Array<U32>,"events",U32>:
  match cap:
    case Ops.Reader{next}:next
def reader(~H:Type,cap:Access.ResourceRead<H,View.View<SchemaA,Array<U32>,"events",U32>>) -> Ops.Reader<SchemaA,H,Array<U32>,"events",U32>:Ops.reader(~SchemaA,~H,~Array<U32>,~"events",~U32,cap)
def writer(~H:Type,cap:Access.ResourceWrite<H,Event.Family<SchemaA,Array<U32>,"events">,View.View<SchemaA,Array<U32>,"events",U32>>) -> Ops.Writer<H,Array<U32>>:Ops.writer(~SchemaA,~H,~Array<U32>,~"events",~View.View<SchemaA,Array<U32>,"events",U32>,cap)
def move(reader:Event.Reader<SchemaA,Array<U32>,"events">) -> Event.Reader<SchemaA,Array<U32>,"events">:reader
