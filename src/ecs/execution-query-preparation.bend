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

# The closed Program brands the symbolic and dynamic evidence together. These
# framework records are built only from actual World handles and storage.
type Evidence<-S:Data,-full:L.Layout,-C:Type,-R:Type,-Ops:Type -> Type,-program:Build.Program(~S,~L.columns(~S,full),~C,~R,~Ops)> is Data:
  Evidence{namespace:U32,handles:List<&2,W.Handle<S>>,recipes:List<&2,Recipe.Recipe<S,L.columns(~S,full)>>,info:List<&2,Schema.Info>,grants:List<&2,Admit.Granted<S,L.columns(~S,full)>>,book:Schema.Book<S,full>}
type Inspection<-World:Type,-Evidence:Data> is Type:
  Inspected{world:World,evidence:Evidence}
  InspectionRefused{world:World}
def lowered(~S:Data,~full:L.Layout,~C:Type,~R:Type,~E:Data,~WR:Type,~Ops:Type -> Type,~program:Build.Program(~S,~L.columns(~S,full),~C,~R,~Ops),world:W.World<S,L.columns(~S,full),WR,E>,namespace:U32,handles:List<&2,W.Handle<S>>,recipes:List<&2,Recipe.Recipe<S,L.columns(~S,full)>>,info:List<&2,Schema.Info>,result:Admit.Lowering<S,L.columns(~S,full),full>) -> Inspection<W.World<S,L.columns(~S,full),WR,E>,Evidence<S,full,C,R,Ops,program>>:
  match result:
    case Admit.LoweringRefused{}:InspectionRefused{world}
    case Admit.Lowered{grants,book}:Inspected{world,Evidence{namespace,handles,recipes,info,grants,book}}
def supported(~S:Data,~full:L.Layout,~C:Type,~R:Type,~E:Data,~WR:Type,~Ops:Type -> Type,~program:Build.Program(~S,~L.columns(~S,full),~C,~R,~Ops),world:W.World<S,L.columns(~S,full),WR,E>,+namespace:U32,+handles:List<&2,W.Handle<S>>,+info:List<&2,Schema.Info>,valid:Bool,compilation:D.Compilation<S,L.columns(~S,full),C,R,Ops>) -> Inspection<W.World<S,L.columns(~S,full),WR,E>,Evidence<S,full,C,R,Ops,program>>:
  match valid compilation:
    case False{} _:InspectionRefused{world}
    case True{} D.Unsupported{_,_,_}:InspectionRefused{world}
    case True{} D.Supported{_,D.Recipes{+recipes,_}}:lowered(~S,~full,~C,~R,~E,~WR,~Ops,~program,world,namespace,handles,recipes,info,Admit.lower(~S,~L.columns(~S,full),~full,~{==},recipes,info,namespace,handles))
def described(~S:Data,~full:L.Layout,~C:Type,~R:Type,~E:Data,~WR:Type,~Ops:Type -> Type,~program:Build.Program(~S,~L.columns(~S,full),~C,~R,~Ops),+namespace:U32,allocator:Allocator.Allocator,resource:WR,events:List<&2,E>,pending:List<Deferred.Command<W.World<S,L.columns(~S,full),WR,E>>>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:Clock.State,lifecycle:Notice.Journal<S>,handles:List<&2,W.Handle<S>>,result:Schema.Description<S,full>) -> Inspection<W.World<S,L.columns(~S,full),WR,E>,Evidence<S,full,C,R,Ops,program>>:
  match result:
    case Schema.Description{columns,info,valid}:supported(~S,~full,~C,~R,~E,~WR,~Ops,~program,W.World{namespace,allocator,columns,resource,events,pending,registrations,nextSystemId,clock,lifecycle},namespace,handles,info,valid,Build.compile_with_general(~S,~L.columns(~S,full),~C,~R,~Interpret.provider_dictionary(~S,~L.columns(~S,full),~C,~R),~Ops,~program))
def captured(~S:Data,~full:L.Layout,~C:Type,~R:Type,~E:Data,~WR:Type,~Ops:Type -> Type,~program:Build.Program(~S,~L.columns(~S,full),~C,~R,~Ops),result:W.World<S,L.columns(~S,full),WR,E> & List<&2,W.Handle<S>>) -> Inspection<W.World<S,L.columns(~S,full),WR,E>,Evidence<S,full,C,R,Ops,program>>:
  match result:
    case (W.World{namespace,allocator,columns,resource,events,pending,registrations,nextSystemId,clock,lifecycle},handles):described(~S,~full,~C,~R,~E,~WR,~Ops,~program,namespace,allocator,resource,events,pending,registrations,nextSystemId,clock,lifecycle,handles,Schema.describe(~S,full,L.AtLeaf{},columns))
def inspect(~S:Data,~full:L.Layout,~C:Type,~R:Type,~E:Data,~WR:Type,~Ops:Type -> Type,~program:Build.Program(~S,~L.columns(~S,full),~C,~R,~Ops),world:W.World<S,L.columns(~S,full),WR,E>) -> Inspection<W.World<S,L.columns(~S,full),WR,E>,Evidence<S,full,C,R,Ops,program>>:
  captured(~S,~full,~C,~R,~E,~WR,~Ops,~program,W.handles(~S,~L.columns(~S,full),~WR,~E,world))


type Binding<-World:Type,-Owner:Type,-Evidence:Data,-S:Data,-WC:Type> is Type:
  Binding{prepared:Prep.Prepared<World,Owner,Prep.Permit<S,WC>>,evidence:Evidence}
type Preparation<-World:Type,-Owner:Type,-Evidence:Data,-S:Data,-WC:Type> is Type:
  Prepared{world:World,binding:Binding<World,Owner,Evidence,S,WC>}
  PreparationRefused{world:World,owner:Owner}
def prepared(~S:Data,~full:L.Layout,~C:Type,~R:Type,~E:Data,~WR:Type,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~program:Build.Program(~S,~L.columns(~S,full),~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),evidence:Evidence<S,full,C,R,Ops,program>,result:W.World<S,L.columns(~S,full),WR,E> & Prep.Prepared<W.World<S,L.columns(~S,full),WR,E>,Sys.Owner<S,L.columns(~S,full),C,R,E,Ops,Local,Error,Out,program,body>,Prep.Permit<S,L.columns(~S,full)>>) -> Preparation<W.World<S,L.columns(~S,full),WR,E>,Sys.Owner<S,L.columns(~S,full),C,R,E,Ops,Local,Error,Out,program,body>,Evidence<S,full,C,R,Ops,program>,S,L.columns(~S,full)>:
  match result:
    case (world,prepared):Prepared{world,Binding{prepared,evidence}}
def inspected(~S:Data,~full:L.Layout,~C:Type,~R:Type,~E:Data,~WR:Type,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~program:Build.Program(~S,~L.columns(~S,full),~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),ids:List<&2,U32>,owner:Sys.Owner<S,L.columns(~S,full),C,R,E,Ops,Local,Error,Out,program,body>,result:Inspection<W.World<S,L.columns(~S,full),WR,E>,Evidence<S,full,C,R,Ops,program>>) -> Preparation<W.World<S,L.columns(~S,full),WR,E>,Sys.Owner<S,L.columns(~S,full),C,R,E,Ops,Local,Error,Out,program,body>,Evidence<S,full,C,R,Ops,program>,S,L.columns(~S,full)>:
  match result:
    case InspectionRefused{world}:PreparationRefused{world,owner}
    case Inspected{world,evidence}:prepared(~S,~full,~C,~R,~E,~WR,~Ops,~Local,~Error,~Out,~program,~body,evidence,Scope.prepare_with_general(~S,~L.columns(~S,full),~C,~R,~E,~Ops,~Local,~Error,~Out,~Interpret.provider_dictionary(~S,~L.columns(~S,full),~C,~R),~program,~body,~WR,ids,world,owner))
def prepare(~S:Data,~full:L.Layout,~C:Type,~R:Type,~E:Data,~WR:Type,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~program:Build.Program(~S,~L.columns(~S,full),~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),ids:List<&2,U32>,world:W.World<S,L.columns(~S,full),WR,E>,owner:Sys.Owner<S,L.columns(~S,full),C,R,E,Ops,Local,Error,Out,program,body>) -> Preparation<W.World<S,L.columns(~S,full),WR,E>,Sys.Owner<S,L.columns(~S,full),C,R,E,Ops,Local,Error,Out,program,body>,Evidence<S,full,C,R,Ops,program>,S,L.columns(~S,full)>:
  inspected(~S,~full,~C,~R,~E,~WR,~Ops,~Local,~Error,~Out,~program,~body,ids,owner,inspect(~S,~full,~C,~R,~E,~WR,~Ops,~program,world))
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
type Invocation<-H:Type,-World:Type,-Owner:Type,-Evidence:Data,-S:Data,-WC:Type,Status:Data> is Type:
  Invoked{scope:H,binding:Binding<World,Owner,Evidence,S,WC>,status:Status}
  InvocationRefused{scope:H,binding:Binding<World,Owner,Evidence,S,WC>,status:Status}
  InvocationInventoryRefused{scope:H,inventory:Prep.Inventory<World,Owner,Prep.Permit<S,WC>>,evidence:Evidence,status:Status}
def invoked(~S:Data,~full:L.Layout,~C:Type,~R:Type,~E:Data,~WR:Type,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~program:Build.Program(~S,~L.columns(~S,full),~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),evidence:Evidence<S,full,C,R,Ops,program>,result:Prep.Invocation<State.Scope<S,C,R>,W.World<S,L.columns(~S,full),WR,E>,Sys.Owner<S,L.columns(~S,full),C,R,E,Ops,Local,Error,Out,program,body>,Prep.Permit<S,L.columns(~S,full)>,List<&2,Ready.Completed<Error,Out>>>) -> Invocation<State.Scope<S,C,R>,W.World<S,L.columns(~S,full),WR,E>,Sys.Owner<S,L.columns(~S,full),C,R,E,Ops,Local,Error,Out,program,body>,Evidence<S,full,C,R,Ops,program>,S,L.columns(~S,full),List<&2,Ready.Completed<Error,Out>>>:
  match result:
    case Prep.Invoked{scope,prepared,status}:Invoked{scope,Binding{prepared,evidence},status}
    case Prep.InvocationRefused{scope,prepared,status}:InvocationRefused{scope,Binding{prepared,evidence},status}
    case Prep.InvocationInventoryRefused{scope,inventory,status}:InvocationInventoryRefused{scope,inventory,evidence,status}
def invoke_checked(~S:Data,~full:L.Layout,~C:Type,~R:Type,~E:Data,~WR:Type,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~program:Build.Program(~S,~L.columns(~S,full),~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),scope:State.Scope<S,C,R>,binding:Binding<W.World<S,L.columns(~S,full),WR,E>,Sys.Owner<S,L.columns(~S,full),C,R,E,Ops,Local,Error,Out,program,body>,Evidence<S,full,C,R,Ops,program>,S,L.columns(~S,full)>,valid:Bool) -> Invocation<State.Scope<S,C,R>,W.World<S,L.columns(~S,full),WR,E>,Sys.Owner<S,L.columns(~S,full),C,R,E,Ops,Local,Error,Out,program,body>,Evidence<S,full,C,R,Ops,program>,S,L.columns(~S,full),List<&2,Ready.Completed<Error,Out>>>:
  match binding valid:
    case binding False{}:InvocationRefused{scope,binding,[]}
    case Binding{prepared,evidence} True{}:invoked(~S,~full,~C,~R,~E,~WR,~Ops,~Local,~Error,~Out,~program,~body,evidence,Scope.invoke_with_general(~S,~L.columns(~S,full),~C,~R,~E,~Ops,~Local,~Error,~Out,~Interpret.provider_dictionary(~S,~L.columns(~S,full),~C,~R),~program,~body,~WR,scope,prepared))
def whole_described(~S:Data,~full:L.Layout,~R:Type,~E:Data,~WR:Type,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~program:Build.Program(~S,~L.columns(~S,full),~L.columns(~S,full),~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),resource:R,+handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,+view:Notice.View<S>,binding:Binding<W.World<S,L.columns(~S,full),WR,E>,Sys.Owner<S,L.columns(~S,full),L.columns(~S,full),R,E,Ops,Local,Error,Out,program,body>,Evidence<S,full,L.columns(~S,full),R,Ops,program>,S,L.columns(~S,full)>,result:Schema.Description<S,full>) -> Invocation<State.Scope<S,L.columns(~S,full),R>,W.World<S,L.columns(~S,full),WR,E>,Sys.Owner<S,L.columns(~S,full),L.columns(~S,full),R,E,Ops,Local,Error,Out,program,body>,Evidence<S,full,L.columns(~S,full),R,Ops,program>,S,L.columns(~S,full),List<&2,Ready.Completed<Error,Out>>>:
  match binding result:
    case Binding{prepared,Evidence{+namespace,+captured,recipes,+expected,grants,book}} Schema.Description{columns,info,valid}:invoke_checked(~S,~full,~L.columns(~S,full),~R,~E,~WR,~Ops,~Local,~Error,~Out,~program,~body,State.Scope{columns,resource,handles,tick,prior,view},Binding{prepared,Evidence{namespace,captured,recipes,expected,grants,book}},Bool.and(valid,Bool.and(U32.is_eq(view_namespace(~S,view),namespace),Bool.and(same_handles(~S,handles,captured),same_info(info,expected)))))
def invoke_whole(~S:Data,~full:L.Layout,~R:Type,~E:Data,~WR:Type,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~program:Build.Program(~S,~L.columns(~S,full),~L.columns(~S,full),~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),scope:State.Scope<S,L.columns(~S,full),R>,binding:Binding<W.World<S,L.columns(~S,full),WR,E>,Sys.Owner<S,L.columns(~S,full),L.columns(~S,full),R,E,Ops,Local,Error,Out,program,body>,Evidence<S,full,L.columns(~S,full),R,Ops,program>,S,L.columns(~S,full)>) -> Invocation<State.Scope<S,L.columns(~S,full),R>,W.World<S,L.columns(~S,full),WR,E>,Sys.Owner<S,L.columns(~S,full),L.columns(~S,full),R,E,Ops,Local,Error,Out,program,body>,Evidence<S,full,L.columns(~S,full),R,Ops,program>,S,L.columns(~S,full),List<&2,Ready.Completed<Error,Out>>>:
  match scope:
    case State.Scope{columns,resource,handles,tick,prior,+view}:whole_described(~S,~full,~R,~E,~WR,~Ops,~Local,~Error,~Out,~program,~body,resource,handles,tick,prior,view,binding,Schema.describe(~S,full,L.AtLeaf{},columns))
def same_grants(~S:Data,~WC:Type,left:List<&2,Admit.Granted<S,WC>>,right:List<&2,Admit.Granted<S,WC>>) -> Bool:
  match left right:
    case [], []:True{}
    case Admit.Granted{le,lh} <> lt, Admit.Granted{re,rh} <> rt:Bool.and(Admit.same_entry(le,re),Bool.and(same_handles(~S,lh,rh),same_grants(~S,~WC,lt,rt)))
    case _ _:False{}
def invoke_sparse(~S:Data,~full:L.Layout,~R:Type,~E:Data,~WR:Type,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~program:Build.Program(~S,~L.columns(~S,full),~Store.Storage<S,full>,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),scope:State.Scope<S,Store.Storage<S,full>,R>,binding:Binding<W.World<S,L.columns(~S,full),WR,E>,Sys.Owner<S,L.columns(~S,full),Store.Storage<S,full>,R,E,Ops,Local,Error,Out,program,body>,Evidence<S,full,Store.Storage<S,full>,R,Ops,program>,S,L.columns(~S,full)>) -> Invocation<State.Scope<S,Store.Storage<S,full>,R>,W.World<S,L.columns(~S,full),WR,E>,Sys.Owner<S,L.columns(~S,full),Store.Storage<S,full>,R,E,Ops,Local,Error,Out,program,body>,Evidence<S,full,Store.Storage<S,full>,R,Ops,program>,S,L.columns(~S,full),List<&2,Ready.Completed<Error,Out>>>:
  match scope binding:
    case State.Scope{Store.Storage{+namespace,columns,+grants,+info},resource,+handles,tick,prior,+view} Binding{prepared,Evidence{+expectedNamespace,+captured,recipes,+expectedInfo,+expectedGrants,book}}:invoke_checked(~S,~full,~Store.Storage<S,full>,~R,~E,~WR,~Ops,~Local,~Error,~Out,~program,~body,State.Scope{Store.Storage{namespace,columns,grants,info},resource,handles,tick,prior,view},Binding{prepared,Evidence{expectedNamespace,captured,recipes,expectedInfo,expectedGrants,book}},Bool.and(Bool.and(U32.is_eq(namespace,expectedNamespace),U32.is_eq(view_namespace(~S,view),expectedNamespace)),Bool.and(same_handles(~S,handles,captured),Bool.and(same_info(info,expectedInfo),same_grants(~S,~L.columns(~S,full),grants,expectedGrants)))))
def definition_inspected(~S:Data,~full:L.Layout,~C:Type,~R:Type,~E:Data,~WR:Type,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~program:Build.Program(~S,~L.columns(~S,full),~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),name:String,local:Local,result:Inspection<W.World<S,L.columns(~S,full),WR,E>,Evidence<S,full,C,R,Ops,program>>) -> Sys.Defined<W.World<S,L.columns(~S,full),WR,E>,Sys.Owner<S,L.columns(~S,full),C,R,E,Ops,Local,Error,Out,program,body>,Local>:
  match result:
    case InspectionRefused{world}:Sys.DefinitionRefused{world,local}
    case Inspected{world,_}:Task.define_with_general(~S,~L.columns(~S,full),~C,~R,~E,~Ops,~Local,~Error,~Out,~Interpret.provider_dictionary(~S,~L.columns(~S,full),~C,~R),~program,~body,~WR,world,name,local)
def define(~S:Data,~full:L.Layout,~C:Type,~R:Type,~E:Data,~WR:Type,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~program:Build.Program(~S,~L.columns(~S,full),~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),world:W.World<S,L.columns(~S,full),WR,E>,name:String,local:Local) -> Sys.Defined<W.World<S,L.columns(~S,full),WR,E>,Sys.Owner<S,L.columns(~S,full),C,R,E,Ops,Local,Error,Out,program,body>,Local>:
  definition_inspected(~S,~full,~C,~R,~E,~WR,~Ops,~Local,~Error,~Out,~program,~body,name,local,inspect(~S,~full,~C,~R,~E,~WR,~Ops,~program,world))
