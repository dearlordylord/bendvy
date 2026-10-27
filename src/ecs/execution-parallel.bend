import Base
import ./execution-lifecycle-notices.bend as Notice
import ./owner-product.bend as Product
import ./execution-state.bend as State
import ./execution-declaration.bend as D
import ./execution-builder.bend as Build
import ./execution-system.bend as Sys
import ./world.bend as W
import ./change-tick.bend as Tick

type Mode is Data:
  Serial{}
  Native{}

def completed(~Scope:Type,~Local:Type,~Error:Data,~Out:Data,result:Scope & (Local & Sys.Completion<Error,Out>)) -> Scope & (Local & Maybe<&2,Sys.Completion<Error,Out>>):
  match result:
    case (scope,(local,completion)):(scope,(local,Some{completion}))

def trusted_invoke(~S:Data,~WC:Type,~C:Type,~R:Type,~Local:Type,~Error:Data,~Out:Data,~Ops:Type -> Type,~declaration:Build.Program(~S,~WC,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),allowed:Bool,scope:State.Scope<S,C,R>,local:Local) -> State.Scope<S,C,R> & (Local & Maybe<&2,Sys.Completion<Error,Out>>):
  match allowed:
    case False{}:(scope,(local,None{}))
    case True{}:completed(~State.Scope<S,C,R>,~Local,~Error,~Out,body(State.Scope<S,C,R>,D.grants(~S,~C,~R,~Ops,Build.compile(~S,~WC,~C,~R,~Ops,~declaration)),scope,local))

def join_right(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~LL:Type,~LR:Type,~EL:Data,~ER:Data,~OL:Data,~OR:Data,lc:CL,lr:RL,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,lo:LL & Maybe<&2,Sys.Completion<EL,OL>>,right:State.Scope<S,CR,RR> & (LR & Maybe<&2,Sys.Completion<ER,OR>>)) -> State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>> & ((LL & Maybe<&2,Sys.Completion<EL,OL>>) & (LR & Maybe<&2,Sys.Completion<ER,OR>>)):
  match right:
    case (State.Scope{rc,rr,_,_,_,+lifecycleView},ro):(State.Scope{Product.Owner{lc,rc},Product.Owner{lr,rr},handles,tick,prior,lifecycleView},(lo,ro))

def joined(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~LL:Type,~LR:Type,~EL:Data,~ER:Data,~OL:Data,~OR:Data,left:State.Scope<S,CL,RL> & (LL & Maybe<&2,Sys.Completion<EL,OL>>),right:State.Scope<S,CR,RR> & (LR & Maybe<&2,Sys.Completion<ER,OR>>)) -> State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>> & ((LL & Maybe<&2,Sys.Completion<EL,OL>>) & (LR & Maybe<&2,Sys.Completion<ER,OR>>)):
  match left:
    case (State.Scope{lc,lr,handles,tick,prior,+lifecycleView},lo):join_right(~S,~CL,~CR,~RL,~RR,~LL,~LR,~EL,~ER,~OL,~OR,lc,lr,handles,tick,prior,lo,right)

def trusted_executed(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~LL:Type,~LR:Type,~EL:Data,~ER:Data,~OL:Data,~OR:Data,~OpsL:Type -> Type,~OpsR:Type -> Type,~dl:Build.Program(~S,~Product.Owner<CL,CR>,~CL,~RL,~OpsL),~dr:Build.Program(~S,~Product.Owner<CL,CR>,~CR,~RR,~OpsR),~bl:@-H:Type -> @-caps:OpsL(H) -> H -> LL -> H & (LL & Sys.Completion<EL,OL>),~br:@-H:Type -> @-caps:OpsR(H) -> H -> LR -> H & (LR & Sys.Completion<ER,OR>),mode:Mode,allowLeft:Bool,allowRight:Bool,left:State.Scope<S,CL,RL>,right:State.Scope<S,CR,RR>,ll:LL,lr:LR) -> State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>> & ((LL & Maybe<&2,Sys.Completion<EL,OL>>) & (LR & Maybe<&2,Sys.Completion<ER,OR>>)):
  match mode:
    case Serial{}:
      leftResult = trusted_invoke(~S,~Product.Owner<CL,CR>,~CL,~RL,~LL,~EL,~OL,~OpsL,~dl,~bl,allowLeft,left,ll)
      rightResult = trusted_invoke(~S,~Product.Owner<CL,CR>,~CR,~RR,~LR,~ER,~OR,~OpsR,~dr,~br,allowRight,right,lr)
      joined(~S,~CL,~CR,~RL,~RR,~LL,~LR,~EL,~ER,~OL,~OR,leftResult,rightResult)
    case Native{}:
      leftResult rightResult = trusted_invoke(~S,~Product.Owner<CL,CR>,~CL,~RL,~LL,~EL,~OL,~OpsL,~dl,~bl,allowLeft,left,ll) trusted_invoke(~S,~Product.Owner<CL,CR>,~CR,~RR,~LR,~ER,~OR,~OpsR,~dr,~br,allowRight,right,lr)
      joined(~S,~CL,~CR,~RL,~RR,~LL,~LR,~EL,~ER,~OL,~OR,leftResult,rightResult)

def trusted_split(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~LL:Type,~LR:Type,~EL:Data,~ER:Data,~OL:Data,~OR:Data,~OpsL:Type -> Type,~OpsR:Type -> Type,~dl:Build.Program(~S,~Product.Owner<CL,CR>,~CL,~RL,~OpsL),~dr:Build.Program(~S,~Product.Owner<CL,CR>,~CR,~RR,~OpsR),~bl:@-H:Type -> @-caps:OpsL(H) -> H -> LL -> H & (LL & Sys.Completion<EL,OL>),~br:@-H:Type -> @-caps:OpsR(H) -> H -> LR -> H & (LR & Sys.Completion<ER,OR>),mode:Mode,allowLeft:Bool,allowRight:Bool,scope:State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>>,rightTick:Tick.Tick,ll:LL,lr:LR) -> State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>> & ((LL & Maybe<&2,Sys.Completion<EL,OL>>) & (LR & Maybe<&2,Sys.Completion<ER,OR>>)):
  match scope:
    case State.Scope{Product.Owner{lc,rc},Product.Owner{lres,rres},+handles,leftTick,+prior,+lifecycleView}:trusted_executed(~S,~CL,~CR,~RL,~RR,~LL,~LR,~EL,~ER,~OL,~OR,~OpsL,~OpsR,~dl,~dr,~bl,~br,mode,allowLeft,allowRight,State.Scope{lc,lres,handles,leftTick,prior,lifecycleView},State.Scope{rc,rres,handles,rightTick,prior,lifecycleView},ll,lr)
