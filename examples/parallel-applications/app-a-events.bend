import Base
import ./app-a-schema.bend as D
import ./app-a-payloads.bend as P
import ./app-a-commands.bend as Author
import ../../src/ecs/world.bend as W
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-access.bend as Access
import ../../src/ecs/execution-event-family.bend as Event
import ../../src/ecs/execution-event-view.bend as View
import ../../src/ecs/execution-event-ops.bend as Ops
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-reservation-task.bend as Task
import ../../src/ecs/execution-parallel-system.bend as Register
import ../../src/ecs/execution-parallel-scope-registry.bend as Tree

def C() -> Type:L.columns(~P.AuditWorkshop,L.origin(D.components(),L.InRight{L.AtLeaf{}}))
def resources() -> L.Layout:D.tail_resources(~Author.Receipts())
def R() -> Type:L.resources(~P.AuditWorkshop,resources())
def World() -> Type:W.World<P.AuditWorkshop,Author.Columns(),L.resources(~P.AuditWorkshop,Author.resources()),Unit>
def Family() -> Type:Event.Family<P.AuditWorkshop,Array<U32>,"RecoveredCargoLog">
def Cached() -> Data:View.View<P.AuditWorkshop,Array<U32>,"RecoveredCargoLog",U32>
def Reader() -> Type:Event.Reader<P.AuditWorkshop,Array<U32>,"RecoveredCargoLog">
def WriterOps(Permit:Data,H:Type) -> Type:Ops.Writer<H,Array<U32>>
def writer_granted(~H:Type,-B:Type,result:B & Access.ResourceWrite<H,Family(),Cached()>) -> B & Ops.Writer<H,Array<U32>>:
  match result:
    case (book,cap):(book,Ops.writer(~P.AuditWorkshop,~H,~Array<U32>,~"RecoveredCargoLog",~Cached(),cap))
def writer_selection(~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~P.AuditWorkshop,~C(),~R(),~H,~B),~cw:Build.ComponentWrite(~P.AuditWorkshop,~C(),~R(),~H,~B),~rr:Build.ResourceRead(~P.AuditWorkshop,~C(),~R(),~H,~B),~rw:Build.ResourceWrite(~P.AuditWorkshop,~C(),~R(),~H,~B),~q:Build.Query(~P.AuditWorkshop,~Author.Columns(),~C(),~R(),~H,~B),~lifecycle:Build.Lifecycle(~P.AuditWorkshop,~Author.Columns(),~C(),~R(),~H,~B),book:B) -> B & WriterOps(Permit,H):
  writer_granted(~H,B,Build.basic_resource_write(~P.AuditWorkshop,~C(),~R(),~H,~B,~resources(),~L.InRight{L.InRight{L.AtLeaf{}}},~{==},~{==},~rw,book))
def writer_declaration(~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~P.AuditWorkshop,~Author.Columns(),~C(),~R(),~Permit,~H,~B),book:B) -> B & WriterOps(Permit,H):builder(WriterOps,writer_selection(~Permit,~H,~B),book)
type WriterLocal is Type:WriterLocal{pending:Maybe<Array<U32>>,returned:List<Array<U32>>,history:List<&2,String>}
def publish(~H:Type,cap:Ops.Writer<H,Array<U32>>) -> Array<U32> -> H -> H & Event.Publication<Array<U32>>:
  match cap:
    case Ops.Writer{publish}:publish
def published(~Permit:Data,~H:Type,returned:List<Array<U32>>,history:List<&2,String>,result:H & Event.Publication<Array<U32>>) -> Task.Task<P.AuditWorkshop,Permit,H & (WriterLocal & Sys.Completion<String,String>)>:
  match result:
    case (scope,Event.Published{id}):Task.TDone{(scope,(WriterLocal{None{},returned,List.append(&2,String,history,["published=" ++ Nat.show(id)])},Sys.Success{"owned cargo published"}))}
    case (scope,Event.PublicationRefused{payload}):Task.TDone{(scope,(WriterLocal{None{},List.append(&1,Array<U32>,returned,[payload]),history},Sys.BodyError{"publication refused","owner retained"}))}
def writer_body(~Permit:Data,~H:Type,~caps:WriterOps(Permit,H),scope:H,local:WriterLocal) -> Task.Task<P.AuditWorkshop,Permit,H & (WriterLocal & Sys.Completion<String,String>)>:
  match local:
    case WriterLocal{None{},returned,history}:Task.TDone{(scope,(WriterLocal{None{},returned,history},Sys.Success{"no pending cargo"}))}
    case WriterLocal{Some{payload},returned,history}:published(~Permit,~H,returned,history,publish(~H,caps)(payload,scope))
type ReaderCaps<-H:Type> is Type:ReaderCaps{events:Ops.Reader<P.AuditWorkshop,H,Array<U32>,"RecoveredCargoLog",U32>,scalar:Access.ComponentWrite<P.AuditWorkshop,H,U32,U32>}
def ReaderOps(Permit:Data,H:Type) -> Type:ReaderCaps<H>
def reader_granted(~H:Type,-B:Type,scalar:Access.ComponentWrite<P.AuditWorkshop,H,U32,U32>,result:B & Access.ResourceRead<H,Cached()>) -> B & ReaderCaps<H>:
  match result:
    case (book,cap):(book,ReaderCaps{Ops.reader(~P.AuditWorkshop,~H,~Array<U32>,~"RecoveredCargoLog",~U32,cap),scalar})
def scalar_granted(~H:Type,~B:Type,~rr:Build.ResourceRead(~P.AuditWorkshop,~C(),~R(),~H,~B),result:B & Access.ComponentWrite<P.AuditWorkshop,H,U32,U32>) -> B & ReaderCaps<H>:
  match result:
    case (book,scalar):reader_granted(~H,B,scalar,Build.basic_resource_read(~P.AuditWorkshop,~C(),~R(),~H,~B,~resources(),~L.InRight{L.InRight{L.AtLeaf{}}},~{==},~{==},~rr,book))
def reader_selection(~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~P.AuditWorkshop,~C(),~R(),~H,~B),~cw:Build.ComponentWrite(~P.AuditWorkshop,~C(),~R(),~H,~B),~rr:Build.ResourceRead(~P.AuditWorkshop,~C(),~R(),~H,~B),~rw:Build.ResourceWrite(~P.AuditWorkshop,~C(),~R(),~H,~B),~q:Build.Query(~P.AuditWorkshop,~Author.Columns(),~C(),~R(),~H,~B),~lifecycle:Build.Lifecycle(~P.AuditWorkshop,~Author.Columns(),~C(),~R(),~H,~B),book:B) -> B & ReaderOps(Permit,H):
  scalar_granted(~H,~B,~rr,cw(L.origin(D.components(),L.InRight{L.AtLeaf{}}),L.AtLeaf{},{==},{==},book))
def reader_declaration(~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~P.AuditWorkshop,~Author.Columns(),~C(),~R(),~Permit,~H,~B),book:B) -> B & ReaderOps(Permit,H):builder(ReaderOps,reader_selection(~Permit,~H,~B),book)
type ReaderLocal is Type:ReaderLocal{reader:Reader(),target:Maybe<&2,W.Handle<P.AuditWorkshop>>,scratch:Array<U32>,readings:List<&2,U32>,values:List<&2,U32>,lagged:Bool}
def events(~H:Type,caps:ReaderCaps<H>) -> Ops.Reader<P.AuditWorkshop,H,Array<U32>,"RecoveredCargoLog",U32>:
  match caps:
    case ReaderCaps{events,_}:events
def scalar(~H:Type,caps:ReaderCaps<H>) -> Access.ComponentWrite<P.AuditWorkshop,H,U32,U32>:
  match caps:
    case ReaderCaps{_,scalar}:scalar
def next(~H:Type,cap:Ops.Reader<P.AuditWorkshop,H,Array<U32>,"RecoveredCargoLog",U32>) -> Reader() -> H -> H & Event.Reading<P.AuditWorkshop,Array<U32>,"RecoveredCargoLog",U32>:
  match cap:
    case Ops.Reader{next}:next
def added(+delta:U32,value:U32) -> U32 & U32:
  +prior=value
  (U32.add(prior,delta),prior)
def updated(~Permit:Data,~H:Type,reader:Reader(),target:W.Handle<P.AuditWorkshop>,scratch:Array<U32>,readings:List<&2,U32>,values:List<&2,U32>,lagged:Bool,result:H & Maybe<&2,U32>) -> Task.Task<P.AuditWorkshop,Permit,H & (ReaderLocal & Sys.Completion<String,String>)>:
  match result:
    case (scope,None{}):Task.TDone{(scope,(ReaderLocal{reader,Some{target},scratch,readings,values,lagged},Sys.BodyError{"scalar absent","reader retained"}))}
    case (scope,Some{value}):Task.TDone{(scope,(ReaderLocal{reader,None{},scratch,readings,List.append(&2,U32,values,[value]),lagged},Sys.Success{"cargo read and scalar updated"}))}
def read(~Permit:Data,~H:Type,~cap:Access.ComponentWrite<P.AuditWorkshop,H,U32,U32>,+target:W.Handle<P.AuditWorkshop>,scratch:Array<U32>,readings:List<&2,U32>,values:List<&2,U32>,lagged:Bool,result:H & Event.Reading<P.AuditWorkshop,Array<U32>,"RecoveredCargoLog",U32>) -> Task.Task<P.AuditWorkshop,Permit,H & (ReaderLocal & Sys.Completion<String,String>)>:
  match result:
    case (scope,Event.Item{reader,_,+value,missed}):updated(~Permit,~H,reader,target,P.increment(value,scratch),List.append(&2,U32,readings,[value]),values,Bool.or(lagged,Bool.not(Nat.is_eq(missed,0n))),Access.component_modify_field(~P.AuditWorkshop,~H,~U32,~U32,cap)(added(value),scope,target))
    case (scope,Event.Empty{reader,missed}):Task.TDone{(scope,(ReaderLocal{reader,Some{target},scratch,readings,values,Bool.or(lagged,Bool.not(Nat.is_eq(missed,0n)))},Sys.Success{"no cargo"}))}
    case (scope,Event.ReadRefused{reader,_}):Task.TDone{(scope,(ReaderLocal{reader,Some{target},scratch,readings,values,lagged},Sys.BodyError{"reader refused","reader retained"}))}
def reader_body(~Permit:Data,~H:Type,~caps:ReaderOps(Permit,H),scope:H,local:ReaderLocal) -> Task.Task<P.AuditWorkshop,Permit,H & (ReaderLocal & Sys.Completion<String,String>)>:
  match local:
    case ReaderLocal{reader,None{},scratch,readings,values,lagged}:Task.TDone{(scope,(ReaderLocal{reader,None{},scratch,readings,values,lagged},Sys.Success{"reader idle"}))}
    case ReaderLocal{reader,Some{target},scratch,readings,values,lagged}:read(~Permit,~H,~scalar(~H,caps),target,scratch,readings,values,lagged,next(~H,events(~H,caps))(reader,scope))
def Writer() -> Type:Sys.Owner<P.AuditWorkshop,Author.Columns(),C(),R(),Unit,WriterOps,WriterLocal,String,String,Build.framework_program(~P.AuditWorkshop,~Author.Columns(),~C(),~R(),~WriterOps,~writer_declaration),writer_body>
def Receiver() -> Type:Sys.Owner<P.AuditWorkshop,Author.Columns(),C(),R(),Unit,ReaderOps,ReaderLocal,String,String,Build.framework_program(~P.AuditWorkshop,~Author.Columns(),~C(),~R(),~ReaderOps,~reader_declaration),reader_body>
def Owners() -> Type:Product.Owner<Writer(),Receiver()>
def tree(~F:Tree.Family(),~leaf:Tree.Leaf(~P.AuditWorkshop,~Author.Columns(),~C(),~R(),~Unit,~Author.resources(),~String,~String,~F),~command:Tree.CommandLeaf(~P.AuditWorkshop,~Author.Columns(),~C(),~R(),~Unit,~Author.resources(),~String,~String,~F),~join:Tree.Join(~F),owners:Owners()) -> F(Owners()):
  match owners:
    case Product.Owner{writer,reader}:join(Writer(),Receiver(),leaf(WriterOps,WriterLocal,Build.framework_program(~P.AuditWorkshop,~Author.Columns(),~C(),~R(),~WriterOps,~writer_declaration),writer_body,writer),leaf(ReaderOps,ReaderLocal,Build.framework_program(~P.AuditWorkshop,~Author.Columns(),~C(),~R(),~ReaderOps,~reader_declaration),reader_body,reader))

type Definition is Type:
  Ready{world:World(),owners:Owners()}
  WriterRefused{world:World(),local:WriterLocal,reader:Reader()}
  ReaderRefused{world:World(),writer:Writer(),local:ReaderLocal}
def reader_defined(writer:Writer(),result:Sys.Defined<World(),Receiver(),ReaderLocal>) -> Definition:
  match result:
    case Sys.Defined{world,reader}:Ready{world,Product.Owner{writer,reader}}
    case Sys.DefinitionRefused{world,local}:ReaderRefused{world,writer,local}
def writer_defined(reader:Reader(),result:Sys.Defined<World(),Writer(),WriterLocal>) -> Definition:
  match result:
    case Sys.Defined{world,writer}:reader_defined(writer,Register.define_framework(~P.AuditWorkshop,~Author.Columns(),~C(),~R(),~Unit,~ReaderOps,~ReaderLocal,~String,~String,~Build.framework_program(~P.AuditWorkshop,~Author.Columns(),~C(),~R(),~ReaderOps,~reader_declaration),~reader_body,~L.resources(~P.AuditWorkshop,Author.resources()),world,"RecoveredCargoReader",ReaderLocal{reader,None{},P.scratch(),[],[],False{}}))
    case Sys.DefinitionRefused{world,local}:WriterRefused{world,local,reader}
def define(world:World(),reader:Reader()) -> Definition:
  writer_defined(reader,Register.define_framework(~P.AuditWorkshop,~Author.Columns(),~C(),~R(),~Unit,~WriterOps,~WriterLocal,~String,~String,~Build.framework_program(~P.AuditWorkshop,~Author.Columns(),~C(),~R(),~WriterOps,~writer_declaration),~writer_body,~L.resources(~P.AuditWorkshop,Author.resources()),world,"RecoveredCargoPublisher",WriterLocal{None{},[],[]}))
def accept(owners:Owners(),target:W.Handle<P.AuditWorkshop>,payload:Array<U32>) -> Owners() & Maybe<Array<U32>>:
  match owners:
    case Product.Owner{Sys.Owner{wn,wi,wname,wa,wc,WriterLocal{None{},returned,history}},Sys.Owner{rn,ri,rname,ra,rc,ReaderLocal{reader,oldTarget,scratch,readings,values,lagged}}}:(Product.Owner{Sys.Owner{wn,wi,wname,wa,wc,WriterLocal{Some{payload},returned,history}},Sys.Owner{rn,ri,rname,ra,rc,ReaderLocal{reader,Some{target},scratch,readings,values,lagged}}},None{})
    case owners:(owners,Some{payload})
def scratch_observed(writer:Writer(),+namespace:U32,+id:U32,name:String,access:List<&2,String>,+cursor:Maybe<&2,Tick.Tick>,reader:Reader(),target:Maybe<&2,W.Handle<P.AuditWorkshop>>,+readings:List<&2,U32>,+values:List<&2,U32>,+lagged:Bool,result:Array<U32> & List<&2,U32>) -> Owners() & String:
  match reader result:
    case Event.Reader{+identity,+readerId,+readCursor}, (scratch,view):(Product.Owner{writer,Sys.Owner{namespace,id,name,access,cursor,ReaderLocal{Event.Reader{identity,readerId,readCursor},target,scratch,readings,values,lagged}}},"event-reader-system-ns=" ++ U32.show(namespace) ++ ";id=" ++ U32.show(id) ++ ";system-cursor=" ++ Tick.cursor_show(cursor) ++ ";family-identity=" ++ U32.show(identity) ++ ";reader-id=" ++ U32.show(readerId) ++ ";reader-cursor=" ++ Nat.show(readCursor) ++ ";lagged=" ++ Bool.show(lagged) ++ ";readings=" ++ List.show(&2,U32,U32.show,readings) ++ ";prior-scalars=" ++ List.show(&2,U32,U32.show,values) ++ ";scratch=" ++ List.show(&2,U32,U32.show,view))
def observed(owners:Owners()) -> Owners() & String:
  match owners:
    case Product.Owner{writer,Sys.Owner{namespace,id,name,access,cursor,ReaderLocal{reader,target,scratch,readings,values,lagged}}}:scratch_observed(writer,namespace,id,name,access,cursor,reader,target,readings,values,lagged,P.project(scratch))
