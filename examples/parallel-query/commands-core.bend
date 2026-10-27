import Base
import ../../src/ecs/execution-reservation-task.bend as Effect
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/execution-command-removed.bend as Removed
import ./payloads.bend as P
import ./declarations.bend as D
import ./output-declaration.bend as Decl
import ./command-body.bend as Body
import ./observation.bend as QueryObserve
import ../../src/ecs/execution-query.bend as Query
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-reservation-bundle.bend as Bundle
import ../../src/ecs/trace-world.bend as Trace
import ../../src/ecs/execution-relation-operation.bend as Relation
import ../../src/ecs/execution-relation-store.bend as RelationStore
import ../../src/ecs/relation-types.bend as RelationTypes
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-parallel-system.bend as Task
import ../../src/ecs/execution-parallel-scope-registry.bend as Tree
import ../../src/ecs/execution-parallel-rootcut.bend as Root
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ../../src/ecs/dependency-application.bend as DepApp
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/execution-condition-registry.bend as Conditions
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
def resources() -> Layout.Layout:Layout.LayoutPair{D.resource_layout(),Layout.EmptyLayout{}}
def Resources(~S:Data) -> Type:Product.Owner<D.Resources(~S),Unit>
def Ops(~S:Data,Permit:Data,H:Type,O:Type) -> Type:Decl.Ops(~S,Permit,H,O)
def PeerOps(~S:Data,Permit:Data,H:Type) -> Type:Unit
def author_declared(~S:Data,~Permit:Data,~H:Type,~O:Type,~B:Type,~K:Type,permission:K,result:B & Ops(~S,Permit,H,O)) -> B & (K & Ops(~S,Permit,H,O)):
  match result:
    case (book,ops):(book,(permission,ops))
def author_declaration(~S:Data,~mode:Query.Mode,~Permit:Data,~H:Type,~O:Type,~commands:Local.Commands<O,S,P.Output>,~B:Type,~builder:Build.Builder(~S,~Store(~S),~Left(~S),~D.Resources(~S),~Permit,~H,~B),~K:Type,~entity:Permission.Grant(~S,~layout(~S),~Permit,~O,~K),~relations:Permission.RelationGrant(~S,~resources(),~O,~K),book:B,permission:K) -> B & (K & Ops(~S,Permit,H,O)):
  author_declared(~S,~Permit,~H,~O,~B,~K,permission,Decl.declaration(~S,~Store(~S),~mode,~Permit,~H,~O,~commands,~B,~builder,book))
def peer_declaration(~S:Data,~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~Store(~S),~Unit,~Unit,~Permit,~H,~B),book:B) -> B & Unit:
  (book,Unit{})
def peer_body(~S:Data,~Permit:Data,~H:Type,~caps:Unit,scope:H,token:Array<U32>) -> Effect.Task<S,Permit,H & (Array<U32> & Sys.Completion<String,String>)>:
  Effect.TDone{(scope,(token,Sys.Success{"peer"}))}
def AuthorLocal(~S:Data) -> Type:Body.User
def Author(~S:Data,~mode:Query.Mode) -> Type:Cmd.Owner<S,Left(~S),D.Resources(~S),Unit,layout(~S),resources(),path(~S),Ops(~S),AuthorLocal(~S),String,String,author_declaration(~S,~mode),Body.run(~S)>
def Peer(~S:Data) -> Type:Sys.Owner<S,Store(~S),Unit,Unit,Unit,PeerOps(~S),Array<U32>,String,String,Build.framework_program(~S,~Store(~S),~Unit,~Unit,~PeerOps(~S),~peer_declaration(~S)),peer_body(~S)>
def left(~S:Data,~mode:Query.Mode,~F:Tree.Family(),~leaf:Tree.Leaf(~S,~Store(~S),~Left(~S),~D.Resources(~S),~Unit,~resources(),~String,~String,~F),~command:Tree.CommandLeaf(~S,~Store(~S),~Left(~S),~D.Resources(~S),~Unit,~resources(),~String,~String,~F),~join:Tree.Join(~F),owner:Author(~S,~mode)) -> F(Author(~S,~mode)):
  command(layout(~S),path(~S),{==},{==},Ops(~S),AuthorLocal(~S),author_declaration(~S,~mode),Body.run(~S),owner)
def right(~S:Data,~F:Tree.Family(),~leaf:Tree.Leaf(~S,~Store(~S),~Unit,~Unit,~Unit,~resources(),~String,~String,~F),~command:Tree.CommandLeaf(~S,~Store(~S),~Unit,~Unit,~Unit,~resources(),~String,~String,~F),~join:Tree.Join(~F),owner:Peer(~S)) -> F(Peer(~S)):
  leaf(PeerOps(~S),Array<U32>,Build.framework_program(~S,~Store(~S),~Unit,~Unit,~PeerOps(~S),~peer_declaration(~S)),peer_body(~S),owner)
type Handler is Type:
  Handler{token:Array<U32>,errors:U32}
def handle(~S:Data,handler:Handler,error:String) -> Handler & Exec.Handling:
  match handler:
    case Handler{token,errors}:(Handler{token,U32.add(errors,1)},Exec.Continue{})
def Application(~S:Data,~mode:Query.Mode) -> Type:Schedule.Scheduled<DepApp.State<W.World<S,Store(~S),Resources(~S),Unit>,Product.Owner<Author(~S,~mode),Peer(~S)>,Unit,Handler>>

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
def input_text(~S:Data,owner:Maybe<&1,P.Input>) -> String:
  match owner:
    case None{}:"none"
    case Some{P.Input{token,step}}:token_value(~S,Array.get(U32,token,0)) ++ ":" ++ U32.show(step)
def output_text(~S:Data,owner:Maybe<&1,P.Output>) -> String:
  match owner:
    case None{}:"none"
    case Some{P.Output{token,value}}:token_value(~S,Array.get(U32,token,0)) ++ ":" ++ U32.show(value)
def bundle_text(~S:Data,owner:Removed.Removed(layout(~S))) -> String:
  match owner:
    case Product.Owner{Product.Owner{Product.Owner{incoming,outgoing},_},_}:"input=" ++ input_text(~S,incoming) ++ ",output=" ++ output_text(~S,outgoing)
def route_text(route:Layout.Route) -> String:
  match route:
    case Layout.AtLeaf{}:"leaf"
    case Layout.InLeft{rest}:"left/" ++ route_text(rest)
    case Layout.InRight{rest}:"right/" ++ route_text(rest)
def operation_text(~S:Data,operation:Relation.Operation<S>) -> String:
  match operation:
    case Relation.Relate{source,target}:"relate:" ++ handle_text(~S,source) ++ ":" ++ handle_text(~S,target)
    case Relation.Unrelate{source}:"unrelate:" ++ handle_text(~S,source)
    case Relation.Reorder{parent,children}:"reorder:" ++ handle_text(~S,parent) ++ ":" ++ List.show(&2,W.Handle<S>,handle_text(~S),children)
def relation_error(error:RelationTypes.Error) -> String:
  match error:
    case RelationTypes.MissingEntity{source}:"missing:" ++ Observe.key(source)
    case RelationTypes.MissingTargetEntity{source,target,name}:"missing-target:" ++ Observe.key(source) ++ ":" ++ Observe.key(target) ++ ":" ++ name
    case RelationTypes.SelfRelationNotAllowed{source,name}:"self:" ++ Observe.key(source) ++ ":" ++ name
    case RelationTypes.HierarchyCycle{source,target,name}:"cycle:" ++ Observe.key(source) ++ ":" ++ Observe.key(target) ++ ":" ++ name
    case RelationTypes.MissingChildEntity{source,child,name}:"missing-child:" ++ Observe.key(source) ++ ":" ++ Observe.key(child) ++ ":" ++ name
    case RelationTypes.DuplicateChild{source,child,name}:"duplicate-child:" ++ Observe.key(source) ++ ":" ++ Observe.key(child) ++ ":" ++ name
    case RelationTypes.ChildNotRelatedToParent{source,child,name}:"not-child:" ++ Observe.key(source) ++ ":" ++ Observe.key(child) ++ ":" ++ name
    case RelationTypes.ChildSetMismatch{source,name}:"child-set:" ++ Observe.key(source) ++ ":" ++ name
def relation_reason(reason:RelationStore.Reason) -> String:
  match reason:
    case RelationStore.NamespaceMismatch{}:"namespace"
    case RelationStore.OperationRefused{Relation.HierarchyRequired{}}:"hierarchy-required"
    case RelationStore.OperationRefused{Relation.RelationError{error}}:relation_error(error)
def relation_receipt(~S:Data,receipt:RelationStore.Receipt<S>) -> String:
  match receipt:
    case RelationStore.Applied{operation}:"applied:" ++ operation_text(~S,operation)
    case RelationStore.Refused{operation,reason}:"refused:" ++ operation_text(~S,operation) ++ ":" ++ relation_reason(reason)
def spawn_reason(reason:Bundle.Refusal) -> String:
  match reason:
    case Bundle.InvalidPending{error}:"pending:" ++ Trace.error(error)
    case Bundle.PermissionDenied{}:"permission"
    case Bundle.DuplicateFamily{}:"duplicate-family"
    case Bundle.PhysicalIndex{}:"physical-index"
    case Bundle.MalformedColumn{key}:"malformed:" ++ key
    case Bundle.OccupiedFamily{key}:"occupied:" ++ key
def entry(~S:Data,value:Buffer.Entry<S,P.Output,Removed.Removed(layout(~S))>) -> Record:
  match value:
    case Buffer.Entry{handle,incoming}:payload_record(~S,"",handle,incoming)
    case Buffer.Despawn{handle}:payload_record(~S,"despawn:",handle,None{})
    case Buffer.Spawn{+handle,bundle}:Record{W.handle_index(~S,handle),0,"spawn:" ++ handle_text(~S,handle) ++ ":" ++ bundle_text(~S,bundle)}
    case Buffer.Relation{route,operation}:Record{0,0,"relation:" ++ route_text(route) ++ ":" ++ operation_text(~S,operation)}
def receipt(~S:Data,value:Buffer.Receipt<S,P.Output,Removed.Removed(layout(~S))>) -> Record:
  match value:
    case Buffer.Applied{handle,previous}:payload_record(~S,"applied:",handle,previous)
    case Buffer.Refused{handle,incoming}:payload_record(~S,"refused:",handle,incoming)
    case Buffer.Despawned{+handle,removed}:Record{W.handle_index(~S,handle),0,"despawned:" ++ handle_text(~S,handle) ++ ":" ++ bundle_text(~S,removed)}
    case Buffer.DespawnRefused{handle}:payload_record(~S,"despawn-refused:",handle,None{})
    case Buffer.Spawned{+handle,previous}:Record{W.handle_index(~S,handle),0,"spawned:" ++ handle_text(~S,handle) ++ ":" ++ bundle_text(~S,previous)}
    case Buffer.SpawnRefused{+handle,bundle,reason}:Record{W.handle_index(~S,handle),0,"spawn-refused:" ++ handle_text(~S,handle) ++ ":" ++ bundle_text(~S,bundle) ++ ":" ++ spawn_reason(reason)}
    case Buffer.RelationPublished{route,result}:Record{0,0,"relation:" ++ route_text(route) ++ ":" ++ relation_receipt(~S,result)}
    case Buffer.RelationUndeclared{route,operation}:Record{0,0,"relation-undeclared:" ++ route_text(route) ++ ":" ++ operation_text(~S,operation)}
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
def entries(~S:Data,values:List<Buffer.Entry<S,P.Output,Removed.Removed(layout(~S))>>) -> List<&2,Record>:
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
def observed(~S:Data,~mode:Query.Mode,prefix:String,application:Application(~S,~mode)) -> String:
  match application:
    case Schedule.Scheduled{DepApp.State{owner,Product.Owner{Cmd.Owner{Sys.Owner{_,_,_,_,cursor,Local.Local{Body.User{userToken,runs},Buffer.Buffer{pending,receipts},_}}},Sys.Owner{_,_,_,_,peerCursor,peer}},_,Handler{handler,errors},_},_,_,_,Schedule.Deferred{_,_,unapplied}}:prefix ++ "|world=" ++ world(~S,owner) ++ "|queue=" ++ List.show(&2,Record,record_text(~S),entries(~S,pending)) ++ "|receipts=" ++ List.show(&2,Record,record_text(~S),receipt_records(~S,receipts)) ++ "|user=" ++ token_value(~S,Array.get(U32,userToken,0)) ++ ":" ++ U32.show(runs) ++ "|cursor=" ++ Tick.cursor_show(cursor) ++ "|peer=" ++ token_value(~S,Array.get(U32,peer,0)) ++ ":" ++ Tick.cursor_show(peerCursor) ++ "|handler=" ++ token_value(~S,Array.get(U32,handler,0)) ++ ":" ++ U32.show(errors) ++ "|unapplied=" ++ List.show(&2,U32,U32.show,unapplied)
def pending_observed(~S:Data,~mode:Query.Mode,prefix:String,result:Application(~S,~mode) & Bool) -> String:
  match result:
    case (application,pending):observed(~S,~mode,prefix ++ ";exact-pending=" ++ Bool.pick(String,pending,"true","false"),application)
def selected(~S:Data,~mode:Query.Mode,native:Bool,app:Application(~S,~mode)) -> IO(Application(~S,~mode) & DepApp.Report<String,String>):
  match native:
    case False{}:Schedule.run_serial(~S,~Left(~S),~Unit,~D.Resources(~S),~Unit,~Unit,~resources(),~{==},~String,~String,~Author(~S,~mode),~Peer(~S),~left(~S,~mode),~right(~S),~Unit,~Handler,~Conditions.empty_dispatch(~W.World<S,Store(~S),Resources(~S),Unit>,~String),~Conditions.empty(~W.World<S,Store(~S),Resources(~S),Unit>,~String),~handle(~S),app)
    case True{}:Schedule.run_native(~S,~Left(~S),~Unit,~D.Resources(~S),~Unit,~Unit,~resources(),~{==},~String,~String,~Author(~S,~mode),~Peer(~S),~left(~S,~mode),~right(~S),~Unit,~Handler,~Conditions.empty_dispatch(~W.World<S,Store(~S),Resources(~S),Unit>,~String),~Conditions.empty(~W.World<S,Store(~S),Resources(~S),Unit>,~String),~handle(~S),app)
def second(~S:Data,~mode:Query.Mode,native:Bool,prefix:String,result:Application(~S,~mode) & DepApp.Report<String,String>) -> String:
  match result:
    case (app,done):pending_observed(~S,~mode,prefix ++ ";" ++ report(~S,done),Schedule.pending(~S,~Left(~S),~Unit,~D.Resources(~S),~Unit,~Unit,~resources(),~{==},~String,~String,~Author(~S,~mode),~Peer(~S),~left(~S,~mode),~right(~S),~Unit,~Handler,~Conditions.empty_dispatch(~W.World<S,Store(~S),Resources(~S),Unit>,~String),~Conditions.empty(~W.World<S,Store(~S),Resources(~S),Unit>,~String),~handle(~S),app))
def first(~S:Data,~mode:Query.Mode,+native:Bool,result:Application(~S,~mode) & DepApp.Report<String,String>) -> IO(String):
  match result:
    case (app,done):IO.bind(Application(~S,~mode) & DepApp.Report<String,String>,String,selected(~S,~mode,native,app),result => IO.pure(String,second(~S,~mode,native,report(~S,done),result)))
def built(~S:Data,~mode:Query.Mode,settings:Settings.Settings,+native:Bool,world:W.World<S,Store(~S),Resources(~S),Unit>,author:Author(~S,~mode),peer:Peer(~S)) -> IO(String):
  IO.bind(Application(~S,~mode) & DepApp.Report<String,String>,String,selected(~S,~mode,native,Schedule.configure(~(DepApp.State<W.World<S,Store(~S),Resources(~S),Unit>,Product.Owner<Author(~S,~mode),Peer(~S)>,Unit,Handler>),settings,Schedule.build(~S,~Left(~S),~Unit,~D.Resources(~S),~Unit,~Unit,~resources(),~{==},~String,~String,~Author(~S,~mode),~Peer(~S),~left(~S,~mode),~right(~S),~Unit,~Handler,~Conditions.empty_dispatch(~W.World<S,Store(~S),Resources(~S),Unit>,~String),~Conditions.empty(~W.World<S,Store(~S),Resources(~S),Unit>,~String),~handle(~S),~(name => True{}),world,Product.Owner{author,peer},Unit{},Handler{ALeaf{901},0},[],[]))),result => first(~S,~mode,native,result))

def peer_defined(~S:Data,~mode:Query.Mode,settings:Settings.Settings,native:Bool,author:Author(~S,~mode),result:Sys.Defined<W.World<S,Store(~S),Resources(~S),Unit>,Peer(~S),Array<U32>>) -> IO(String):
  match result:
    case Sys.Defined{world,peer}:built(~S,~mode,settings,native,world,author,peer)
    case Sys.DefinitionRefused{_,_}:IO.pure(String,"ERROR: peer definition")
def author_defined(~S:Data,~mode:Query.Mode,settings:Settings.Settings,native:Bool,result:Sys.Defined<W.World<S,Store(~S),Resources(~S),Unit>,Author(~S,~mode),Cmd.Captures(~S,~layout(~S),~resources(),~path(~S),~AuthorLocal(~S))>) -> IO(String):
  match result:
    case Sys.Defined{world,author}:peer_defined(~S,~mode,settings,native,author,Task.define(~S,~Store(~S),~Unit,~Unit,~Unit,~PeerOps(~S),~Array<U32>,~String,~String,~peer_declaration(~S),~peer_body(~S),~Resources(~S),world,"peer",ALeaf{801}))
    case Sys.DefinitionRefused{_,_}:IO.pure(String,"ERROR: author definition")
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
def created(~S:Data,~mode:Query.Mode,settings:Settings.Settings,native:Bool,result:W.Creation<S,Store(~S),Resources(~S),Unit>) -> IO(String):
  match result:
    case W.Created{_,world}:author_defined(~S,~mode,settings,native,Cmd.define(~S,~Left(~S),~D.Resources(~S),~Unit,~layout(~S),~resources(),~path(~S),~{==},~Ops(~S),~AuthorLocal(~S),~String,~String,~author_declaration(~S,~mode),~Body.run(~S),~Resources(~S),spawn(~S,18n,world),"author",Body.User{ALeaf{900},0}))
    case W.CreateRejected{_,_}:IO.pure(String,"ERROR: creation")
def run_mode(~S:Data,~mode:Query.Mode,settings:Settings.Settings,native:Bool) -> IO(String):
  created(~S,~mode,settings,native,W.create(~S,~Store(~S),~Resources(~S),~Unit,~empty(~S),W.factory(),Product.Owner{D.resource(~S),Unit{}}))

def run(~S:Data,settings:Settings.Settings,native:Bool) -> IO(String):
  run_mode(~S,~Query.Parallel{},settings,native)
