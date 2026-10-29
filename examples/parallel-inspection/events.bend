import Base
import ../../src/ecs/world.bend as W
import ../../src/ecs/inspector.bend as I
import ../../src/ecs/execution-inspector.bend as Modern
import ../../src/ecs/execution-event-family.bend as Event
import ../../src/ecs/execution-event-view.bend as View
import ../../src/ecs/execution-event-io.bend as EventIO
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-resource-policy.bend as Policy
import ../../src/ecs/owned-event-log.bend as Log
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/check.bend as Check

type Schema is Data:Schema{}
def payload(value:Array<U32>) -> Array<U32> & U32:Array.get(U32,value,0)
def layout() -> L.Layout:L.LayoutLeaf{Event.Family<Schema,Array<U32>,"events">,View.View<Schema,Array<U32>,"events",U32>,View.refresh(~Schema,~Array<U32>,~"events",~U32,~payload),"events",Policy.Ordinary{}}
def R() -> Type:L.resources(~Schema,layout())
def World() -> Type:W.World<Schema,Unit,R(),Unit>
def Ops(H:Type) -> Type:Cap.ValueRead<H,View.View<Schema,Array<U32>,"events",U32>>
def plan() -> I.Plan<Schema,Unit,R(),Unit,Ops>:
  I.Plan{Modern.resource_grant(~I.Frame<Schema,Unit,R(),Unit>,~View.View<Schema,Array<U32>,"events",U32>,Modern.resource(~Schema,~Unit,~R(),~Unit,~layout(),~L.AtLeaf{},~{==},~{==}))}
def rows_text(rows:List<&2,View.Row<U32>>) -> String:
  match rows:
    case []:""
    case View.Row{id,value} <> rest:Nat.show(id) ++ "=" ++ U32.show(value) ++ ";" ++ rows_text(rest)
def viewed(~H:Type,fail:Bool,result:H & View.View<Schema,Array<U32>,"events",U32>) -> H & Result<&2,&2,String,String>:
  match fail result:
    case False{}, (owner,View.View{_,_,_,_,_,rows}):(owner,Done{rows_text(rows)})
    case True{}, (owner,View.View{_,_,_,_,_,rows}):(owner,Fail{rows_text(rows)})
def body(~H:Type,~read:Ops(H),fail:Bool,owner:H) -> H & Result<&2,&2,String,String>:
  viewed(~H,fail,Cap.value_read(~H,~View.View<Schema,Array<U32>,"events",U32>,~read,owner))
def result_text(result:Result<&2,&2,String,String>) -> String:
  match result:
    case Done{value}:"ok/" ++ value
    case Fail{error}:"error/" ++ error
def owners_text(rows:List<Log.Row<Array<U32>>>) -> String:
  match rows:
    case []:""
    case Log.Row{id,ALeaf{value}} <> rest:Nat.show(id) ++ "=" ++ U32.show(value) ++ ";" ++ owners_text(rest)
    case _ <> rest:"unexpected;" ++ owners_text(rest)
def read_text(result:Event.Reading<Schema,Array<U32>,"events",U32>) -> String:
  match result:
    case Event.Item{Event.Reader{identity,id,cursor},item,value,missed}:"item=" ++ Nat.show(item) ++ "/" ++ U32.show(value) ++ ";reader=" ++ U32.show(identity) ++ "/" ++ U32.show(id) ++ "/" ++ Nat.show(cursor) ++ ";missed=" ++ Nat.show(missed)
    case _:"read-refused-or-empty"
def reader_read(view:View.View<Schema,Array<U32>,"events",U32>,reader:Event.Reader<Schema,Array<U32>,"events">) -> String:
  match reader:
    case Event.Reader{+identity,+id,+cursor}:"before=" ++ Nat.show(cursor) ++ ";" ++ read_text(View.read(~Schema,~Array<U32>,~"events",~U32,view,Event.Reader{identity,id,cursor}))
def required(world:World()) -> World() & List<&2,String>:(world,[])
def check_plan() -> Check.Plan<Schema,Unit,R(),Unit,Ops>:
  Check.Plan{required,Modern.resource_grant(~Check.Frame<Schema,Unit,R(),Unit>,~View.View<Schema,Array<U32>,"events",U32>,Modern.check_resource(~Schema,~Unit,~R(),~Unit,~layout(),~L.AtLeaf{},~{==},~{==}))}
def check_read(~H:Type,result:H & View.View<Schema,Array<U32>,"events",U32>) -> H & Bool:
  match result:
    case (owner,View.View{_,_,_,_,_,[]}):(owner,False{})
    case (owner,View.View{_,_,_,_,_,_ <> _}):(owner,True{})
def check_body(~H:Type,~read:Ops(H),_:Unit,owner:H) -> H & Bool:
  check_read(~H,Cap.value_read(~H,~View.View<Schema,Array<U32>,"events",U32>,~read,owner))
def checked(first:String,second:String,reader:Event.Reader<Schema,Array<U32>,"events">,result:Check.Checked<Schema,Unit,R(),Unit>) -> IO(Unit):
  match result:
    case Check.Checked{W.World{_,_,_,L.ResourceSlot{L.Viewed{Event.Family{_,_,Log.Log{_,rows},_,_,nextReader,active,_},view},_},_,_,_,_,clock,_},Done{present}}:IO.print("first=" ++ first ++ ";second=" ++ second ++ ";check=" ++ Bool.show(present) ++ ";clock=" ++ Tick.show(Clock.current(clock)) ++ ";nextReader=" ++ U32.show(nextReader) ++ ";active=" ++ List.show(&2,U32,U32.show,active) ++ ";owners=" ++ owners_text(rows) ++ ";" ++ reader_read(view,reader))
    case _:IO.print("check-refused")
def finished(first:String,reader:Event.Reader<Schema,Array<U32>,"events">,result:I.Observed<Schema,Unit,R(),Unit,String,String>) -> IO(Unit):
  match result:
    case I.Observed{world,_,result}:checked(first,result_text(result),reader,Check.run(~Schema,~Unit,~R(),~Unit,~Ops,~Unit,~check_body,~check_plan(),Unit{},world))
def observed(reader:Event.Reader<Schema,Array<U32>,"events">,result:I.Observed<Schema,Unit,R(),Unit,String,String>) -> IO(Unit):
  match result:
    case I.Observed{world,instance,result}:finished(result_text(result),reader,I.passive(~Schema,~Unit,~R(),~Unit,~Ops,~Bool,~String,~String,~plan(),~body,instance,True{},world))
def columns(_:Unit) -> Unit:Unit{}
def world_created(reader:Event.Reader<Schema,Array<U32>,"events">,result:W.Creation<Schema,Unit,R(),Unit>) -> IO(Unit):
  match result:
    case W.Created{_,world}:observed(reader,I.passive(~Schema,~Unit,~R(),~Unit,~Ops,~Bool,~String,~String,~plan(),~body,I.Fresh{},False{},world))
    case W.CreateRejected{_,_}:IO.print("world-refused")
def registered(result:Event.Family<Schema,Array<U32>,"events"> & Event.Registration<Schema,Array<U32>,"events">) -> IO(Unit):
  match result:
    case (family,Event.Registered{reader}):world_created(reader,W.create(~Schema,~Unit,~R(),~Unit,~columns,W.factory(),L.ResourceSlot{L.initialize(layout(),L.AtLeaf{},family),L.unknown_stamp()}))
    case _:IO.print("reader-refused")
def published(result:Event.Family<Schema,Array<U32>,"events"> & Event.Publication<Array<U32>>) -> IO(Unit):
  match result:
    case (family,Event.Published{_}):registered(Event.register(~Schema,~Array<U32>,~"events",Event.Retained{},family))
    case _:IO.print("publication-refused")
def created(result:Event.Creation<Schema,Array<U32>,"events">) -> IO(Unit):
  match result:
    case Event.Created{family}:published(Event.publish(~Schema,~Array<U32>,~"events",family,ALeaf{11}))
    case _:IO.print("family-refused")
def main() -> IO(Unit):IO.bind(Event.Creation<Schema,Array<U32>,"events">,Unit,EventIO.create(~Schema,~Array<U32>,~"events"),created)
