import Base
import ../../src/ecs/entity-allocator.bend as A
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/execution-command-removed.bend as Removed
import ../parallel-query/payloads.bend as P
import ../parallel-query/declarations.bend as D
import ./notice-writer.bend as Decl
import ./notice-readers.bend as Readers
import ./notice-observation.bend as NoticeObserve
import ../../src/ecs/execution-lifecycle-notices.bend as Notice
import ../../src/ecs/execution-lifecycle-administration.bend as Admin
import ../../src/ecs/dependency-plan.bend as Plan
import ../parallel-query/commands-core.bend as Core
import ../parallel-query/command-body.bend as Body
import ../parallel-query/observation.bend as QueryObserve
import ../../src/ecs/execution-query.bend as Query
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-parallel-system.bend as Task
import ../../src/ecs/execution-parallel-scope-registry.bend as Tree
import ../../src/ecs/execution-parallel-rootcut.bend as Root
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ../../src/ecs/dependency-application.bend as DepApp
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-registry-program.bend as Prog
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/chunk-column.bend as Column
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/deferred-command.bend as Deferred
import ../../test-fixtures/common/column-observation.bend as Observe

def layout(~S:Data) -> Layout.Layout:Layout.LayoutPair{D.layout(),Layout.EmptyLayout{}}
def path(~S:Data) -> Layout.Route:Layout.InLeft{Layout.InLeft{Layout.InRight{Layout.AtLeaf{}}}}
def Left(~S:Data) -> Type:Layout.columns(~S,D.layout())
def Store(~S:Data) -> Type:Layout.columns(~S,layout(~S))
def Resources(~S:Data) -> Type:Product.Owner<D.Resources(~S),Unit>
def Ops(~S:Data,H:Type,O:Type) -> Type:Decl.Ops(~S,H,O)
def PeerOps(~S:Data,H:Type) -> Type:Readers.Ops(~S,H)
def author_declaration(~S:Data,~mode:Query.Mode,~H:Type,~O:Type,~commands:Local.Commands<O,S,P.Output>,~B:Type,~builder:Build.Builder(~S,~Store(~S),~Left(~S),~D.Resources(~S),~H,~B),~K:Type,~entity:Permission.Grant(~S,~layout(~S),~O,~K),book:B,permission:K) -> B & (K & Ops(~S,H,O)):
  Decl.author_declaration(~S,~mode,~H,~O,~commands,~B,~builder,~K,~entity,book,permission)
def peer_declaration(~S:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~Store(~S),~Unit,~Unit,~H,~B),book:B) -> B & Readers.Ops(~S,H):
  Readers.declaration(~S,~H,~B,~builder,book)
def peer_body(~S:Data,~H:Type,~caps:Readers.Ops(~S,H),scope:H,local:Readers.Captures<S>) -> H & (Readers.Captures<S> & Sys.Completion<String,String>):
  Readers.body(~S,~H,~caps,scope,local)
def AuthorLocal(~S:Data) -> Type:Decl.User<S>
def Author(~S:Data,~mode:Query.Mode) -> Type:Cmd.Owner<S,Left(~S),D.Resources(~S),Unit,layout(~S),path(~S),Ops(~S),AuthorLocal(~S),String,String,author_declaration(~S,~mode),Decl.body(~S)>
def Peer(~S:Data) -> Type:Sys.Owner<S,Store(~S),Unit,Unit,Unit,PeerOps(~S),Readers.Captures<S>,String,String,peer_declaration(~S),peer_body(~S)>
def left(~S:Data,~mode:Query.Mode,~F:Tree.Family(),~leaf:Tree.Leaf(~S,~Store(~S),~Left(~S),~D.Resources(~S),~Unit,~String,~String,~F),~command:Tree.CommandLeaf(~S,~Store(~S),~Left(~S),~D.Resources(~S),~Unit,~String,~String,~F),~join:Tree.Join(~F),owner:Author(~S,~mode)) -> F(Author(~S,~mode)):
  command(layout(~S),path(~S),{==},{==},Ops(~S),AuthorLocal(~S),author_declaration(~S,~mode),Decl.body(~S),owner)
def right(~S:Data,~F:Tree.Family(),~leaf:Tree.Leaf(~S,~Store(~S),~Unit,~Unit,~Unit,~String,~String,~F),~command:Tree.CommandLeaf(~S,~Store(~S),~Unit,~Unit,~Unit,~String,~String,~F),~join:Tree.Join(~F),owner:Peer(~S)) -> F(Peer(~S)):
  leaf(PeerOps(~S),Readers.Captures<S>,peer_declaration(~S),peer_body(~S),owner)
type Handler is Type:
  Handler{token:Array<U32>,errors:U32}
def handle(~S:Data,handler:Handler,error:String) -> Handler & Exec.Handling:
  match handler:
    case Handler{token,errors}:(Handler{token,U32.add(errors,1)},Exec.Continue{})
def Application(~S:Data,~mode:Query.Mode) -> Type:Schedule.Scheduled<DepApp.Application<W.World<S,Store(~S),Resources(~S),Unit>,Product.Owner<Author(~S,~mode),Peer(~S)>,Unit,Handler,String,String,Root.dispatch(~S,~Left(~S),~Unit,~D.Resources(~S),~Unit,~Unit,~String,~String,~Author(~S,~mode),~Peer(~S),~left(~S,~mode),~right(~S)),Reg.empty_dispatch(~W.World<S,Store(~S),Resources(~S),Unit>,~String,~Bool),handle(~S)>>
def token_value(~S:Data,result:Array<U32> & U32) -> String:
  match result:
    case (_,value):U32.show(value)
def handle_text(~S:Data,value:W.Handle<S>) -> String:
  match value:
    case W.Handle{namespace,key}:U32.show(namespace) ++ ":" ++ Observe.key(key)
type Record is Data:
  Record{index:U32,token:U32,text:String}
def record_token(~S:Data,label:String,+handle:W.Handle<S>,value:U32,result:Array<U32> & U32) -> Record:
  match result:
    case (_, +token):Record{W.handle_index(~S,handle),token,label ++ handle_text(~S,handle) ++ ":" ++ U32.show(token) ++ ":" ++ U32.show(value)}
def payload_record(~S:Data,label:String,+handle:W.Handle<S>,owner:Maybe<&1,P.Output>) -> Record:
  match owner:
    case None{}:Record{W.handle_index(~S,handle),0,label ++ handle_text(~S,handle) ++ ":none"}
    case Some{P.Output{token,value}}:record_token(~S,label,handle,value,Array.get(U32,token,0))
def entry(~S:Data,value:Buffer.Entry<S,P.Output>) -> Record:
  match value:
    case Buffer.Entry{handle,incoming}:payload_record(~S,"",handle,incoming)
    case Buffer.Despawn{handle}:payload_record(~S,"despawn:",handle,None{})
def input_payload(value:Maybe<&1,P.Input>) -> String:
  match value:
    case None{}:"none"
    case Some{owner}:Observe.projected(~P.Input,P.input(owner))
def output_payload(value:Maybe<&1,P.Output>) -> String:
  match value:
    case None{}:"none"
    case Some{owner}:Observe.projected(~P.Output,P.output(owner))
def despawn_record(~S:Data,+handle:W.Handle<S>,removed:Removed.Removed(layout(~S))) -> Record:
  match removed:
    case Product.Owner{Product.Owner{Product.Owner{input,output},_},_}:Record{W.handle_index(~S,handle),0,"despawned:" ++ handle_text(~S,handle) ++ ":input=" ++ input_payload(input) ++ "/output=" ++ output_payload(output)}
def receipt(~S:Data,value:Buffer.Receipt<S,P.Output,Removed.Removed(layout(~S))>) -> Record:
  match value:
    case Buffer.Applied{handle,previous}:payload_record(~S,"applied:",handle,previous)
    case Buffer.Refused{handle,incoming}:payload_record(~S,"refused:",handle,incoming)
    case Buffer.Despawned{handle,removed}:despawn_record(~S,handle,removed)
    case Buffer.DespawnRefused{handle}:payload_record(~S,"despawn-refused:",handle,None{})
def record_before(~S:Data,left:Record,right:Record) -> Bool:
  match left right:
    case Record{+li,lt,_} Record{+ri,rt,_}:U32.is_lt(li,ri) || (U32.is_eq(li,ri) && U32.is_le(lt,rt))
def record_chosen(~S:Data,value:Record,head:Record,rest:List<&2,Record>,placed:List<&2,Record>,before:Bool) -> List<&2,Record>:
  match before:
    case True{}:value <> head <> rest
    case False{}:head <> placed
def record_insert(~S:Data,+value:Record,records:List<&2,Record>) -> List<&2,Record>:
  match records:
    case []:[value]
    case +head <> +rest:record_chosen(~S,value,head,rest,record_insert(~S,value,rest),record_before(~S,value,head))
def entries(~S:Data,values:List<Buffer.Entry<S,P.Output>>) -> List<&2,Record>:
  match values:
    case []:[]
    case value <> rest:record_insert(~S,entry(~S,value),entries(~S,rest))
def receipt_records(~S:Data,values:List<Buffer.Receipt<S,P.Output,Removed.Removed(layout(~S))>>) -> List<&2,Record>:
  match values:
    case []:[]
    case value <> rest:record_insert(~S,receipt(~S,value),receipt_records(~S,rest))
def record_text(~S:Data,value:Record) -> String:
  match value:
    case Record{_,_,text}:text
def world(~S:Data,world:W.World<S,Store(~S),Resources(~S),Unit>) -> String:
  match world:
    case W.World{namespace,allocator,Product.Owner{store,_},Product.Owner{resource,_},events,pending,registrations,next,clock,lifecycle}:"namespace=" ++ U32.show(namespace) ++ ";allocator={" ++ Observe.allocator(allocator) ++ "};" ++ QueryObserve.store(~S,store) ++ ";resource=" ++ QueryObserve.resource(~S,resource) ++ ";events=" ++ Nat.show(List.length(&2,Unit,events)) ++ ";legacy-pending=" ++ Nat.show(List.length(&1,Deferred.Command<W.World<S,Store(~S),Resources(~S),Unit>>,pending)) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,Observe.registration,registrations) ++ ";next=" ++ U32.show(next) ++ ";clock=" ++ Observe.clock(clock)
def event(~S:Data,value:Exec.Observation<String,String>) -> String:
  match value:
    case Exec.Ran{id,out}:"ran:" ++ U32.show(id) ++ ":" ++ out
    case Exec.BodyFailed{id,error,out}:"error:" ++ U32.show(id) ++ ":" ++ error ++ ":" ++ out
    case Exec.Skipped{id}:"skip:" ++ U32.show(id)
    case Exec.AdmissionRejected{id}:"refused:" ++ U32.show(id)
    case Exec.ConditionFailed{id,error}:"condition-error:" ++ U32.show(id) ++ ":" ++ error
    case Exec.ConditionRejected{id}:"condition-refused:" ++ U32.show(id)
def report(~S:Data,value:DepApp.Report<String,String>) -> String:
  match value:
    case DepApp.Finished{events}:List.show(&2,Exec.Observation<String,String>,event(~S),events)
    case DepApp.Stopped{_,events}:"stopped:" ++ List.show(&2,Exec.Observation<String,String>,event(~S),events)
    case DepApp.Invalid{_}:"invalid"
def world_journal(~S:Data,namespace:U32,allocator:A.Allocator,store:Store(~S),resource:Resources(~S),events:List<&2,Unit>,pending:List<Deferred.Command<W.World<S,Store(~S),Resources(~S),Unit>>>,registrations:List<&2,W.RegistrationMeta>,next:U32,clock:Clock.State,result:Notice.Journal<S> & String) -> String:
  match result:
    case (journal,text):"journal={" ++ text ++ "};" ++ Core.world(~S,W.World{namespace,allocator,store,resource,events,pending,registrations,next,clock,journal})
def notice_world(~S:Data,world:W.World<S,Store(~S),Resources(~S),Unit>) -> String:
  match world:
    case W.World{namespace,allocator,store,resource,events,pending,registrations,next,clock,journal}:world_journal(~S,namespace,allocator,store,resource,events,pending,registrations,next,clock,NoticeObserve.journal(~S,journal))
def observed(~S:Data,~mode:Query.Mode,prefix:String,application:Application(~S,~mode)) -> String:
  match application:
    case Schedule.Scheduled{DepApp.Application{DepApp.State{owner,Product.Owner{Cmd.Owner{Sys.Owner{_,_,_,_,cursor,Local.Local{Decl.User{userToken,runs,handles},Buffer.Buffer{pending,receipts},permission}}},Sys.Owner{_,_,_,_,peerCursor,peer}},_,Handler{handler,errors},_},_,_},_,Schedule.Deferred{_,_,unapplied}}:prefix ++ "|world=" ++ notice_world(~S,owner) ++ "|queue=" ++ List.show(&2,Record,record_text(~S),entries(~S,pending)) ++ "|receipts=" ++ List.show(&2,Record,record_text(~S),receipt_records(~S,receipts)) ++ "|handles=" ++ List.show(&2,W.Handle<S>,handle_text(~S),handles) ++ "|user=" ++ token_value(~S,Array.get(U32,userToken,0)) ++ ":" ++ U32.show(runs) ++ "|cursor=" ++ Tick.cursor_show(cursor) ++ "|peer={" ++ Readers.observed(~S,peer) ++ "}:" ++ Tick.cursor_show(peerCursor) ++ "|handler=" ++ token_value(~S,Array.get(U32,handler,0)) ++ ":" ++ U32.show(errors) ++ "|unapplied=" ++ List.show(&2,U32,U32.show,unapplied)
def pending_observed(~S:Data,~mode:Query.Mode,prefix:String,result:Application(~S,~mode) & Bool) -> String:
  match result:
    case (application,pending):observed(~S,~mode,prefix ++ ";exact-pending=" ++ Bool.pick(String,pending,"true","false"),application)
def selected(~S:Data,~mode:Query.Mode,native:Bool,app:Application(~S,~mode)) -> Application(~S,~mode) & DepApp.Report<String,String>:
  match native:
    case False{}:Schedule.run_serial(~S,~Left(~S),~Unit,~D.Resources(~S),~Unit,~Unit,~String,~String,~Author(~S,~mode),~Peer(~S),~left(~S,~mode),~right(~S),~Unit,~Handler,~Reg.empty_dispatch(~W.World<S,Store(~S),Resources(~S),Unit>,~String,~Bool),~Prog.empty(~W.World<S,Store(~S),Resources(~S),Unit>,~String,~Bool),~handle(~S),app)
    case True{}:Schedule.run_native(~S,~Left(~S),~Unit,~D.Resources(~S),~Unit,~Unit,~String,~String,~Author(~S,~mode),~Peer(~S),~left(~S,~mode),~right(~S),~Unit,~Handler,~Reg.empty_dispatch(~W.World<S,Store(~S),Resources(~S),Unit>,~String,~Bool),~Prog.empty(~W.World<S,Store(~S),Resources(~S),Unit>,~String,~Bool),~handle(~S),app)
def finished(~S:Data,~mode:Query.Mode,+native:Bool,remaining:Nat,prefix:String,result:Application(~S,~mode) & DepApp.Report<String,String>) -> String:
  match remaining result:
    case 0n, (app,done):pending_observed(~S,~mode,prefix ++ report(~S,done),Schedule.pending(~S,~Left(~S),~Unit,~D.Resources(~S),~Unit,~Unit,~String,~String,~Author(~S,~mode),~Peer(~S),~left(~S,~mode),~right(~S),~Unit,~Handler,~Reg.empty_dispatch(~W.World<S,Store(~S),Resources(~S),Unit>,~String,~Bool),~Prog.empty(~W.World<S,Store(~S),Resources(~S),Unit>,~String,~Bool),~handle(~S),app))
    case 1n+rest, (app,done):finished(~S,~mode,native,rest,prefix ++ report(~S,done) ++ ";",selected(~S,~mode,native,app))
def first(~S:Data,~mode:Query.Mode,+native:Bool,result:Application(~S,~mode) & DepApp.Report<String,String>) -> String:
  finished(~S,~mode,native,3n,"",result)
type Setup<-S:Data,-mode:Query.Mode> is Type:
  Ready{application:Application(~S,~mode)}
  Failed{reason:String}
def setup_run(~S:Data,~mode:Query.Mode,+native:Bool,result:Setup<S,mode>) -> String:
  match result:
    case Ready{app}:first(~S,~mode,native,selected(~S,~mode,native,app))
    case Failed{reason}:reason
def built(~S:Data,~mode:Query.Mode,settings:Settings.Settings,+native:Bool,world:W.World<S,Store(~S),Resources(~S),Unit>,author:Author(~S,~mode),peer:Peer(~S)) -> Setup<S,mode>:
  Ready{Schedule.configure(~(DepApp.Application<W.World<S,Store(~S),Resources(~S),Unit>,Product.Owner<Author(~S,~mode),Peer(~S)>,Unit,Handler,String,String,Root.dispatch(~S,~Left(~S),~Unit,~D.Resources(~S),~Unit,~Unit,~String,~String,~Author(~S,~mode),~Peer(~S),~left(~S,~mode),~right(~S)),Reg.empty_dispatch(~W.World<S,Store(~S),Resources(~S),Unit>,~String,~Bool),handle(~S)>),settings,Schedule.build(~S,~Left(~S),~Unit,~D.Resources(~S),~Unit,~Unit,~String,~String,~Author(~S,~mode),~Peer(~S),~left(~S,~mode),~right(~S),~Unit,~Handler,~Reg.empty_dispatch(~W.World<S,Store(~S),Resources(~S),Unit>,~String,~Bool),~Prog.empty(~W.World<S,Store(~S),Resources(~S),Unit>,~String,~Bool),~handle(~S),~(name => True{}),world,Product.Owner{author,peer},Unit{},Handler{ALeaf{901},0},[Plan.Edge{1,2}],[]))}
def peer_defined(~S:Data,~mode:Query.Mode,settings:Settings.Settings,native:Bool,author:Author(~S,~mode),result:Sys.Defined<W.World<S,Store(~S),Resources(~S),Unit>,Peer(~S),Readers.Captures<S>>) -> Setup<S,mode>:
  match result:
    case Sys.Defined{world,peer}:built(~S,~mode,settings,native,world,author,peer)
    case Sys.DefinitionRefused{_,_}:Failed{"ERROR: peer definition"}
def author_defined(~S:Data,~mode:Query.Mode,settings:Settings.Settings,native:Bool,readers:Readers.Captures<S>,result:Sys.Defined<W.World<S,Store(~S),Resources(~S),Unit>,Author(~S,~mode),Cmd.Captures(~S,~layout(~S),~path(~S),~AuthorLocal(~S))>) -> Setup<S,mode>:
  match result:
    case Sys.Defined{world,author}:peer_defined(~S,~mode,settings,native,author,Task.define(~S,~Store(~S),~Unit,~Unit,~Unit,~PeerOps(~S),~Readers.Captures<S>,~String,~String,~peer_declaration(~S),~peer_body(~S),~Resources(~S),world,"reader",readers))
    case Sys.DefinitionRefused{_,_}:Failed{"ERROR: author definition"}
def activated(~S:Data,result:W.World<S,Store(~S),Resources(~S),Unit> & W.Status) -> W.World<S,Store(~S),Resources(~S),Unit>:
  match result:
    case (world,_):world
def reserved(~S:Data,result:W.World<S,Store(~S),Resources(~S),Unit> & W.Reservation<S>) -> W.World<S,Store(~S),Resources(~S),Unit>:
  match result:
    case (world,W.Reserved{handle}):activated(~S,W.activate(~S,~Store(~S),~Resources(~S),~Unit,world,handle))
    case (world,_):world
def spawn(~S:Data,fuel:Nat,world:W.World<S,Store(~S),Resources(~S),Unit>) -> W.World<S,Store(~S),Resources(~S),Unit>:
  match fuel:
    case 0n:world
    case 1n+rest:spawn(~S,rest,reserved(~S,W.reserve_id(~S,~Store(~S),~Resources(~S),~Unit,world)))
def empty(~S:Data,_:Unit) -> Store(~S):Product.Owner{D.empty(~S,Unit{}),Unit{}}
def handles_ready(~S:Data,~mode:Query.Mode,settings:Settings.Settings,native:Bool,readers:Readers.Captures<S>,result:W.World<S,Store(~S),Resources(~S),Unit> & List<&2,W.Handle<S>>) -> Setup<S,mode>:
  match result:
    case (world,handles):author_defined(~S,~mode,settings,native,readers,Cmd.define(~S,~Left(~S),~D.Resources(~S),~Unit,~layout(~S),~path(~S),~{==},~Ops(~S),~AuthorLocal(~S),~String,~String,~author_declaration(~S,~mode),~Decl.body(~S),~Resources(~S),world,"author",Decl.User{ALeaf{900},0,handles}))
def despawn_registered(~S:Data,~mode:Query.Mode,settings:Settings.Settings,native:Bool,fast:Readers.OutputReader(~S),slow:Readers.OutputReader(~S),input:Readers.InputReader(~S),result:W.World<S,Store(~S),Resources(~S),Unit> & Notice.Registration<S,Layout.EmptyLayout{},Notice.Despawned{}>) -> Setup<S,mode>:
  match result:
    case (world,Notice.Registered{despawn}):handles_ready(~S,~mode,settings,native,Readers.Captures{ALeaf{700},0,fast,slow,input,despawn,""},W.handles(~S,~Store(~S),~Resources(~S),~Unit,world))
    case (_,Notice.RegistrationRefused{_}):Failed{"ERROR: despawn reader"}
def input_registered(~S:Data,~mode:Query.Mode,settings:Settings.Settings,native:Bool,fast:Readers.OutputReader(~S),slow:Readers.OutputReader(~S),result:W.World<S,Store(~S),Resources(~S),Unit> & Notice.Registration<S,Readers.input_origin(),Notice.Removed{"input"}>) -> Setup<S,mode>:
  match result:
    case (world,Notice.Registered{input}):despawn_registered(~S,~mode,settings,native,fast,slow,input,Admin.register_despawn(~S,~Store(~S),~Resources(~S),~Unit,world,Notice.Retained{}))
    case (_,Notice.RegistrationRefused{_}):Failed{"ERROR: input reader"}
def slow_registered(~S:Data,~mode:Query.Mode,settings:Settings.Settings,native:Bool,fast:Readers.OutputReader(~S),result:W.World<S,Store(~S),Resources(~S),Unit> & Notice.Registration<S,Readers.output_origin(),Notice.Removed{"output"}>) -> Setup<S,mode>:
  match result:
    case (world,Notice.Registered{slow}):input_registered(~S,~mode,settings,native,fast,slow,Admin.register_removed(~S,~Store(~S),~Resources(~S),~Unit,~layout(~S),~Readers.input_route(),~{==},~{==},world,Notice.Retained{}))
    case (_,Notice.RegistrationRefused{_}):Failed{"ERROR: slow reader"}
def fast_registered(~S:Data,~mode:Query.Mode,settings:Settings.Settings,native:Bool,result:W.World<S,Store(~S),Resources(~S),Unit> & Notice.Registration<S,Readers.output_origin(),Notice.Removed{"output"}>) -> Setup<S,mode>:
  match result:
    case (world,Notice.Registered{fast}):slow_registered(~S,~mode,settings,native,fast,Admin.register_removed(~S,~Store(~S),~Resources(~S),~Unit,~layout(~S),~Readers.output_route(),~{==},~{==},world,Notice.Retained{}))
    case (_,Notice.RegistrationRefused{_}):Failed{"ERROR: fast reader"}
def admitted(~S:Data,~mode:Query.Mode,settings:Settings.Settings,native:Bool,world:W.World<S,Store(~S),Resources(~S),Unit>) -> Setup<S,mode>:
  fast_registered(~S,~mode,settings,native,Admin.register_removed(~S,~Store(~S),~Resources(~S),~Unit,~layout(~S),~Readers.output_route(),~{==},~{==},spawn(~S,18n,world),Notice.Retained{}))
def created(~S:Data,~mode:Query.Mode,settings:Settings.Settings,+native:Bool,result:W.Creation<S,Store(~S),Resources(~S),Unit>) -> String:
  match result:
    case W.Created{_,world}:setup_run(~S,~mode,native,admitted(~S,~mode,settings,native,world))
    case W.CreateRejected{_,_}:"ERROR: creation"
type First is Data:First{}
def first_created(result:W.Creation<First,Store(~First),Resources(~First),Unit>) -> String:
  created(~First,~Query.Parallel{},Settings.defaults(),True{},result)
