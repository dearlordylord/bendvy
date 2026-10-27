import Base
import ./execution-composer-layout.bend as L
import ./execution-state.bend as State
import ./execution-query-store.bend as QueryStore
import ./execution-query-schema.bend as Schema
import ./execution-resource-store.bend as ResourceStore
import ./execution-resource-query-partition.bend as Cut
import ./execution-resource-pair-admission.bend as Admission
import ./execution-reservation-task.bend as Task
import ./execution-reservation-authority.bend as Authority

# Held includes the actual accepted Compilation, Prepared owner, and evidence.
# The task never borrows an allocator or reconstructs World while Issuer owns it.
type LeafResult<-H:Type,-Held:Type,Status:Data> is Type:
  LeafResult{scope:H,held:Held,status:Status}
type GroupResult<-S:Data,-components:L.Layout,-resources:L.Layout,-Left:Type,-Right:Type,Status:Data> is Type:
  Returned{scope:State.Scope<S,L.columns(~S,components),L.resources(~S,resources)>,left:Left,right:Right,status:Status,displaced:List<&1,Schema.displacements(~S,components)>}
  CutRefused{inventory:Cut.Partition<S,components,resources>,left:Left,right:Right,status:Status,displaced:List<&1,Schema.displacements(~S,components)>}
  JoinRefused{inventory:Cut.Joined<S,components,resources>,left:Left,right:Right,status:Status,displaced:List<&1,Schema.displacements(~S,components)>}
def returned(~S:Data,~components:L.Layout,~resources:L.Layout,-Left:Type,-Right:Type,-Status:Data,left:Left,right:Right,status:Status,priorDisplaced:List<&1,Schema.displacements(~S,components)>,result:Cut.Joined<S,components,resources>) -> GroupResult<S,components,resources,Left,Right,Status>:
  match result:
    case Cut.Joined{scope,moved}:Returned{scope,left,right,status,moved <> priorDisplaced}
    case inventory:JoinRefused{inventory,left,right,status,priorDisplaced}
def parallel_returned(~S:Data,~components:L.Layout,~resources:L.Layout,-Left:Type,-Right:Type,-Status:Data,combine:Status -> Status -> Status,join:Cut.Join<S,components,resources>,left:LeafResult<State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Left,Status>,right:LeafResult<State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Right,Status>) -> GroupResult<S,components,resources,Left,Right,Status>:
  match left right:
    case LeafResult{ls,left,lc} LeafResult{rs,right,rc}:returned(~S,~components,~resources,Left,Right,Status,left,right,combine(lc,rc),[],Cut.join(~S,~components,~resources,ls,rs,join))
def parallel(~S:Data,~components:L.Layout,~resources:L.Layout,-Left:Type,-Right:Type,-Status:Data,combine:Status -> Status -> Status,leftInvoke:State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>> -> Left -> Task.Task<S,Authority.Permit,LeafResult<State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Left,Status>>,rightInvoke:State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>> -> Right -> Task.Task<S,Authority.Permit,LeafResult<State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Right,Status>>,left:Left,right:Right,empty:Status,result:Cut.Partition<S,components,resources>) -> Task.Task<S,Authority.Permit,GroupResult<S,components,resources,Left,Right,Status>>:
  match result:
    case Cut.Parallel{ls,rs,join}:Task.TFork{LeafResult<State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Left,Status>,LeafResult<State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Right,Status>,leftInvoke(ls,left),rightInvoke(rs,right),left => right => Task.TDone{parallel_returned(~S,~components,~resources,Left,Right,Status,combine,join,left,right)}}
    case inventory:Task.TDone{CutRefused{inventory,left,right,empty,[]}}
def second_invoked(~S:Data,~components:L.Layout,~resources:L.Layout,-Left:Type,-Right:Type,-Status:Data,combine:Status -> Status -> Status,left:Left,leftStatus:Status,priorDisplaced:List<&1,Schema.displacements(~S,components)>,unused:State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,join:Cut.Join<S,components,resources>,result:LeafResult<State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Right,Status>) -> Task.Task<S,Authority.Permit,GroupResult<S,components,resources,Left,Right,Status>>:
  match result:
    case LeafResult{scope,right,rightStatus}:Task.TDone{returned(~S,~components,~resources,Left,Right,Status,left,right,combine(leftStatus,rightStatus),priorDisplaced,Cut.join(~S,~components,~resources,scope,unused,join))}
def second_cut(~S:Data,~components:L.Layout,~resources:L.Layout,-Left:Type,-Right:Type,-Status:Data,combine:Status -> Status -> Status,rightInvoke:State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>> -> Right -> Task.Task<S,Authority.Permit,LeafResult<State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Right,Status>>,left:Left,right:Right,leftStatus:Status,priorDisplaced:List<&1,Schema.displacements(~S,components)>,result:Cut.Partition<S,components,resources>) -> Task.Task<S,Authority.Permit,GroupResult<S,components,resources,Left,Right,Status>>:
  match result:
    case Cut.Parallel{scope,unused,join}:Task.bind(S,Authority.Permit,LeafResult<State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Right,Status>,GroupResult<S,components,resources,Left,Right,Status>,rightInvoke(scope,right),result => second_invoked(~S,~components,~resources,Left,Right,Status,combine,left,leftStatus,priorDisplaced,unused,join,result))
    case inventory:Task.TDone{CutRefused{inventory,left,right,leftStatus,priorDisplaced}}
def first_joined(~S:Data,~components:L.Layout,~resources:L.Layout,-Left:Type,-Right:Type,-Status:Data,combine:Status -> Status -> Status,cutRight:State.Scope<S,L.columns(~S,components),L.resources(~S,resources)> -> Cut.Partition<S,components,resources>,rightInvoke:State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>> -> Right -> Task.Task<S,Authority.Permit,LeafResult<State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Right,Status>>,left:Left,right:Right,leftStatus:Status,result:Cut.Joined<S,components,resources>) -> Task.Task<S,Authority.Permit,GroupResult<S,components,resources,Left,Right,Status>>:
  match result:
    case Cut.Joined{scope,moved}:second_cut(~S,~components,~resources,Left,Right,Status,combine,rightInvoke,left,right,leftStatus,[moved],cutRight(scope))
    case inventory:Task.TDone{JoinRefused{inventory,left,right,leftStatus,[]}}
def first_invoked(~S:Data,~components:L.Layout,~resources:L.Layout,-Left:Type,-Right:Type,-Status:Data,combine:Status -> Status -> Status,cutRight:State.Scope<S,L.columns(~S,components),L.resources(~S,resources)> -> Cut.Partition<S,components,resources>,rightInvoke:State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>> -> Right -> Task.Task<S,Authority.Permit,LeafResult<State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Right,Status>>,right:Right,unused:State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,join:Cut.Join<S,components,resources>,result:LeafResult<State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Left,Status>) -> Task.Task<S,Authority.Permit,GroupResult<S,components,resources,Left,Right,Status>>:
  match result:
    case LeafResult{scope,left,status}:first_joined(~S,~components,~resources,Left,Right,Status,combine,cutRight,rightInvoke,left,right,status,Cut.join(~S,~components,~resources,scope,unused,join))
def serial_cut(~S:Data,~components:L.Layout,~resources:L.Layout,-Left:Type,-Right:Type,-Status:Data,combine:Status -> Status -> Status,cutRight:State.Scope<S,L.columns(~S,components),L.resources(~S,resources)> -> Cut.Partition<S,components,resources>,leftInvoke:State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>> -> Left -> Task.Task<S,Authority.Permit,LeafResult<State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Left,Status>>,rightInvoke:State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>> -> Right -> Task.Task<S,Authority.Permit,LeafResult<State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Right,Status>>,left:Left,right:Right,empty:Status,result:Cut.Partition<S,components,resources>) -> Task.Task<S,Authority.Permit,GroupResult<S,components,resources,Left,Right,Status>>:
  match result:
    case Cut.Parallel{scope,unused,join}:Task.bind(S,Authority.Permit,LeafResult<State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Left,Status>,GroupResult<S,components,resources,Left,Right,Status>,leftInvoke(scope,left),result => first_invoked(~S,~components,~resources,Left,Right,Status,combine,cutRight,rightInvoke,right,unused,join,result))
    case inventory:Task.TDone{CutRefused{inventory,left,right,empty,[]}}
# All three cuts below are framework interpretations of the same admitted closed
# recipes. Single cuts keep the complete active grant; their unused peer is never invoked.
def run(~S:Data,~components:L.Layout,~resources:L.Layout,-Left:Type,-Right:Type,-Status:Data,mode:Admission.Mode,combine:Status -> Status -> Status,cutBoth:State.Scope<S,L.columns(~S,components),L.resources(~S,resources)> -> Cut.Partition<S,components,resources>,cutLeft:State.Scope<S,L.columns(~S,components),L.resources(~S,resources)> -> Cut.Partition<S,components,resources>,cutRight:State.Scope<S,L.columns(~S,components),L.resources(~S,resources)> -> Cut.Partition<S,components,resources>,leftInvoke:State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>> -> Left -> Task.Task<S,Authority.Permit,LeafResult<State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Left,Status>>,rightInvoke:State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>> -> Right -> Task.Task<S,Authority.Permit,LeafResult<State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Right,Status>>,scope:State.Scope<S,L.columns(~S,components),L.resources(~S,resources)>,left:Left,right:Right,empty:Status) -> Task.Task<S,Authority.Permit,GroupResult<S,components,resources,Left,Right,Status>>:
  match mode:
    case Admission.Parallel{}:parallel(~S,~components,~resources,Left,Right,Status,combine,leftInvoke,rightInvoke,left,right,empty,cutBoth(scope))
    case Admission.Serial{}:serial_cut(~S,~components,~resources,Left,Right,Status,combine,cutRight,leftInvoke,rightInvoke,left,right,empty,cutLeft(scope))
