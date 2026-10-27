import Base
import ./execution-builder.bend as Build
import ./execution-declaration.bend as D
import ./execution-resource-admission.bend as Admission
import ./execution-compiled-binding.bend as Binding
import ./execution-composer-layout.bend as L
import ./execution-prepared.bend as Prep
import ./execution-parallel-scope.bend as Scope
import ./execution-system.bend as Sys
import ./world.bend as W
import ./execution-state.bend as State
import ./execution-lifecycle-notices.bend as Notice
import ./execution-reservation-task.bend as Effect
import ./execution-reservation-permit.bend as RuntimePermit
import ./execution-parallel-schedule.bend as Ready

# Observation, admission, and clock entry thread the same actual compilation.
def inspected(~S:Data,~components:L.Layout,~resources:L.Layout,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~program:Build.FrameworkProgram(~S,~L.columns(~S,components),~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),ids:List<&2,U32>,owner:Sys.Owner<S,L.columns(~S,components),C,R,E,Ops,Local,Error,Out,program,body>,inspection:Admission.Inspection<S,components,resources,C,R,E,Ops,program>) -> Binding.Preparation<D.Compilation<S,L.columns(~S,components),C,R,Ops>,W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,Sys.Owner<S,L.columns(~S,components),C,R,E,Ops,Local,Error,Out,program,body>,Maybe<&2,Admission.Evidence<S,components,resources,C,R,Ops,program>>,Prep.Permit<S,L.columns(~S,components)>>:
  match inspection:
    case Admission.Refused{world,compilation}:Binding.Refused{world,compilation,Prep.Inventory{owner,Prep.Unprepared{}},None{}}
    case Admission.Admitted{world,compilation,evidence}:Binding.prepared(~D.Compilation<S,L.columns(~S,components),C,R,Ops>,~W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,~Sys.Owner<S,L.columns(~S,components),C,R,E,Ops,Local,Error,Out,program,body>,~Maybe<&2,Admission.Evidence<S,components,resources,C,R,Ops,program>>,~Prep.Permit<S,L.columns(~S,components)>,Some{evidence},Scope.prepare_with_compilation(~S,~L.columns(~S,components),~C,~R,~E,~Ops,~Local,~Error,~Out,~program,~body,~L.resources(~S,resources),compilation,ids,world,owner))

def prepare_with_compilation(~S:Data,~components:L.Layout,~resources:L.Layout,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~program:Build.FrameworkProgram(~S,~L.columns(~S,components),~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),compilation:D.Compilation<S,L.columns(~S,components),C,R,Ops>,ids:List<&2,U32>,world:W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,owner:Sys.Owner<S,L.columns(~S,components),C,R,E,Ops,Local,Error,Out,program,body>) -> Binding.Preparation<D.Compilation<S,L.columns(~S,components),C,R,Ops>,W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,Sys.Owner<S,L.columns(~S,components),C,R,E,Ops,Local,Error,Out,program,body>,Maybe<&2,Admission.Evidence<S,components,resources,C,R,Ops,program>>,Prep.Permit<S,L.columns(~S,components)>>:
  inspected(~S,~components,~resources,~C,~R,~E,~Ops,~Local,~Error,~Out,~program,~body,ids,owner,Admission.inspect_with_compilation(~S,~components,~resources,~C,~R,~E,~Ops,~program,compilation,world))

def same_handles(~S:Data,left:List<&2,W.Handle<S>>,right:List<&2,W.Handle<S>>) -> Bool:
  match left right:
    case [], []:True{}
    case lh <> lt, rh <> rt:Bool.and(State.same(~S,lh,rh),same_handles(~S,lt,rt))
    case _ _:False{}
def view_namespace(~S:Data,view:Notice.View<S>) -> U32:
  match view:
    case Notice.View{namespace,_,_}:namespace

def invoke_checked(~S:Data,~components:L.Layout,~resources:L.Layout,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~program:Build.FrameworkProgram(~S,~L.columns(~S,components),~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~compiledCaps:Ops(Effect.Granted,State.Scope<S,C,R>),~grant_of_caps:Ops(Effect.Granted,State.Scope<S,C,R>) -> Ops(Effect.Granted,State.Scope<S,C,R>) & RuntimePermit.Grant,scope:State.Scope<S,C,R>,binding:Binding.Binding<D.Compilation<S,L.columns(~S,components),C,R,Ops>,W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,Sys.Owner<S,L.columns(~S,components),C,R,E,Ops,Local,Error,Out,program,body>,Maybe<&2,Admission.Evidence<S,components,resources,C,R,Ops,program>>,Prep.Permit<S,L.columns(~S,components)>>,valid:Bool) -> Effect.Task<S,RuntimePermit.Permit,Binding.Invocation<D.Compilation<S,L.columns(~S,components),C,R,Ops>,State.Scope<S,C,R>,W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,Sys.Owner<S,L.columns(~S,components),C,R,E,Ops,Local,Error,Out,program,body>,Maybe<&2,Admission.Evidence<S,components,resources,C,R,Ops,program>>,Prep.Permit<S,L.columns(~S,components)>,List<&2,Ready.Completed<Error,Out>>>>:
  match binding valid:
    case binding False{}:Effect.TDone{Binding.InvocationRefused{scope,binding,[]}}
    case Binding.Binding{compilation,prepared,evidence} True{}:Sys.map(S,RuntimePermit.Permit,D.Compilation<S,L.columns(~S,components),C,R,Ops> & Prep.Invocation<State.Scope<S,C,R>,W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,Sys.Owner<S,L.columns(~S,components),C,R,E,Ops,Local,Error,Out,program,body>,Prep.Permit<S,L.columns(~S,components)>,List<&2,Ready.Completed<Error,Out>>>,Binding.Invocation<D.Compilation<S,L.columns(~S,components),C,R,Ops>,State.Scope<S,C,R>,W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,Sys.Owner<S,L.columns(~S,components),C,R,E,Ops,Local,Error,Out,program,body>,Maybe<&2,Admission.Evidence<S,components,resources,C,R,Ops,program>>,Prep.Permit<S,L.columns(~S,components)>,List<&2,Ready.Completed<Error,Out>>>,Scope.invoke_with_compilation(~S,~L.columns(~S,components),~C,~R,~E,~Ops,~Local,~Error,~Out,~program,~body,~L.resources(~S,resources),~compiledCaps,~grant_of_caps,compilation,scope,prepared),result => Binding.invoked(~D.Compilation<S,L.columns(~S,components),C,R,Ops>,~State.Scope<S,C,R>,~W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,~Sys.Owner<S,L.columns(~S,components),C,R,E,Ops,Local,Error,Out,program,body>,~Maybe<&2,Admission.Evidence<S,components,resources,C,R,Ops,program>>,~Prep.Permit<S,L.columns(~S,components)>,~List<&2,Ready.Completed<Error,Out>>,evidence,result))

# The physical partition layer supplies the local owner selected by this closed
# program. This adapter additionally checks its actual captured identity domain.
def invoke_bound(~S:Data,~components:L.Layout,~resources:L.Layout,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~program:Build.FrameworkProgram(~S,~L.columns(~S,components),~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~compiledCaps:Ops(Effect.Granted,State.Scope<S,C,R>),~grant_of_caps:Ops(Effect.Granted,State.Scope<S,C,R>) -> Ops(Effect.Granted,State.Scope<S,C,R>) & RuntimePermit.Grant,scope:State.Scope<S,C,R>,binding:Binding.Binding<D.Compilation<S,L.columns(~S,components),C,R,Ops>,W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,Sys.Owner<S,L.columns(~S,components),C,R,E,Ops,Local,Error,Out,program,body>,Maybe<&2,Admission.Evidence<S,components,resources,C,R,Ops,program>>,Prep.Permit<S,L.columns(~S,components)>>) -> Effect.Task<S,RuntimePermit.Permit,Binding.Invocation<D.Compilation<S,L.columns(~S,components),C,R,Ops>,State.Scope<S,C,R>,W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,Sys.Owner<S,L.columns(~S,components),C,R,E,Ops,Local,Error,Out,program,body>,Maybe<&2,Admission.Evidence<S,components,resources,C,R,Ops,program>>,Prep.Permit<S,L.columns(~S,components)>,List<&2,Ready.Completed<Error,Out>>>>:
  match scope binding:
    case scope Binding.Binding{compilation,prepared,None{}}:Effect.TDone{Binding.InvocationRefused{scope,Binding.Binding{compilation,prepared,None{}},[]}}
    case State.Scope{store,resource,+handles,tick,prior,+view} Binding.Binding{compilation,prepared,Some{Admission.Evidence{+namespace,+captured,queryRecipes,resourceRecipes,componentInfo,resourceInfo,grants,queryBook,resourceBook}}}:invoke_checked(~S,~components,~resources,~C,~R,~E,~Ops,~Local,~Error,~Out,~program,~body,~compiledCaps,~grant_of_caps,State.Scope{store,resource,handles,tick,prior,view},Binding.Binding{compilation,prepared,Some{Admission.Evidence{namespace,captured,queryRecipes,resourceRecipes,componentInfo,resourceInfo,grants,queryBook,resourceBook}}},Bool.and(U32.is_eq(namespace,view_namespace(~S,view)),same_handles(~S,handles,captured)))
