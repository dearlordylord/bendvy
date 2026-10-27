import Base
import ./world.bend as W
import ./execution-system.bend as Sys
import ./execution-declaration.bend as D
import ./execution-builder.bend as Build
import ./execution-parallel.bend as Parallel
import ./execution-parallel-system.bend as Task
import ./execution-parallel-run.bend as Run
import ./owner-product.bend as Product

type ParallelApp<-World:Type,-Left:Type,-Right:Type> is Type:
  ParallelApp{world:World,left:Left,right:Right}
type Definition<-World:Type,-Left:Type,-Right:Type,-LL:Type,-LR:Type> is Type:
  Defined{app:ParallelApp<World,Left,Right>}
  LeftRefused{world:World,leftLocal:LL,rightLocal:LR}
  RightRefused{world:World,left:Left,rightLocal:LR}

def right_defined(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~EL:Data,~ER:Data,~OL:Data,~OR:Data,~OpsL:Type -> Type,~OpsR:Type -> Type,~dl:Build.Program(~S,~Product.Owner<CL,CR>,~CL,~RL,~OpsL),~dr:Build.Program(~S,~Product.Owner<CL,CR>,~CR,~RR,~OpsR),~bl:@-H:Type -> @-caps:OpsL(H) -> H -> LL -> H & (LL & Sys.Completion<EL,OL>),~br:@-H:Type -> @-caps:OpsR(H) -> H -> LR -> H & (LR & Sys.Completion<ER,OR>),left:Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,EL,OL,dl,bl>,result:Sys.Defined<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,ER,OR,dr,br>,LR>) -> Definition<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,EL,OL,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,ER,OR,dr,br>,LL,LR>:
  match result:
    case Sys.Defined{world,right}:Defined{ParallelApp{world,left,right}}
    case Sys.DefinitionRefused{world,local}:RightRefused{world,left,local}

def left_defined(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~EL:Data,~ER:Data,~OL:Data,~OR:Data,~OpsL:Type -> Type,~OpsR:Type -> Type,~dl:Build.Program(~S,~Product.Owner<CL,CR>,~CL,~RL,~OpsL),~dr:Build.Program(~S,~Product.Owner<CL,CR>,~CR,~RR,~OpsR),~bl:@-H:Type -> @-caps:OpsL(H) -> H -> LL -> H & (LL & Sys.Completion<EL,OL>),~br:@-H:Type -> @-caps:OpsR(H) -> H -> LR -> H & (LR & Sys.Completion<ER,OR>),rightName:String,rightLocal:LR,result:Sys.Defined<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,EL,OL,dl,bl>,LL>) -> Definition<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,EL,OL,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,ER,OR,dr,br>,LL,LR>:
  match result:
    case Sys.DefinitionRefused{world,local}:LeftRefused{world,local,rightLocal}
    case Sys.Defined{world,left}:right_defined(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~EL,~ER,~OL,~OR,~OpsL,~OpsR,~dl,~dr,~bl,~br,left,Task.define(~S,~Product.Owner<CL,CR>,~CR,~RR,~E,~OpsR,~LR,~ER,~OR,~dr,~br,~Product.Owner<RL,RR>,world,rightName,rightLocal))

def define(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~EL:Data,~ER:Data,~OL:Data,~OR:Data,~OpsL:Type -> Type,~OpsR:Type -> Type,~dl:Build.Program(~S,~Product.Owner<CL,CR>,~CL,~RL,~OpsL),~dr:Build.Program(~S,~Product.Owner<CL,CR>,~CR,~RR,~OpsR),~bl:@-H:Type -> @-caps:OpsL(H) -> H -> LL -> H & (LL & Sys.Completion<EL,OL>),~br:@-H:Type -> @-caps:OpsR(H) -> H -> LR -> H & (LR & Sys.Completion<ER,OR>),world:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,leftName:String,rightName:String,leftLocal:LL,rightLocal:LR) -> Definition<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,EL,OL,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,ER,OR,dr,br>,LL,LR>:
  left_defined(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~EL,~ER,~OL,~OR,~OpsL,~OpsR,~dl,~dr,~bl,~br,rightName,rightLocal,Task.define(~S,~Product.Owner<CL,CR>,~CL,~RL,~E,~OpsL,~LL,~EL,~OL,~dl,~bl,~Product.Owner<RL,RR>,world,leftName,leftLocal))

def right_detached(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~EL:Data,~ER:Data,~OL:Data,~OR:Data,~OpsL:Type -> Type,~OpsR:Type -> Type,~dl:Build.Program(~S,~Product.Owner<CL,CR>,~CL,~RL,~OpsL),~dr:Build.Program(~S,~Product.Owner<CL,CR>,~CR,~RR,~OpsR),~bl:@-H:Type -> @-caps:OpsL(H) -> H -> LL -> H & (LL & Sys.Completion<EL,OL>),~br:@-H:Type -> @-caps:OpsR(H) -> H -> LR -> H & (LR & Sys.Completion<ER,OR>),mode:Parallel.Mode,gateLeft:Bool,gateRight:Bool,world:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,lm:Task.Meta<Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,EL,OL,dl,bl>>,ll:LL,right:Task.Meta<Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,ER,OR,dr,br>> & LR) -> Run.PairResult<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,EL,OL,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,ER,OR,dr,br>,EL,ER,OL,OR>:
  match right:
    case (rm,lr):Run.trusted_run(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~EL,~ER,~OL,~OR,~Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,EL,OL,dl,bl>,~Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,ER,OR,dr,br>,~Task.restored(~S,~Product.Owner<CL,CR>,~CL,~RL,~E,~OpsL,~LL,~EL,~OL,~dl,~bl),~Task.restored(~S,~Product.Owner<CL,CR>,~CR,~RR,~E,~OpsR,~LR,~ER,~OR,~dr,~br),~Parallel.trusted_split(~S,~CL,~CR,~RL,~RR,~LL,~LR,~EL,~ER,~OL,~OR,~OpsL,~OpsR,~dl,~dr,~bl,~br),mode,gateLeft,gateRight,lm,rm,ll,lr,world)

def left_detached(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~EL:Data,~ER:Data,~OL:Data,~OR:Data,~OpsL:Type -> Type,~OpsR:Type -> Type,~dl:Build.Program(~S,~Product.Owner<CL,CR>,~CL,~RL,~OpsL),~dr:Build.Program(~S,~Product.Owner<CL,CR>,~CR,~RR,~OpsR),~bl:@-H:Type -> @-caps:OpsL(H) -> H -> LL -> H & (LL & Sys.Completion<EL,OL>),~br:@-H:Type -> @-caps:OpsR(H) -> H -> LR -> H & (LR & Sys.Completion<ER,OR>),mode:Parallel.Mode,gateLeft:Bool,gateRight:Bool,world:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,right:Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,ER,OR,dr,br>,left:Task.Meta<Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,EL,OL,dl,bl>> & LL) -> Run.PairResult<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,EL,OL,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,ER,OR,dr,br>,EL,ER,OL,OR>:
  match left:
    case (lm,ll):right_detached(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~EL,~ER,~OL,~OR,~OpsL,~OpsR,~dl,~dr,~bl,~br,mode,gateLeft,gateRight,world,lm,ll,Task.detached(~S,~Product.Owner<CL,CR>,~CR,~RR,~E,~OpsR,~LR,~ER,~OR,~dr,~br,right))

def run_when(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~EL:Data,~ER:Data,~OL:Data,~OR:Data,~OpsL:Type -> Type,~OpsR:Type -> Type,~dl:Build.Program(~S,~Product.Owner<CL,CR>,~CL,~RL,~OpsL),~dr:Build.Program(~S,~Product.Owner<CL,CR>,~CR,~RR,~OpsR),~bl:@-H:Type -> @-caps:OpsL(H) -> H -> LL -> H & (LL & Sys.Completion<EL,OL>),~br:@-H:Type -> @-caps:OpsR(H) -> H -> LR -> H & (LR & Sys.Completion<ER,OR>),mode:Parallel.Mode,gateLeft:Bool,gateRight:Bool,app:ParallelApp<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,EL,OL,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,ER,OR,dr,br>>) -> Run.PairResult<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,EL,OL,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,ER,OR,dr,br>,EL,ER,OL,OR>:
  match app:
    case ParallelApp{world,left,right}:left_detached(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~EL,~ER,~OL,~OR,~OpsL,~OpsR,~dl,~dr,~bl,~br,mode,gateLeft,gateRight,world,right,Task.detached(~S,~Product.Owner<CL,CR>,~CL,~RL,~E,~OpsL,~LL,~EL,~OL,~dl,~bl,left))

def run(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~EL:Data,~ER:Data,~OL:Data,~OR:Data,~OpsL:Type -> Type,~OpsR:Type -> Type,~dl:Build.Program(~S,~Product.Owner<CL,CR>,~CL,~RL,~OpsL),~dr:Build.Program(~S,~Product.Owner<CL,CR>,~CR,~RR,~OpsR),~bl:@-H:Type -> @-caps:OpsL(H) -> H -> LL -> H & (LL & Sys.Completion<EL,OL>),~br:@-H:Type -> @-caps:OpsR(H) -> H -> LR -> H & (LR & Sys.Completion<ER,OR>),mode:Parallel.Mode,app:ParallelApp<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,EL,OL,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,ER,OR,dr,br>>) -> Run.PairResult<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,EL,OL,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,ER,OR,dr,br>,EL,ER,OL,OR>:
  run_when(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~EL,~ER,~OL,~OR,~OpsL,~OpsR,~dl,~dr,~bl,~br,mode,True{},True{},app)

def retained(~World:Type,~Left:Type,~Right:Type,~EL:Data,~ER:Data,~OL:Data,~OR:Data,result:Run.PairResult<World,Left,Right,EL,ER,OL,OR>) -> ParallelApp<World,Left,Right> & (Maybe<&2,Sys.Completion<EL,OL>> & Maybe<&2,Sys.Completion<ER,OR>>):
  match result:
    case Run.Finished{world,left,right,lc,rc}:(ParallelApp{world,left,right},(lc,rc))
