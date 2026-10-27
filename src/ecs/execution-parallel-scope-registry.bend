import Base
import ./execution-reservation-task.bend as Effect
import ./execution-reservation-permit.bend as RuntimePermit
import ./execution-prepared.bend as Prep
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

type Runtime<S:Data,-World:Type,P:Data,-Scope:Type,-Owners:Type,Error:Data,Out:Data> is Type:
  Runtime{-Held:Type,-restore:Held -> Owners,held:Held,nodes:List<&2,Plan.Node<String>>,entries:List<&2,Part.Entry>,invalid:Maybe<&2,Plan.Invalid<String>>,deferred:List<&2,U32>,pending:List<&2,U32> -> World -> Held -> World & (Held & Bool),publish:List<&2,U32> -> Tick.Tick -> World -> Held -> World & Held,prepare:List<&2,U32> -> World -> Held -> Prep.Preparation<World,Held,P>,invoke:Scope -> Prep.Prepared<World,Held,P> -> Effect.Task<S,RuntimePermit.Permit,Prep.Invocation<Scope,World,Held,P,List<&2,Ready.Completed<Error,Out>>>>}
def Family() -> Type:(@-Owners:Type -> Type)
def Leaf(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~F:Family()) -> Type:
  @-Ops:(Data -> Type -> Type) -> @-Local:Type -> @-declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops) -> @-body:(Sys.Body(~S,~Ops,~Local,~Error,~Out)) -> Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body> -> F(Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>)
def Join(~F:Family()) -> Type:
  @-L:Type -> @-R:Type -> F(L) -> F(R) -> F(Product.Owner<L,R>)
def CommandLeaf(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~F:Family()) -> Type:
  @-layout:Layout.Layout -> @-route:Layout.Route -> @-same:{WC == Layout.columns(~S,layout) : Type} -> @-valid:{Layout.grant_valid(~layout,~route) == True{} : Bool} -> @-Ops:(Data -> Type -> Type -> Type) -> @-User:Type -> @-declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops) -> @-body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out) -> Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> -> F(Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>)
def Selection(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~Owners:Type) -> Type:
  @-F:Family() -> @-leaf:Leaf(~S,~WC,~C,~R,~E,~Error,~Out,~F) -> @-command:CommandLeaf(~S,~WC,~C,~R,~E,~Error,~Out,~F) -> @-join:Join(~F) -> Owners -> F(Owners)
def leaf(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~Ops:Data -> Type -> Type,~Local:Type,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~F:Family(),~leaf:Leaf(~S,~WC,~C,~R,~E,~Error,~Out,~F),~command:CommandLeaf(~S,~WC,~C,~R,~E,~Error,~Out,~F),~join:Join(~F),owner:Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>) -> F(Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>):
  leaf(Ops,Local,declaration,body,owner)
def pair(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R0:Type,~left:Selection(~S,~WC,~C,~R,~E,~Error,~Out,~L),~right:Selection(~S,~WC,~C,~R,~E,~Error,~Out,~R0),~F:Family(),~leaf:Leaf(~S,~WC,~C,~R,~E,~Error,~Out,~F),~command:CommandLeaf(~S,~WC,~C,~R,~E,~Error,~Out,~F),~join:Join(~F),owners:Product.Owner<L,R0>) -> F(Product.Owner<L,R0>):
  match owners:
    case Product.Owner{l,r}:join(L,R0,left(F,leaf,command,join,l),right(F,leaf,command,join,r))
def interpreted(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~WC:Type,~WR:Type,~Owners:Type) -> Type:
  Runtime<S,W.World<S,WC,WR,E>,Prep.Permit<S,WC>,State.Scope<S,C,R>,Owners,Error,Out>
def trusted_leaf_prepared(~World:Type,~Owner:Type,~P:Data,result:World & Prep.Prepared<World,Owner,P>) -> Prep.Preparation<World,Owner,P>:
  match result:
    case (world,prepared):Prep.PreparationReady{world,prepared}
def binding_prepared(~Compilation:Type,~World:Type,~Owner:Type,~P:Data,result:Compilation & Prep.Preparation<World,Owner,P>) -> Prep.Preparation<World,Scope.CompiledBinding<Compilation,Owner>,P>:
  match result:
    case (compilation,Prep.PreparationReady{world,Prep.Prepared{namespace,owner,permits,provenance}}):Prep.PreparationReady{world,Prep.Prepared{namespace,Scope.CompiledBinding{compilation,owner},permits,provenance}}
    case (compilation,Prep.PreparationRefused{world,Prep.Inventory{owner,provenance}}):Prep.PreparationRefused{world,Prep.Inventory{Scope.CompiledBinding{compilation,owner},provenance}}
def binding_invoked(~Compilation:Type,~World:Type,~H:Type,~Owner:Type,~P:Data,~Status:Data,result:Compilation & Prep.Invocation<H,World,Owner,P,Status>) -> Prep.Invocation<H,World,Scope.CompiledBinding<Compilation,Owner>,P,Status>:
  match result:
    case (compilation,Prep.Invoked{scope,Prep.Prepared{namespace,owner,permits,provenance},status}):Prep.Invoked{scope,Prep.Prepared{namespace,Scope.CompiledBinding{compilation,owner},permits,provenance},status}
    case (compilation,Prep.InvocationRefused{scope,Prep.Prepared{namespace,owner,permits,provenance},status}):Prep.InvocationRefused{scope,Prep.Prepared{namespace,Scope.CompiledBinding{compilation,owner},permits,provenance},status}
    case (compilation,Prep.InvocationInventoryRefused{scope,Prep.Inventory{owner,provenance},status}):Prep.InvocationInventoryRefused{scope,Prep.Inventory{Scope.CompiledBinding{compilation,owner},provenance},status}
def no_structural(~Ops:Data -> Type -> Type,~H:Type,caps:Ops(Effect.Granted,H)) -> Ops(Effect.Granted,H) & RuntimePermit.Grant:
  (caps,RuntimePermit.NoStructural{})
def no_pending(~World:Type,~Owner:Type,ids:List<&2,U32>,world:World,owner:Owner) -> World & (Owner & Bool):
  (world,(owner,False{}))
def no_publish(~World:Type,~Owner:Type,ids:List<&2,U32>,tick:Tick.Tick,world:World,owner:Owner) -> World & Owner:
  (world,owner)
def pending_binding_returned(~World:Type,~Compilation:Type,~Owner:Type,compilation:Compilation,result:World & (Owner & Bool)) -> World & (Scope.CompiledBinding<Compilation,Owner> & Bool):
  match result:
    case (world,(owner,pending)):(world,(Scope.CompiledBinding{compilation,owner},pending))
def pending_binding(~World:Type,~Compilation:Type,~Owner:Type,~pending:List<&2,U32> -> World -> Owner -> World & (Owner & Bool),ids:List<&2,U32>,world:World,binding:Scope.CompiledBinding<Compilation,Owner>) -> World & (Scope.CompiledBinding<Compilation,Owner> & Bool):
  match binding:
    case Scope.CompiledBinding{compilation,owner}:pending_binding_returned(~World,~Compilation,~Owner,compilation,pending(ids,world,owner))
def publish_binding_returned(~World:Type,~Compilation:Type,~Owner:Type,compilation:Compilation,result:World & Owner) -> World & Scope.CompiledBinding<Compilation,Owner>:
  match result:
    case (world,owner):(world,Scope.CompiledBinding{compilation,owner})
def publish_binding(~World:Type,~Compilation:Type,~Owner:Type,~publish:List<&2,U32> -> Tick.Tick -> World -> Owner -> World & Owner,ids:List<&2,U32>,tick:Tick.Tick,world:World,binding:Scope.CompiledBinding<Compilation,Owner>) -> World & Scope.CompiledBinding<Compilation,Owner>:
  match binding:
    case Scope.CompiledBinding{compilation,owner}:publish_binding_returned(~World,~Compilation,~Owner,compilation,publish(ids,tick,world,owner))
def prepare_binding(~Compilation:Type,~World:Type,~Owner:Type,~P:Data,~prepare:Compilation -> List<&2,U32> -> World -> Owner -> Compilation & Prep.Preparation<World,Owner,P>,ids:List<&2,U32>,world:World,binding:Scope.CompiledBinding<Compilation,Owner>) -> Prep.Preparation<World,Scope.CompiledBinding<Compilation,Owner>,P>:
  match binding:
    case Scope.CompiledBinding{compilation,owner}:binding_prepared(~Compilation,~World,~Owner,~P,prepare(compilation,ids,world,owner))
def invoke_binding(~S:Data,~Compilation:Type,~World:Type,~H:Type,~Owner:Type,~P:Data,~Status:Data,~invoke:Compilation -> H -> Prep.Prepared<World,Owner,P> -> Effect.Task<S,RuntimePermit.Permit,Compilation & Prep.Invocation<H,World,Owner,P,Status>>,scope:H,prepared:Prep.Prepared<World,Scope.CompiledBinding<Compilation,Owner>,P>) -> Effect.Task<S,RuntimePermit.Permit,Prep.Invocation<H,World,Scope.CompiledBinding<Compilation,Owner>,P,Status>>:
  match prepared:
    case Prep.Prepared{namespace,Scope.CompiledBinding{compilation,owner},permits,provenance}:Sys.map(S,RuntimePermit.Permit,Compilation & Prep.Invocation<H,World,Owner,P,Status>,Prep.Invocation<H,World,Scope.CompiledBinding<Compilation,Owner>,P,Status>,invoke(compilation,scope,Prep.Prepared{namespace,owner,permits,provenance}),result => binding_invoked(~Compilation,~World,~H,~Owner,~P,~Status,result))
def leaf_runtime(~S:Data,~World:Type,~P:Data,~H:Type,~Owner:Type,~Error:Data,~Out:Data,~Compilation:Type,~pending:List<&2,U32> -> World -> Owner -> World & (Owner & Bool),~publish:List<&2,U32> -> Tick.Tick -> World -> Owner -> World & Owner,~prepare:Compilation -> List<&2,U32> -> World -> Owner -> Compilation & Prep.Preparation<World,Owner,P>,~invoke:Compilation -> H -> Prep.Prepared<World,Owner,P> -> Effect.Task<S,RuntimePermit.Permit,Compilation & Prep.Invocation<H,World,Owner,P,List<&2,Ready.Completed<Error,Out>>>>,owner:Owner,compilation:Compilation,+id:U32,+access:List<&2,D.Access>,supported:Bool,deferred:List<&2,U32>,condition:Bool) -> Runtime<S,World,P,H,Owner,Error,Out>:
  Runtime{Scope.CompiledBinding<Compilation,Owner>,Scope.restore_binding(~Compilation,~Owner),Scope.CompiledBinding{compilation,owner},[Plan.Node{id,D.qualified(access)}],[Part.Entry{id,Part.uses(access)}],Reg.condition_permission(Bool.and(condition,Bool.and(supported,D.read_only(access))),id),deferred,pending_binding(~World,~Compilation,~Owner,~pending),publish_binding(~World,~Compilation,~Owner,~publish),prepare_binding(~Compilation,~World,~Owner,~P,~prepare),invoke_binding(~S,~Compilation,~World,~H,~Owner,~P,~List<&2,Ready.Completed<Error,Out>>,~invoke)}
def leaf_compilation_access(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~WC:Type,~WR:Type,~Ops:Data -> Type -> Type,~Local:Type,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),owner:Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,compilation:D.Compilation<S,WC,C,R,Ops>,requirements:List<&2,D.Access>,supported:Bool) -> Runtime<S,W.World<S,WC,WR,E>,Prep.Permit<S,WC>,State.Scope<S,C,R>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>:
  match owner:
    case Sys.Owner{namespace,+id,name,access,cursor,local}:leaf_runtime(~S,~W.World<S,WC,WR,E>,~Prep.Permit<S,WC>,~State.Scope<S,C,R>,~Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,~Error,~Out,~D.Compilation<S,WC,C,R,Ops>,~no_pending(~W.World<S,WC,WR,E>,~Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>),~no_publish(~W.World<S,WC,WR,E>,~Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>),~Scope.prepare_with_compilation(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR),~Scope.invoke_with_compilation(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR,~D.trusted_construction_caps(~S,~WC,~C,~R,~Ops,Build.compile_framework(~S,~WC,~C,~R,~Ops,~declaration)),~no_structural(~Ops,~State.Scope<S,C,R>)),Sys.Owner{namespace,id,name,access,cursor,local},compilation,id,requirements,supported,[],True{})
def compiled_leaf(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~WC:Type,~WR:Type,~Ops:Data -> Type -> Type,~Local:Type,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),owner:Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,compilation:D.Compilation<S,WC,C,R,Ops>) -> Runtime<S,W.World<S,WC,WR,E>,Prep.Permit<S,WC>,State.Scope<S,C,R>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>:
  match compilation:
    case D.Supported{D.Declaration{caps,+access},recipes}:leaf_compilation_access(~S,~C,~R,~E,~Error,~Out,~WC,~WR,~Ops,~Local,~declaration,~body,owner,D.Supported{D.Declaration{caps,access},recipes},access,True{})
    case D.Unsupported{caps,+access,recipes}:leaf_compilation_access(~S,~C,~R,~E,~Error,~Out,~WC,~WR,~Ops,~Local,~declaration,~body,owner,D.Unsupported{caps,access,recipes},access,False{})
def accessed(~S:Data,~WC:Type,~C:Type,~R:Type,~Ops:Data -> Type -> Type,~Owner:Type,~Result:Type,~next:Owner -> D.Compilation<S,WC,C,R,Ops> -> List<&2,D.Access> -> Bool -> Result,owner:Owner,compilation:D.Compilation<S,WC,C,R,Ops>) -> Result:
  match compilation:
    case D.Supported{D.Declaration{caps,+access},recipes}:next(owner,D.Supported{D.Declaration{caps,access},recipes},access,True{})
    case D.Unsupported{caps,+access,recipes}:next(owner,D.Unsupported{caps,access,recipes},access,False{})
def compile_leaf(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~WC:Type,~WR:Type,~Ops:Data -> Type -> Type,~Local:Type,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),owner:Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>) -> Runtime<S,W.World<S,WC,WR,E>,Prep.Permit<S,WC>,State.Scope<S,C,R>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>:
  compiled_leaf(~S,~C,~R,~E,~Error,~Out,~WC,~WR,~Ops,~Local,~declaration,~body,owner,Build.compile_framework(~S,~WC,~C,~R,~Ops,~declaration))
def trusted_preparation_joined(~World:Type,~L:Type,~R:Type,~P:Data,world:World,joined:Prep.Joining<World,L,R,P>) -> Prep.Preparation<World,Product.Owner<L,R>,P>:
  match joined:
    case Prep.Joined{prepared}:Prep.PreparationReady{world,prepared}
    case Prep.JoinRefused{Prep.Prepared{_,left,_,lt},Prep.Prepared{_,right,_,rt}}:Prep.PreparationRefused{world,Prep.Inventory{Product.Owner{left,right},Prep.Pair{lt,rt}}}
def trusted_prepared_right(~World:Type,~L:Type,~R:Type,~P:Data,left:Prep.Prepared<World,L,P>,result:Prep.Preparation<World,R,P>) -> Prep.Preparation<World,Product.Owner<L,R>,P>:
  match left result:
    case left Prep.PreparationReady{world,right}:trusted_preparation_joined(~World,~L,~R,~P,world,Prep.join(~World,~L,~R,~P,left,right))
    case Prep.Prepared{_,left,_,lt} Prep.PreparationRefused{world,Prep.Inventory{right,rt}}:Prep.PreparationRefused{world,Prep.Inventory{Product.Owner{left,right},Prep.Pair{lt,rt}}}
def trusted_prepared_left(~World:Type,~L:Type,~R:Type,~P:Data,rightPrepare:List<&2,U32> -> World -> R -> Prep.Preparation<World,R,P>,ids:List<&2,U32>,right:R,result:Prep.Preparation<World,L,P>) -> Prep.Preparation<World,Product.Owner<L,R>,P>:
  match result:
    case Prep.PreparationReady{world,left}:trusted_prepared_right(~World,~L,~R,~P,left,rightPrepare(ids,world,right))
    case Prep.PreparationRefused{world,Prep.Inventory{left,lt}}:Prep.PreparationRefused{world,Prep.Inventory{Product.Owner{left,right},Prep.Pair{lt,Prep.Unprepared{}}}}
def trusted_prepare_pair(~World:Type,~L:Type,~R:Type,~P:Data,leftPrepare:List<&2,U32> -> World -> L -> Prep.Preparation<World,L,P>,rightPrepare:List<&2,U32> -> World -> R -> Prep.Preparation<World,R,P>,+ids:List<&2,U32>,world:World,owners:Product.Owner<L,R>) -> Prep.Preparation<World,Product.Owner<L,R>,P>:
  match owners:
    case Product.Owner{left,right}:trusted_prepared_left(~World,~L,~R,~P,rightPrepare,ids,right,leftPrepare(ids,world,left))
def trusted_invocation_joined(~World:Type,~H:Type,~L:Type,~R:Type,~P:Data,~Error:Data,~Out:Data,refused:Bool,scope:H,status:List<&2,Ready.Completed<Error,Out>>,joined:Prep.Joining<World,L,R,P>) -> Prep.Invocation<H,World,Product.Owner<L,R>,P,List<&2,Ready.Completed<Error,Out>>>:
  match refused joined:
    case _ Prep.JoinRefused{Prep.Prepared{_,left,_,lt},Prep.Prepared{_,right,_,rt}}:Prep.InvocationInventoryRefused{scope,Prep.Inventory{Product.Owner{left,right},Prep.Pair{lt,rt}},status}
    case False{} Prep.Joined{prepared}:Prep.Invoked{scope,prepared,status}
    case True{} Prep.Joined{prepared}:Prep.InvocationRefused{scope,prepared,status}
def trusted_invoked_right(~World:Type,~H:Type,~L:Type,~R:Type,~P:Data,~Error:Data,~Out:Data,left:Prep.Prepared<World,L,P>,leftOut:List<&2,Ready.Completed<Error,Out>>,result:Prep.Invocation<H,World,R,P,List<&2,Ready.Completed<Error,Out>>>) -> Prep.Invocation<H,World,Product.Owner<L,R>,P,List<&2,Ready.Completed<Error,Out>>>:
  match left result:
    case left Prep.Invoked{scope,right,out}:trusted_invocation_joined(~World,~H,~L,~R,~P,~Error,~Out,False{},scope,List.append(&2,Ready.Completed<Error,Out>,leftOut,out),Prep.join(~World,~L,~R,~P,left,right))
    case left Prep.InvocationRefused{scope,right,out}:trusted_invocation_joined(~World,~H,~L,~R,~P,~Error,~Out,True{},scope,List.append(&2,Ready.Completed<Error,Out>,leftOut,out),Prep.join(~World,~L,~R,~P,left,right))
    case Prep.Prepared{_,left,_,lt} Prep.InvocationInventoryRefused{scope,Prep.Inventory{right,rt},out}:Prep.InvocationInventoryRefused{scope,Prep.Inventory{Product.Owner{left,right},Prep.Pair{lt,rt}},List.append(&2,Ready.Completed<Error,Out>,leftOut,out)}
def trusted_invoked_left(~S:Data,~World:Type,~H:Type,~L:Type,~R:Type,~P:Data,~Error:Data,~Out:Data,rightInvoke:H -> Prep.Prepared<World,R,P> -> Effect.Task<S,RuntimePermit.Permit,Prep.Invocation<H,World,R,P,List<&2,Ready.Completed<Error,Out>>>>,right:Prep.Prepared<World,R,P>,result:Prep.Invocation<H,World,L,P,List<&2,Ready.Completed<Error,Out>>>) -> Effect.Task<S,RuntimePermit.Permit,Prep.Invocation<H,World,Product.Owner<L,R>,P,List<&2,Ready.Completed<Error,Out>>>>:
  match right result:
    case right Prep.Invoked{scope,left,out}:Sys.map(S,RuntimePermit.Permit,Prep.Invocation<H,World,R,P,List<&2,Ready.Completed<Error,Out>>>,Prep.Invocation<H,World,Product.Owner<L,R>,P,List<&2,Ready.Completed<Error,Out>>>,rightInvoke(scope,right),result => trusted_invoked_right(~World,~H,~L,~R,~P,~Error,~Out,left,out,result))
    case right Prep.InvocationRefused{scope,left,out}:Effect.TDone{trusted_invocation_joined(~World,~H,~L,~R,~P,~Error,~Out,True{},scope,out,Prep.join(~World,~L,~R,~P,left,right))}
    case Prep.Prepared{_,right,_,rt} Prep.InvocationInventoryRefused{scope,Prep.Inventory{left,lt},out}:Effect.TDone{Prep.InvocationInventoryRefused{scope,Prep.Inventory{Product.Owner{left,right},Prep.Pair{lt,rt}},out}}
def trusted_invoke_pair(~S:Data,~World:Type,~H:Type,~L:Type,~R:Type,~P:Data,~Error:Data,~Out:Data,leftInvoke:H -> Prep.Prepared<World,L,P> -> Effect.Task<S,RuntimePermit.Permit,Prep.Invocation<H,World,L,P,List<&2,Ready.Completed<Error,Out>>>>,rightInvoke:H -> Prep.Prepared<World,R,P> -> Effect.Task<S,RuntimePermit.Permit,Prep.Invocation<H,World,R,P,List<&2,Ready.Completed<Error,Out>>>>,scope:H,prepared:Prep.Prepared<World,Product.Owner<L,R>,P>) -> Effect.Task<S,RuntimePermit.Permit,Prep.Invocation<H,World,Product.Owner<L,R>,P,List<&2,Ready.Completed<Error,Out>>>>:
  match prepared:
    case Prep.Prepared{+namespace,Product.Owner{left,right},permits,Prep.Pair{+lt,+rt}}:Effect.bind(S,RuntimePermit.Permit,Prep.Invocation<H,World,L,P,List<&2,Ready.Completed<Error,Out>>>,Prep.Invocation<H,World,Product.Owner<L,R>,P,List<&2,Ready.Completed<Error,Out>>>,leftInvoke(scope,Prep.Prepared{namespace,left,Prep.permits(~P,lt),lt}),result => trusted_invoked_left(~S,~World,~H,~L,~R,~P,~Error,~Out,rightInvoke,Prep.Prepared{namespace,right,Prep.permits(~P,rt),rt},result))
    case Prep.Prepared{namespace,owner,permits,Prep.Leaf{n,ps}}:Effect.TDone{Prep.InvocationRefused{scope,Prep.Prepared{namespace,owner,permits,Prep.Leaf{n,ps}},[]}}
    case Prep.Prepared{namespace,owner,permits,Prep.Unprepared{}}:Effect.TDone{Prep.InvocationRefused{scope,Prep.Prepared{namespace,owner,permits,Prep.Unprepared{}},[]}}
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
def restore_pair(~L:Type,~R:Type,~HL:Type,~HR:Type,~left:HL -> L,~right:HR -> R,held:Product.Owner<HL,HR>) -> Product.Owner<L,R>:
  match held:
    case Product.Owner{l,r}:Product.Owner{left(l),right(r)}
def compile_join(~S:Data,~World:Type,~P:Data,~H:Type,~Error:Data,~Out:Data,~L:Type,~R:Type,left:Runtime<S,World,P,H,L,Error,Out>,right:Runtime<S,World,P,H,R,Error,Out>) -> Runtime<S,World,P,H,Product.Owner<L,R>,Error,Out>:
  match left right:
    case Runtime{HL,restoreLeft,l,ln,le,li,ld,lq,ls,lp,lv} Runtime{HR,restoreRight,r,rn,re,ri,rd,rq,rs,rp,rv}:Runtime{Product.Owner<HL,HR>,restore_pair(~L,~R,~HL,~HR,~restoreLeft,~restoreRight),Product.Owner{l,r},List.append(&2,Plan.Node<String>,ln,rn),List.append(&2,Part.Entry,le,re),Plan.first_error(~String,li,ri),List.append(&2,U32,ld,rd),(ids => world => owners => pending_pair(~World,~HL,~HR,lq,rq,ids,world,owners)),(ids => tick => world => owners => publish_pair(~World,~HL,~HR,ls,rs,ids,tick,world,owners)),(ids => world => owners => trusted_prepare_pair(~World,~HL,~HR,~P,lp,rp,ids,world,owners)),(scope => prepared => trusted_invoke_pair(~S,~World,~H,~HL,~HR,~P,~Error,~Out,lv,rv,scope,prepared))}
def command_compilation_access(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~WR:Type,~layout:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~Ops:Data -> Type -> Type -> Type,~User:Type,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),owner:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>,compilation:D.Compilation<S,Layout.columns(~S,layout),C,R,Cmd.ScopedOps(~S,~layout,~route,~Ops)>,requirements:List<&2,D.Access>,supported:Bool) -> Runtime<S,W.World<S,Layout.columns(~S,layout),WR,E>,Prep.Permit<S,Layout.columns(~S,layout)>,State.Scope<S,C,R>,Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>,Error,Out>:
  match owner:
    case Cmd.Owner{Sys.Owner{namespace,+id,name,access,cursor,local}}:leaf_runtime(~S,~W.World<S,Layout.columns(~S,layout),WR,E>,~Prep.Permit<S,Layout.columns(~S,layout)>,~State.Scope<S,C,R>,~Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>,~Error,~Out,~D.Compilation<S,Layout.columns(~S,layout),C,R,Cmd.ScopedOps(~S,~layout,~route,~Ops)>,~CommandScope.pending(~S,~Layout.columns(~S,layout),~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR),~CommandScope.publish(~S,~Layout.columns(~S,layout),~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR,~{==},~valid),~CommandScope.prepare_with_compilation(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR),~CommandScope.invoke_with_compilation(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR,~D.trusted_construction_caps(~S,~Layout.columns(~S,layout),~C,~R,~Cmd.ScopedOps(~S,~layout,~route,~Ops),Build.compile_framework(~S,~Layout.columns(~S,layout),~C,~R,~Cmd.ScopedOps(~S,~layout,~route,~Ops),~Cmd.program_for_buffer(~S,~C,~R,~layout,~route,~Ops,~declaration)))),Cmd.Owner{Sys.Owner{namespace,id,name,access,cursor,local}},compilation,id,requirements,supported,[id],False{})
def compile_command_layout(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~WR:Type,~layout:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~Ops:Data -> Type -> Type -> Type,~User:Type,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),owner:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>) -> Runtime<S,W.World<S,Layout.columns(~S,layout),WR,E>,Prep.Permit<S,Layout.columns(~S,layout)>,State.Scope<S,C,R>,Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>,Error,Out>:
  accessed(~S,~Layout.columns(~S,layout),~C,~R,~Cmd.ScopedOps(~S,~layout,~route,~Ops),~Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>,~Runtime<S,W.World<S,Layout.columns(~S,layout),WR,E>,Prep.Permit<S,Layout.columns(~S,layout)>,State.Scope<S,C,R>,Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>,Error,Out>,~command_compilation_access(~S,~C,~R,~E,~Error,~Out,~WR,~layout,~route,~valid,~Ops,~User,~declaration,~body),owner,Build.compile_framework(~S,~Layout.columns(~S,layout),~C,~R,~Cmd.ScopedOps(~S,~layout,~route,~Ops),~Cmd.program_for_buffer(~S,~C,~R,~layout,~route,~Ops,~declaration)))
def compile_command(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~WR:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{WC == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~Ops:Data -> Type -> Type -> Type,~User:Type,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),owner:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>) -> Runtime<S,W.World<S,WC,WR,E>,Prep.Permit<S,WC>,State.Scope<S,C,R>,Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>,Error,Out>:
  %Equal.sym(Type,WC,Layout.columns(~S,layout),same) : Runtime<S,W.World<S,_,WR,E>,Prep.Permit<S,_>,State.Scope<S,C,R>,Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>,Error,Out>
  (compile_command_layout(~S,~C,~R,~E,~Error,~Out,~WR,~layout,~route,~valid,~Ops,~User,~declaration,~body,owner))
def command(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{WC == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~Ops:Data -> Type -> Type -> Type,~User:Type,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~F:Family(),~leaf:Leaf(~S,~WC,~C,~R,~E,~Error,~Out,~F),~command:CommandLeaf(~S,~WC,~C,~R,~E,~Error,~Out,~F),~join:Join(~F),owner:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>) -> F(Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>):
  command(layout,route,same,valid,Ops,User,declaration,body,owner)
def compile(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~WC:Type,~WR:Type,~Owners:Type,~selection:Selection(~S,~WC,~C,~R,~E,~Error,~Out,~Owners),owners:Owners) -> Runtime<S,W.World<S,WC,WR,E>,Prep.Permit<S,WC>,State.Scope<S,C,R>,Owners,Error,Out>:
  selection(interpreted(~S,~C,~R,~E,~Error,~Out,~WC,~WR),compile_leaf(~S,~C,~R,~E,~Error,~Out,~WC,~WR),compile_command(~S,~WC,~C,~R,~E,~Error,~Out,~WR),compile_join(~S,~W.World<S,WC,WR,E>,~Prep.Permit<S,WC>,~State.Scope<S,C,R>,~Error,~Out),owners)
