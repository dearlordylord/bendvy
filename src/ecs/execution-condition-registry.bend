import Base
import ./world.bend as W
import ./execution-parallel-scope.bend as Scope
import ./execution-reservation-task.bend as Effect
import ./execution-state.bend as State
import ./execution-system.bend as Sys
import ./execution-builder.bend as Build
import ./execution-declaration.bend as D
import ./dependency-registration.bend as Reg
import ./dependency-plan.bend as Plan
import ./dependency-executor.bend as Exec

def Dispatch(~World:Type,~Owners:Type,~Error:Data) -> Type:
  Owners -> World -> U32 -> IO(Owners & (World & Exec.Invocation<Error,Bool>))
type Registry<-World:Type,-Owners:Type,-Error:Data,-dispatch:Dispatch(~World,~Owners,~Error)> is Type:
  Registry{owners:Owners,nodes:List<&2,Plan.Node<String>>,invalid:Maybe<&2,Plan.Invalid<String>>}
def System(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Bool)) -> Type:
  Sys.Owner<S,C,C,R,E,Ops,Local,Error,Bool,declaration,body>
def permission(allowed:Bool,id:U32) -> Maybe<&2,Plan.Invalid<String>>:
  match allowed:
    case True{}:None{}
    case False{}:Some{Plan.InvalidCondition{id}}
def left_returned(~World:Type,~L:Type,~R:Type,~Error:Data,right:R,ids:List<&2,U32>,result:L & (World & Exec.Invocation<Error,Bool>)) -> IO(Reg.Product<L,R> & (World & Exec.Invocation<Error,Bool>)):
  match result:
    case (left,status):IO.pure(Reg.Product<L,R> & (World & Exec.Invocation<Error,Bool>),(Reg.Product{left,right,ids},status))
def right_returned(~World:Type,~L:Type,~R:Type,~Error:Data,left:L,ids:List<&2,U32>,result:R & (World & Exec.Invocation<Error,Bool>)) -> IO(Reg.Product<L,R> & (World & Exec.Invocation<Error,Bool>)):
  match result:
    case (right,status):IO.pure(Reg.Product<L,R> & (World & Exec.Invocation<Error,Bool>),(Reg.Product{left,right,ids},status))
def pair_selected(~World:Type,~L:Type,~R:Type,~Error:Data,~left:Dispatch(~World,~L,~Error),~right:Dispatch(~World,~R,~Error),selected:Bool,l:L,r:R,ids:List<&2,U32>,world:World,id:U32) -> IO(Reg.Product<L,R> & (World & Exec.Invocation<Error,Bool>)):
  match selected:
    case True{}:IO.bind(L & (World & Exec.Invocation<Error,Bool>),Reg.Product<L,R> & (World & Exec.Invocation<Error,Bool>),left(l,world,id),result => left_returned(~World,~L,~R,~Error,r,ids,result))
    case False{}:IO.bind(R & (World & Exec.Invocation<Error,Bool>),Reg.Product<L,R> & (World & Exec.Invocation<Error,Bool>),right(r,world,id),result => right_returned(~World,~L,~R,~Error,l,ids,result))
def paired_dispatch_actual(~World:Type,~L:Type,~R:Type,~Error:Data,~left:Dispatch(~World,~L,~Error),~right:Dispatch(~World,~R,~Error),owners:Reg.Product<L,R>,world:World,+id:U32) -> IO(Reg.Product<L,R> & (World & Exec.Invocation<Error,Bool>)):
  match owners:
    case Reg.Product{l,r,+ids}:pair_selected(~World,~L,~R,~Error,~left,~right,Reg.contains(ids,id),l,r,ids,world,id)
def paired_dispatch(~World:Type,~L:Type,~R:Type,~Error:Data,~left:Dispatch(~World,~L,~Error),~right:Dispatch(~World,~R,~Error),owners:Reg.Product<L,R>,world:World,id:U32) -> IO(Reg.Product<L,R> & (World & Exec.Invocation<Error,Bool>)):
  paired_dispatch_actual(~World,~L,~R,~Error,~left,~right,owners,world,id)
def compile_join(~Error:Data,~World:Type,~L:Type,~R:Type,~left:Dispatch(~World,~L,~Error),~right:Dispatch(~World,~R,~Error),l:Registry<World,L,Error,left>,r:Registry<World,R,Error,right>) -> Registry<World,Reg.Product<L,R>,Error,paired_dispatch(~World,~L,~R,~Error,~left,~right)>:
  match l r:
    case Registry{l,+ln,li} Registry{r,rn,ri}:Registry{Reg.Product{l,r,Reg.ids(ln)},List.append(&2,Plan.Node<String>,ln,rn),Plan.first_error(~String,li,ri)}
def empty_dispatch(~World:Type,~Error:Data,owner:Unit,world:World,_:U32) -> IO(Unit & (World & Exec.Invocation<Error,Bool>)):
  IO.pure(Unit & (World & Exec.Invocation<Error,Bool>),(owner,(world,Exec.AdmissionRefused{})))
def compile_empty(~Error:Data,~World:Type) -> Registry<World,Unit,Error,empty_dispatch(~World,~Error)>:
  Registry{Unit{},[],None{}}
# The factory supplies the closed construction witness once. Actual inventory
# remains affine across registry admission and every dispatch; no method table
# or runtime reconstruction of the declaration is stored in this binding.
def RetainedSystem(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Bool)) -> Type:
  Scope.CompiledBinding<D.Compilation<S,C,C,R,Ops>,System(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body)>
def retained_leaf_returned(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Bool),result:D.Compilation<S,C,C,R,Ops> & Sys.RunResult<W.World<S,C,R,E>,System(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body),Error,Bool>) -> IO(RetainedSystem(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body) & (W.World<S,C,R,E> & Exec.Invocation<Error,Bool>)):
  match result:
    case (compilation,Sys.Refused{world,system}):IO.pure(RetainedSystem(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body) & (W.World<S,C,R,E> & Exec.Invocation<Error,Bool>),(Scope.CompiledBinding{compilation,system},(world,Exec.AdmissionRefused{})))
    case (compilation,Sys.Executed{world,system,Sys.Success{output}}):IO.pure(RetainedSystem(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body) & (W.World<S,C,R,E> & Exec.Invocation<Error,Bool>),(Scope.CompiledBinding{compilation,system},(world,Exec.Completed{output})))
    case (compilation,Sys.Executed{world,system,Sys.BodyError{error,output}}):IO.pure(RetainedSystem(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body) & (W.World<S,C,R,E> & Exec.Invocation<Error,Bool>),(Scope.CompiledBinding{compilation,system},(world,Exec.BodyError{error,output})))
def retained_leaf_selected(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Bool),~caps:Ops(Effect.Granted,State.Scope<S,C,R>),selected:Bool,node:RetainedSystem(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body),world:W.World<S,C,R,E>) -> IO(RetainedSystem(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body) & (W.World<S,C,R,E> & Exec.Invocation<Error,Bool>)):
  match selected node:
    case False{} node:IO.pure(RetainedSystem(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body) & (W.World<S,C,R,E> & Exec.Invocation<Error,Bool>),(node,(world,Exec.AdmissionRefused{})))
    case True{} Scope.CompiledBinding{compilation,owner}:IO.bind(D.Compilation<S,C,C,R,Ops> & Sys.RunResult<W.World<S,C,R,E>,System(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body),Error,Bool>,RetainedSystem(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body) & (W.World<S,C,R,E> & Exec.Invocation<Error,Bool>),Sys.run_retained_compilation(~S,~C,~R,~E,~Ops,~Local,~Error,~Bool,~declaration,~body,~caps,compilation,owner,world),retained_leaf_returned(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body))
def retained_leaf_dispatch(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Bool),~construction:D.Compilation<S,C,C,R,Ops>,node:RetainedSystem(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body),world:W.World<S,C,R,E>,id:U32) -> IO(RetainedSystem(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body) & (W.World<S,C,R,E> & Exec.Invocation<Error,Bool>)):
  match node:
    case Scope.CompiledBinding{compilation,Sys.Owner{namespace,+actual,name,access,cursor,local}}:retained_leaf_selected(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body,~D.trusted_construction_caps(~S,~C,~C,~R,~Ops,construction),U32.is_eq(actual,id),Scope.CompiledBinding{compilation,Sys.Owner{namespace,actual,name,access,cursor,local}},world)
def compile_retained_leaf(~Error:Data,~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Bool),~construction:D.Compilation<S,C,C,R,Ops>,node:RetainedSystem(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body)) -> Registry<W.World<S,C,R,E>,RetainedSystem(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body),Error,retained_leaf_dispatch(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body,~construction)>:
  match node:
    case Scope.CompiledBinding{D.Supported{D.Declaration{caps,+requirements},recipes},Sys.Owner{namespace,+id,name,access,cursor,local}}:Registry{Scope.CompiledBinding{D.Supported{D.Declaration{caps,requirements},recipes},Sys.Owner{namespace,id,name,access,cursor,local}},[Plan.Node{id,D.qualified(requirements)}],permission(D.read_only(requirements),id)}
    case Scope.CompiledBinding{D.Unsupported{caps,+requirements,recipes},Sys.Owner{namespace,+id,name,access,cursor,local}}:Registry{Scope.CompiledBinding{D.Unsupported{caps,requirements,recipes},Sys.Owner{namespace,id,name,access,cursor,local}},[Plan.Node{id,D.qualified(requirements)}],Some{Plan.InvalidCondition{id}}}
def Family(~Error:Data) -> Type:
  @-World:Type -> @-Owners:Type -> @-dispatch:Dispatch(~World,~Owners,~Error) -> Type
def Leaf(~Error:Data,~F:Family(~Error)) -> Type:
  @-S:Data -> @-C:Type -> @-R:Type -> @-E:Data -> @-Ops:(Data -> Type -> Type) -> @-Local:Type -> @-declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops) -> @-body:Sys.Body(~S,~Ops,~Local,~Error,~Bool) -> @-construction:D.Compilation<S,C,C,R,Ops> -> RetainedSystem(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body) -> F(W.World<S,C,R,E>,RetainedSystem(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body),retained_leaf_dispatch(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body,~construction))
def Join(~Error:Data,~F:Family(~Error)) -> Type:
  @-World:Type -> @-L:Type -> @-R:Type -> @-left:Dispatch(~World,~L,~Error) -> @-right:Dispatch(~World,~R,~Error) -> F(World,L,left) -> F(World,R,right) -> F(World,Reg.Product<L,R>,paired_dispatch(~World,~L,~R,~Error,~left,~right))
def Vacant(~Error:Data,~F:Family(~Error)) -> Type:
  @-World:Type -> F(World,Unit,empty_dispatch(~World,~Error))
def Selection(~World:Type,~Owners:Type,~Error:Data,~dispatch:Dispatch(~World,~Owners,~Error)) -> Type:
  @-F:Family(~Error) -> @-leaf:Leaf(~Error,~F) -> @-pair:Join(~Error,~F) -> @-empty:Vacant(~Error,~F) -> Owners -> F(World,Owners,dispatch)
def Checked(~Error:Data,~World:Type,~Owners:Type,~dispatch:Dispatch(~World,~Owners,~Error)) -> Type:
  Registry<World,Owners,Error,dispatch>
def compile(~World:Type,~Owners:Type,~Error:Data,~dispatch:Dispatch(~World,~Owners,~Error),~selection:Selection(~World,~Owners,~Error,~dispatch),owners:Owners) -> Registry<World,Owners,Error,dispatch>:
  selection(Checked(~Error),compile_retained_leaf(~Error),compile_join(~Error),compile_empty(~Error),owners)
def leaf(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Bool),~construction:D.Compilation<S,C,C,R,Ops>,~F:Family(~Error),~leaf:Leaf(~Error,~F),~pair:Join(~Error,~F),~empty:Vacant(~Error,~F),node:RetainedSystem(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body)) -> F(W.World<S,C,R,E>,RetainedSystem(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body),retained_leaf_dispatch(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body,~construction)):
  leaf(S,C,R,E,Ops,Local,declaration,body,construction,node)
def paired(~World:Type,~L:Type,~R:Type,~Error:Data,~left:Dispatch(~World,~L,~Error),~right:Dispatch(~World,~R,~Error),~leftSelection:Selection(~World,~L,~Error,~left),~rightSelection:Selection(~World,~R,~Error,~right),~F:Family(~Error),~leaf:Leaf(~Error,~F),~pair:Join(~Error,~F),~empty:Vacant(~Error,~F),owners:Reg.Product<L,R>) -> F(World,Reg.Product<L,R>,paired_dispatch(~World,~L,~R,~Error,~left,~right)):
  match owners:
    case Reg.Product{l,r,_}:pair(World,L,R,left,right,leftSelection(F,leaf,pair,empty,l),rightSelection(F,leaf,pair,empty,r))
def empty(~World:Type,~Error:Data,~F:Family(~Error),~leaf:Leaf(~Error,~F),~pair:Join(~Error,~F),~empty:Vacant(~Error,~F),_:Unit) -> F(World,Unit,empty_dispatch(~World,~Error)):
  empty(World)

def RetainedLeaf(~Error:Data,~F:Family(~Error)) -> Type:
  Leaf(~Error,~F)
def RetainedSelection(~World:Type,~Owners:Type,~Error:Data,~dispatch:Dispatch(~World,~Owners,~Error)) -> Type:
  Selection(~World,~Owners,~Error,~dispatch)
def compile_retained(~World:Type,~Owners:Type,~Error:Data,~dispatch:Dispatch(~World,~Owners,~Error),~selection:RetainedSelection(~World,~Owners,~Error,~dispatch),owners:Owners) -> Registry<World,Owners,Error,dispatch>:
  compile(~World,~Owners,~Error,~dispatch,~selection,owners)
