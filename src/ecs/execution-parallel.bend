import Base
import ./execution-reservation-authority.bend as Request
import ./execution-lifecycle-notices.bend as Notice
import ./owner-product.bend as Product
import ./execution-state.bend as State
import ./execution-declaration.bend as D
import ./execution-builder.bend as Build
import ./execution-system.bend as Sys
import ./execution-reservation-task.bend as Effect
import ./world.bend as W
import ./change-tick.bend as Tick

type Mode is Data:
  Serial{}
  Native{}

def completed(~Scope:Type,~Local:Type,~Error:Data,~Out:Data,result:Scope & (Local & Sys.Completion<Error,Out>)) -> Scope & (Local & Maybe<&2,Sys.Completion<Error,Out>>):
  match result:
    case (scope,(local,completion)):(scope,(local,Some{completion}))

def trusted_invoke_compiled(~S:Data,~WC:Type,~C:Type,~R:Type,~Local:Type,~Error:Data,~Out:Data,~Ops:Data -> Type -> Type,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~compiledCaps:Ops(Effect.Granted,State.Scope<S,C,R>),allowed:Bool,scope:State.Scope<S,C,R>,local:Local,compilation:D.Compilation<S,WC,C,R,Ops>) -> Effect.Task<S,Effect.Granted,State.Scope<S,C,R> & (Local & Maybe<&2,Sys.Completion<Error,Out>>)>:
  match allowed compilation:
    case False{} _:Effect.TDone{(scope,(local,None{}))}
    case True{} D.Unsupported{_,_,_}:Effect.TDone{(scope,(local,None{}))}
    case True{} D.Supported{D.Declaration{_,_},_}:Sys.map(S,Effect.Granted,State.Scope<S,C,R> & (Local & Sys.Completion<Error,Out>),State.Scope<S,C,R> & (Local & Maybe<&2,Sys.Completion<Error,Out>>),body(Effect.Granted,State.Scope<S,C,R>,compiledCaps,scope,local),result => completed(~State.Scope<S,C,R>,~Local,~Error,~Out,result))
def trusted_invoke_constructed(~S:Data,~WC:Type,~C:Type,~R:Type,~Local:Type,~Error:Data,~Out:Data,~Ops:Data -> Type -> Type,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~compilation:D.Compilation<S,WC,C,R,Ops>,context:Request.Context,allowed:Bool,scope:State.Scope<S,C,R>,local:Local) -> Effect.Task<S,Request.Permit,State.Scope<S,C,R> & (Local & Maybe<&2,Sys.Completion<Error,Out>>)>:
  Effect.qualify(S,State.Scope<S,C,R> & (Local & Maybe<&2,Sys.Completion<Error,Out>>),context,trusted_invoke_compiled(~S,~WC,~C,~R,~Local,~Error,~Out,~Ops,~declaration,~body,~D.trusted_construction_caps(~S,~WC,~C,~R,~Ops,compilation),allowed,scope,local,compilation))
def trusted_invoke(~S:Data,~WC:Type,~C:Type,~R:Type,~Local:Type,~Error:Data,~Out:Data,~Ops:Data -> Type -> Type,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),context:Request.Context,allowed:Bool,scope:State.Scope<S,C,R>,local:Local) -> Effect.Task<S,Request.Permit,State.Scope<S,C,R> & (Local & Maybe<&2,Sys.Completion<Error,Out>>)>:
  trusted_invoke_constructed(~S,~WC,~C,~R,~Local,~Error,~Out,~Ops,~declaration,~body,~Build.compile_framework(~S,~WC,~C,~R,~Ops,~declaration),context,allowed,scope,local)

def join_right(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~LL:Type,~LR:Type,~EL:Data,~ER:Data,~OL:Data,~OR:Data,lc:CL,lr:RL,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,lo:LL & Maybe<&2,Sys.Completion<EL,OL>>,right:State.Scope<S,CR,RR> & (LR & Maybe<&2,Sys.Completion<ER,OR>>)) -> State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>> & ((LL & Maybe<&2,Sys.Completion<EL,OL>>) & (LR & Maybe<&2,Sys.Completion<ER,OR>>)):
  match right:
    case (State.Scope{rc,rr,_,_,_,+lifecycleView},ro):(State.Scope{Product.Owner{lc,rc},Product.Owner{lr,rr},handles,tick,prior,lifecycleView},(lo,ro))

def joined(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~LL:Type,~LR:Type,~EL:Data,~ER:Data,~OL:Data,~OR:Data,left:State.Scope<S,CL,RL> & (LL & Maybe<&2,Sys.Completion<EL,OL>>),right:State.Scope<S,CR,RR> & (LR & Maybe<&2,Sys.Completion<ER,OR>>)) -> State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>> & ((LL & Maybe<&2,Sys.Completion<EL,OL>>) & (LR & Maybe<&2,Sys.Completion<ER,OR>>)):
  match left:
    case (State.Scope{lc,lr,handles,tick,prior,+lifecycleView},lo):join_right(~S,~CL,~CR,~RL,~RR,~LL,~LR,~EL,~ER,~OL,~OR,lc,lr,handles,tick,prior,lo,right)

def trusted_executed(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~LL:Type,~LR:Type,~EL:Data,~ER:Data,~OL:Data,~OR:Data,~OpsL:Data -> Type -> Type,~OpsR:Data -> Type -> Type,~dl:Build.FrameworkProgram(~S,~Product.Owner<CL,CR>,~CL,~RL,~OpsL),~dr:Build.FrameworkProgram(~S,~Product.Owner<CL,CR>,~CR,~RR,~OpsR),~bl:Sys.Body(~S,~OpsL,~LL,~EL,~OL),~br:Sys.Body(~S,~OpsR,~LR,~ER,~OR),leftContext:Request.Context,rightContext:Request.Context,mode:Mode,allowLeft:Bool,allowRight:Bool,left:State.Scope<S,CL,RL>,right:State.Scope<S,CR,RR>,ll:LL,lr:LR) -> Effect.Task<S,Request.Permit,State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>> & ((LL & Maybe<&2,Sys.Completion<EL,OL>>) & (LR & Maybe<&2,Sys.Completion<ER,OR>>))>:
  match mode:
    case Serial{}:Effect.bind(S,Request.Permit,State.Scope<S,CL,RL> & (LL & Maybe<&2,Sys.Completion<EL,OL>>),State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>> & ((LL & Maybe<&2,Sys.Completion<EL,OL>>) & (LR & Maybe<&2,Sys.Completion<ER,OR>>)),trusted_invoke(~S,~Product.Owner<CL,CR>,~CL,~RL,~LL,~EL,~OL,~OpsL,~dl,~bl,leftContext,allowLeft,left,ll),leftResult => Sys.map(S,Request.Permit,State.Scope<S,CR,RR> & (LR & Maybe<&2,Sys.Completion<ER,OR>>),State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>> & ((LL & Maybe<&2,Sys.Completion<EL,OL>>) & (LR & Maybe<&2,Sys.Completion<ER,OR>>)),trusted_invoke(~S,~Product.Owner<CL,CR>,~CR,~RR,~LR,~ER,~OR,~OpsR,~dr,~br,rightContext,allowRight,right,lr),rightResult => joined(~S,~CL,~CR,~RL,~RR,~LL,~LR,~EL,~ER,~OL,~OR,leftResult,rightResult)))
    case Native{}:Effect.TFork{State.Scope<S,CL,RL> & (LL & Maybe<&2,Sys.Completion<EL,OL>>),State.Scope<S,CR,RR> & (LR & Maybe<&2,Sys.Completion<ER,OR>>),trusted_invoke(~S,~Product.Owner<CL,CR>,~CL,~RL,~LL,~EL,~OL,~OpsL,~dl,~bl,leftContext,allowLeft,left,ll),trusted_invoke(~S,~Product.Owner<CL,CR>,~CR,~RR,~LR,~ER,~OR,~OpsR,~dr,~br,rightContext,allowRight,right,lr),leftResult => rightResult => Effect.TDone{joined(~S,~CL,~CR,~RL,~RR,~LL,~LR,~EL,~ER,~OL,~OR,leftResult,rightResult)}}

def trusted_split(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~LL:Type,~LR:Type,~EL:Data,~ER:Data,~OL:Data,~OR:Data,~OpsL:Data -> Type -> Type,~OpsR:Data -> Type -> Type,~dl:Build.FrameworkProgram(~S,~Product.Owner<CL,CR>,~CL,~RL,~OpsL),~dr:Build.FrameworkProgram(~S,~Product.Owner<CL,CR>,~CR,~RR,~OpsR),~bl:Sys.Body(~S,~OpsL,~LL,~EL,~OL),~br:Sys.Body(~S,~OpsR,~LR,~ER,~OR),leftContext:Request.Context,rightContext:Request.Context,mode:Mode,allowLeft:Bool,allowRight:Bool,scope:State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>>,rightTick:Tick.Tick,ll:LL,lr:LR) -> Effect.Task<S,Request.Permit,State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>> & ((LL & Maybe<&2,Sys.Completion<EL,OL>>) & (LR & Maybe<&2,Sys.Completion<ER,OR>>))>:
  match scope:
    case State.Scope{Product.Owner{lc,rc},Product.Owner{lres,rres},+handles,leftTick,+prior,+lifecycleView}:trusted_executed(~S,~CL,~CR,~RL,~RR,~LL,~LR,~EL,~ER,~OL,~OR,~OpsL,~OpsR,~dl,~dr,~bl,~br,leftContext,rightContext,mode,allowLeft,allowRight,State.Scope{lc,lres,handles,leftTick,prior,lifecycleView},State.Scope{rc,rres,handles,rightTick,prior,lifecycleView},ll,lr)
