import Base
import ./execution-builder.bend as Build
import ./execution-query-interpreter.bend as Interpret
import ./execution-query-admission.bend as Admit
import ./execution-query-recipe.bend as Recipe
import ./execution-query-domain.bend as Domain
import ./execution-query-schema.bend as Schema
import ./execution-query-store.bend as Store
import ./execution-composer-layout.bend as L
import ./world.bend as W
import ./entity-allocator.bend as Allocator
import ./deferred-command.bend as Deferred
import ./clock-state.bend as Clock
import ./change-tick.bend as Tick
import ./execution-lifecycle-notices.bend as Notice
import ./execution-declaration.bend as D
import ./execution-prepared.bend as Prep
import ./execution-system.bend as Sys
import ./execution-parallel-scope.bend as Scope
import ./execution-parallel-system.bend as Task
import ./execution-state.bend as State
import ./execution-parallel-schedule.bend as Ready
import ./execution-compiled-binding.bend as Binding
import ./execution-reservation-task.bend as Effect
import ./execution-reservation-permit.bend as RuntimePermit

# The closed Program brands the symbolic and dynamic evidence together. These
# framework records are built only from actual World handles and storage.
type Evidence<-S:Data,-full:L.Layout,-C:Type,-R:Type,-Ops:Data -> Type -> Type,-program:Build.FrameworkProgram(~S,~L.columns(~S,full),~C,~R,~Ops)> is Data:
  Evidence{namespace:U32,handles:List<&2,W.Handle<S>>,recipes:List<&2,Recipe.Recipe<S,L.columns(~S,full)>>,info:List<&2,Schema.Info>,grants:List<&2,Admit.Granted<S,L.columns(~S,full)>>,book:Schema.Book<S,full>}
type Inspection<-World:Type,-Evidence:Data,-Compilation:Type> is Type:
  Inspected{world:World,compilation:Compilation,evidence:Evidence}
  InspectionRefused{world:World,compilation:Compilation}
def lowered(~S:Data,~full:L.Layout,~C:Type,~R:Type,~E:Data,~WR:Type,~Ops:Data -> Type -> Type,~program:Build.FrameworkProgram(~S,~L.columns(~S,full),~C,~R,~Ops),compilation:D.Compilation<S,L.columns(~S,full),C,R,Ops>,world:W.World<S,L.columns(~S,full),WR,E>,namespace:U32,handles:List<&2,W.Handle<S>>,recipes:List<&2,Recipe.Recipe<S,L.columns(~S,full)>>,info:List<&2,Schema.Info>,result:Admit.Lowering<S,L.columns(~S,full),full>) -> Inspection<W.World<S,L.columns(~S,full),WR,E>,Evidence<S,full,C,R,Ops,program>,D.Compilation<S,L.columns(~S,full),C,R,Ops>>:
  match result:
    case Admit.LoweringRefused{}:InspectionRefused{world,compilation}
    case Admit.Lowered{grants,book}:Inspected{world,compilation,Evidence{namespace,handles,recipes,info,grants,book}}
def supported(~S:Data,~full:L.Layout,~C:Type,~R:Type,~E:Data,~WR:Type,~Ops:Data -> Type -> Type,~program:Build.FrameworkProgram(~S,~L.columns(~S,full),~C,~R,~Ops),world:W.World<S,L.columns(~S,full),WR,E>,+namespace:U32,+handles:List<&2,W.Handle<S>>,+info:List<&2,Schema.Info>,valid:Bool,compilation:D.Compilation<S,L.columns(~S,full),C,R,Ops>) -> Inspection<W.World<S,L.columns(~S,full),WR,E>,Evidence<S,full,C,R,Ops,program>,D.Compilation<S,L.columns(~S,full),C,R,Ops>>:
  match valid compilation:
    case False{} compilation:InspectionRefused{world,compilation}
    case True{} D.Unsupported{caps,access,recipes}:InspectionRefused{world,D.Unsupported{caps,access,recipes}}
    case True{} D.Supported{declaration,D.Recipes{+recipes,resources}}:lowered(~S,~full,~C,~R,~E,~WR,~Ops,~program,D.Supported{declaration,D.Recipes{recipes,resources}},world,namespace,handles,recipes,info,Admit.lower(~S,~L.columns(~S,full),~full,~{==},recipes,info,namespace,handles))
def described(~S:Data,~full:L.Layout,~C:Type,~R:Type,~E:Data,~WR:Type,~Ops:Data -> Type -> Type,~program:Build.FrameworkProgram(~S,~L.columns(~S,full),~C,~R,~Ops),compilation:D.Compilation<S,L.columns(~S,full),C,R,Ops>,+namespace:U32,allocator:Allocator.Allocator,resource:WR,events:List<&2,E>,pending:List<Deferred.Command<W.World<S,L.columns(~S,full),WR,E>>>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:Clock.State,lifecycle:Notice.Journal<S>,handles:List<&2,W.Handle<S>>,result:Schema.Description<S,full>) -> Inspection<W.World<S,L.columns(~S,full),WR,E>,Evidence<S,full,C,R,Ops,program>,D.Compilation<S,L.columns(~S,full),C,R,Ops>>:
  match result:
    case Schema.Description{columns,info,valid}:supported(~S,~full,~C,~R,~E,~WR,~Ops,~program,W.World{namespace,allocator,columns,resource,events,pending,registrations,nextSystemId,clock,lifecycle},namespace,handles,info,valid,compilation)
def captured(~S:Data,~full:L.Layout,~C:Type,~R:Type,~E:Data,~WR:Type,~Ops:Data -> Type -> Type,~program:Build.FrameworkProgram(~S,~L.columns(~S,full),~C,~R,~Ops),compilation:D.Compilation<S,L.columns(~S,full),C,R,Ops>,result:W.World<S,L.columns(~S,full),WR,E> & List<&2,W.Handle<S>>) -> Inspection<W.World<S,L.columns(~S,full),WR,E>,Evidence<S,full,C,R,Ops,program>,D.Compilation<S,L.columns(~S,full),C,R,Ops>>:
  match result:
    case (W.World{namespace,allocator,columns,resource,events,pending,registrations,nextSystemId,clock,lifecycle},handles):described(~S,~full,~C,~R,~E,~WR,~Ops,~program,compilation,namespace,allocator,resource,events,pending,registrations,nextSystemId,clock,lifecycle,handles,Schema.describe(~S,full,L.AtLeaf{},columns))
def inspect_with_compilation(~S:Data,~full:L.Layout,~C:Type,~R:Type,~E:Data,~WR:Type,~Ops:Data -> Type -> Type,~program:Build.FrameworkProgram(~S,~L.columns(~S,full),~C,~R,~Ops),compilation:D.Compilation<S,L.columns(~S,full),C,R,Ops>,world:W.World<S,L.columns(~S,full),WR,E>) -> Inspection<W.World<S,L.columns(~S,full),WR,E>,Evidence<S,full,C,R,Ops,program>,D.Compilation<S,L.columns(~S,full),C,R,Ops>>:
  captured(~S,~full,~C,~R,~E,~WR,~Ops,~program,compilation,W.handles(~S,~L.columns(~S,full),~WR,~E,world))


def inspected(~S:Data,~full:L.Layout,~C:Type,~R:Type,~E:Data,~WR:Type,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~program:Build.FrameworkProgram(~S,~L.columns(~S,full),~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),ids:List<&2,U32>,owner:Sys.Owner<S,L.columns(~S,full),C,R,E,Ops,Local,Error,Out,program,body>,result:Inspection<W.World<S,L.columns(~S,full),WR,E>,Evidence<S,full,C,R,Ops,program>,D.Compilation<S,L.columns(~S,full),C,R,Ops>>) -> Binding.Preparation<D.Compilation<S,L.columns(~S,full),C,R,Ops>,W.World<S,L.columns(~S,full),WR,E>,Sys.Owner<S,L.columns(~S,full),C,R,E,Ops,Local,Error,Out,program,body>,Maybe<&2,Evidence<S,full,C,R,Ops,program>>,Prep.Permit<S,L.columns(~S,full)>>:
  match result:
    case InspectionRefused{world,compilation}:Binding.Refused{world,compilation,Prep.Inventory{owner,Prep.Unprepared{}},None{}}
    case Inspected{world,compilation,evidence}:Binding.prepared(~D.Compilation<S,L.columns(~S,full),C,R,Ops>,~W.World<S,L.columns(~S,full),WR,E>,~Sys.Owner<S,L.columns(~S,full),C,R,E,Ops,Local,Error,Out,program,body>,~Maybe<&2,Evidence<S,full,C,R,Ops,program>>,~Prep.Permit<S,L.columns(~S,full)>,Some{evidence},Scope.prepare_with_compilation(~S,~L.columns(~S,full),~C,~R,~E,~Ops,~Local,~Error,~Out,~program,~body,~WR,compilation,ids,world,owner))
def prepare_with_compilation(~S:Data,~full:L.Layout,~C:Type,~R:Type,~E:Data,~WR:Type,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~program:Build.FrameworkProgram(~S,~L.columns(~S,full),~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),compilation:D.Compilation<S,L.columns(~S,full),C,R,Ops>,ids:List<&2,U32>,world:W.World<S,L.columns(~S,full),WR,E>,owner:Sys.Owner<S,L.columns(~S,full),C,R,E,Ops,Local,Error,Out,program,body>) -> Binding.Preparation<D.Compilation<S,L.columns(~S,full),C,R,Ops>,W.World<S,L.columns(~S,full),WR,E>,Sys.Owner<S,L.columns(~S,full),C,R,E,Ops,Local,Error,Out,program,body>,Maybe<&2,Evidence<S,full,C,R,Ops,program>>,Prep.Permit<S,L.columns(~S,full)>>:
  inspected(~S,~full,~C,~R,~E,~WR,~Ops,~Local,~Error,~Out,~program,~body,ids,owner,inspect_with_compilation(~S,~full,~C,~R,~E,~WR,~Ops,~program,compilation,world))
def view_namespace(~S:Data,view:Notice.View<S>) -> U32:
  match view:
    case Notice.View{namespace,_,_}:namespace
def same_handles(~S:Data,left:List<&2,W.Handle<S>>,right:List<&2,W.Handle<S>>) -> Bool:
  match left right:
    case [], []:True{}
    case lh <> lt, rh <> rt:Bool.and(State.same(~S,lh,rh),same_handles(~S,lt,rt))
    case _ _:False{}
def same_offsets(left:List<&2,U32>,right:List<&2,U32>) -> Bool:
  match left right:
    case [], []:True{}
    case lh <> lt, rh <> rt:Bool.and(U32.is_eq(lh,rh),same_offsets(lt,rt))
    case _ _:False{}
def same_info(left:List<&2,Schema.Info>,right:List<&2,Schema.Info>) -> Bool:
  match left right:
    case [], []:True{}
    case Schema.Info{lr,lc,Domain.Domain{lp}} <> lt, Schema.Info{rr,rc,Domain.Domain{rp}} <> rt:Bool.and(Schema.same_route(lr,rr),Bool.and(U32.is_eq(lc,rc),Bool.and(same_offsets(lp,rp),same_info(lt,rt))))
    case _ _:False{}
def same_grants(~S:Data,~WC:Type,left:List<&2,Admit.Granted<S,WC>>,right:List<&2,Admit.Granted<S,WC>>) -> Bool:
  match left right:
    case [], []:True{}
    case Admit.Granted{le,lh} <> lt, Admit.Granted{re,rh} <> rt:Bool.and(Admit.same_entry(le,re),Bool.and(same_handles(~S,lh,rh),same_grants(~S,~WC,lt,rt)))
    case _ _:False{}
def invoke_checked(~S:Data,~full:L.Layout,~C:Type,~R:Type,~E:Data,~WR:Type,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~program:Build.FrameworkProgram(~S,~L.columns(~S,full),~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~compiledCaps:Ops(Effect.Granted,State.Scope<S,C,R>),~grant_of_caps:Ops(Effect.Granted,State.Scope<S,C,R>) -> Ops(Effect.Granted,State.Scope<S,C,R>) & RuntimePermit.Grant,scope:State.Scope<S,C,R>,binding:Binding.Binding<D.Compilation<S,L.columns(~S,full),C,R,Ops>,W.World<S,L.columns(~S,full),WR,E>,Sys.Owner<S,L.columns(~S,full),C,R,E,Ops,Local,Error,Out,program,body>,Maybe<&2,Evidence<S,full,C,R,Ops,program>>,Prep.Permit<S,L.columns(~S,full)>>,valid:Bool) -> Effect.Task<S,RuntimePermit.Permit,Binding.Invocation<D.Compilation<S,L.columns(~S,full),C,R,Ops>,State.Scope<S,C,R>,W.World<S,L.columns(~S,full),WR,E>,Sys.Owner<S,L.columns(~S,full),C,R,E,Ops,Local,Error,Out,program,body>,Maybe<&2,Evidence<S,full,C,R,Ops,program>>,Prep.Permit<S,L.columns(~S,full)>,List<&2,Ready.Completed<Error,Out>>>>:
  match binding valid:
    case binding False{}:Effect.TDone{Binding.InvocationRefused{scope,binding,[]}}
    case Binding.Binding{compilation,prepared,evidence} True{}:Sys.map(S,RuntimePermit.Permit,D.Compilation<S,L.columns(~S,full),C,R,Ops> & Prep.Invocation<State.Scope<S,C,R>,W.World<S,L.columns(~S,full),WR,E>,Sys.Owner<S,L.columns(~S,full),C,R,E,Ops,Local,Error,Out,program,body>,Prep.Permit<S,L.columns(~S,full)>,List<&2,Ready.Completed<Error,Out>>>,Binding.Invocation<D.Compilation<S,L.columns(~S,full),C,R,Ops>,State.Scope<S,C,R>,W.World<S,L.columns(~S,full),WR,E>,Sys.Owner<S,L.columns(~S,full),C,R,E,Ops,Local,Error,Out,program,body>,Maybe<&2,Evidence<S,full,C,R,Ops,program>>,Prep.Permit<S,L.columns(~S,full)>,List<&2,Ready.Completed<Error,Out>>>,Scope.invoke_with_compilation(~S,~L.columns(~S,full),~C,~R,~E,~Ops,~Local,~Error,~Out,~program,~body,~WR,~compiledCaps,~grant_of_caps,compilation,scope,prepared),result => Binding.invoked(~D.Compilation<S,L.columns(~S,full),C,R,Ops>,~State.Scope<S,C,R>,~W.World<S,L.columns(~S,full),WR,E>,~Sys.Owner<S,L.columns(~S,full),C,R,E,Ops,Local,Error,Out,program,body>,~Maybe<&2,Evidence<S,full,C,R,Ops,program>>,~Prep.Permit<S,L.columns(~S,full)>,~List<&2,Ready.Completed<Error,Out>>,evidence,result))
def whole_described(~S:Data,~full:L.Layout,~R:Type,~E:Data,~WR:Type,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~program:Build.FrameworkProgram(~S,~L.columns(~S,full),~L.columns(~S,full),~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~compiledCaps:Ops(Effect.Granted,State.Scope<S,L.columns(~S,full),R>),~grant_of_caps:Ops(Effect.Granted,State.Scope<S,L.columns(~S,full),R>) -> Ops(Effect.Granted,State.Scope<S,L.columns(~S,full),R>) & RuntimePermit.Grant,resource:R,+handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,+view:Notice.View<S>,binding:Binding.Binding<D.Compilation<S,L.columns(~S,full),L.columns(~S,full),R,Ops>,W.World<S,L.columns(~S,full),WR,E>,Sys.Owner<S,L.columns(~S,full),L.columns(~S,full),R,E,Ops,Local,Error,Out,program,body>,Maybe<&2,Evidence<S,full,L.columns(~S,full),R,Ops,program>>,Prep.Permit<S,L.columns(~S,full)>>,result:Schema.Description<S,full>) -> Effect.Task<S,RuntimePermit.Permit,Binding.Invocation<D.Compilation<S,L.columns(~S,full),L.columns(~S,full),R,Ops>,State.Scope<S,L.columns(~S,full),R>,W.World<S,L.columns(~S,full),WR,E>,Sys.Owner<S,L.columns(~S,full),L.columns(~S,full),R,E,Ops,Local,Error,Out,program,body>,Maybe<&2,Evidence<S,full,L.columns(~S,full),R,Ops,program>>,Prep.Permit<S,L.columns(~S,full)>,List<&2,Ready.Completed<Error,Out>>>>:
  match binding result:
    case Binding.Binding{compilation,prepared,None{}} Schema.Description{columns,_,_}:Effect.TDone{Binding.InvocationRefused{State.Scope{columns,resource,handles,tick,prior,view},Binding.Binding{compilation,prepared,None{}},[]}}
    case Binding.Binding{compilation,prepared,Some{Evidence{+namespace,+captured,recipes,+expected,grants,book}}} Schema.Description{columns,info,valid}:invoke_checked(~S,~full,~L.columns(~S,full),~R,~E,~WR,~Ops,~Local,~Error,~Out,~program,~body,~compiledCaps,~grant_of_caps,State.Scope{columns,resource,handles,tick,prior,view},Binding.Binding{compilation,prepared,Some{Evidence{namespace,captured,recipes,expected,grants,book}}},Bool.and(valid,Bool.and(U32.is_eq(view_namespace(~S,view),namespace),Bool.and(same_handles(~S,handles,captured),same_info(info,expected)))))
def invoke_whole(~S:Data,~full:L.Layout,~R:Type,~E:Data,~WR:Type,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~program:Build.FrameworkProgram(~S,~L.columns(~S,full),~L.columns(~S,full),~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~compiledCaps:Ops(Effect.Granted,State.Scope<S,L.columns(~S,full),R>),~grant_of_caps:Ops(Effect.Granted,State.Scope<S,L.columns(~S,full),R>) -> Ops(Effect.Granted,State.Scope<S,L.columns(~S,full),R>) & RuntimePermit.Grant,scope:State.Scope<S,L.columns(~S,full),R>,binding:Binding.Binding<D.Compilation<S,L.columns(~S,full),L.columns(~S,full),R,Ops>,W.World<S,L.columns(~S,full),WR,E>,Sys.Owner<S,L.columns(~S,full),L.columns(~S,full),R,E,Ops,Local,Error,Out,program,body>,Maybe<&2,Evidence<S,full,L.columns(~S,full),R,Ops,program>>,Prep.Permit<S,L.columns(~S,full)>>) -> Effect.Task<S,RuntimePermit.Permit,Binding.Invocation<D.Compilation<S,L.columns(~S,full),L.columns(~S,full),R,Ops>,State.Scope<S,L.columns(~S,full),R>,W.World<S,L.columns(~S,full),WR,E>,Sys.Owner<S,L.columns(~S,full),L.columns(~S,full),R,E,Ops,Local,Error,Out,program,body>,Maybe<&2,Evidence<S,full,L.columns(~S,full),R,Ops,program>>,Prep.Permit<S,L.columns(~S,full)>,List<&2,Ready.Completed<Error,Out>>>>:
  match scope:
    case State.Scope{columns,resource,handles,tick,prior,+view}:whole_described(~S,~full,~R,~E,~WR,~Ops,~Local,~Error,~Out,~program,~body,~compiledCaps,~grant_of_caps,resource,handles,tick,prior,view,binding,Schema.describe(~S,full,L.AtLeaf{},columns))
def invoke_sparse(~S:Data,~full:L.Layout,~R:Type,~E:Data,~WR:Type,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~program:Build.FrameworkProgram(~S,~L.columns(~S,full),~Store.Storage<S,full>,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~compiledCaps:Ops(Effect.Granted,State.Scope<S,Store.Storage<S,full>,R>),~grant_of_caps:Ops(Effect.Granted,State.Scope<S,Store.Storage<S,full>,R>) -> Ops(Effect.Granted,State.Scope<S,Store.Storage<S,full>,R>) & RuntimePermit.Grant,scope:State.Scope<S,Store.Storage<S,full>,R>,binding:Binding.Binding<D.Compilation<S,L.columns(~S,full),Store.Storage<S,full>,R,Ops>,W.World<S,L.columns(~S,full),WR,E>,Sys.Owner<S,L.columns(~S,full),Store.Storage<S,full>,R,E,Ops,Local,Error,Out,program,body>,Maybe<&2,Evidence<S,full,Store.Storage<S,full>,R,Ops,program>>,Prep.Permit<S,L.columns(~S,full)>>) -> Effect.Task<S,RuntimePermit.Permit,Binding.Invocation<D.Compilation<S,L.columns(~S,full),Store.Storage<S,full>,R,Ops>,State.Scope<S,Store.Storage<S,full>,R>,W.World<S,L.columns(~S,full),WR,E>,Sys.Owner<S,L.columns(~S,full),Store.Storage<S,full>,R,E,Ops,Local,Error,Out,program,body>,Maybe<&2,Evidence<S,full,Store.Storage<S,full>,R,Ops,program>>,Prep.Permit<S,L.columns(~S,full)>,List<&2,Ready.Completed<Error,Out>>>>:
  match scope binding:
    case scope Binding.Binding{compilation,prepared,None{}}:Effect.TDone{Binding.InvocationRefused{scope,Binding.Binding{compilation,prepared,None{}},[]}}
    case State.Scope{Store.Storage{+namespace,columns,+grants,+info},resource,+handles,tick,prior,+view} Binding.Binding{compilation,prepared,Some{Evidence{+expectedNamespace,+captured,recipes,+expectedInfo,+expectedGrants,book}}}:invoke_checked(~S,~full,~Store.Storage<S,full>,~R,~E,~WR,~Ops,~Local,~Error,~Out,~program,~body,~compiledCaps,~grant_of_caps,State.Scope{Store.Storage{namespace,columns,grants,info},resource,handles,tick,prior,view},Binding.Binding{compilation,prepared,Some{Evidence{expectedNamespace,captured,recipes,expectedInfo,expectedGrants,book}}},Bool.and(Bool.and(U32.is_eq(namespace,expectedNamespace),U32.is_eq(view_namespace(~S,view),expectedNamespace)),Bool.and(same_handles(~S,handles,captured),Bool.and(same_info(info,expectedInfo),same_grants(~S,~L.columns(~S,full),grants,expectedGrants)))))
# Registration consumes metadata from the same admitted construction inventory.
def definition_inspected(~S:Data,~full:L.Layout,~C:Type,~R:Type,~E:Data,~WR:Type,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~program:Build.FrameworkProgram(~S,~L.columns(~S,full),~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),+name:String,local:Local,result:Inspection<W.World<S,L.columns(~S,full),WR,E>,Evidence<S,full,C,R,Ops,program>,D.Compilation<S,L.columns(~S,full),C,R,Ops>>) -> D.Compilation<S,L.columns(~S,full),C,R,Ops> & Sys.Defined<W.World<S,L.columns(~S,full),WR,E>,Sys.Owner<S,L.columns(~S,full),C,R,E,Ops,Local,Error,Out,program,body>,Local>:
  match result:
    case InspectionRefused{world,compilation}:(compilation,Sys.DefinitionRefused{world,local})
    case Inspected{world,D.Unsupported{caps,access,recipes},_}:(D.Unsupported{caps,access,recipes},Sys.DefinitionRefused{world,local})
    case Inspected{world,D.Supported{D.Declaration{caps,+access},recipes},Evidence{namespace,_,_,_,_,_}}:(D.Supported{D.Declaration{caps,access},recipes},Task.registered(~S,~L.columns(~S,full),~C,~R,~E,~Ops,~Local,~Error,~Out,~program,~body,~WR,namespace,name,D.keys(access),local,W.register(~S,~L.columns(~S,full),~WR,~E,world,name,D.keys(access))))
def define_with_compilation(~S:Data,~full:L.Layout,~C:Type,~R:Type,~E:Data,~WR:Type,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~program:Build.FrameworkProgram(~S,~L.columns(~S,full),~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),compilation:D.Compilation<S,L.columns(~S,full),C,R,Ops>,world:W.World<S,L.columns(~S,full),WR,E>,name:String,local:Local) -> D.Compilation<S,L.columns(~S,full),C,R,Ops> & Sys.Defined<W.World<S,L.columns(~S,full),WR,E>,Sys.Owner<S,L.columns(~S,full),C,R,E,Ops,Local,Error,Out,program,body>,Local>:
  definition_inspected(~S,~full,~C,~R,~E,~WR,~Ops,~Local,~Error,~Out,~program,~body,name,local,inspect_with_compilation(~S,~full,~C,~R,~E,~WR,~Ops,~program,compilation,world))
