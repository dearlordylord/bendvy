import Base
import ../../src/ecs/execution-event-family.bend as Event
import ../../src/ecs/execution-event-view.bend as View
import ../../src/ecs/execution-event-ops.bend as Ops
import ../../src/ecs/execution-access.bend as Access
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/owned-event-log.bend as Log

def layout(~S:Data,~P:Type,~project:P -> P & U32) -> Layout.Layout:Layout.LayoutLeaf{Event.Family<S,P,"events">,View.View<S,P,"events",U32>,View.refresh(~S,~P,~"events",~U32,~project),"events"}
def Resources(~S:Data,~P:Type,~project:P -> P & U32) -> Type:Layout.resources(~S,layout(~S,~P,~project))
def Writers(~P:Type,H:Type) -> Type:Ops.Writer<H,P>
def Readers(~S:Data,~P:Type,H:Type) -> Type:Ops.Reader<S,H,P,"events",U32>
def Admins(~S:Data,~P:Type,H:Type) -> Type:Ops.Admin<S,H,P,"events">
def writer_granted(~S:Data,~P:Type,~H:Type,~B:Type,result:B & Access.ResourceWrite<H,Event.Family<S,P,"events">,View.View<S,P,"events",U32>>) -> B & Writers(~P,H):
  match result:
    case (book,cap):(book,Ops.writer(~S,~H,~P,~"events",~View.View<S,P,"events",U32>,cap))
def reader_granted(~S:Data,~P:Type,~H:Type,~B:Type,result:B & Access.ResourceRead<H,View.View<S,P,"events",U32>>) -> B & Readers(~S,~P,H):
  match result:
    case (book,cap):(book,Ops.reader(~S,~H,~P,~"events",~U32,cap))
def admin_granted(~S:Data,~P:Type,~H:Type,~B:Type,result:B & Access.ResourceWrite<H,Event.Family<S,P,"events">,View.View<S,P,"events",U32>>) -> B & Admins(~S,~P,H):
  match result:
    case (book,cap):(book,Ops.admin(~S,~H,~P,~"events",~View.View<S,P,"events",U32>,cap))
def writer_selection(~S:Data,~WC:Type,~P:Type,~project:P -> P & U32,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~Unit,~Resources(~S,~P,~project),~H,~B),~cw:Build.ComponentWrite(~S,~Unit,~Resources(~S,~P,~project),~H,~B),~rr:Build.ResourceRead(~S,~Unit,~Resources(~S,~P,~project),~H,~B),~rw:Build.ResourceWrite(~S,~Unit,~Resources(~S,~P,~project),~H,~B),~query:Build.Query(~S,~WC,~Unit,~Resources(~S,~P,~project),~H,~B),~lifecycle:Build.Lifecycle(~S,~WC,~Unit,~Resources(~S,~P,~project),~H,~B),book:B) -> B & Writers(~P,H):
  writer_granted(~S,~P,~H,~B,rw(layout(~S,~P,~project),Layout.AtLeaf{},{==},{==},book))
def writer(~S:Data,~WC:Type,~P:Type,~project:P -> P & U32,~H:Type,~B:Type,~builder:Build.Builder(~S,~WC,~Unit,~Resources(~S,~P,~project),~H,~B),book:B) -> B & Writers(~P,H):
  builder(Writers(~P),writer_selection(~S,~WC,~P,~project,~H,~B),book)
def reader_selection(~S:Data,~WC:Type,~P:Type,~project:P -> P & U32,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~Unit,~Resources(~S,~P,~project),~H,~B),~cw:Build.ComponentWrite(~S,~Unit,~Resources(~S,~P,~project),~H,~B),~rr:Build.ResourceRead(~S,~Unit,~Resources(~S,~P,~project),~H,~B),~rw:Build.ResourceWrite(~S,~Unit,~Resources(~S,~P,~project),~H,~B),~query:Build.Query(~S,~WC,~Unit,~Resources(~S,~P,~project),~H,~B),~lifecycle:Build.Lifecycle(~S,~WC,~Unit,~Resources(~S,~P,~project),~H,~B),book:B) -> B & Readers(~S,~P,H):
  reader_granted(~S,~P,~H,~B,rr(layout(~S,~P,~project),Layout.AtLeaf{},{==},{==},book))
def reader(~S:Data,~WC:Type,~P:Type,~project:P -> P & U32,~H:Type,~B:Type,~builder:Build.Builder(~S,~WC,~Unit,~Resources(~S,~P,~project),~H,~B),book:B) -> B & Readers(~S,~P,H):
  builder(Readers(~S,~P),reader_selection(~S,~WC,~P,~project,~H,~B),book)
def admin_selection(~S:Data,~WC:Type,~P:Type,~project:P -> P & U32,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~Unit,~Resources(~S,~P,~project),~H,~B),~cw:Build.ComponentWrite(~S,~Unit,~Resources(~S,~P,~project),~H,~B),~rr:Build.ResourceRead(~S,~Unit,~Resources(~S,~P,~project),~H,~B),~rw:Build.ResourceWrite(~S,~Unit,~Resources(~S,~P,~project),~H,~B),~query:Build.Query(~S,~WC,~Unit,~Resources(~S,~P,~project),~H,~B),~lifecycle:Build.Lifecycle(~S,~WC,~Unit,~Resources(~S,~P,~project),~H,~B),book:B) -> B & Admins(~S,~P,H):
  admin_granted(~S,~P,~H,~B,rw(layout(~S,~P,~project),Layout.AtLeaf{},{==},{==},book))
def admin(~S:Data,~WC:Type,~P:Type,~project:P -> P & U32,~H:Type,~B:Type,~builder:Build.Builder(~S,~WC,~Unit,~Resources(~S,~P,~project),~H,~B),book:B) -> B & Admins(~S,~P,H):
  builder(Admins(~S,~P),admin_selection(~S,~WC,~P,~project,~H,~B),book)
type Sent<-P:Type> is Type:Sent{pending:List<P>,refused:List<P>,text:String}
type WriterLocal<-P:Type> is Type:WriterLocal{pending:List<P>,refused:List<P>,runs:U32,history:List<&2,String>}
type ReaderLocal<-S:Data,-P:Type> is Type:ReaderLocal{reader:Event.Reader<S,P,"events">,runs:U32,history:List<&2,String>}
type AdminLocal<-S:Data,-P:Type> is Type:AdminLocal{removable:Maybe<&1,Event.Reader<S,P,"events">>,foreign:Maybe<&1,Event.Reader<S,P,"events">>,retired:List<Log.Row<P>>,extra:List<Event.Reader<S,P,"events">>,runs:U32,history:List<&2,String>}
def publish_field(~H:Type,~P:Type,cap:Writers(~P,H)) -> P -> H -> H & Event.Publication<P>:
  match cap:
    case Ops.Writer{publish}:publish
def read_field(~S:Data,~H:Type,~P:Type,cap:Readers(~S,~P,H)) -> Event.Reader<S,P,"events"> -> H -> H & Event.Reading<S,P,"events",U32>:
  match cap:
    case Ops.Reader{next}:next
def admin_field(~S:Data,~H:Type,~P:Type,cap:Admins(~S,~P,H)) -> Ops.Command<S,P,"events"> -> H -> H & Ops.Outcome<S,P,"events">:
  match cap:
    case Ops.Admin{apply}:apply
def publication(~H:Type,~P:Type,pending:List<P>,refused:List<P>,result:H & Event.Publication<P>) -> H & Sent<P>:
  match result:
    case (scope,Event.Published{id}):(scope,Sent{pending,refused,"published" ++ Nat.show(id)})
    case (scope,Event.PublicationRefused{payload}):(scope,Sent{pending,List.append(&1,P,refused,[payload]),"refused"})
def send(~H:Type,~P:Type,~cap:Writers(~P,H),scope:H,pending:List<P>,refused:List<P>) -> H & Sent<P>:
  match pending:
    case []:(scope,Sent{[],refused,"none"})
    case payload <> rest:publication(~H,~P,rest,refused,publish_field(~H,~P,cap)(payload,scope))
def second_sent(~H:Type,~P:Type,first:String,result:H & Sent<P>) -> H & Sent<P>:
  match result:
    case (scope,Sent{pending,refused,text}):(scope,Sent{pending,refused,first ++ "+" ++ text})
def first_sent(~H:Type,~P:Type,~cap:Writers(~P,H),result:H & Sent<P>) -> H & Sent<P>:
  match result:
    case (scope,Sent{pending,refused,text}):second_sent(~H,~P,text,send(~H,~P,~cap,scope,pending,refused))
def send_selected(~H:Type,~P:Type,~cap:Writers(~P,H),runs:U32,scope:H,pending:List<P>,refused:List<P>) -> H & Sent<P>:
  match runs:
    case 0:first_sent(~H,~P,~cap,send(~H,~P,~cap,scope,pending,refused))
    case 1:send(~H,~P,~cap,scope,pending,refused)
    case 4:send(~H,~P,~cap,scope,pending,refused)
    case _:(scope,Sent{pending,refused,"idle"})
def completion(failed:Bool,text:String) -> Sys.Completion<String,String>:
  match failed:
    case True{}:Sys.BodyError{"after-operation",text}
    case False{}:Sys.Success{text}
def writer_local(~P:Type,pending:List<P>,refused:List<P>,runs:U32,history:List<&2,String>) -> WriterLocal<P>:WriterLocal{pending,refused,runs,history}
def writer_returned(~H:Type,~P:Type,+runs:U32,history:List<&2,String>,result:H & Sent<P>) -> H & (WriterLocal<P> & Sys.Completion<String,String>):
  match result:
    case (scope,Sent{pending,refused,+text}):(scope,(writer_local(~P,pending,refused,U32.add(runs,1),List.append(&2,String,history,[text])),completion(U32.is_eq(runs,0),text)))
def writer_body(~P:Type,~H:Type,~cap:Writers(~P,H),scope:H,local:WriterLocal<P>) -> H & (WriterLocal<P> & Sys.Completion<String,String>):
  match local:
    case WriterLocal{pending,refused,+runs,history}:writer_returned(~H,~P,runs,history,send_selected(~H,~P,~cap,runs,scope,pending,refused))
def refusal(value:Event.Refusal) -> String:
  match value:
    case Event.Closed{}:"closed"
    case Event.ForeignLog{}:"foreign"
    case Event.Inactive{}:"inactive"
    case Event.ReaderLimit{}:"reader-limit"
    case Event.MissingPayload{}:"missing"
def reader_result(~S:Data,~H:Type,~P:Type,+runs:U32,history:List<&2,String>,scope:H,result:Event.Reading<S,P,"events",U32>) -> H & (ReaderLocal<S,P> & Sys.Completion<String,String>):
  match result:
    case Event.Item{reader,+id,+value,+missed}:(scope,(ReaderLocal{reader,U32.add(runs,1),List.append(&2,String,history,["item" ++ Nat.show(id) ++ "=" ++ U32.show(value) ++ "/missed" ++ Nat.show(missed)])},completion(U32.is_eq(runs,0),"item" ++ Nat.show(id) ++ "=" ++ U32.show(value) ++ "/missed" ++ Nat.show(missed))))
    case Event.Empty{reader,+missed}:(scope,(ReaderLocal{reader,U32.add(runs,1),List.append(&2,String,history,["empty/missed" ++ Nat.show(missed)])},Sys.Success{"empty/missed" ++ Nat.show(missed)}))
    case Event.ReadRefused{reader,+reason}:(scope,(ReaderLocal{reader,U32.add(runs,1),List.append(&2,String,history,[refusal(reason)])},Sys.Success{refusal(reason)}))
def reader_returned(~S:Data,~H:Type,~P:Type,runs:U32,history:List<&2,String>,result:H & Event.Reading<S,P,"events",U32>) -> H & (ReaderLocal<S,P> & Sys.Completion<String,String>):
  match result:
    case (scope,result):reader_result(~S,~H,~P,runs,history,scope,result)
def reader_body(~S:Data,~P:Type,~H:Type,~cap:Readers(~S,~P,H),scope:H,local:ReaderLocal<S,P>) -> H & (ReaderLocal<S,P> & Sys.Completion<String,String>):
  match local:
    case ReaderLocal{reader,runs,history}:reader_returned(~S,~H,~P,runs,history,read_field(~S,~H,~P,cap)(reader,scope))
type AdminDone<-S:Data,-P:Type> is Type:AdminDone{local:AdminLocal<S,P>,text:String}
def admin_outcome(~S:Data,~H:Type,~P:Type,removable:Maybe<&1,Event.Reader<S,P,"events">>,foreign:Maybe<&1,Event.Reader<S,P,"events">>,retired:List<Log.Row<P>>,extra:List<Event.Reader<S,P,"events">>,runs:U32,history:List<&2,String>,result:H & Ops.Outcome<S,P,"events">) -> H & AdminDone<S,P>:
  match result:
    case (scope,Ops.Retired{rows}):(scope,AdminDone{AdminLocal{removable,foreign,List.append(&1,Log.Row<P>,retired,rows),extra,runs,history},"retired"})
    case (scope,Ops.Registration{Event.RegistrationRefused{reason}}):(scope,AdminDone{AdminLocal{removable,foreign,retired,extra,runs,history},"registration-" ++ refusal(reason)})
    case (scope,Ops.Registration{Event.Registered{reader}}):(scope,AdminDone{AdminLocal{removable,foreign,retired,reader <> extra,runs,history},"registered"})
    case (scope,Ops.Removal{Event.Removed{reader}}):(scope,AdminDone{AdminLocal{Some{reader},foreign,retired,extra,runs,history},"removed"})
    case (scope,Ops.Removal{Event.RemovalRefused{reader,reason}}):(scope,AdminDone{AdminLocal{Some{reader},foreign,retired,extra,runs,history},"removal-" ++ refusal(reason)})
def foreign_removed(~S:Data,~H:Type,~P:Type,removable:Maybe<&1,Event.Reader<S,P,"events">>,retired:List<Log.Row<P>>,extra:List<Event.Reader<S,P,"events">>,runs:U32,history:List<&2,String>,result:H & Ops.Outcome<S,P,"events">) -> H & AdminDone<S,P>:
  match result:
    case (scope,Ops.Removal{Event.RemovalRefused{reader,reason}}):(scope,AdminDone{AdminLocal{removable,Some{reader},retired,extra,runs,history},"foreign-" ++ refusal(reason)})
    case (scope,Ops.Removal{Event.Removed{reader}}):(scope,AdminDone{AdminLocal{removable,Some{reader},retired,extra,runs,history},"foreign-removed"})
    case (scope,_):(scope,AdminDone{AdminLocal{removable,None{},retired,extra,runs,history},"unexpected-foreign-outcome"})
def admin_update(~S:Data,~H:Type,~P:Type,~cap:Admins(~S,~P,H),first:String,result:H & AdminDone<S,P>) -> H & AdminDone<S,P>:
  match result:
    case (scope,AdminDone{AdminLocal{removable,foreign,retired,extra,runs,history},text}):admin_outcome(~S,~H,~P,removable,foreign,retired,extra,runs,List.append(&2,String,history,[first ++ text]),admin_field(~S,~H,~P,cap)(Ops.Update{},scope))
def admin_selected(~S:Data,~H:Type,~P:Type,~cap:Admins(~S,~P,H),scope:H,local:AdminLocal<S,P>) -> H & AdminDone<S,P>:
  match local:
    case AdminLocal{removable,Some{foreign},retired,extra,0,history}:admin_update(~S,~H,~P,~cap,"",foreign_removed(~S,~H,~P,removable,retired,extra,0,history,admin_field(~S,~H,~P,cap)(Ops.Remove{foreign},scope)))
    case AdminLocal{removable,foreign,retired,extra,1,history}:admin_outcome(~S,~H,~P,removable,foreign,retired,extra,1,history,admin_field(~S,~H,~P,cap)(Ops.Update{},scope))
    case AdminLocal{Some{removable},foreign,retired,extra,2,history}:admin_outcome(~S,~H,~P,None{},foreign,retired,extra,2,history,admin_field(~S,~H,~P,cap)(Ops.Remove{removable},scope))
    case AdminLocal{removable,foreign,retired,extra,3,history}:admin_outcome(~S,~H,~P,removable,foreign,retired,extra,3,history,admin_field(~S,~H,~P,cap)(Ops.Shutdown{},scope))
    case AdminLocal{removable,foreign,retired,extra,runs,history}:admin_outcome(~S,~H,~P,removable,foreign,retired,extra,runs,history,admin_field(~S,~H,~P,cap)(Ops.Register{Event.Retained{}},scope))
def admin_returned(~S:Data,~H:Type,~P:Type,result:H & AdminDone<S,P>) -> H & (AdminLocal<S,P> & Sys.Completion<String,String>):
  match result:
    case (scope,AdminDone{AdminLocal{removable,foreign,retired,extra,runs,history},+text}):(scope,(AdminLocal{removable,foreign,retired,extra,U32.add(runs,1),List.append(&2,String,history,[text])},Sys.Success{text}))
def admin_body(~S:Data,~P:Type,~H:Type,~cap:Admins(~S,~P,H),scope:H,local:AdminLocal<S,P>) -> H & (AdminLocal<S,P> & Sys.Completion<String,String>):
  admin_returned(~S,~H,~P,admin_selected(~S,~H,~P,~cap,scope,local))
