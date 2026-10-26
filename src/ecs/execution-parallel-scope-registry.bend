import Base
import ./world.bend as W
import ./execution-state.bend as State
import ./execution-system.bend as Sys
import ./execution-builder.bend as Build
import ./execution-declaration.bend as D
import ./execution-parallel-scope.bend as Scope
import ./execution-parallel-registration.bend as Part
import ./execution-parallel-schedule.bend as Ready
import ./dependency-plan.bend as Plan
import ./dependency-registration.bend as Reg
import ./owner-product.bend as Product

type Runtime<-World:Type,-Scope:Type,-Owners:Type,Error:Data,Out:Data> is Type:
  Runtime{owners:Owners,nodes:List<&2,Plan.Node<String>>,entries:List<&2,Part.Entry>,invalid:Maybe<&2,Plan.Invalid<String>>,prepare:List<&2,U32> -> World -> Owners -> World & (Owners & List<&2,Scope.Permit>),invoke:List<&2,Scope.Permit> -> Scope -> Owners -> Scope & (Owners & List<&2,Ready.Completed<Error,Out>>)}
def Family() -> Type:(@-Owners:Type -> Type)
def Leaf(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~F:Family()) -> Type:
  @-Ops:(Type -> Type) -> @-Local:Type -> @-declaration:Build.Program(~S,~C,~R,~Ops) -> @-body:(@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>)) -> Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body> -> F(Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>)
def Join(~F:Family()) -> Type:
  @-L:Type -> @-R:Type -> F(L) -> F(R) -> F(Product.Owner<L,R>)
def Selection(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~Owners:Type) -> Type:
  @-F:Family() -> @-leaf:Leaf(~S,~C,~R,~E,~Error,~Out,~F) -> @-join:Join(~F) -> Owners -> F(Owners)
def leaf(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~Ops:Type -> Type,~Local:Type,~declaration:Build.Program(~S,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),~F:Family(),~leaf:Leaf(~S,~C,~R,~E,~Error,~Out,~F),~join:Join(~F),owner:Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>) -> F(Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>):
  leaf(Ops,Local,declaration,body,owner)
def pair(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R0:Type,~left:Selection(~S,~C,~R,~E,~Error,~Out,~L),~right:Selection(~S,~C,~R,~E,~Error,~Out,~R0),~F:Family(),~leaf:Leaf(~S,~C,~R,~E,~Error,~Out,~F),~join:Join(~F),owners:Product.Owner<L,R0>) -> F(Product.Owner<L,R0>):
  match owners:
    case Product.Owner{l,r}:join(L,R0,left(F,leaf,join,l),right(F,leaf,join,r))
def interpreted(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~WC:Type,~WR:Type,~Owners:Type) -> Type:
  Runtime<W.World<S,WC,WR,E>,State.Scope<S,C,R>,Owners,Error,Out>
def compile_leaf(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~WC:Type,~WR:Type,~Ops:Type -> Type,~Local:Type,~declaration:Build.Program(~S,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),owner:Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>) -> Runtime<W.World<S,WC,WR,E>,State.Scope<S,C,R>,Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>:
  match owner:
    case Sys.Owner{namespace,+id,name,access,cursor,local}:Runtime{Sys.Owner{namespace,id,name,access,cursor,local},[Plan.Node{id,D.requirement_keys(~S,~C,~R,~Ops,Build.compile(~S,~C,~R,~Ops,~declaration))}],[Part.Entry{id,Part.uses(D.requirements(~S,~C,~R,~Ops,Build.compile(~S,~C,~R,~Ops,~declaration)))}],Reg.condition_permission(D.read_only(D.requirements(~S,~C,~R,~Ops,Build.compile(~S,~C,~R,~Ops,~declaration))),id),Scope.prepare(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WC,~WR),Scope.invoke(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body)}
def prepared_right(~World:Type,~L:Type,~R:Type,left:L,leftPermits:List<&2,Scope.Permit>,result:World & (R & List<&2,Scope.Permit>)) -> World & (Product.Owner<L,R> & List<&2,Scope.Permit>):
  match result:
    case (world,(right,permits)):(world,(Product.Owner{left,right},List.append(&2,Scope.Permit,leftPermits,permits)))
def prepared_left(~World:Type,~L:Type,~R:Type,rightPrepare:List<&2,U32> -> World -> R -> World & (R & List<&2,Scope.Permit>),ids:List<&2,U32>,right:R,result:World & (L & List<&2,Scope.Permit>)) -> World & (Product.Owner<L,R> & List<&2,Scope.Permit>):
  match result:
    case (world,(left,permits)):prepared_right(~World,~L,~R,left,permits,rightPrepare(ids,world,right))
def prepare_pair(~World:Type,~L:Type,~R:Type,leftPrepare:List<&2,U32> -> World -> L -> World & (L & List<&2,Scope.Permit>),rightPrepare:List<&2,U32> -> World -> R -> World & (R & List<&2,Scope.Permit>),+ids:List<&2,U32>,world:World,owners:Product.Owner<L,R>) -> World & (Product.Owner<L,R> & List<&2,Scope.Permit>):
  match owners:
    case Product.Owner{left,right}:prepared_left(~World,~L,~R,rightPrepare,ids,right,leftPrepare(ids,world,left))
def invoked_right(~H:Type,~L:Type,~R:Type,~Error:Data,~Out:Data,left:L,leftOut:List<&2,Ready.Completed<Error,Out>>,result:H & (R & List<&2,Ready.Completed<Error,Out>>)) -> H & (Product.Owner<L,R> & List<&2,Ready.Completed<Error,Out>>):
  match result:
    case (scope,(right,out)):(scope,(Product.Owner{left,right},List.append(&2,Ready.Completed<Error,Out>,leftOut,out)))
def invoked_left(~H:Type,~L:Type,~R:Type,~Error:Data,~Out:Data,rightInvoke:List<&2,Scope.Permit> -> H -> R -> H & (R & List<&2,Ready.Completed<Error,Out>>),permits:List<&2,Scope.Permit>,right:R,result:H & (L & List<&2,Ready.Completed<Error,Out>>)) -> H & (Product.Owner<L,R> & List<&2,Ready.Completed<Error,Out>>):
  match result:
    case (scope,(left,out)):invoked_right(~H,~L,~R,~Error,~Out,left,out,rightInvoke(permits,scope,right))
def invoke_pair(~H:Type,~L:Type,~R:Type,~Error:Data,~Out:Data,leftInvoke:List<&2,Scope.Permit> -> H -> L -> H & (L & List<&2,Ready.Completed<Error,Out>>),rightInvoke:List<&2,Scope.Permit> -> H -> R -> H & (R & List<&2,Ready.Completed<Error,Out>>),+permits:List<&2,Scope.Permit>,scope:H,owners:Product.Owner<L,R>) -> H & (Product.Owner<L,R> & List<&2,Ready.Completed<Error,Out>>):
  match owners:
    case Product.Owner{left,right}:invoked_left(~H,~L,~R,~Error,~Out,rightInvoke,permits,right,leftInvoke(permits,scope,left))
def compile_join(~World:Type,~H:Type,~Error:Data,~Out:Data,~L:Type,~R:Type,left:Runtime<World,H,L,Error,Out>,right:Runtime<World,H,R,Error,Out>) -> Runtime<World,H,Product.Owner<L,R>,Error,Out>:
  match left right:
    case Runtime{l,ln,le,li,lp,lv} Runtime{r,rn,re,ri,rp,rv}:Runtime{Product.Owner{l,r},List.append(&2,Plan.Node<String>,ln,rn),List.append(&2,Part.Entry,le,re),Plan.first_error(~String,li,ri),(ids => world => owners => prepare_pair(~World,~L,~R,lp,rp,ids,world,owners)),(permits => scope => owners => invoke_pair(~H,~L,~R,~Error,~Out,lv,rv,permits,scope,owners))}
def compile(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~WC:Type,~WR:Type,~Owners:Type,~selection:Selection(~S,~C,~R,~E,~Error,~Out,~Owners),owners:Owners) -> Runtime<W.World<S,WC,WR,E>,State.Scope<S,C,R>,Owners,Error,Out>:
  selection(interpreted(~S,~C,~R,~E,~Error,~Out,~WC,~WR),compile_leaf(~S,~C,~R,~E,~Error,~Out,~WC,~WR),compile_join(~W.World<S,WC,WR,E>,~State.Scope<S,C,R>,~Error,~Out),owners)
