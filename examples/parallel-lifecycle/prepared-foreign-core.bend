import Base
import ./notice-observation.bend as NoticeObserve
import ../../src/ecs/execution-lifecycle-notices.bend as Notice
import ../../src/ecs/entity-allocator.bend as Allocator
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/deferred-command.bend as Deferred
import ../../src/ecs/dependency-executor.bend as Exec
import ../parallel-query/commands-core.bend as Core
import ../parallel-query/declarations.bend as D
import ../parallel-query/command-body.bend as Body
import ../parallel-query/payloads.bend as P
import ../parallel-query/observation.bend as Observe
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/execution-command-removed.bend as Removed
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-command-scope.bend as Scope
import ../../src/ecs/execution-parallel-rootcut.bend as Root
import ../../src/ecs/execution-prepared.bend as Prep
import ../../src/ecs/execution-parallel-schedule.bend as Ready
import ../../src/ecs/execution-state.bend as State
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-query.bend as Query
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/world.bend as W
import ../../src/ecs/owner-product.bend as Product

type First is Data:
  First{}
type Second is Data:
  Second{}
def Runtime(~S:Data) -> Type:W.World<S,Core.Store(~S),Core.Resources(~S),Unit>
def Owner(~S:Data) -> Type:Core.Author(~S,~Query.Parallel{})
def ScopeOwner(~S:Data) -> Type:State.Scope<S,Core.Left(~S),D.Resources(~S)>
def Prepared(~S:Data) -> Type:Prep.Prepared<Runtime(~S),Owner(~S),Prep.Permit<S,Core.Store(~S)>>
def Attempt(~S:Data) -> Type:Prep.Invocation<ScopeOwner(~S),Runtime(~S),Owner(~S),Prep.Permit<S,Core.Store(~S)>,List<&2,Ready.Completed<String,String>>>
def narrow(~S:Data,value:State.Scope<S,Core.Store(~S),Core.Resources(~S)>) -> ScopeOwner(~S):
  match value:
    case State.Scope{Product.Owner{store,Unit{}},Product.Owner{resource,Unit{}},handles,tick,prior,lifecycle}:State.Scope{store,resource,handles,tick,prior,lifecycle}
def widen(~S:Data,value:ScopeOwner(~S)) -> State.Scope<S,Core.Store(~S),Core.Resources(~S)>:
  match value:
    case State.Scope{store,resource,handles,tick,prior,lifecycle}:State.Scope{Product.Owner{store,Unit{}},Product.Owner{resource,Unit{}},handles,tick,prior,lifecycle}
def owner_token(~S:Data,+namespace:U32,+id:U32,+name:String,+access:List<&2,String>,+cursor:Maybe<&2,Tick.Tick>,+runs:U32,commands:Buffer.Buffer<S,P.Output,Removed.Removed(Core.layout(~S))>,permission:Permission.Permission,pending:Bool,result:Array<U32> & U32) -> Owner(~S) & String:
  match result:
    case (token,value):(Cmd.Owner{Sys.Owner{namespace,id,name,access,cursor,Local.Local{Body.User{token,runs},commands,permission}}},U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x=>x,access) ++ ":" ++ Tick.cursor_show(cursor) ++ ":" ++ U32.show(value) ++ ":" ++ U32.show(runs) ++ ":" ++ Bool.show(pending))
def owner_pending(~S:Data,namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:Maybe<&2,Tick.Tick>,token:Array<U32>,runs:U32,permission:Permission.Permission,result:Buffer.Buffer<S,P.Output,Removed.Removed(Core.layout(~S))> & Bool) -> Owner(~S) & String:
  match result:
    case (commands,pending):owner_token(~S,namespace,id,name,access,cursor,runs,commands,permission,pending,Array.get(U32,token,0))
def owner_observed(~S:Data,value:Owner(~S)) -> Owner(~S) & String:
  match value:
    case Cmd.Owner{Sys.Owner{namespace,id,name,access,cursor,Local.Local{Body.User{token,runs},commands,permission}}}:owner_pending(~S,namespace,id,name,access,cursor,token,runs,permission,Buffer.pending(~S,~P.Output,~Removed.Removed(Core.layout(~S)),commands))
def prepared_observed(~S:Data,namespace:U32,permits:List<&2,Prep.Permit<S,Core.Store(~S)>>,tree:Prep.Provenance<Prep.Permit<S,Core.Store(~S)>>,result:Owner(~S) & String) -> Prepared(~S) & String:
  match result:
    case (owner,text):(Prep.Prepared{namespace,owner,permits,tree},text)
def observe_prepared(~S:Data,value:Prepared(~S)) -> Prepared(~S) & String:
  match value:
    case Prep.Prepared{namespace,owner,permits,tree}:prepared_observed(~S,namespace,permits,tree,owner_observed(~S,owner))
def invocation_text(value:Exec.Invocation<String,String>) -> String:
  match value:
    case Exec.Completed{out}:"done:" ++ out
    case Exec.BodyError{error,out}:"error:" ++ error ++ ":" ++ out
    case Exec.AdmissionRefused{}:"admission-refused"
def completion_text(value:Ready.Completed<String,String>) -> String:
  match value:
    case Ready.Completed{id,result}:U32.show(id) ++ ":" ++ invocation_text(result)
def world_returned(~S:Data,namespace:U32,allocator:Allocator.Allocator,store:Core.Store(~S),resource:Core.Resources(~S),events:List<&2,Unit>,pending:List<Deferred.Command<Runtime(~S)>>,registrations:List<&2,W.RegistrationMeta>,next:U32,clock:Clock.State,result:Notice.Journal<S> & String) -> String:
  match result:
    case (journal,text):Core.world(~S,W.World{namespace,allocator,store,resource,events,pending,registrations,next,clock,journal}) ++ ";journal={" ++ text ++ "}"
def observed_world(~S:Data,value:Runtime(~S)) -> String:
  match value:
    case W.World{namespace,allocator,store,resource,events,pending,registrations,next,clock,journal}:world_returned(~S,namespace,allocator,store,resource,events,pending,registrations,next,clock,NoticeObserve.journal(~S,journal))
def final_owner(~S:Data,prefix:String,world:Runtime(~S),foreign:Runtime(~S),value:Owner(~S)) -> String:
  match value:
    case Cmd.Owner{Sys.Owner{namespace,id,name,access,cursor,Local.Local{Body.User{token,runs},Buffer.Buffer{pending,receipts},_}}}:prefix ++ ";owner=" ++ U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x=>x,access) ++ ":" ++ Tick.cursor_show(cursor) ++ ":" ++ Core.token_value(~S,Array.get(U32,token,0)) ++ ":" ++ U32.show(runs) ++ ";queue=" ++ List.show(&2,Core.Record,Core.record_text(~S),Core.entries(~S,pending)) ++ ";receipts=" ++ List.show(&2,Core.Record,Core.record_text(~S),Core.receipt_records(~S,receipts)) ++ ";original={" ++ observed_world(~S,world) ++ "};foreign={" ++ observed_world(~S,foreign) ++ "}"
def retried(~S:Data,prefix:String,admin:State.Administration<S,Core.Store(~S),Core.Resources(~S),Unit>,foreign:Runtime(~S),result:Attempt(~S)) -> String:
  match result:
    case Prep.Invoked{scope,Prep.Prepared{_,owner,permits,_},status}:final_owner(~S,prefix ++ ";retry=invoked;retry-status=" ++ List.show(&2,Ready.Completed<String,String>,completion_text,status),Root.leave(~S,~Core.Store(~S),~Core.Resources(~S),~Unit,permits,State.reassemble(~S,~Core.Store(~S),~Core.Resources(~S),~Unit,admin,widen(~S,scope))),foreign,owner)
    case Prep.InvocationRefused{scope,Prep.Prepared{_,owner,permits,_},_}:final_owner(~S,prefix ++ ";retry=refused",Root.leave(~S,~Core.Store(~S),~Core.Resources(~S),~Unit,permits,State.reassemble(~S,~Core.Store(~S),~Core.Resources(~S),~Unit,admin,widen(~S,scope))),foreign,owner)
    case Prep.InvocationInventoryRefused{scope,Prep.Inventory{owner,tree},_}:final_owner(~S,prefix ++ ";retry=inventory-refused",Root.leave(~S,~Core.Store(~S),~Core.Resources(~S),~Unit,Prep.permits(~Prep.Permit<S,Core.Store(~S)>,tree),State.reassemble(~S,~Core.Store(~S),~Core.Resources(~S),~Unit,admin,widen(~S,scope))),foreign,owner)
def retry_observed(~S:Data,prefix:String,admin:State.Administration<S,Core.Store(~S),Core.Resources(~S),Unit>,foreign:Runtime(~S),scope:ScopeOwner(~S),result:Prepared(~S) & String) -> String:
  match result:
    case (prepared,text):retried(~S,prefix ++ ";retained=" ++ text,admin,foreign,Scope.invoke(~S,~Core.Store(~S),~Core.Left(~S),~D.Resources(~S),~Unit,~Core.layout(~S),~Core.path(~S),~Core.Ops(~S),~Core.AuthorLocal(~S),~String,~String,~Core.author_declaration(~S,~Query.Parallel{}),~Body.run(~S),~Core.Resources(~S),~{==},scope,prepared))
def foreign_returned(~S:Data,admin:State.Administration<S,Core.Store(~S),Core.Resources(~S),Unit>,foreignAdmin:State.Administration<S,Core.Store(~S),Core.Resources(~S),Unit>,original:ScopeOwner(~S),result:Attempt(~S)) -> String:
  match result:
    case Prep.InvocationRefused{foreign,prepared,status}:retry_observed(~S,"foreign=refused;foreign-status=" ++ List.show(&2,Ready.Completed<String,String>,completion_text,status),admin,State.reassemble(~S,~Core.Store(~S),~Core.Resources(~S),~Unit,foreignAdmin,widen(~S,foreign)),original,observe_prepared(~S,prepared))
    case Prep.Invoked{foreign,Prep.Prepared{_,owner,permits,_},_}:final_owner(~S,"ERROR: foreign invoked",Root.leave(~S,~Core.Store(~S),~Core.Resources(~S),~Unit,permits,State.reassemble(~S,~Core.Store(~S),~Core.Resources(~S),~Unit,admin,widen(~S,original))),State.reassemble(~S,~Core.Store(~S),~Core.Resources(~S),~Unit,foreignAdmin,widen(~S,foreign)),owner)
    case Prep.InvocationInventoryRefused{foreign,Prep.Inventory{owner,tree},_}:final_owner(~S,"ERROR: foreign inventory",Root.leave(~S,~Core.Store(~S),~Core.Resources(~S),~Unit,Prep.permits(~Prep.Permit<S,Core.Store(~S)>,tree),State.reassemble(~S,~Core.Store(~S),~Core.Resources(~S),~Unit,admin,widen(~S,original))),State.reassemble(~S,~Core.Store(~S),~Core.Resources(~S),~Unit,foreignAdmin,widen(~S,foreign)),owner)
def foreign_separated(~S:Data,admin:State.Administration<S,Core.Store(~S),Core.Resources(~S),Unit>,original:ScopeOwner(~S),prepared:Prepared(~S),result:State.Administration<S,Core.Store(~S),Core.Resources(~S),Unit> & State.Scope<S,Core.Store(~S),Core.Resources(~S)>) -> String:
  match result:
    case (foreignAdmin,foreign):foreign_returned(~S,admin,foreignAdmin,original,Scope.invoke(~S,~Core.Store(~S),~Core.Left(~S),~D.Resources(~S),~Unit,~Core.layout(~S),~Core.path(~S),~Core.Ops(~S),~Core.AuthorLocal(~S),~String,~String,~Core.author_declaration(~S,~Query.Parallel{}),~Body.run(~S),~Core.Resources(~S),~{==},narrow(~S,foreign),prepared))
def foreign_clocked(~S:Data,admin:State.Administration<S,Core.Store(~S),Core.Resources(~S),Unit>,scope:ScopeOwner(~S),prepared:Prepared(~S),result:Runtime(~S) & Tick.Tick) -> String:
  match result:
    case (foreign,tick):foreign_separated(~S,admin,scope,prepared,State.separate(~S,~Core.Store(~S),~Core.Resources(~S),~Unit,foreign,tick))
def original_separated(~S:Data,foreign:Runtime(~S),prepared:Prepared(~S),result:State.Administration<S,Core.Store(~S),Core.Resources(~S),Unit> & State.Scope<S,Core.Store(~S),Core.Resources(~S)>) -> String:
  match result:
    case (admin,scope):foreign_clocked(~S,admin,narrow(~S,scope),prepared,W.execution_clock(~S,~Core.Store(~S),~Core.Resources(~S),~Unit,foreign))
def original_clocked(~S:Data,foreign:Runtime(~S),prepared:Prepared(~S),result:Runtime(~S) & Tick.Tick) -> String:
  match result:
    case (world,tick):original_separated(~S,foreign,prepared,State.separate(~S,~Core.Store(~S),~Core.Resources(~S),~Unit,world,tick))
def prepared(~S:Data,foreign:Runtime(~S),result:Runtime(~S) & Prepared(~S)) -> String:
  match result:
    case (world,prepared):original_clocked(~S,foreign,prepared,W.execution_clock(~S,~Core.Store(~S),~Core.Resources(~S),~Unit,world))
def defined(~S:Data,foreign:Runtime(~S),result:Sys.Defined<Runtime(~S),Owner(~S),Cmd.Captures(~S,~Core.layout(~S),~Core.path(~S),~Core.AuthorLocal(~S))>) -> String:
  match result:
    case Sys.Defined{world,Cmd.Owner{Sys.Owner{namespace,+id,name,access,cursor,local}}}:prepared(~S,foreign,Scope.prepare(~S,~Core.Store(~S),~Core.Left(~S),~D.Resources(~S),~Unit,~Core.layout(~S),~Core.path(~S),~Core.Ops(~S),~Core.AuthorLocal(~S),~String,~String,~Core.author_declaration(~S,~Query.Parallel{}),~Body.run(~S),~Core.Resources(~S),~{==},[id],world,Cmd.Owner{Sys.Owner{namespace,id,name,access,cursor,local}}))
    case Sys.DefinitionRefused{_,_}:"ERROR: definition"
def run(~S:Data,world:Runtime(~S),foreign:Runtime(~S)) -> String:
  defined(~S,Core.spawn(~S,18n,foreign),Cmd.define(~S,~Core.Left(~S),~D.Resources(~S),~Unit,~Core.layout(~S),~Core.path(~S),~{==},~Core.Ops(~S),~Core.AuthorLocal(~S),~String,~String,~Core.author_declaration(~S,~Query.Parallel{}),~Body.run(~S),~Core.Resources(~S),Core.spawn(~S,18n,world),"prepared-author",Body.User{ALeaf{900},0}))
def first(world:Runtime(~First),foreign:Runtime(~First)) -> String:run(~First,world,foreign)
def second(world:Runtime(~Second),foreign:Runtime(~Second)) -> String:run(~Second,world,foreign)
