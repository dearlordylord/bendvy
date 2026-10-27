import Base
import ./declarations.bend as D
import ../../src/ecs/execution-machine-state.bend as State
import ../../src/ecs/execution-machine-access.bend as Machine
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/owner-product.bend as Product

type Phase is Data:
  Exit{}
  Transition{}
  Enter{}
  Running{}
def enabled(~S:Data,phase:Phase,view:State.View<S,D.Key,D.Mode>) -> Bool:
  match phase view:
    case Exit{} State.View{_,_,_,_,_,event}:State.run_exit(D.Mode,event)
    case Transition{} State.View{_,_,_,_,_,event}:State.run_transition(D.Mode,event)
    case Enter{} State.View{_,_,_,_,_,event}:State.run_enter(D.Mode,event)
    case Running{} view:State.matches(~S,~D.Key,~D.Mode,~D.same,D.Running{},view)
type Local is Type:
  Local{identity:Array<U32>,phase:Phase}
def observed(~S:Data,~H:Type,identity:Array<U32>,+phase:Phase,result:H & State.View<S,D.Key,D.Mode>) -> H & (Local & Sys.Completion<String,Bool>):
  match result:
    case (scope,view):(scope,(Local{identity,phase},Sys.Success{enabled(~S,phase,view)}))
def body(~S:Data,~H:Type,~caps:D.read_ops(~S)(H),scope:H,local:Local) -> H & (Local & Sys.Completion<String,Bool>):
  match local:
    case Local{identity,phase}:observed(~S,~H,identity,phase,Machine.read_field(~S,~D.Key,~D.Mode,~H,caps)(scope))

def Resources(~S:Data) -> Type:Product.Owner<D.Resources(~S),Unit>
def layout(~S:Data) -> Layout.Layout:Layout.LayoutPair{D.layout(~S),Layout.EmptyLayout{}}
def view_proof(~S:Data) -> {Layout.view(layout(~S),Layout.InLeft{Layout.AtLeaf{}}) == State.View<S,D.Key,D.Mode> : Data}:{==}
def selection(~S:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~D.Store(~S),~Resources(~S),~H,~B),~cw:Build.ComponentWrite(~S,~D.Store(~S),~Resources(~S),~H,~B),~rr:Build.ResourceRead(~S,~D.Store(~S),~Resources(~S),~H,~B),~rw:Build.ResourceWrite(~S,~D.Store(~S),~Resources(~S),~H,~B),~q:Build.Query(~S,~D.Store(~S),~D.Store(~S),~Resources(~S),~H,~B),~lifecycle:Build.Lifecycle(~S,~D.Store(~S),~D.Store(~S),~Resources(~S),~H,~B),book:B) -> B & D.read_ops(~S)(H):
  Machine.select_read(~S,~D.Key,~D.Mode,~D.Store(~S),~Resources(~S),~H,~B,~layout(~S),~Layout.InLeft{Layout.AtLeaf{}},~{==},~{==},~view_proof(~S),~rr,book)
def declaration(~S:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~D.Store(~S),~D.Store(~S),~Resources(~S),~H,~B),book:B) -> B & D.read_ops(~S)(H):
  builder(D.read_ops(~S),selection(~S,~H,~B),book)
