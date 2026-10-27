import Base
import ./execution-composer-layout.bend as L
import ./execution-state.bend as State
import ./execution-builder.bend as Build
import ./execution-declaration.bend as D
import ./execution-system.bend as Sys
import ./execution-parallel-system.bend as System
import ./execution-parallel-scope.bend as Scope
import ./execution-prepared.bend as Prep
import ./execution-compiled-binding.bend as Binding
import ./execution-resource-preparation.bend as Preparation
import ./execution-resource-admission.bend as Admission
import ./execution-resource-pair-admission.bend as PairAdmission
import ./execution-resource-query-partition.bend as Cut
import ./execution-resource-query-task.bend as Phase
import ./execution-query-store.bend as QueryStore
import ./execution-query-schema.bend as Schema
import ./execution-resource-store.bend as ResourceStore
import ./execution-reservation-task.bend as Task
import ./execution-reservation-authority.bend as Authority
import ./execution-reservation-driver.bend as Driver
import ./execution-parallel-schedule.bend as Ready
import ./dependency-executor.bend as Exec
import ./owner-product.bend as Product
import ./clock-state.bend as Clock
import ./change-tick.bend as Tick
import ./world.bend as W

type Held<-Compilation:Type,-World:Type,-Owner:Type,-Evidence:Data,P:Data> is Type:
  HeldReady{binding:Binding.Binding<Compilation,World,Owner,Evidence,P>}
  HeldInventory{compilation:Compilation,inventory:Prep.Inventory<World,Owner,P>,evidence:Evidence}
def prepared(-Compilation:Type,-World:Type,-Owner:Type,-Evidence:Data,-P:Data,evidence:Evidence,result:Compilation & Prep.Preparation<World,Owner,P>) -> World & Held<Compilation,World,Owner,Evidence,P>:
  match result:
    case (compilation,Prep.PreparationReady{world,prepared}):(world,HeldReady{Binding.Binding{compilation,prepared,evidence}})
    case (compilation,Prep.PreparationRefused{world,inventory}):(world,HeldInventory{compilation,inventory,evidence})
def invoked(-Compilation:Type,-H:Type,-World:Type,-Owner:Type,-Evidence:Data,-P:Data,-Status:Data,result:Binding.Invocation<Compilation,H,World,Owner,Evidence,P,Status>) -> Phase.LeafResult<H,Held<Compilation,World,Owner,Evidence,P>,Status>:
  match result:
    case Binding.Invoked{scope,binding,status}:Phase.LeafResult{scope,HeldReady{binding},status}
    case Binding.InvocationRefused{scope,binding,status}:Phase.LeafResult{scope,HeldReady{binding},status}
    case Binding.InventoryRefused{scope,compilation,inventory,evidence,status}:Phase.LeafResult{scope,HeldInventory{compilation,inventory,evidence},status}
def unpack(-Compilation:Type,-World:Type,-Owner:Type,-Evidence:Data,-P:Data,held:Held<Compilation,World,Owner,Evidence,P>) -> Owner & List<&2,P>:
  match held:
    case HeldReady{Binding.Binding{_,Prep.Prepared{_,owner,permits,_},_}}:(owner,permits)
    case HeldInventory{_,Prep.Inventory{owner,provenance},_}:(owner,Prep.permits(P,provenance))
def choose_status(-Error:Data,-Out:Data,same:Bool,actual:Exec.Invocation<Error,Out>,rest:Exec.Invocation<Error,Out>) -> Exec.Invocation<Error,Out>:
  match same:
    case True{}:actual
    case False{}:rest
def find_status(-Error:Data,-Out:Data,+id:U32,statuses:List<&2,Ready.Completed<Error,Out>>) -> Exec.Invocation<Error,Out>:
  match statuses:
    case []:Exec.AdmissionRefused{}
    case Ready.Completed{actual,value} <> rest:choose_status(Error,Out,U32.is_eq(id,actual),value,find_status(Error,Out,id,rest))
def observed_permits(-Compilation:Type,-World:Type,-Owner:Type,-Evidence:Data,-P:Data,held:Held<Compilation,World,Owner,Evidence,P>) -> Held<Compilation,World,Owner,Evidence,P> & List<&2,P>:
  match held:
    case HeldReady{Binding.Binding{compilation,Prep.Prepared{namespace,owner,+permits,provenance},evidence}}:(HeldReady{Binding.Binding{compilation,Prep.Prepared{namespace,owner,permits,provenance},evidence}},permits)
    case HeldInventory{compilation,Prep.Inventory{owner,+provenance},evidence}:(HeldInventory{compilation,Prep.Inventory{owner,provenance},evidence},Prep.permits(P,provenance))
def completed_statuses(-Error:Data,-Out:Data,+statuses:List<&2,Ready.Completed<Error,Out>>,ids:List<&2,U32>) -> List<&2,Ready.Completed<Error,Out>>:
  match ids:
    case []:[]
    case +id <> rest:Ready.Completed{id,find_status(Error,Out,id,statuses)} <> completed_statuses(Error,Out,statuses,rest)
def invoke_leaf(~S:Data,~components:L.Layout,~resources:L.Layout,~E:Data,~Error:Data,~Out:Data,~Ops:Data -> Type -> Type,~Local:Type,~program:Build.FrameworkProgram(~S,~L.columns(~S,components),~QueryStore.Storage<S,components>,~ResourceStore.Storage<S,resources>,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~caps:Ops(Task.Granted,State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>),scope:State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,held:Held<D.Compilation<S,L.columns(~S,components),QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>,Ops>,W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,Sys.Owner<S,L.columns(~S,components),QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>,E,Ops,Local,Error,Out,program,body>,Maybe<&2,Admission.Evidence<S,components,resources,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>,Ops,program>>,Prep.Permit<S,L.columns(~S,components)>>) -> Task.Task<S,Authority.Permit,Phase.LeafResult<State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Held<D.Compilation<S,L.columns(~S,components),QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>,Ops>,W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,Sys.Owner<S,L.columns(~S,components),QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>,E,Ops,Local,Error,Out,program,body>,Maybe<&2,Admission.Evidence<S,components,resources,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>,Ops,program>>,Prep.Permit<S,L.columns(~S,components)>>,List<&2,Ready.Completed<Error,Out>>>>:
  match held:
    case HeldInventory{compilation,inventory,evidence}:Task.TDone{Phase.LeafResult{scope,HeldInventory{compilation,inventory,evidence},[]}}
    case HeldReady{binding}:Sys.map(S,Authority.Permit,Binding.Invocation<D.Compilation<S,L.columns(~S,components),QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>,Ops>,State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,Sys.Owner<S,L.columns(~S,components),QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>,E,Ops,Local,Error,Out,program,body>,Maybe<&2,Admission.Evidence<S,components,resources,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>,Ops,program>>,Prep.Permit<S,L.columns(~S,components)>,List<&2,Ready.Completed<Error,Out>>>,Phase.LeafResult<State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Held<D.Compilation<S,L.columns(~S,components),QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>,Ops>,W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,Sys.Owner<S,L.columns(~S,components),QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>,E,Ops,Local,Error,Out,program,body>,Maybe<&2,Admission.Evidence<S,components,resources,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>,Ops,program>>,Prep.Permit<S,L.columns(~S,components)>>,List<&2,Ready.Completed<Error,Out>>>,Preparation.invoke_bound(~S,~components,~resources,~QueryStore.Storage<S,components>,~ResourceStore.Storage<S,resources>,~E,~Ops,~Local,~Error,~Out,~program,~body,~caps,~Scope.no_structural(~Ops(Task.Granted,State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>)),scope,binding),result => invoked(D.Compilation<S,L.columns(~S,components),QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>,Ops>,State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,Sys.Owner<S,L.columns(~S,components),QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>,E,Ops,Local,Error,Out,program,body>,Maybe<&2,Admission.Evidence<S,components,resources,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>,Ops,program>>,Prep.Permit<S,L.columns(~S,components)>,List<&2,Ready.Completed<Error,Out>>,result))
type RunResult<-S:Data,-components:L.Layout,-resources:L.Layout,-E:Data,-Owners:Type,Error:Data,Out:Data> is Type:
  Returned{world:W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,owners:Owners,status:List<&2,Ready.Completed<Error,Out>>,displaced:List<&1,Schema.displacements(~S,components)>}
  AdmissionRefused{world:W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,owners:Owners,status:List<&2,Ready.Completed<Error,Out>>}
  CutInventoryRefused{administration:State.Administration<S,L.columns(~S,components),L.resources(~S,resources),E>,inventory:Cut.Partition<S,components,resources>,owners:Owners,status:List<&2,Ready.Completed<Error,Out>>,displaced:List<&1,Schema.displacements(~S,components)>}
  JoinInventoryRefused{administration:State.Administration<S,L.columns(~S,components),L.resources(~S,resources),E>,inventory:Cut.Joined<S,components,resources>,owners:Owners,status:List<&2,Ready.Completed<Error,Out>>,displaced:List<&1,Schema.displacements(~S,components)>}
def leave_allowed(allowed:Bool,clock:Clock.State) -> Clock.State:
  match allowed:
    case False{}:clock
    case True{}:Clock.leave(clock)
def leave_clock(~S:Data,~components:L.Layout,permits:List<&2,Prep.Permit<S,L.columns(~S,components)>>,clock:Clock.State) -> Clock.State:
  match permits:
    case []:clock
    case Prep.Permit{_,_,allowed,_} <> rest:leave_clock(~S,~components,rest,leave_allowed(allowed,clock))
def leave_admin(~S:Data,~components:L.Layout,~resources:L.Layout,~E:Data,~Error:Data,~Out:Data,admin:State.Administration<S,L.columns(~S,components),L.resources(~S,resources),E>,permits:List<&2,Prep.Permit<S,L.columns(~S,components)>>) -> State.Administration<S,L.columns(~S,components),L.resources(~S,resources),E>:
  match admin:
    case State.Administration{namespace,allocator,events,pending,registrations,next,clock,lifecycle}:State.Administration{namespace,allocator,events,pending,registrations,next,leave_clock(~S,~components,permits,clock),lifecycle}
def authorized(~S:Data,~components:L.Layout,permits:List<&2,Prep.Permit<S,L.columns(~S,components)>>) -> List<&2,U32>:
  match permits:
    case []:[]
    case Prep.Permit{_,id,True{},_} <> rest:id <> authorized(~S,~components,rest)
    case Prep.Permit{_,_,False{},_} <> rest:authorized(~S,~components,rest)
def owner_checked(-World:Type,-Owner:Type,+id:U32,owner:Owner,result:World & Bool) -> World & (Owner & (U32 & Bool)):
  match result:
    case (world,valid):(world,(owner,(id,valid)))
def keep_id_chosen(id:U32,next:U32,rest:List<&2,U32>,same:Bool) -> List<&2,U32>:
  match same:
    case True{}:rest
    case False{}:next <> rest
def keep_id(+id:U32,items:List<&2,U32>) -> List<&2,U32>:
  match items:
    case []:[]
    case +next <> rest:keep_id_chosen(id,next,keep_id(id,rest),U32.is_eq(id,next))
def admitted_ids(id:U32,valid:Bool,ids:List<&2,U32>) -> List<&2,U32>:
  match valid:
    case True{}:ids
    case False{}:keep_id(id,ids)
def check_leaf(~S:Data,~components:L.Layout,~resources:L.Layout,~E:Data,~Error:Data,~Out:Data,~Ops:Data -> Type -> Type,~Local:Type,~program:Build.FrameworkProgram(~S,~L.columns(~S,components),~QueryStore.Storage<S,components>,~ResourceStore.Storage<S,resources>,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),world:W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,binding:Scope.CompiledBinding<D.Compilation<S,L.columns(~S,components),QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>,Ops>,Sys.Owner<S,L.columns(~S,components),QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>,E,Ops,Local,Error,Out,program,body>>) -> W.World<S,L.columns(~S,components),L.resources(~S,resources),E> & (Scope.CompiledBinding<D.Compilation<S,L.columns(~S,components),QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>,Ops>,Sys.Owner<S,L.columns(~S,components),QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>,E,Ops,Local,Error,Out,program,body>> & (U32 & Bool)):
  match binding:
    case Scope.CompiledBinding{compilation,Sys.Owner{+namespace,+id,+name,+access,+cursor,local}}:owner_checked(W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,Scope.CompiledBinding<D.Compilation<S,L.columns(~S,components),QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>,Ops>,Sys.Owner<S,L.columns(~S,components),QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>,E,Ops,Local,Error,Out,program,body>>,id,Scope.CompiledBinding{compilation,Sys.Owner{namespace,id,name,access,cursor,local}},System.verify(~S,~L.columns(~S,components),~L.resources(~S,resources),~E,~Sys.Owner<S,L.columns(~S,components),QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>,E,Ops,Local,Error,Out,program,body>,System.Meta{namespace,id,name,access,cursor},world))
