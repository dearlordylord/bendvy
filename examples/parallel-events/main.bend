import Base
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-access.bend as Access
import ../../src/ecs/execution-projection.bend as Projection
import ../../src/ecs/execution-app.bend as Execute
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/world.bend as W

import ../../src/ecs/execution-event-family.bend as Event
import ../../src/ecs/execution-event-io.bend as EventIO
import ../../src/ecs/execution-event-ops.bend as Ops
import ../../src/ecs/owned-event-log.bend as Log

type Nominal is Data:Nominal{}
def Payload() -> Type:Array<U32>
def Family() -> Type:Event.Family<Nominal,Payload(),"hits">
type Local is Type:Local{pending:Maybe<&1,Payload()>,runs:U32}
def resource_layout() -> Layout.Layout:Layout.LayoutLeaf{Family(),"hits"}
def Resources() -> Type:Layout.resources(~Nominal,resource_layout())
def World() -> Type:W.World<Nominal,Unit,Resources(),Unit>
def Caps(H:Type) -> Type:Ops.Writer<H,Payload()>
def wrapped(~H:Type,~B:Type,result:B & Access.ResourceWrite<H,Family(),Event.Snapshot>) -> B & Caps(H):
  match result:
    case (book,cap):(book,Ops.writer(~Nominal,~H,~Payload(),~"hits",~Event.Snapshot,cap))
def selection(~H:Type,~B:Type,~cr:Build.ComponentRead(~Nominal,~Unit,~Resources(),~H,~B),~cw:Build.ComponentWrite(~Nominal,~Unit,~Resources(),~H,~B),~rr:Build.ResourceRead(~Nominal,~Unit,~Resources(),~H,~B),~rw:Build.ResourceWrite(~Nominal,~Unit,~Resources(),~H,~B),~query:Build.Query(~Nominal,~Unit,~Resources(),~H,~B),book:B) -> B & Caps(H):
  wrapped(~H,~B,rw(resource_layout(),Layout.AtLeaf{},{==},{==},Event.Snapshot,Event.snapshot(~Nominal,~Payload(),~"hits"),Projection.trusted_affine(~Family(),~Event.Snapshot,~Event.snapshot(~Nominal,~Payload(),~"hits")),book))
def program(~H:Type,~B:Type,~builder:Build.Builder(~Nominal,~Unit,~Resources(),~H,~B),book:B) -> B & Caps(H):
  builder(Caps,selection(~H,~B),book)
def publish_field(~H:Type,cap:Caps(H)) -> Payload() -> H -> H & Event.Publication<Payload()>:
  match cap:
    case Ops.Writer{publish}:publish
def published(~H:Type,runs:U32,result:H & Event.Publication<Payload()>) -> H & (Local & Sys.Completion<String,String>):
  match result:
    case (scope,Event.Published{id}):(scope,(Local{None{},runs},Sys.BodyError{"after-publication","published=" ++ Nat.show(id)}))
    case (scope,Event.PublicationRefused{payload}):(scope,(Local{Some{payload},runs},Sys.Success{"owner-refused"}))
def body(~H:Type,~cap:Caps(H),scope:H,local:Local) -> H & (Local & Sys.Completion<String,String>):
  match local:
    case Local{None{},runs}:(scope,(Local{None{},runs},Sys.Success{"no-pending"}))
    case Local{Some{payload},runs}:published(~H,U32.add(runs,1),publish_field(~H,cap)(payload,scope))
def Application() -> Type:Execute.Application<Nominal,Unit,Resources(),Unit,Caps,Local,String,String,program,body>
def status(status:Execute.Status<String,String>) -> String:
  match status:
    case Execute.AdmissionRefused{}:"admission-refused"
    case Execute.Ran{Sys.Success{text}}:text
    case Execute.Ran{Sys.BodyError{error,text}}:error ++ "/" ++ text
def array_id(result:Array<U32> & U32) -> String:
  match result:
    case (_,id):U32.show(id)
def row_ids(rows:List<Log.Row<Payload()>>) -> String:
  match rows:
    case []:""
    case Log.Row{id,payload} <> rest:Nat.show(id) ++ ":" ++ array_id(Array.get(U32,payload,0)) ++ ";" ++ row_ids(rest)
def drained(prefix:String,result:Family() & List<Log.Row<Payload()>>) -> String:
  match result:
    case (_,rows):prefix ++ ";retained=" ++ row_ids(rows)
def observed(first:String,result:Application() & Execute.Status<String,String>) -> String:
  match result:
    case (Execute.Application{W.World{_,_,_,Layout.ResourceSlot{family},_,_,_,_,_},Sys.Owner{_,_,_,_,_,Local{_,runs}}},done):drained(first ++ "," ++ status(done) ++ ";runs=" ++ U32.show(runs),Event.shutdown(~Nominal,~Payload(),~"hits",family))
def first(result:Application() & Execute.Status<String,String>) -> String:
  match result:
    case (application,done):observed(status(done),Execute.run(~Nominal,~Unit,~Resources(),~Unit,~Caps,~Local,~String,~String,~program,~body,application))
def registered(result:Execute.Built<Application(),World(),Local>) -> String:
  match result:
    case Execute.BuildRefused{_,_}:"definition-refused"
    case Execute.Built{application}:first(Execute.run(~Nominal,~Unit,~Resources(),~Unit,~Caps,~Local,~String,~String,~program,~body,application))
def empty(_:Unit) -> Unit:Unit{}
def created(result:W.Creation<Nominal,Unit,Resources(),Unit>) -> String:
  match result:
    case W.CreateRejected{_,_}:"creation-refused"
    case W.Created{_,world}:registered(Execute.define(~Nominal,~Unit,~Resources(),~Unit,~Caps,~Local,~String,~String,~program,~body,world,"publisher",Local{Some{ALeaf{202}},0}))
def allocated(result:Event.Creation<Nominal,Payload(),"hits">) -> IO(Unit):
  match result:
    case Event.CreationRefused{}:IO.print("identity-refused")
    case Event.Created{family}:IO.print(created(W.create(~Nominal,~Unit,~Resources(),~Unit,~empty,W.factory(),Layout.ResourceSlot{family})))
def main() -> IO(Unit):
  IO.bind(Event.Creation<Nominal,Payload(),"hits">,Unit,EventIO.create(~Nominal,~Payload(),~"hits"),allocated)
