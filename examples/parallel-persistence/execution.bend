import Base
import ./declarations.bend as Ordinary
import ./receiver.bend as Receiver
import ./scheduled.bend as Persistence
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-access.bend as Access
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-scope-registry.bend as Tree
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/execution-reservation-task.bend as Task
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-lifecycle-notices.bend as Notice
import ./restore-receipt.bend as Receipt
import ../../src/ecs/execution-save-data.bend as Saved
import ../../src/ecs/execution-save-gate.bend as Gate
import ../../src/ecs/execution-save-recipe.bend as Recipe
import ../../src/ecs/execution-lifecycle-access.bend as Life
import ../../src/ecs/capabilities.bend as Cap

type Local is Type:Local{capture:Array<U32>,runs:U32}
type ReaderLocal<-S:Data> is Type:ReaderLocal{capture:Array<U32>,runs:U32,reader:Notice.Reader<S,Layout.EmptyLayout{},Notice.Despawned{}>,notices:U32}
type Handler is Type:Handler{capture:Array<U32>,handled:U32}
def handle(handler:Handler,_:String) -> Handler & Exec.Handling:
  match handler:
    case Handler{capture,handled}:(Handler{capture,U32.add(handled,1)},Exec.Continue{})
def config_changed(~S:Data,+enabled:Bool,result:Array<U32> & U32) -> Ordinary.Config<S> & Ordinary.ConfigView:
  match result:
    case (limit,+value):(Ordinary.Config{enabled,Array.set(U32,limit,0,U32.add(value,1))},Ordinary.ConfigView{enabled,U32.add(value,1)})
def config_increment(~S:Data,owner:Ordinary.Config<S>) -> Ordinary.Config<S> & Ordinary.ConfigView:
  match owner:
    case Ordinary.Config{enabled,limit}:config_changed(~S,enabled,Array.get(U32,limit,0))
def scratch_changed(~S:Data,result:Array<U32> & U32) -> Ordinary.Scratch<S> & Unit:
  match result:
    case (values,value):(Ordinary.Scratch{Array.set(U32,values,0,U32.add(value,1))},Unit{})
def scratch_increment(~S:Data,owner:Ordinary.Scratch<S>) -> Ordinary.Scratch<S> & Unit:
  match owner:
    case Ordinary.Scratch{values}:scratch_changed(~S,Array.get(U32,values,0))
def LeftOps(~S:Data,Permit:Data,H:Type) -> Type:Access.ResourceWrite<H,Ordinary.Config<S>,Ordinary.ConfigView>
def RightOps(~S:Data,Permit:Data,H:Type) -> Type:Cap.Bundle<Access.ResourceWrite<H,Ordinary.Scratch<S>,Unit>,Life.Next<S,H,Layout.EmptyLayout{},Notice.Despawned{}>>
def left_selection(~S:Data,~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~Persistence.LeftColumn(~S),~Persistence.LeftResource(~S),~H,~B),~cw:Build.ComponentWrite(~S,~Persistence.LeftColumn(~S),~Persistence.LeftResource(~S),~H,~B),~rr:Build.ResourceRead(~S,~Persistence.LeftColumn(~S),~Persistence.LeftResource(~S),~H,~B),~rw:Build.ResourceWrite(~S,~Persistence.LeftColumn(~S),~Persistence.LeftResource(~S),~H,~B),~q:Build.Query(~S,~Layout.columns(~S,Receiver.Components(~S)),~Persistence.LeftColumn(~S),~Persistence.LeftResource(~S),~H,~B),~life:Build.Lifecycle(~S,~Layout.columns(~S,Receiver.Components(~S)),~Persistence.LeftColumn(~S),~Persistence.LeftResource(~S),~H,~B),book:B) -> B & LeftOps(~S,Permit,H):
  Build.basic_resource_write(~S,~Persistence.LeftColumn(~S),~Persistence.LeftResource(~S),~H,~B,~Layout.subtree(Plan.layout(Ordinary.resources(~S)),Layout.InLeft{Layout.AtLeaf{}}),~Layout.AtLeaf{},~{==},~{==},~rw,book)
def right_combined(~S:Data,~Permit:Data,~H:Type,~B:Type,writer:Access.ResourceWrite<H,Ordinary.Scratch<S>,Unit>,result:B & Life.Next<S,H,Layout.EmptyLayout{},Notice.Despawned{}>) -> B & RightOps(~S,Permit,H):
  match result:
    case (book,reader):(book,Cap.Bundle{writer,reader})
def right_granted(~S:Data,~Permit:Data,~H:Type,~B:Type,~life:Build.Lifecycle(~S,~Layout.columns(~S,Receiver.Components(~S)),~Persistence.RightColumn(~S),~Persistence.RightResource(~S),~H,~B),result:B & Access.ResourceWrite<H,Ordinary.Scratch<S>,Unit>) -> B & RightOps(~S,Permit,H):
  match result:
    case (book,writer):right_combined(~S,~Permit,~H,~B,writer,Build.despawn_lifecycle(~S,~Layout.columns(~S,Receiver.Components(~S)),~Persistence.RightColumn(~S),~Persistence.RightResource(~S),~H,~B,~life,book))
def right_selection(~S:Data,~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~Persistence.RightColumn(~S),~Persistence.RightResource(~S),~H,~B),~cw:Build.ComponentWrite(~S,~Persistence.RightColumn(~S),~Persistence.RightResource(~S),~H,~B),~rr:Build.ResourceRead(~S,~Persistence.RightColumn(~S),~Persistence.RightResource(~S),~H,~B),~rw:Build.ResourceWrite(~S,~Persistence.RightColumn(~S),~Persistence.RightResource(~S),~H,~B),~q:Build.Query(~S,~Layout.columns(~S,Receiver.Components(~S)),~Persistence.RightColumn(~S),~Persistence.RightResource(~S),~H,~B),~life:Build.Lifecycle(~S,~Layout.columns(~S,Receiver.Components(~S)),~Persistence.RightColumn(~S),~Persistence.RightResource(~S),~H,~B),book:B) -> B & RightOps(~S,Permit,H):
  right_granted(~S,~Permit,~H,~B,~life,Build.basic_resource_write(~S,~Persistence.RightColumn(~S),~Persistence.RightResource(~S),~H,~B,~Layout.subtree(Plan.layout(Ordinary.resources(~S)),Layout.InRight{Layout.AtLeaf{}}),~Layout.AtLeaf{},~{==},~{==},~rw,book))
def left_declaration(~S:Data,~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~S,~Layout.columns(~S,Receiver.Components(~S)),~Persistence.LeftColumn(~S),~Persistence.LeftResource(~S),~Permit,~H,~B),book:B) -> B & LeftOps(~S,Permit,H):builder(LeftOps(~S),left_selection(~S,~Permit,~H,~B),book)
def right_declaration(~S:Data,~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~S,~Layout.columns(~S,Receiver.Components(~S)),~Persistence.RightColumn(~S),~Persistence.RightResource(~S),~Permit,~H,~B),book:B) -> B & RightOps(~S,Permit,H):builder(RightOps(~S),right_selection(~S,~Permit,~H,~B),book)
def left_returned(~S:Data,~H:Type,local:Local,result:H & Ordinary.ConfigView) -> H & (Local & Sys.Completion<String,String>):
  match local result:
    case Local{capture,runs}, (scope,Ordinary.ConfigView{_,limit}):(scope,(Local{capture,U32.add(runs,1)},Sys.Success{"config/" ++ U32.show(limit)}))
def right_returned(~S:Data,~H:Type,local:ReaderLocal<S>,result:H & Unit) -> H & (ReaderLocal<S> & Sys.Completion<String,String>):
  match local result:
    case ReaderLocal{capture,runs,reader,+notices}, (scope,_):(scope,(ReaderLocal{capture,U32.add(runs,1),reader,notices},Sys.Success{"transient/notices=" ++ U32.show(notices)}))
def left_body(~S:Data,~Permit:Data,~H:Type,~caps:LeftOps(~S,Permit,H),scope:H,local:Local) -> Task.Task<S,Permit,H & (Local & Sys.Completion<String,String>)>:
  Task.TDone{left_returned(~S,~H,local,Access.resource_modify_field(~H,~Ordinary.Config<S>,~Ordinary.ConfigView,caps)(config_increment(~S),scope))}
def right_read(~S:Data,~Permit:Data,~H:Type,~writer:Access.ResourceWrite<H,Ordinary.Scratch<S>,Unit>,capture:Array<U32>,runs:U32,notices:U32,result:H & Notice.Reading<S,Layout.EmptyLayout{},Notice.Despawned{}>) -> Task.Task<S,Permit,H & (ReaderLocal<S> & Sys.Completion<String,String>)>:
  match result:
    case (scope,Notice.Item{reader,_,_}):Task.TDone{right_returned(~S,~H,ReaderLocal{capture,runs,reader,U32.add(notices,1)},Access.resource_modify_field(~H,~Ordinary.Scratch<S>,~Unit,writer)(scratch_increment(~S),scope))}
    case (scope,Notice.Empty{reader,_}):Task.TDone{right_returned(~S,~H,ReaderLocal{capture,runs,reader,notices},Access.resource_modify_field(~H,~Ordinary.Scratch<S>,~Unit,writer)(scratch_increment(~S),scope))}
    case (scope,Notice.ReadRefused{reader,_}):Task.TDone{(scope,(ReaderLocal{capture,runs,reader,notices},Sys.BodyError{"reader-refused","transient"}))}
def right_body(~S:Data,~Permit:Data,~H:Type,~caps:RightOps(~S,Permit,H),scope:H,local:ReaderLocal<S>) -> Task.Task<S,Permit,H & (ReaderLocal<S> & Sys.Completion<String,String>)>:
  match local:
    case ReaderLocal{capture,runs,reader,notices}:right_read(~S,~Permit,~H,~Cap.first(~Access.ResourceWrite<H,Ordinary.Scratch<S>,Unit>,~Life.Next<S,H,Layout.EmptyLayout{},Notice.Despawned{}>,caps),capture,runs,notices,Life.next(~S,~H,~Layout.EmptyLayout{},~Notice.Despawned{},Cap.second(~Access.ResourceWrite<H,Ordinary.Scratch<S>,Unit>,~Life.Next<S,H,Layout.EmptyLayout{},Notice.Despawned{}>,caps),scope,reader))
def Left(~S:Data) -> Type:Sys.Owner<S,Layout.columns(~S,Receiver.Components(~S)),Persistence.LeftColumn(~S),Persistence.LeftResource(~S),Unit,LeftOps(~S),Local,String,String,left_declaration(~S),left_body(~S)>
def Right(~S:Data) -> Type:Sys.Owner<S,Layout.columns(~S,Receiver.Components(~S)),Persistence.RightColumn(~S),Persistence.RightResource(~S),Unit,RightOps(~S),ReaderLocal<S>,String,String,right_declaration(~S),right_body(~S)>
def left(~S:Data,~F:Tree.Family(),~leaf:Tree.Leaf(~S,~Layout.columns(~S,Receiver.Components(~S)),~Persistence.LeftColumn(~S),~Persistence.LeftResource(~S),~Unit,~String,~String,~F),~command:Tree.CommandLeaf(~S,~Layout.columns(~S,Receiver.Components(~S)),~Persistence.LeftColumn(~S),~Persistence.LeftResource(~S),~Unit,~String,~String,~F),~join:Tree.Join(~F),owner:Left(~S)) -> F(Left(~S)):leaf(LeftOps(~S),Local,left_declaration(~S),left_body(~S),owner)
def right(~S:Data,~F:Tree.Family(),~leaf:Tree.Leaf(~S,~Layout.columns(~S,Receiver.Components(~S)),~Persistence.RightColumn(~S),~Persistence.RightResource(~S),~Unit,~String,~String,~F),~command:Tree.CommandLeaf(~S,~Layout.columns(~S,Receiver.Components(~S)),~Persistence.RightColumn(~S),~Persistence.RightResource(~S),~Unit,~String,~String,~F),~join:Tree.Join(~F),owner:Right(~S)) -> F(Right(~S)):leaf(RightOps(~S),ReaderLocal<S>,right_declaration(~S),right_body(~S),owner)
def Application(~S:Data) -> Type:Persistence.Application(~S,~Product.Owner<Left(~S),Right(~S)>,~Unit,~Handler)
def build(~S:Data,world:Receiver.World(~S),leftOwner:Left(~S),rightOwner:Right(~S),handler:Handler) -> Application(~S):
  Schedule.build(~S,~Persistence.LeftColumn(~S),~Persistence.RightColumn(~S),~Persistence.LeftResource(~S),~Persistence.RightResource(~S),~Unit,~String,~String,~Left(~S),~Right(~S),~left(~S),~right(~S),~Unit,~Handler,~Conditions.empty_dispatch(~Receiver.World(~S),~String),~Conditions.empty(~Receiver.World(~S),~String),~handle,~(key => True{}),world,Product.Owner{leftOwner,rightOwner},Unit{},handler,[],[])
def run_native(~S:Data,app:Application(~S)) -> IO(Application(~S) & App.Report<String,String>):
  Schedule.run_native(~S,~Persistence.LeftColumn(~S),~Persistence.RightColumn(~S),~Persistence.LeftResource(~S),~Persistence.RightResource(~S),~Unit,~String,~String,~Left(~S),~Right(~S),~left(~S),~right(~S),~Unit,~Handler,~Conditions.empty_dispatch(~Receiver.World(~S),~String),~Conditions.empty(~Receiver.World(~S),~String),~handle,app)
def run_serial(~S:Data,app:Application(~S)) -> IO(Application(~S) & App.Report<String,String>):
  Schedule.run_serial(~S,~Persistence.LeftColumn(~S),~Persistence.RightColumn(~S),~Persistence.LeftResource(~S),~Persistence.RightResource(~S),~Unit,~String,~String,~Left(~S),~Right(~S),~left(~S),~right(~S),~Unit,~Handler,~Conditions.empty_dispatch(~Receiver.World(~S),~String),~Conditions.empty(~Receiver.World(~S),~String),~handle,app)
def save(~S:Data,schema:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)>,app:Application(~S)) -> Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)> & (Application(~S) & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>):
  Persistence.save(~S,~Left(~S),~Right(~S),~left(~S),~right(~S),~Unit,~Handler,~Conditions.empty_dispatch(~Receiver.World(~S),~String),~Conditions.empty(~Receiver.World(~S),~String),~handle,schema,app)
def restore(~S:Data,schema:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)>,input:Saved.Snapshot<S>,app:Application(~S)) -> Application(~S) & Receipt.Receipt<S>:
  Persistence.restore(~S,~Left(~S),~Right(~S),~left(~S),~right(~S),~Unit,~Handler,~Conditions.empty_dispatch(~Receiver.World(~S),~String),~Conditions.empty(~Receiver.World(~S),~String),~handle,schema,input,app)
def restored_status(status:Receipt.Status) -> Bool:
  match status:
    case Receipt.Restored{}:True{}
    case _:False{}
def status(~S:Data,receipt:Receipt.Receipt<S>) -> Receipt.Receipt<S> & Bool:
  match receipt:
    case Receipt.Receipt{state,input,removed,rows,mapping,publications,previous,remaining,+status}:(Receipt.Receipt{state,input,removed,rows,mapping,publications,previous,remaining,status},restored_status(status))
type Resumed<-S:Data> is Type:
  Resumed{app:Application(~S),receipt:Receipt.Receipt<S>,report:App.Report<String,String>}
  Retained{app:Application(~S),receipt:Receipt.Receipt<S>}
def resumed(~S:Data,receipt:Receipt.Receipt<S>,result:Application(~S) & App.Report<String,String>) -> Resumed<S>:
  match result:
    case (app,report):Resumed{app,receipt,report}
def resume_checked(~S:Data,native:Bool,app:Application(~S),result:Receipt.Receipt<S> & Bool) -> IO(Resumed<S>):
  match native result:
    case _, (receipt,False{}):IO.pure(Resumed<S>,Retained{app,receipt})
    case True{}, (receipt,True{}):IO.bind(Application(~S) & App.Report<String,String>,Resumed<S>,run_native(~S,app),result => IO.pure(Resumed<S>,resumed(~S,receipt,result)))
    case False{}, (receipt,True{}):IO.bind(Application(~S) & App.Report<String,String>,Resumed<S>,run_serial(~S,app),result => IO.pure(Resumed<S>,resumed(~S,receipt,result)))
def resume(~S:Data,native:Bool,result:Application(~S) & Receipt.Receipt<S>) -> IO(Resumed<S>):
  match result:
    case (app,receipt):resume_checked(~S,native,app,status(~S,receipt))
def alpha_native(schema:Plan.Schema<Ordinary.Alpha,Ordinary.components(~Ordinary.Alpha),Ordinary.resources(~Ordinary.Alpha)>,input:Saved.Snapshot<Ordinary.Alpha>,app:Application(~Ordinary.Alpha)) -> IO(Resumed<Ordinary.Alpha>):resume(~Ordinary.Alpha,True{},restore(~Ordinary.Alpha,schema,input,app))
def alpha_serial(schema:Plan.Schema<Ordinary.Alpha,Ordinary.components(~Ordinary.Alpha),Ordinary.resources(~Ordinary.Alpha)>,input:Saved.Snapshot<Ordinary.Alpha>,app:Application(~Ordinary.Alpha)) -> IO(Resumed<Ordinary.Alpha>):resume(~Ordinary.Alpha,False{},restore(~Ordinary.Alpha,schema,input,app))
def beta_native(schema:Plan.Schema<Ordinary.Beta,Ordinary.components(~Ordinary.Beta),Ordinary.resources(~Ordinary.Beta)>,input:Saved.Snapshot<Ordinary.Beta>,app:Application(~Ordinary.Beta)) -> IO(Resumed<Ordinary.Beta>):resume(~Ordinary.Beta,True{},restore(~Ordinary.Beta,schema,input,app))
def beta_serial(schema:Plan.Schema<Ordinary.Beta,Ordinary.components(~Ordinary.Beta),Ordinary.resources(~Ordinary.Beta)>,input:Saved.Snapshot<Ordinary.Beta>,app:Application(~Ordinary.Beta)) -> IO(Resumed<Ordinary.Beta>):resume(~Ordinary.Beta,False{},restore(~Ordinary.Beta,schema,input,app))
