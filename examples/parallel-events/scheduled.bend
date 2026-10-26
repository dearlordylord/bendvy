import Base
import ./scenario.bend as D
import ../../src/ecs/execution-event-family.bend as Event
import ../../src/ecs/execution-event-view.bend as View
import ../../src/ecs/execution-event-io.bend as EventIO
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-parallel-system.bend as Task
import ../../src/ecs/execution-parallel-scope-registry.bend as Tree
import ../../src/ecs/execution-parallel-rootcut.bend as Root
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-registry-program.bend as Prog
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/owned-event-log.bend as Log
import ../../src/ecs/world.bend as W
import ../../src/ecs/change-tick.bend as Tick

def Store() -> Type:Product.Owner<Unit,Unit>
def Resources(~S:Data,~P:Type,~project:P -> P & U32) -> Type:Product.Owner<D.Resources(~S,~P,~project),Unit>
def World(~S:Data,~P:Type,~project:P -> P & U32) -> Type:W.World<S,Store(),Resources(~S,~P,~project),Unit>
def Writer(~S:Data,~P:Type,~project:P -> P & U32) -> Type:Sys.Owner<S,Store(),Unit,D.Resources(~S,~P,~project),Unit,D.Writers(~P),D.WriterLocal<P>,String,String,D.writer(~S,~Store(),~P,~project),D.writer_body(~P)>
def Reader(~S:Data,~P:Type,~project:P -> P & U32) -> Type:Sys.Owner<S,Store(),Unit,D.Resources(~S,~P,~project),Unit,D.Readers(~S,~P),D.ReaderLocal<S,P>,String,String,D.reader(~S,~Store(),~P,~project),D.reader_body(~S,~P)>
def Admin(~S:Data,~P:Type,~project:P -> P & U32) -> Type:Sys.Owner<S,Store(),Unit,D.Resources(~S,~P,~project),Unit,D.Admins(~S,~P),D.AdminLocal<S,P>,String,String,D.admin(~S,~Store(),~P,~project),D.admin_body(~S,~P)>
def Left(~S:Data,~P:Type,~project:P -> P & U32) -> Type:Product.Owner<Writer(~S,~P,~project),Product.Owner<Reader(~S,~P,~project),Product.Owner<Reader(~S,~P,~project),Admin(~S,~P,~project)>>>
def NoOps(H:Type) -> Type:Unit
def peer_program(~S:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~Store(),~Unit,~Unit,~H,~B),book:B) -> B & Unit:(book,Unit{})
def peer_body(~H:Type,~caps:Unit,scope:H,runs:U32) -> H & (U32 & Sys.Completion<String,String>):(scope,(U32.add(runs,1),Sys.Success{"peer"}))
def Peer(~S:Data) -> Type:Sys.Owner<S,Store(),Unit,Unit,Unit,NoOps,U32,String,String,peer_program(~S),peer_body>
def left(~S:Data,~P:Type,~project:P -> P & U32,~F:Tree.Family(),~leaf:Tree.Leaf(~S,~Store(),~Unit,~D.Resources(~S,~P,~project),~Unit,~String,~String,~F),~command:Tree.CommandLeaf(~S,~Store(),~Unit,~D.Resources(~S,~P,~project),~Unit,~String,~String,~F),~join:Tree.Join(~F),owners:Left(~S,~P,~project)) -> F(Left(~S,~P,~project)):
  match owners:
    case Product.Owner{writer,Product.Owner{fast,Product.Owner{slow,admin}}}:join(Writer(~S,~P,~project),Product.Owner<Reader(~S,~P,~project),Product.Owner<Reader(~S,~P,~project),Admin(~S,~P,~project)>>,leaf(D.Writers(~P),D.WriterLocal<P>,D.writer(~S,~Store(),~P,~project),D.writer_body(~P),writer),join(Reader(~S,~P,~project),Product.Owner<Reader(~S,~P,~project),Admin(~S,~P,~project)>,leaf(D.Readers(~S,~P),D.ReaderLocal<S,P>,D.reader(~S,~Store(),~P,~project),D.reader_body(~S,~P),fast),join(Reader(~S,~P,~project),Admin(~S,~P,~project),leaf(D.Readers(~S,~P),D.ReaderLocal<S,P>,D.reader(~S,~Store(),~P,~project),D.reader_body(~S,~P),slow),leaf(D.Admins(~S,~P),D.AdminLocal<S,P>,D.admin(~S,~Store(),~P,~project),D.admin_body(~S,~P),admin))))
def right(~S:Data,~F:Tree.Family(),~leaf:Tree.Leaf(~S,~Store(),~Unit,~Unit,~Unit,~String,~String,~F),~command:Tree.CommandLeaf(~S,~Store(),~Unit,~Unit,~Unit,~String,~String,~F),~join:Tree.Join(~F),owner:Peer(~S)) -> F(Peer(~S)):
  leaf(NoOps,U32,peer_program(~S),peer_body,owner)
def guard_program(~S:Data,~P:Type,~project:P -> P & U32,~H:Type,~B:Type,~builder:Build.Builder(~S,~Store(),~Store(),~Resources(~S,~P,~project),~H,~B),book:B) -> B & Unit:(book,Unit{})
def guard_step(~H:Type,scope:H,+runs:U32) -> H & (U32 & Sys.Completion<String,Bool>):(scope,(U32.add(runs,1),Sys.Success{U32.is_le(2,runs)}))
def guard_body(~H:Type,~caps:Unit,scope:H,runs:U32) -> H & (U32 & Sys.Completion<String,Bool>):guard_step(~H,scope,runs)
def Guard(~S:Data,~P:Type,~project:P -> P & U32) -> Type:Sys.Owner<S,Store(),Store(),Resources(~S,~P,~project),Unit,NoOps,U32,String,Bool,guard_program(~S,~P,~project),guard_body>
def guard_dispatch(~S:Data,~P:Type,~project:P -> P & U32) -> Guard(~S,~P,~project) -> World(~S,~P,~project) -> U32 -> Guard(~S,~P,~project) & (World(~S,~P,~project) & Exec.Invocation<String,Bool>):Reg.leaf_dispatch(~S,~Store(),~Resources(~S,~P,~project),~Unit,~NoOps,~U32,~String,~Bool,~guard_program(~S,~P,~project),~guard_body)
def guard_selection(~S:Data,~P:Type,~project:P -> P & U32,~F:Prog.Family(~String,~Bool),~leaf:Prog.Leaf(~String,~Bool,~F),~pair:Prog.Join(~String,~Bool,~F),~partition:Prog.Partition(~String,~Bool,~F),~rootcut:Prog.Rootcut(~String,~Bool,~F),~empty:Prog.Vacant(~String,~Bool,~F),owner:Guard(~S,~P,~project)) -> F(World(~S,~P,~project),Guard(~S,~P,~project),guard_dispatch(~S,~P,~project)):
  leaf(S,Store(),Resources(~S,~P,~project),Unit,NoOps,U32,guard_program(~S,~P,~project),guard_body,owner)
type Handler is Type:Handler{token:Array<U32>,errors:U32}
def handle(owner:Handler,_:String) -> Handler & Exec.Handling:
  match owner:
    case Handler{token,errors}:(Handler{token,U32.add(errors,1)},Exec.Continue{})
def available(_:String) -> Bool:True{}
def Application(~S:Data,~P:Type,~project:P -> P & U32) -> Type:Schedule.Scheduled<App.Application<World(~S,~P,~project),Product.Owner<Left(~S,~P,~project),Peer(~S)>,Guard(~S,~P,~project),Handler,String,String,Root.dispatch(~S,~Unit,~Unit,~D.Resources(~S,~P,~project),~Unit,~Unit,~String,~String,~Left(~S,~P,~project),~Peer(~S),~left(~S,~P,~project),~right(~S)),guard_dispatch(~S,~P,~project),handle>>
def text(value:String) -> String:value
def strings(values:List<&2,String>) -> String:List.show(&2,String,text,values)
def reused(~P:Type,first:U32,result:P & U32) -> String:
  match result:
    case (_,second):U32.show(first) ++ "/" ++ U32.show(second)
def value_returned(~P:Type,~project:P -> P & U32,result:P & U32) -> String:
  match result:
    case (owner,first):reused(~P,first,project(owner))
def payload(~P:Type,~project:P -> P & U32,owner:P) -> String:value_returned(~P,~project,project(owner))
def values(~P:Type,~project:P -> P & U32,owners:List<P>) -> String:List.show(&1,P,payload(~P,~project),owners)
def row(~P:Type,~project:P -> P & U32,value:Log.Row<P>) -> String:
  match value:
    case Log.Row{id,owner}:Nat.show(id) ++ "=" ++ payload(~P,~project,owner)
def event_rows(~P:Type,~project:P -> P & U32,owners:List<Log.Row<P>>) -> String:List.show(&1,Log.Row<P>,row(~P,~project),owners)
def cursor(~S:Data,~P:Type,reader:Event.Reader<S,P,"events">) -> String:
  match reader:
    case Event.Reader{identity,id,at}:U32.show(identity) ++ ":" ++ U32.show(id) ++ ":" ++ Nat.show(at)
def maybe_cursor(~S:Data,~P:Type,reader:Maybe<&1,Event.Reader<S,P,"events">>) -> String:
  match reader:
    case None{}:"none"
    case Some{reader}:cursor(~S,~P,reader)
def writer_local(~P:Type,~project:P -> P & U32,local:D.WriterLocal<P>) -> String:
  match local:
    case D.WriterLocal{pending,refused,runs,history}:"pending=" ++ values(~P,~project,pending) ++ ";refused=" ++ values(~P,~project,refused) ++ ";runs=" ++ U32.show(runs) ++ ";history=" ++ strings(history)
def reader_local(~S:Data,~P:Type,local:D.ReaderLocal<S,P>) -> String:
  match local:
    case D.ReaderLocal{reader,runs,history}:"cursor=" ++ cursor(~S,~P,reader) ++ ";runs=" ++ U32.show(runs) ++ ";history=" ++ strings(history)
def admin_local(~S:Data,~P:Type,~project:P -> P & U32,local:D.AdminLocal<S,P>) -> String:
  match local:
    case D.AdminLocal{removable,foreign,retired,extra,runs,history}:"removed=" ++ maybe_cursor(~S,~P,removable) ++ ";foreign=" ++ maybe_cursor(~S,~P,foreign) ++ ";owners=" ++ event_rows(~P,~project,retired) ++ ";extra=" ++ List.show(&1,Event.Reader<S,P,"events">,cursor(~S,~P),extra) ++ ";runs=" ++ U32.show(runs) ++ ";history=" ++ strings(history)
def cached_row(value:View.Row<U32>) -> String:
  match value:
    case View.Row{id,value}:Nat.show(id) ++ "=" ++ U32.show(value)
def cached(~S:Data,~P:Type,value:View.View<S,P,"events",U32>) -> String:
  match value:
    case View.View{identity,open,next,active,dropped,rows}:"id=" ++ U32.show(identity) ++ ";open=" ++ Bool.pick(String,open,"true","false") ++ ";next=" ++ Nat.show(next) ++ ";active=" ++ List.show(&2,U32,U32.show,active) ++ ";dropped=" ++ Nat.show(dropped) ++ ";rows=" ++ List.show(&2,View.Row<U32>,cached_row,rows)
def family(~S:Data,~P:Type,~project:P -> P & U32,value:Event.Family<S,P,"events">) -> String:
  match value:
    case Event.Family{identity,open,Log.Log{next,rows},previous,current,nextReader,active,dropped}:"id=" ++ U32.show(identity) ++ ";open=" ++ Bool.pick(String,open,"true","false") ++ ";next=" ++ Nat.show(next) ++ ";previous=" ++ List.show(&2,Nat,Nat.show,previous) ++ ";current=" ++ List.show(&2,Nat,Nat.show,current) ++ ";next-reader=" ++ U32.show(nextReader) ++ ";active=" ++ List.show(&2,U32,U32.show,active) ++ ";dropped=" ++ Nat.show(dropped) ++ ";rows=" ++ event_rows(~P,~project,rows)
def event(value:Exec.Observation<String,String>) -> String:
  match value:
    case Exec.Ran{id,out}:U32.show(id) ++ "/success/" ++ out
    case Exec.BodyFailed{id,error,out}:U32.show(id) ++ "/error/" ++ error ++ "/" ++ out
    case Exec.Skipped{id}:U32.show(id) ++ "/disabled"
    case Exec.ConditionFailed{id,error}:U32.show(id) ++ "/condition-error/" ++ error
    case Exec.ConditionRejected{id}:U32.show(id) ++ "/condition-refused"
    case Exec.AdmissionRejected{id}:U32.show(id) ++ "/admission-refused"
def event_id(value:Exec.Observation<String,String>) -> U32:
  match value:
    case Exec.Ran{id,_}:id
    case Exec.BodyFailed{id,_,_}:id
    case Exec.Skipped{id}:id
    case Exec.ConditionFailed{id,_}:id
    case Exec.ConditionRejected{id}:id
    case Exec.AdmissionRejected{id}:id
def event_le(left:Exec.Observation<String,String>,right:Exec.Observation<String,String>) -> Bool:U32.is_le(event_id(left),event_id(right))
def report(value:App.Report<String,String>) -> String:
  match value:
    case App.Finished{events}:List.show(&2,Exec.Observation<String,String>,event,List.sort(~Exec.Observation<String,String>,~event_le,events))
    case App.Stopped{_,_}:"stopped"
    case App.Invalid{_}:"invalid"
def token(result:Array<U32> & U32) -> String:
  match result:
    case (_,value):U32.show(value)
def access(value:Decl.Access) -> String:
  match value:
    case Decl.Access{key,Decl.ResourceAccess{},Decl.Exclusive{},Decl.Writable{}}:"resource/" ++ key ++ "/exclusive/write"
    case Decl.Access{key,Decl.ResourceAccess{},Decl.Exclusive{},Decl.ReadOnly{}}:"resource/" ++ key ++ "/exclusive/read"
    case _ :"unexpected-access"
def metadata(~S:Data,~P:Type,~project:P -> P & U32) -> String:
  List.show(&2,Decl.Access,access,Decl.requirements(~S,~Unit,~D.Resources(~S,~P,~project),~D.Writers(~P),Build.compile(~S,~Store(),~Unit,~D.Resources(~S,~P,~project),~D.Writers(~P),~D.writer(~S,~Store(),~P,~project)))) ++ "/" ++ List.show(&2,Decl.Access,access,Decl.requirements(~S,~Unit,~D.Resources(~S,~P,~project),~D.Readers(~S,~P),Build.compile(~S,~Store(),~Unit,~D.Resources(~S,~P,~project),~D.Readers(~S,~P),~D.reader(~S,~Store(),~P,~project)))) ++ "/" ++ List.show(&2,Decl.Access,access,Decl.requirements(~S,~Unit,~D.Resources(~S,~P,~project),~D.Admins(~S,~P),Build.compile(~S,~Store(),~Unit,~D.Resources(~S,~P,~project),~D.Admins(~S,~P),~D.admin(~S,~Store(),~P,~project))))
def observed(~S:Data,~P:Type,~project:P -> P & U32,trace:String,application:Application(~S,~P,~project)) -> String:
  match application:
    case Schedule.Scheduled{App.Application{App.State{W.World{_,_,_,Product.Owner{Layout.ResourceSlot{Layout.Viewed{owner,cache}},_},_,_,_,_,_,_},Product.Owner{Product.Owner{Sys.Owner{_,_,_,wa,_,wl},Product.Owner{Sys.Owner{_,_,_,fa,_,fl},Product.Owner{Sys.Owner{_,_,_,sa,_,sl},Sys.Owner{_,_,_,aa,_,al}}}},Sys.Owner{_,_,_,_,_,peer}},Sys.Owner{_,_,_,_,_,guards},Handler{handler,errors},_},_,_},_,_}:trace ++ "|family={" ++ family(~S,~P,~project,owner) ++ "}|cache={" ++ cached(~S,~P,cache) ++ "}|writer={" ++ writer_local(~P,~project,wl) ++ "}|fast={" ++ reader_local(~S,~P,fl) ++ "}|slow={" ++ reader_local(~S,~P,sl) ++ "}|admin={" ++ admin_local(~S,~P,~project,al) ++ "}|access=" ++ strings(wa) ++ "/" ++ strings(fa) ++ "/" ++ strings(sa) ++ "/" ++ strings(aa) ++ "|metadata=" ++ metadata(~S,~P,~project) ++ "|peer=" ++ U32.show(peer) ++ ";guard=" ++ U32.show(guards) ++ ";handler=" ++ token(Array.get(U32,handler,0)) ++ ":" ++ U32.show(errors)
def selected(~S:Data,~P:Type,~project:P -> P & U32,native:Bool,app:Application(~S,~P,~project)) -> Application(~S,~P,~project) & App.Report<String,String>:
  match native:
    case False{}:Schedule.run_serial(~S,~Unit,~Unit,~D.Resources(~S,~P,~project),~Unit,~Unit,~String,~String,~Left(~S,~P,~project),~Peer(~S),~left(~S,~P,~project),~right(~S),~Guard(~S,~P,~project),~Handler,~guard_dispatch(~S,~P,~project),~guard_selection(~S,~P,~project),~handle,app)
    case True{}:Schedule.run_native(~S,~Unit,~Unit,~D.Resources(~S,~P,~project),~Unit,~Unit,~String,~String,~Left(~S,~P,~project),~Peer(~S),~left(~S,~P,~project),~right(~S),~Guard(~S,~P,~project),~Handler,~guard_dispatch(~S,~P,~project),~guard_selection(~S,~P,~project),~handle,app)
def repeated(~S:Data,~P:Type,~project:P -> P & U32,next:String -> Application(~S,~P,~project) -> String,trace:String,result:Application(~S,~P,~project) & App.Report<String,String>) -> String:
  match result:
    case (application,status):next(trace ++ report(status) ++ "|",application)
def repeat(~S:Data,~P:Type,~project:P -> P & U32,fuel:Nat,+native:Bool,trace:String,application:Application(~S,~P,~project)) -> String:
  match fuel:
    case 0n:observed(~S,~P,~project,trace,application)
    case 1n+rest:repeated(~S,~P,~project,next=>app=>repeat(~S,~P,~project,rest,native,next,app),trace,selected(~S,~P,~project,native,application))
def guarded(~S:Data,~P:Type,~project:P -> P & U32,native:Bool,owners:Product.Owner<Left(~S,~P,~project),Peer(~S)>,result:Sys.Defined<World(~S,~P,~project),Guard(~S,~P,~project),U32>) -> String:
  match result:
    case Sys.DefinitionRefused{_,_}:"ERROR:guard"
    case Sys.Defined{world,guard}:repeat(~S,~P,~project,5n,native,"",Schedule.build(~S,~Unit,~Unit,~D.Resources(~S,~P,~project),~Unit,~Unit,~String,~String,~Left(~S,~P,~project),~Peer(~S),~left(~S,~P,~project),~right(~S),~Guard(~S,~P,~project),~Handler,~guard_dispatch(~S,~P,~project),~guard_selection(~S,~P,~project),~handle,~available,world,owners,guard,Handler{ALeaf{701},0},[Plan.Edge{1,2},Plan.Edge{1,3},Plan.Edge{2,4},Plan.Edge{3,4}],[App.Binding{3,6}]))
def peer_defined(~S:Data,~P:Type,~project:P -> P & U32,native:Bool,writer:Writer(~S,~P,~project),fast:Reader(~S,~P,~project),slow:Reader(~S,~P,~project),admin:Admin(~S,~P,~project),result:Sys.Defined<World(~S,~P,~project),Peer(~S),U32>) -> String:
  match result:
    case Sys.DefinitionRefused{_,_}:"ERROR:peer"
    case Sys.Defined{world,peer}:guarded(~S,~P,~project,native,Product.Owner{Product.Owner{writer,Product.Owner{fast,Product.Owner{slow,admin}}},peer},Sys.define(~S,~Store(),~Resources(~S,~P,~project),~Unit,~NoOps,~U32,~String,~Bool,~guard_program(~S,~P,~project),~guard_body,world,"slow-enabled",0))
def admin_defined(~S:Data,~P:Type,~project:P -> P & U32,native:Bool,writer:Writer(~S,~P,~project),fast:Reader(~S,~P,~project),slow:Reader(~S,~P,~project),result:Sys.Defined<World(~S,~P,~project),Admin(~S,~P,~project),D.AdminLocal<S,P>>) -> String:
  match result:
    case Sys.DefinitionRefused{_,_}:"ERROR:admin"
    case Sys.Defined{world,admin}:peer_defined(~S,~P,~project,native,writer,fast,slow,admin,Task.define(~S,~Store(),~Unit,~Unit,~Unit,~NoOps,~U32,~String,~String,~peer_program(~S),~peer_body,~Resources(~S,~P,~project),world,"peer",0))
def slow_defined(~S:Data,~P:Type,~project:P -> P & U32,native:Bool,writer:Writer(~S,~P,~project),fast:Reader(~S,~P,~project),admin:D.AdminLocal<S,P>,result:Sys.Defined<World(~S,~P,~project),Reader(~S,~P,~project),D.ReaderLocal<S,P>>) -> String:
  match result:
    case Sys.DefinitionRefused{_,_}:"ERROR:slow"
    case Sys.Defined{world,slow}:admin_defined(~S,~P,~project,native,writer,fast,slow,Task.define(~S,~Store(),~Unit,~D.Resources(~S,~P,~project),~Unit,~D.Admins(~S,~P),~D.AdminLocal<S,P>,~String,~String,~D.admin(~S,~Store(),~P,~project),~D.admin_body(~S,~P),~Resources(~S,~P,~project),world,"admin",admin))
def fast_defined(~S:Data,~P:Type,~project:P -> P & U32,native:Bool,writer:Writer(~S,~P,~project),slow:D.ReaderLocal<S,P>,admin:D.AdminLocal<S,P>,result:Sys.Defined<World(~S,~P,~project),Reader(~S,~P,~project),D.ReaderLocal<S,P>>) -> String:
  match result:
    case Sys.DefinitionRefused{_,_}:"ERROR:fast"
    case Sys.Defined{world,fast}:slow_defined(~S,~P,~project,native,writer,fast,admin,Task.define(~S,~Store(),~Unit,~D.Resources(~S,~P,~project),~Unit,~D.Readers(~S,~P),~D.ReaderLocal<S,P>,~String,~String,~D.reader(~S,~Store(),~P,~project),~D.reader_body(~S,~P),~Resources(~S,~P,~project),world,"slow",slow))
def writer_defined(~S:Data,~P:Type,~project:P -> P & U32,native:Bool,fast:D.ReaderLocal<S,P>,slow:D.ReaderLocal<S,P>,admin:D.AdminLocal<S,P>,result:Sys.Defined<World(~S,~P,~project),Writer(~S,~P,~project),D.WriterLocal<P>>) -> String:
  match result:
    case Sys.DefinitionRefused{_,_}:"ERROR:writer"
    case Sys.Defined{world,writer}:fast_defined(~S,~P,~project,native,writer,slow,admin,Task.define(~S,~Store(),~Unit,~D.Resources(~S,~P,~project),~Unit,~D.Readers(~S,~P),~D.ReaderLocal<S,P>,~String,~String,~D.reader(~S,~Store(),~P,~project),~D.reader_body(~S,~P),~Resources(~S,~P,~project),world,"fast",fast))
def created(~S:Data,~P:Type,~project:P -> P & U32,native:Bool,pending:List<P>,fast:Event.Reader<S,P,"events">,slow:Event.Reader<S,P,"events">,removable:Event.Reader<S,P,"events">,foreign:Event.Reader<S,P,"events">,result:W.Creation<S,Store(),Resources(~S,~P,~project),Unit>) -> String:
  match result:
    case W.CreateRejected{_,_}:"ERROR:world"
    case W.Created{_,world}:writer_defined(~S,~P,~project,native,D.ReaderLocal{fast,0,[]},D.ReaderLocal{slow,0,[]},D.AdminLocal{Some{removable},Some{foreign},[],[],0,[]},Task.define(~S,~Store(),~Unit,~D.Resources(~S,~P,~project),~Unit,~D.Writers(~P),~D.WriterLocal<P>,~String,~String,~D.writer(~S,~Store(),~P,~project),~D.writer_body(~P),~Resources(~S,~P,~project),world,"publisher",D.WriterLocal{pending,[],0,[]}))
def empty(_:Unit) -> Store():Product.Owner{Unit{},Unit{}}
def removable_registered(~S:Data,~P:Type,~project:P -> P & U32,native:Bool,pending:List<P>,fast:Event.Reader<S,P,"events">,slow:Event.Reader<S,P,"events">,foreign:Event.Reader<S,P,"events">,result:Event.Family<S,P,"events"> & Event.Registration<S,P,"events">) -> String:
  match result:
    case (_,Event.RegistrationRefused{_}):"ERROR:removable-registration"
    case (family,Event.Registered{removable}):created(~S,~P,~project,native,pending,fast,slow,removable,foreign,W.create(~S,~Store(),~Resources(~S,~P,~project),~Unit,~empty,W.factory(),Product.Owner{Layout.ResourceSlot{Layout.initialize(D.layout(~S,~P,~project),Layout.AtLeaf{},family)},Unit{}}))
def slow_registered(~S:Data,~P:Type,~project:P -> P & U32,native:Bool,pending:List<P>,fast:Event.Reader<S,P,"events">,foreign:Event.Reader<S,P,"events">,result:Event.Family<S,P,"events"> & Event.Registration<S,P,"events">) -> String:
  match result:
    case (_,Event.RegistrationRefused{_}):"ERROR:slow-registration"
    case (family,Event.Registered{slow}):removable_registered(~S,~P,~project,native,pending,fast,slow,foreign,Event.register(~S,~P,~"events",Event.Retained{},family))
def fast_registered(~S:Data,~P:Type,~project:P -> P & U32,native:Bool,pending:List<P>,foreign:Event.Reader<S,P,"events">,result:Event.Family<S,P,"events"> & Event.Registration<S,P,"events">) -> String:
  match result:
    case (_,Event.RegistrationRefused{_}):"ERROR:fast-registration"
    case (family,Event.Registered{fast}):slow_registered(~S,~P,~project,native,pending,fast,foreign,Event.register(~S,~P,~"events",Event.Future{},family))
def initial_published(~S:Data,~P:Type,~project:P -> P & U32,start:Event.Start,native:Bool,pending:List<P>,foreign:Event.Reader<S,P,"events">,result:Event.Family<S,P,"events"> & Event.Publication<P>) -> String:
  match result:
    case (_,Event.PublicationRefused{_}):"ERROR:initial-publication"
    case (family,Event.Published{_}):fast_registered(~S,~P,~project,native,pending,foreign,Event.register(~S,~P,~"events",start,family))
def foreign_registered(~S:Data,~P:Type,~project:P -> P & U32,start:Event.Start,native:Bool,initial:P,pending:List<P>,primary:Event.Family<S,P,"events">,result:Event.Family<S,P,"events"> & Event.Registration<S,P,"events">) -> String:
  match result:
    case (_,Event.RegistrationRefused{_}):"ERROR:foreign-registration"
    case (_,Event.Registered{foreign}):initial_published(~S,~P,~project,start,native,pending,foreign,Event.publish(~S,~P,~"events",primary,initial))
def foreign_created(~S:Data,~P:Type,~project:P -> P & U32,start:Event.Start,native:Bool,initial:P,pending:List<P>,primary:Event.Family<S,P,"events">,result:Event.Creation<S,P,"events">) -> IO(String):
  match result:
    case Event.CreationRefused{}:IO.pure(String,"ERROR:foreign-identity")
    case Event.Created{foreign}:IO.pure(String,foreign_registered(~S,~P,~project,start,native,initial,pending,primary,Event.register(~S,~P,~"events",Event.Retained{},foreign)))
def primary_created(~S:Data,~P:Type,~project:P -> P & U32,start:Event.Start,native:Bool,initial:P,pending:List<P>,result:Event.Creation<S,P,"events">) -> IO(String):
  match result:
    case Event.CreationRefused{}:IO.pure(String,"ERROR:primary-identity")
    case Event.Created{primary}:IO.bind(Event.Creation<S,P,"events">,String,EventIO.create(~S,~P,~"events"),result=>foreign_created(~S,~P,~project,start,native,initial,pending,primary,result))
def run_started(~S:Data,~P:Type,~project:P -> P & U32,start:Event.Start,native:Bool,initial:P,pending:List<P>) -> IO(String):
  IO.bind(Event.Creation<S,P,"events">,String,EventIO.create(~S,~P,~"events"),result=>primary_created(~S,~P,~project,start,native,initial,pending,result))
def run(~S:Data,~P:Type,~project:P -> P & U32,native:Bool,initial:P,pending:List<P>) -> IO(String):
  run_started(~S,~P,~project,Event.Retained{},native,initial,pending)
def run_future(~S:Data,~P:Type,~project:P -> P & U32,native:Bool,initial:P,pending:List<P>) -> IO(String):
  run_started(~S,~P,~project,Event.Future{},native,initial,pending)
