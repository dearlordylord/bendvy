import Base
import ../../../src/ecs/execution-composer-layout.bend as Layout
import ../../../src/ecs/execution-builder.bend as Build
import ../../../src/ecs/execution-access.bend as Access
import ../../../src/ecs/execution-projection.bend as Projection
import ../../../src/ecs/execution-app.bend as Execute
import ../../../src/ecs/execution-system.bend as Sys
import ../../../src/ecs/world.bend as W

type Nominal is Data:Nominal{}
type Mailbox is Type:Mailbox{token:Array<U32>,slot:Maybe<&1,Array<U32>>}
type Publication is Type:
  PublicationAccepted{}
  PublicationRefused{owner:Array<U32>}
type Local is Type:Local{pending:Maybe<&1,Array<U32>>,runs:U32}
def viewed(slot:Maybe<&1,Array<U32>>,result:Array<U32> & U32) -> Mailbox & U32:
  match result:
    case (token,id):(Mailbox{token,slot},id)
def view(owner:Mailbox) -> Mailbox & U32:
  match owner:
    case Mailbox{token,slot}:viewed(slot,Array.get(U32,token,0))
def resource_layout() -> Layout.Layout:Layout.LayoutLeaf{Mailbox,U32,view,"mailbox"}
def Resources() -> Type:Layout.resources(~Nominal,resource_layout())
def World() -> Type:W.World<Nominal,Unit,Resources(),Unit>
def Ops(H:Type) -> Type:Access.ResourceWrite<H,Mailbox,U32>
def selection(~H:Type,~B:Type,~cr:Build.ComponentRead(~Nominal,~Unit,~Resources(),~H,~B),~cw:Build.ComponentWrite(~Nominal,~Unit,~Resources(),~H,~B),~rr:Build.ResourceRead(~Nominal,~Unit,~Resources(),~H,~B),~rw:Build.ResourceWrite(~Nominal,~Unit,~Resources(),~H,~B),~query:Build.Query(~Nominal,~Unit,~Resources(),~H,~B),~lifecycle:Build.Lifecycle(~Nominal,~Unit,~Resources(),~H,~B),book:B) -> B & Ops(H):
  rw(resource_layout(),Layout.AtLeaf{},{==},{==},book)
def program(~H:Type,~B:Type,~builder:Build.Builder(~Nominal,~Unit,~Resources(),~H,~B),book:B) -> B & Ops(H):
  builder(Ops,selection(~H,~B),book)
def publish(incoming:Array<U32>,mailbox:Mailbox) -> Mailbox & Publication:
  match mailbox:
    case Mailbox{token,None{}}:(Mailbox{token,Some{incoming}},PublicationAccepted{})
    case Mailbox{token,Some{retained}}:(Mailbox{token,Some{retained}},PublicationRefused{incoming})
def completion(failed:Bool,text:String) -> Sys.Completion<String,String>:
  match failed:
    case False{}:Sys.Success{text}
    case True{}:Sys.BodyError{"after-refusal",text}
def retained(~H:Type,scope:H,+runs:U32,+before:U32,result:Array<U32> & U32) -> H & (Local & Sys.Completion<String,String>):
  match result:
    case (owner,_):(scope,(Local{Some{owner},runs},completion(U32.is_eq(runs,2),"refused" ++ U32.show(before))))
def inspected(~H:Type,scope:H,runs:U32,result:Array<U32> & U32) -> H & (Local & Sys.Completion<String,String>):
  match result:
    case (owner,+before):retained(~H,scope,runs,before,Array.swap(U32,owner,0,U32.add(before,1)))
def published(~H:Type,runs:U32,result:H & Publication) -> H & (Local & Sys.Completion<String,String>):
  match result:
    case (scope,PublicationAccepted{}):(scope,(Local{None{},runs},Sys.Success{"accepted"}))
    case (scope,PublicationRefused{owner}):inspected(~H,scope,runs,Array.get(U32,owner,0))
def body(~H:Type,~cap:Ops(H),scope:H,local:Local) -> H & (Local & Sys.Completion<String,String>):
  match local:
    case Local{None{},runs}:(scope,(Local{None{},runs},Sys.Success{"none"}))
    case Local{Some{incoming},runs}:published(~H,U32.add(runs,1),Access.resource_own_field(~H,~Mailbox,~U32,Publication,cap)(mailbox => publish(incoming,mailbox),scope))
def Application() -> Type:Execute.Application<Nominal,Unit,Resources(),Unit,Ops,Local,String,String,program,body>
def done(status:Execute.Status<String,String>) -> String:
  match status:
    case Execute.AdmissionRefused{}:"refused-before-body"
    case Execute.Ran{Sys.Success{text}}:text
    case Execute.Ran{Sys.BodyError{error,text}}:error ++ "/" ++ text
def array_id(result:Array<U32> & U32) -> String:
  match result:
    case (_,id):U32.show(id)
def pending(owner:Maybe<&1,Array<U32>>) -> String:
  match owner:
    case None{}:"none"
    case Some{owner}:array_id(Array.get(U32,owner,0))
def observed(first:String,result:Application() & Execute.Status<String,String>) -> String:
  match result:
    case (Execute.Application{W.World{_,_,_,Layout.ResourceSlot{Layout.Viewed{Mailbox{token,slot},_}},_,_,_,_,_,lifecycle},Sys.Owner{_,_,_,_,_,Local{owner,runs}}},status):first ++ "," ++ done(status) ++ ";mailbox=" ++ array_id(Array.get(U32,token,0)) ++ ";retained=" ++ pending(slot) ++ ";pending=" ++ pending(owner) ++ ";runs=" ++ U32.show(runs)
def first(result:Application() & Execute.Status<String,String>) -> String:
  match result:
    case (application,status):observed(done(status),Execute.run(~Nominal,~Unit,~Resources(),~Unit,~Ops,~Local,~String,~String,~program,~body,application))
def registered(result:Execute.Built<Application(),World(),Local>) -> String:
  match result:
    case Execute.BuildRefused{_,_}:"definition-refused"
    case Execute.Built{application}:first(Execute.run(~Nominal,~Unit,~Resources(),~Unit,~Ops,~Local,~String,~String,~program,~body,application))
def empty(_:Unit) -> Unit:Unit{}
def created(result:W.Creation<Nominal,Unit,Resources(),Unit>) -> String:
  match result:
    case W.CreateRejected{_,_}:"creation-refused"
    case W.Created{_,world}:registered(Execute.define(~Nominal,~Unit,~Resources(),~Unit,~Ops,~Local,~String,~String,~program,~body,world,"publisher",Local{Some{ALeaf{202}},0}))
def main() -> IO(Unit):
  IO.print(created(W.create(~Nominal,~Unit,~Resources(),~Unit,~empty,W.factory(),Layout.ResourceSlot{Layout.initialize(resource_layout(),Layout.AtLeaf{},Mailbox{ALeaf{101},Some{ALeaf{901}}})})))
