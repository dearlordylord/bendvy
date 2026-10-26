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
import ./execution-command-system.bend as Cmd
import ./execution-command-scope.bend as CommandScope
import ./execution-composer-layout.bend as Layout
import ./change-tick.bend as Tick

type Runtime<-World:Type,-Scope:Type,-Owners:Type,Error:Data,Out:Data> is Type:
  Runtime{owners:Owners,nodes:List<&2,Plan.Node<String>>,entries:List<&2,Part.Entry>,invalid:Maybe<&2,Plan.Invalid<String>>,deferred:List<&2,U32>,pending:List<&2,U32> -> World -> Owners -> World & (Owners & Bool),publish:List<&2,U32> -> Tick.Tick -> World -> Owners -> World & Owners,prepare:List<&2,U32> -> World -> Owners -> World & (Owners & List<&2,Scope.Permit>),invoke:List<&2,Scope.Permit> -> Scope -> Owners -> Scope & (Owners & List<&2,Ready.Completed<Error,Out>>)}
def Family() -> Type:(@-Owners:Type -> Type)
def Leaf(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~F:Family()) -> Type:
  @-Ops:(Type -> Type) -> @-Local:Type -> @-declaration:Build.Program(~S,~C,~R,~Ops) -> @-body:(@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>)) -> Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body> -> F(Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>)
def Join(~F:Family()) -> Type:
  @-L:Type -> @-R:Type -> F(L) -> F(R) -> F(Product.Owner<L,R>)
def CommandLeaf(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~F:Family()) -> Type:
  @-layout:Layout.Layout -> @-route:Layout.Route -> @-same:{WC == Layout.columns(~S,layout) : Type} -> @-valid:{Layout.grant_valid(~layout,~route) == True{} : Bool} -> @-Ops:(Type -> Type -> Type) -> @-User:Type -> @-declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops) -> @-body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out) -> Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> -> F(Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>)
def Selection(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~Owners:Type) -> Type:
  @-F:Family() -> @-leaf:Leaf(~S,~WC,~C,~R,~E,~Error,~Out,~F) -> @-command:CommandLeaf(~S,~WC,~C,~R,~E,~Error,~Out,~F) -> @-join:Join(~F) -> Owners -> F(Owners)
def leaf(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~Ops:Type -> Type,~Local:Type,~declaration:Build.Program(~S,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),~F:Family(),~leaf:Leaf(~S,~WC,~C,~R,~E,~Error,~Out,~F),~command:CommandLeaf(~S,~WC,~C,~R,~E,~Error,~Out,~F),~join:Join(~F),owner:Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>) -> F(Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>):
  leaf(Ops,Local,declaration,body,owner)
def pair(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R0:Type,~left:Selection(~S,~WC,~C,~R,~E,~Error,~Out,~L),~right:Selection(~S,~WC,~C,~R,~E,~Error,~Out,~R0),~F:Family(),~leaf:Leaf(~S,~WC,~C,~R,~E,~Error,~Out,~F),~command:CommandLeaf(~S,~WC,~C,~R,~E,~Error,~Out,~F),~join:Join(~F),owners:Product.Owner<L,R0>) -> F(Product.Owner<L,R0>):
  match owners:
    case Product.Owner{l,r}:join(L,R0,left(F,leaf,command,join,l),right(F,leaf,command,join,r))
def interpreted(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~WC:Type,~WR:Type,~Owners:Type) -> Type:
  Runtime<W.World<S,WC,WR,E>,State.Scope<S,C,R>,Owners,Error,Out>
def compile_leaf(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~WC:Type,~WR:Type,~Ops:Type -> Type,~Local:Type,~declaration:Build.Program(~S,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),owner:Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>) -> Runtime<W.World<S,WC,WR,E>,State.Scope<S,C,R>,Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>:
  match owner:
    case Sys.Owner{namespace,+id,name,access,cursor,local}:Runtime{Sys.Owner{namespace,id,name,access,cursor,local},[Plan.Node{id,D.requirement_keys(~S,~C,~R,~Ops,Build.compile(~S,~C,~R,~Ops,~declaration))}],[Part.Entry{id,Part.uses(D.requirements(~S,~C,~R,~Ops,Build.compile(~S,~C,~R,~Ops,~declaration)))}],Reg.condition_permission(D.read_only(D.requirements(~S,~C,~R,~Ops,Build.compile(~S,~C,~R,~Ops,~declaration))),id),[],(ids => world => owner => (world,(owner,False{}))),(ids => tick => world => owner => (world,owner)),Scope.prepare(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WC,~WR),Scope.invoke(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body)}
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
def pending_right(~World:Type,~L:Type,~R:Type,left:L,a:Bool,result:World & (R & Bool)) -> World & (Product.Owner<L,R> & Bool):
  match result:
    case (world,(right,b)):(world,(Product.Owner{left,right},Bool.or(a,b)))
def pending_left(~World:Type,~L:Type,~R:Type,rightPending:List<&2,U32> -> World -> R -> World & (R & Bool),ids:List<&2,U32>,right:R,result:World & (L & Bool)) -> World & (Product.Owner<L,R> & Bool):
  match result:
    case (world,(left,a)):pending_right(~World,~L,~R,left,a,rightPending(ids,world,right))
def pending_pair(~World:Type,~L:Type,~R:Type,leftPending:List<&2,U32> -> World -> L -> World & (L & Bool),rightPending:List<&2,U32> -> World -> R -> World & (R & Bool),+ids:List<&2,U32>,world:World,owners:Product.Owner<L,R>) -> World & (Product.Owner<L,R> & Bool):
  match owners:
    case Product.Owner{left,right}:pending_left(~World,~L,~R,rightPending,ids,right,leftPending(ids,world,left))
def published_right(~World:Type,~L:Type,~R:Type,left:L,result:World & R) -> World & Product.Owner<L,R>:
  match result:
    case (world,right):(world,Product.Owner{left,right})
def published_left(~World:Type,~L:Type,~R:Type,rightPublish:List<&2,U32> -> Tick.Tick -> World -> R -> World & R,ids:List<&2,U32>,tick:Tick.Tick,right:R,result:World & L) -> World & Product.Owner<L,R>:
  match result:
    case (world,left):published_right(~World,~L,~R,left,rightPublish(ids,tick,world,right))
def publish_pair(~World:Type,~L:Type,~R:Type,leftPublish:List<&2,U32> -> Tick.Tick -> World -> L -> World & L,rightPublish:List<&2,U32> -> Tick.Tick -> World -> R -> World & R,+ids:List<&2,U32>,+tick:Tick.Tick,world:World,owners:Product.Owner<L,R>) -> World & Product.Owner<L,R>:
  match owners:
    case Product.Owner{left,right}:published_left(~World,~L,~R,rightPublish,ids,tick,right,leftPublish(ids,tick,world,left))
def compile_join(~World:Type,~H:Type,~Error:Data,~Out:Data,~L:Type,~R:Type,left:Runtime<World,H,L,Error,Out>,right:Runtime<World,H,R,Error,Out>) -> Runtime<World,H,Product.Owner<L,R>,Error,Out>:
  match left right:
    case Runtime{l,ln,le,li,ld,lq,ls,lp,lv} Runtime{r,rn,re,ri,rd,rq,rs,rp,rv}:Runtime{Product.Owner{l,r},List.append(&2,Plan.Node<String>,ln,rn),List.append(&2,Part.Entry,le,re),Plan.first_error(~String,li,ri),List.append(&2,U32,ld,rd),(ids => world => owners => pending_pair(~World,~L,~R,lq,rq,ids,world,owners)),(ids => tick => world => owners => publish_pair(~World,~L,~R,ls,rs,ids,tick,world,owners)),(ids => world => owners => prepare_pair(~World,~L,~R,lp,rp,ids,world,owners)),(permits => scope => owners => invoke_pair(~H,~L,~R,~Error,~Out,lv,rv,permits,scope,owners))}
def compile_command(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~WR:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{WC == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~Ops:Type -> Type -> Type,~User:Type,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),owner:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>) -> Runtime<W.World<S,WC,WR,E>,State.Scope<S,C,R>,Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>,Error,Out>:
  match owner:
    case Cmd.Owner{Sys.Owner{namespace,+id,name,access,cursor,local}}:Runtime{Cmd.Owner{Sys.Owner{namespace,id,name,access,cursor,local}},[Plan.Node{id,D.requirement_keys(~S,~C,~R,~Cmd.ScopedOps(~S,~layout,~route,~Ops),Build.compile(~S,~C,~R,~Cmd.ScopedOps(~S,~layout,~route,~Ops),~Cmd.program_for_buffer(~S,~C,~R,~layout,~route,~Ops,~declaration)))}],[Part.Entry{id,Part.uses(D.requirements(~S,~C,~R,~Cmd.ScopedOps(~S,~layout,~route,~Ops),Build.compile(~S,~C,~R,~Cmd.ScopedOps(~S,~layout,~route,~Ops),~Cmd.program_for_buffer(~S,~C,~R,~layout,~route,~Ops,~declaration))))}],Some{Plan.InvalidCondition{id}},[id],CommandScope.pending(~S,~WC,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR),CommandScope.publish(~S,~WC,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR,~same,~valid),CommandScope.prepare(~S,~WC,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR),CommandScope.invoke(~S,~WC,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body)}
def command(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{WC == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~Ops:Type -> Type -> Type,~User:Type,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~F:Family(),~leaf:Leaf(~S,~WC,~C,~R,~E,~Error,~Out,~F),~command:CommandLeaf(~S,~WC,~C,~R,~E,~Error,~Out,~F),~join:Join(~F),owner:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>) -> F(Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>):
  command(layout,route,same,valid,Ops,User,declaration,body,owner)
def compile(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~WC:Type,~WR:Type,~Owners:Type,~selection:Selection(~S,~WC,~C,~R,~E,~Error,~Out,~Owners),owners:Owners) -> Runtime<W.World<S,WC,WR,E>,State.Scope<S,C,R>,Owners,Error,Out>:
  selection(interpreted(~S,~C,~R,~E,~Error,~Out,~WC,~WR),compile_leaf(~S,~C,~R,~E,~Error,~Out,~WC,~WR),compile_command(~S,~WC,~C,~R,~E,~Error,~Out,~WR),compile_join(~W.World<S,WC,WR,E>,~State.Scope<S,C,R>,~Error,~Out),owners)
