import Base
import ./extended-declarations.bend as Schema
import ../parallel-machines/declarations.bend as Modes
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-access.bend as Access
import ../../src/ecs/execution-machine-state.bend as Cell
import ../../src/ecs/execution-machine-access.bend as Machine
import ../../src/ecs/execution-relation-store.bend as Graph
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-reservation-task.bend as Task
import ../../src/ecs/machine.bend as M
import ../../src/ecs/change-tick.bend as Tick

def Columns(~S:Data) -> Type:Layout.columns(~S,Schema.components(~S))
def LeftColumn(~S:Data) -> Type:Layout.columns(~S,Layout.subtree(Schema.components(~S),Layout.InLeft{Layout.AtLeaf{}}))
def RightColumn(~S:Data) -> Type:Layout.columns(~S,Layout.subtree(Schema.components(~S),Layout.InRight{Layout.AtLeaf{}}))
def LeftLayout(~S:Data) -> Layout.Layout:Layout.subtree(Schema.resource_layout(~S),Layout.InLeft{Layout.AtLeaf{}})
def RightLayout(~S:Data) -> Layout.Layout:Layout.subtree(Schema.resource_layout(~S),Layout.InRight{Layout.AtLeaf{}})
def LeftResource(~S:Data) -> Type:Layout.resources(~S,LeftLayout(~S))
def RightResource(~S:Data) -> Type:Layout.resources(~S,RightLayout(~S))
type Local is Type:Local{capture:Array<U32>,runs:U32}
def LeftOps(~S:Data,Permit:Data,H:Type) -> Type:Access.ResourceRead<H,Graph.View<S,Schema.hierarchy(~S)>>
def RightOps(~S:Data,Permit:Data,H:Type) -> Type:Access.ResourceWrite<H,Cell.Cell<S,Modes.Key,Modes.Mode>,Cell.View<S,Modes.Key,Modes.Mode>>
def GuardOps(~S:Data,Permit:Data,H:Type) -> Type:Machine.Read<S,Modes.Key,Modes.Mode,H>
def left_selection(~S:Data,~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~LeftColumn(~S),~LeftResource(~S),~H,~B),~cw:Build.ComponentWrite(~S,~LeftColumn(~S),~LeftResource(~S),~H,~B),~rr:Build.ResourceRead(~S,~LeftColumn(~S),~LeftResource(~S),~H,~B),~rw:Build.ResourceWrite(~S,~LeftColumn(~S),~LeftResource(~S),~H,~B),~q:Build.Query(~S,~Columns(~S),~LeftColumn(~S),~LeftResource(~S),~H,~B),~life:Build.Lifecycle(~S,~Columns(~S),~LeftColumn(~S),~LeftResource(~S),~H,~B),book:B) -> B & LeftOps(~S,Permit,H):Build.basic_resource_read(~S,~LeftColumn(~S),~LeftResource(~S),~H,~B,~LeftLayout(~S),~Layout.AtLeaf{},~{==},~{==},~rr,book)
def right_selection(~S:Data,~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~RightColumn(~S),~RightResource(~S),~H,~B),~cw:Build.ComponentWrite(~S,~RightColumn(~S),~RightResource(~S),~H,~B),~rr:Build.ResourceRead(~S,~RightColumn(~S),~RightResource(~S),~H,~B),~rw:Build.ResourceWrite(~S,~RightColumn(~S),~RightResource(~S),~H,~B),~q:Build.Query(~S,~Columns(~S),~RightColumn(~S),~RightResource(~S),~H,~B),~life:Build.Lifecycle(~S,~Columns(~S),~RightColumn(~S),~RightResource(~S),~H,~B),book:B) -> B & RightOps(~S,Permit,H):Build.basic_resource_write(~S,~RightColumn(~S),~RightResource(~S),~H,~B,~RightLayout(~S),~Layout.InLeft{Layout.AtLeaf{}},~{==},~{==},~rw,book)
def guard_selection(~S:Data,~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~Columns(~S),~Schema.Resources(~S),~H,~B),~cw:Build.ComponentWrite(~S,~Columns(~S),~Schema.Resources(~S),~H,~B),~rr:Build.ResourceRead(~S,~Columns(~S),~Schema.Resources(~S),~H,~B),~rw:Build.ResourceWrite(~S,~Columns(~S),~Schema.Resources(~S),~H,~B),~q:Build.Query(~S,~Columns(~S),~Columns(~S),~Schema.Resources(~S),~H,~B),~life:Build.Lifecycle(~S,~Columns(~S),~Columns(~S),~Schema.Resources(~S),~H,~B),book:B) -> B & GuardOps(~S,Permit,H):Machine.select_read(~S,~Modes.Key,~Modes.Mode,~Columns(~S),~Schema.Resources(~S),~H,~B,~Schema.resource_layout(~S),~Layout.InRight{Layout.InLeft{Layout.AtLeaf{}}},~{==},~{==},~{==},~rr,book)
def left_declaration(~S:Data,~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~S,~Columns(~S),~LeftColumn(~S),~LeftResource(~S),~Permit,~H,~B),book:B) -> B & LeftOps(~S,Permit,H):builder(LeftOps(~S),left_selection(~S,~Permit,~H,~B),book)
def right_declaration(~S:Data,~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~S,~Columns(~S),~RightColumn(~S),~RightResource(~S),~Permit,~H,~B),book:B) -> B & RightOps(~S,Permit,H):builder(RightOps(~S),right_selection(~S,~Permit,~H,~B),book)
def guard_declaration(~S:Data,~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~S,~Columns(~S),~Columns(~S),~Schema.Resources(~S),~Permit,~H,~B),book:B) -> B & GuardOps(~S,Permit,H):builder(GuardOps(~S),guard_selection(~S,~Permit,~H,~B),book)
def left_returned(~S:Data,~H:Type,local:Local,result:H & Graph.View<S,Schema.hierarchy(~S)>) -> H & (Local & Sys.Completion<String,String>):
  match local result:
    case Local{capture,runs}, (scope,_):(scope,(Local{capture,U32.add(runs,1)},Sys.BodyError{"retained-handler","graph-read"}))
def left_body(~S:Data,~Permit:Data,~H:Type,~caps:LeftOps(~S,Permit,H),scope:H,local:Local) -> Task.Task<S,Permit,H & (Local & Sys.Completion<String,String>)>:Task.TDone{left_returned(~S,~H,local,Access.resource_read_field(~H,~Graph.View<S,Schema.hierarchy(~S)>,caps)(scope))}
def applied(~S:Data,+tick:Tick.Tick,result:Cell.Cell<S,Modes.Key,Modes.Mode> & Unit) -> Cell.Cell<S,Modes.Key,Modes.Mode> & Cell.View<S,Modes.Key,Modes.Mode>:
  match result:
    case (cell,_):Cell.projected(S,Modes.Key,Modes.Mode,Cell.apply(~S,~Modes.Key,~Modes.Mode,~Modes.same,cell,tick))
def transition_at(~S:Data,+tick:Tick.Tick,cell:Cell.Cell<S,Modes.Key,Modes.Mode>) -> Cell.Cell<S,Modes.Key,Modes.Mode> & Cell.View<S,Modes.Key,Modes.Mode>:applied(~S,tick,Cell.queued_at(~S,~Modes.Key,~Modes.Mode,~Modes.same,M.Set{Modes.Running{},True{}},tick,cell))
def transition(~S:Data,tick:Tick.Tick,cell:Cell.Cell<S,Modes.Key,Modes.Mode>) -> Cell.Cell<S,Modes.Key,Modes.Mode> & Cell.View<S,Modes.Key,Modes.Mode>:transition_at(~S,tick,cell)
def right_returned(~S:Data,~H:Type,local:Local,result:H & Cell.View<S,Modes.Key,Modes.Mode>) -> H & (Local & Sys.Completion<String,String>):
  match local result:
    case Local{capture,runs}, (scope,Cell.View{_,_,revision,_,_,intent}):(scope,(Local{capture,U32.add(runs,1)},Sys.Success{"revision=" ++ Nat.show(revision) ++ "/transition=" ++ Bool.show(Cell.run_transition(Modes.Mode,intent))}))
def right_body(~S:Data,~Permit:Data,~H:Type,~caps:RightOps(~S,Permit,H),scope:H,local:Local) -> Task.Task<S,Permit,H & (Local & Sys.Completion<String,String>)>:Task.TDone{right_returned(~S,~H,local,Access.resource_own_at_field(~H,~Cell.Cell<S,Modes.Key,Modes.Mode>,~Cell.View<S,Modes.Key,Modes.Mode>,Cell.View<S,Modes.Key,Modes.Mode>,caps)(transition(~S),scope))}
def guarded(~S:Data,~H:Type,local:Local,result:H & Cell.View<S,Modes.Key,Modes.Mode>) -> H & (Local & Sys.Completion<String,Bool>):
  match local result:
    case Local{capture,runs}, (scope,view):(scope,(Local{capture,U32.add(runs,1)},Sys.Success{Cell.matches(~S,~Modes.Key,~Modes.Mode,~Modes.same,Modes.Waiting{},view)}))
def guard_body(~S:Data,~Permit:Data,~H:Type,~caps:GuardOps(~S,Permit,H),scope:H,local:Local) -> Task.Task<S,Permit,H & (Local & Sys.Completion<String,Bool>)>:Task.TDone{guarded(~S,~H,local,Machine.read_field(~S,~Modes.Key,~Modes.Mode,~H,caps)(scope))}
def Left(~S:Data) -> Type:Sys.Owner<S,Columns(~S),LeftColumn(~S),LeftResource(~S),Unit,LeftOps(~S),Local,String,String,left_declaration(~S),left_body(~S)>
def Right(~S:Data) -> Type:Sys.Owner<S,Columns(~S),RightColumn(~S),RightResource(~S),Unit,RightOps(~S),Local,String,String,right_declaration(~S),right_body(~S)>
def Guard(~S:Data) -> Type:Sys.Owner<S,Columns(~S),Columns(~S),Schema.Resources(~S),Unit,GuardOps(~S),Local,String,Bool,guard_declaration(~S),guard_body(~S)>
