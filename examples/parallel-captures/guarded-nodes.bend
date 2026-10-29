import Base
import ./declarations.bend as D
import ./payloads.bend as Payload
import ./bodies.bend as Body
import ./contexts.bend as Context
import ../../src/ecs/execution-capture.bend as Capture
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-query-store.bend as QueryStore
import ../../src/ecs/execution-resource-store.bend as ResourceStore
import ../../src/ecs/execution-resource-access.bend as Access
import ../../src/ecs/execution-resource-program.bend as Program
import ../../src/ecs/execution-resource-query-leaf.bend as Leaf
import ../../src/ecs/execution-resource-query-composite.bend as Composite
import ../../src/ecs/execution-resource-query-group.bend as Group
import ../../src/ecs/execution-resource-query-execution.bend as Execution
import ../../src/ecs/execution-resource-query-lifecycle.bend as Life
import ../../src/ecs/execution-system-lifecycle.bend as Identity
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-system.bend as System
import ../../src/ecs/execution-parallel-scope.bend as Scope
import ../../src/ecs/execution-parallel-scope-registry.bend as Tree
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-prepared.bend as Prep
import ../../src/ecs/execution-resource-admission.bend as Admission
import ../../src/ecs/execution-reservation-task.bend as Task
import ../../src/ecs/execution-parallel-schedule.bend as Ready
import ../../src/ecs/world.bend as W
import ../../src/ecs/owner-product.bend as Product

def components() -> Layout.Layout:Layout.LayoutPair{Layout.EmptyLayout{},Layout.EmptyLayout{}}
def C(~S:Data) -> Type:QueryStore.Storage<S,components()>
def R(~S:Data) -> Type:ResourceStore.Storage<S,D.resources_layout()>
def World(~S:Data) -> Type:W.World<S,D.Store(~S),D.Resources(~S),Unit>
def LeftOps(Permit:Data,H:Type) -> Type:Access.Writer<H,Payload.Counter,String>
def RightOps(Permit:Data,H:Type) -> Type:Access.Writer<H,Payload.Score,String>

# These adapters keep the original affine Local and capture steps. A missing
# generalized resource owner returns BodyError, never a fabricated resource view.
def left_written(-H:Type,state:Array<U32>,capture:Context.Count(),+runs:U32,value:U32,result:H & ResourceStore.Edit<Payload.Counter,String>) -> H & (Body.LeftLocal() & Sys.Completion<String,String>):
  match result:
    case (scope,ResourceStore.Edited{_}):(scope,(Capture.Local{state,capture},Body.completion(U32.is_eq(runs,2),U32.show(runs) ++ "/capture=" ++ U32.show(value))))
    case (scope,ResourceStore.Unchanged{_}):(scope,(Capture.Local{state,capture},Sys.BodyError{"counter-owner-refused",U32.show(runs) ++ "/capture=" ++ U32.show(value)}))
def left_captured(-H:Type,cap:LeftOps(Task.Granted,H),scope:H,state:Array<U32>,runs:U32,result:Context.Count() & U32) -> H & (Body.LeftLocal() & Sys.Completion<String,String>):
  match cap result:
    case Access.Writer{_,own,_}, (capture,value):left_written(H,state,capture,runs,value,own(String,scope,Payload.update_counter))
    case Access.UnsupportedWriter{}, (capture,value):(scope,(Capture.Local{state,capture},Sys.BodyError{"counter-writer-unsupported",U32.show(runs) ++ "/capture=" ++ U32.show(value)}))
def left_advanced(-Permit:Data,-H:Type,cap:LeftOps(Permit,H),scope:H,capture:Context.Count(),result:Array<U32> & U32) -> H & (Body.LeftLocal() & Sys.Completion<String,String>):
  match result:
    case (state,runs):left_captured(H,cap,scope,state,runs,Capture.invoke(~Array<U32>,~U32,~U32,~Context.count_step,capture,2))
def left_body(~S:Data,~Permit:Data,~H:Type,~caps:LeftOps(Permit,H),scope:H,local:Body.LeftLocal()) -> Task.Task<S,Permit,H & (Body.LeftLocal() & Sys.Completion<String,String>)>:
  match local:
    case Capture.Local{state,capture}:Task.TDone{left_advanced(Permit,H,caps,scope,capture,Body.advance(state))}
def right_written(-H:Type,state:Array<U32>,capture:Context.Text(),runs:U32,value:String,result:H & ResourceStore.Edit<Payload.Score,String>) -> H & (Body.RightLocal() & Sys.Completion<String,String>):
  match result:
    case (scope,ResourceStore.Edited{_}):(scope,(Capture.Local{state,capture},Sys.Success{U32.show(runs) ++ "/capture=" ++ value}))
    case (scope,ResourceStore.Unchanged{_}):(scope,(Capture.Local{state,capture},Sys.BodyError{"score-owner-refused",U32.show(runs) ++ "/capture=" ++ value}))
def right_captured(-H:Type,cap:RightOps(Task.Granted,H),scope:H,state:Array<U32>,runs:U32,result:Context.Text() & String) -> H & (Body.RightLocal() & Sys.Completion<String,String>):
  match cap result:
    case Access.Writer{_,own,_}, (capture,value):right_written(H,state,capture,runs,value,own(String,scope,Payload.update_score))
    case Access.UnsupportedWriter{}, (capture,value):(scope,(Capture.Local{state,capture},Sys.BodyError{"score-writer-unsupported",U32.show(runs) ++ "/capture=" ++ value}))
def right_advanced(-Permit:Data,-H:Type,cap:RightOps(Permit,H),scope:H,capture:Context.Text(),result:Array<U32> & U32) -> H & (Body.RightLocal() & Sys.Completion<String,String>):
  match result:
    case (state,runs):right_captured(H,cap,scope,state,runs,Capture.invoke(~Context.TextContext,~String,~String,~Context.text_step,capture,"x"))
def right_body(~S:Data,~Permit:Data,~H:Type,~caps:RightOps(Permit,H),scope:H,local:Body.RightLocal()) -> Task.Task<S,Permit,H & (Body.RightLocal() & Sys.Completion<String,String>)>:
  match local:
    case Capture.Local{state,capture}:Task.TDone{right_advanced(Permit,H,caps,scope,capture,Body.advance(state))}

def left_selection(~S:Data,~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~C(~S),~R(~S),~H,~B),~cw:Build.ComponentWrite(~S,~C(~S),~R(~S),~H,~B),~rr:Build.ResourceRead(~S,~C(~S),~R(~S),~H,~B),~rw:Build.ResourceWrite(~S,~C(~S),~R(~S),~H,~B),~query:Build.Query(~S,~D.Store(~S),~C(~S),~R(~S),~H,~B),~lifecycle:Build.Lifecycle(~S,~D.Store(~S),~C(~S),~R(~S),~H,~B),book:B) -> B & LeftOps(Permit,H):
  Build.general_resource_write(~S,~C(~S),~R(~S),~H,~B,~D.resources_layout(),~Layout.InLeft{Layout.AtLeaf{}},~{==},~ResourceStore.Sparse{},~{==},~rw,book)
def left_declaration(~S:Data,~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~D.Store(~S),~C(~S),~R(~S),~Permit,~H,~B),book:B) -> B & LeftOps(Permit,H):
  builder(LeftOps,left_selection(~S,~Permit,~H,~B),book)
def left_kernel(~S:Data,~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~S,~D.Store(~S),~C(~S),~R(~S),~Permit,~H,~B),book:B) -> B & LeftOps(Permit,H):
  Build.framework_program(~S,~D.Store(~S),~C(~S),~R(~S),~LeftOps,~left_declaration(~S),~Permit,~token,~H,~B,~builder,book)
def LeftCompilation(~S:Data) -> Type:Decl.Compilation<S,D.Store(~S),C(~S),R(~S),LeftOps>
def left_compilation(~S:Data) -> LeftCompilation(~S):
  Program.compile_framework(~S,~D.Store(~S),~C(~S),~R(~S),~LeftOps,~left_kernel(~S))
def LeftOwner(~S:Data) -> Type:Sys.Owner<S,D.Store(~S),C(~S),R(~S),Unit,LeftOps,Body.LeftLocal(),String,String,left_kernel(~S),left_body(~S)>
def LeftNode(~S:Data) -> Type:Leaf.node_type(~S,~components(),~D.resources_layout(),~Unit,~String,~String,~LeftOps,~Body.LeftLocal(),~left_kernel(~S),~left_body(~S))
def LeftEvidence(~S:Data) -> Data:Admission.Evidence<S,components(),D.resources_layout(),C(~S),R(~S),LeftOps,left_kernel(~S)>
def left_leaf(~S:Data,node:LeftNode(~S)) -> Leaf.Leaf<S,components(),D.resources_layout(),Unit,LeftNode(~S),String,String>:
  Tree.compile_retained_generalized_leaf(~S,~components(),~D.resources_layout(),~Unit,~String,~String,~LeftOps,~Body.LeftLocal(),~left_kernel(~S),~left_body(~S),~left_compilation(~S),node)
def define_left(~S:Data,world:World(~S),name:String,local:Body.LeftLocal()) -> LeftCompilation(~S) & Sys.Defined<World(~S),LeftOwner(~S),Body.LeftLocal()>:
  System.define_with_compilation(~S,~D.Store(~S),~C(~S),~R(~S),~Unit,~LeftOps,~Body.LeftLocal(),~String,~String,~left_kernel(~S),~left_body(~S),~D.Resources(~S),left_compilation(~S),world,name,local)
def left_node(~S:Data,compilation:LeftCompilation(~S),owner:LeftOwner(~S)) -> LeftNode(~S):
  Leaf.Uninspected{Scope.CompiledBinding{compilation,owner}}

def right_selection(~S:Data,~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~C(~S),~R(~S),~H,~B),~cw:Build.ComponentWrite(~S,~C(~S),~R(~S),~H,~B),~rr:Build.ResourceRead(~S,~C(~S),~R(~S),~H,~B),~rw:Build.ResourceWrite(~S,~C(~S),~R(~S),~H,~B),~query:Build.Query(~S,~D.Store(~S),~C(~S),~R(~S),~H,~B),~lifecycle:Build.Lifecycle(~S,~D.Store(~S),~C(~S),~R(~S),~H,~B),book:B) -> B & RightOps(Permit,H):
  Build.general_resource_write(~S,~C(~S),~R(~S),~H,~B,~D.resources_layout(),~Layout.InRight{Layout.AtLeaf{}},~{==},~ResourceStore.Sparse{},~{==},~rw,book)
def right_declaration(~S:Data,~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~D.Store(~S),~C(~S),~R(~S),~Permit,~H,~B),book:B) -> B & RightOps(Permit,H):
  builder(RightOps,right_selection(~S,~Permit,~H,~B),book)
def right_kernel(~S:Data,~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~S,~D.Store(~S),~C(~S),~R(~S),~Permit,~H,~B),book:B) -> B & RightOps(Permit,H):
  Build.framework_program(~S,~D.Store(~S),~C(~S),~R(~S),~RightOps,~right_declaration(~S),~Permit,~token,~H,~B,~builder,book)
def RightCompilation(~S:Data) -> Type:Decl.Compilation<S,D.Store(~S),C(~S),R(~S),RightOps>
def right_compilation(~S:Data) -> RightCompilation(~S):
  Program.compile_framework(~S,~D.Store(~S),~C(~S),~R(~S),~RightOps,~right_kernel(~S))
def RightOwner(~S:Data) -> Type:Sys.Owner<S,D.Store(~S),C(~S),R(~S),Unit,RightOps,Body.RightLocal(),String,String,right_kernel(~S),right_body(~S)>
def RightNode(~S:Data) -> Type:Leaf.node_type(~S,~components(),~D.resources_layout(),~Unit,~String,~String,~RightOps,~Body.RightLocal(),~right_kernel(~S),~right_body(~S))
def RightEvidence(~S:Data) -> Data:Admission.Evidence<S,components(),D.resources_layout(),C(~S),R(~S),RightOps,right_kernel(~S)>
def right_leaf(~S:Data,node:RightNode(~S)) -> Leaf.Leaf<S,components(),D.resources_layout(),Unit,RightNode(~S),String,String>:
  Tree.compile_retained_generalized_leaf(~S,~components(),~D.resources_layout(),~Unit,~String,~String,~RightOps,~Body.RightLocal(),~right_kernel(~S),~right_body(~S),~right_compilation(~S),node)
def define_right(~S:Data,world:World(~S),name:String,local:Body.RightLocal()) -> RightCompilation(~S) & Sys.Defined<World(~S),RightOwner(~S),Body.RightLocal()>:
  System.define_with_compilation(~S,~D.Store(~S),~C(~S),~R(~S),~Unit,~RightOps,~Body.RightLocal(),~String,~String,~right_kernel(~S),~right_body(~S),~D.Resources(~S),right_compilation(~S),world,name,local)
def right_node(~S:Data,compilation:RightCompilation(~S),owner:RightOwner(~S)) -> RightNode(~S):
  Leaf.Uninspected{Scope.CompiledBinding{compilation,owner}}

def LeftTree(~S:Data) -> Type:Product.Owner<LeftNode(~S),LeftNode(~S)>
def Nodes(~S:Data) -> Type:Product.Owner<LeftTree(~S),RightNode(~S)>
def left_tree(~S:Data,nodes:LeftTree(~S)) -> Leaf.Leaf<S,components(),D.resources_layout(),Unit,LeftTree(~S),String,String>:
  Composite.from_nodes(~S,~components(),~D.resources_layout(),~Unit,~String,~String,~LeftNode(~S),~LeftNode(~S),~left_leaf(~S),~left_leaf(~S),nodes)
def dispatch(~S:Data,native:Bool,nodes:Nodes(~S),world:World(~S),ids:List<&2,U32>) -> IO(Execution.RunResult<S,components(),D.resources_layout(),Unit,Nodes(~S),String,String>):
  match native nodes:
    case False{} Product.Owner{left,right}:Group.run_retained_serial(~S,~components(),~D.resources_layout(),~Unit,~String,~String,LeftTree(~S),RightNode(~S),ids,world,left_tree(~S,left),right_leaf(~S,right))
    case True{} Product.Owner{left,right}:Group.run_retained(~S,~components(),~D.resources_layout(),~Unit,~String,~String,LeftTree(~S),RightNode(~S),ids,world,left_tree(~S,left),right_leaf(~S,right))
def RightReturned(~S:Data) -> Type:Life.Released<RightCompilation(~S),World(~S),Body.RightLocal(),RightEvidence(~S),Prep.Permit<S,D.Store(~S)>>
def right_returned(~S:Data,node:RightNode(~S)) -> RightReturned(~S):
  Life.returned(S,D.Store(~S),C(~S),R(~S),Unit,RightOps,Body.RightLocal(),String,String,right_kernel(~S),right_body(~S),RightCompilation(~S),World(~S),RightEvidence(~S),Prep.Permit<S,D.Store(~S)>,node)
def right_rebuild(~S:Data,returned:RightReturned(~S)) -> RightNode(~S):
  Life.rebuild(S,D.Store(~S),C(~S),R(~S),Unit,RightOps,Body.RightLocal(),String,String,right_kernel(~S),right_body(~S),RightCompilation(~S),World(~S),RightEvidence(~S),Prep.Permit<S,D.Store(~S)>,returned)
def retire(~S:Data,node:RightNode(~S),world:World(~S)) -> Identity.Retirement<World(~S),RightNode(~S)>:
  Life.retire(~S,~D.Store(~S),~D.Resources(~S),~Unit,C(~S),R(~S),Unit,RightOps,Body.RightLocal(),String,String,right_kernel(~S),right_body(~S),RightCompilation(~S),RightEvidence(~S),Prep.Permit<S,D.Store(~S)>,node,world)
def reregister(~S:Data,returned:RightReturned(~S),world:World(~S)) -> Life.Reregistration<World(~S),RightNode(~S),RightReturned(~S)>:
  Life.reregister(S,D.Store(~S),C(~S),R(~S),Unit,RightOps,Body.RightLocal(),String,String,right_kernel(~S),right_body(~S),D.Resources(~S),Unit,RightEvidence(~S),Prep.Permit<S,D.Store(~S)>,returned,world)

def left_facts(~S:Data,node:LeftNode(~S)) -> Tree.GeneralizedFacts<LeftNode(~S)>:
  Tree.generalized_leaf_facts(~S,~components(),~D.resources_layout(),~Unit,~String,~String,~LeftOps,~Body.LeftLocal(),~left_kernel(~S),~left_body(~S),Leaf.registered_binding(LeftCompilation(~S),World(~S),LeftOwner(~S),LeftEvidence(~S),Prep.Permit<S,D.Store(~S)>,node))

def right_facts(~S:Data,node:RightNode(~S)) -> Tree.GeneralizedFacts<RightNode(~S)>:
  Tree.generalized_leaf_facts(~S,~components(),~D.resources_layout(),~Unit,~String,~String,~RightOps,~Body.RightLocal(),~right_kernel(~S),~right_body(~S),Leaf.registered_binding(RightCompilation(~S),World(~S),RightOwner(~S),RightEvidence(~S),Prep.Permit<S,D.Store(~S)>,node))

def facts(~S:Data,nodes:Nodes(~S)) -> Tree.GeneralizedFacts<Nodes(~S)>:
  match nodes:
    case Product.Owner{Product.Owner{left,other},right}:Tree.generalized_pair_facts(LeftTree(~S),RightNode(~S),Tree.generalized_pair_facts(LeftNode(~S),LeftNode(~S),left_facts(~S,left),left_facts(~S,other)),right_facts(~S,right))
def publish(~S:Data,_:List<&2,U32>,world:World(~S),nodes:Nodes(~S)) -> World(~S) & (Nodes(~S) & List<&2,U32>):
  (world,(nodes,[]))
def LeftReturned(~S:Data) -> Type:Life.Released<LeftCompilation(~S),World(~S),Body.LeftLocal(),LeftEvidence(~S),Prep.Permit<S,D.Store(~S)>>
def left_returned(~S:Data,node:LeftNode(~S)) -> LeftReturned(~S):
  Life.returned(S,D.Store(~S),C(~S),R(~S),Unit,LeftOps,Body.LeftLocal(),String,String,left_kernel(~S),left_body(~S),LeftCompilation(~S),World(~S),LeftEvidence(~S),Prep.Permit<S,D.Store(~S)>,node)
