import Base
import ./execution-reservation-task.bend as Effect
import ./execution-reservation-permit.bend as Request
import ./execution-reservation-driver.bend as Driver
import ./world.bend as W
import ./execution-system.bend as Sys
import ./execution-state.bend as State
import ./execution-parallel.bend as Parallel
import ./execution-parallel-system.bend as Task
import ./owner-product.bend as Product
import ./change-tick.bend as Tick

type PairResult<-World:Type,-Left:Type,-Right:Type,EL:Data,ER:Data,OL:Data,OR:Data> is Type:
  Finished{world:World,left:Left,right:Right,leftCompletion:Maybe<&2,Sys.Completion<EL,OL>>,rightCompletion:Maybe<&2,Sys.Completion<ER,OR>>}
  AdmissionRefused{world:World,left:Left,right:Right,leftCompletion:Maybe<&2,Sys.Completion<EL,OL>>,rightCompletion:Maybe<&2,Sys.Completion<ER,OR>>}

def classified(~World:Type,~Left:Type,~Right:Type,~EL:Data,~ER:Data,~OL:Data,~OR:Data,admitted:Bool,result:PairResult<World,Left,Right,EL,ER,OL,OR>) -> PairResult<World,Left,Right,EL,ER,OL,OR>:
  match admitted result:
    case True{} Finished{world,left,right,lc,rc}:Finished{world,left,right,lc,rc}
    case False{} Finished{world,left,right,lc,rc}:AdmissionRefused{world,left,right,lc,rc}
    case True{} AdmissionRefused{world,left,right,lc,rc}:AdmissionRefused{world,left,right,lc,rc}
    case False{} AdmissionRefused{world,left,right,lc,rc}:AdmissionRefused{world,left,right,lc,rc}

def trusted_finished(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~EL:Data,~ER:Data,~OL:Data,~OR:Data,~Left:Type,~Right:Type,~restoreLeft:Task.Meta<Left> -> LL -> Left,~restoreRight:Task.Meta<Right> -> LR -> Right,admitted:Bool,admin:State.Administration<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,lm:Task.Meta<Left>,rm:Task.Meta<Right>,+allowLeft:Bool,+allowRight:Bool,leftTick:Tick.Tick,rightTick:Tick.Tick,result:State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>> & ((LL & Maybe<&2,Sys.Completion<EL,OL>>) & (LR & Maybe<&2,Sys.Completion<ER,OR>>))) -> PairResult<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Left,Right,EL,ER,OL,OR>:
  match result:
    case (scope,((ll,lo),(lr,ro))):classified(~W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,~Left,~Right,~EL,~ER,~OL,~OR,admitted,Finished{Task.leave(~S,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~E,allowLeft,Task.leave(~S,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~E,allowRight,State.reassemble(~S,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~E,admin,scope))),restoreLeft(Task.completed_meta(~Left,allowLeft,leftTick,lm),ll),restoreRight(Task.completed_meta(~Right,allowRight,rightTick,rm),lr),lo,ro})

def request_context(~Owner:Type,meta:Task.Meta<Owner>) -> Request.Context:
  match meta:
    case Task.Meta{namespace,id,_,_,_}:Request.Context{namespace,id,Request.NoStructural{}}

def trusted_driven(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~EL:Data,~ER:Data,~OL:Data,~OR:Data,~Left:Type,~Right:Type,~restoreLeft:Task.Meta<Left> -> LL -> Left,~restoreRight:Task.Meta<Right> -> LR -> Right,admitted:Bool,lm:Task.Meta<Left>,rm:Task.Meta<Right>,allowLeft:Bool,allowRight:Bool,leftTick:Tick.Tick,rightTick:Tick.Tick,result:State.Administration<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & (State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>> & ((LL & Maybe<&2,Sys.Completion<EL,OL>>) & (LR & Maybe<&2,Sys.Completion<ER,OR>>)))) -> PairResult<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Left,Right,EL,ER,OL,OR>:
  match result:
    case (admin,joined):trusted_finished(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~EL,~ER,~OL,~OR,~Left,~Right,~restoreLeft,~restoreRight,admitted,admin,lm,rm,allowLeft,allowRight,leftTick,rightTick,joined)

def trusted_separated(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~EL:Data,~ER:Data,~OL:Data,~OR:Data,~Left:Type,~Right:Type,~restoreLeft:Task.Meta<Left> -> LL -> Left,~restoreRight:Task.Meta<Right> -> LR -> Right,~execute:Request.Context -> Request.Context -> Parallel.Mode -> Bool -> Bool -> State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>> -> Tick.Tick -> LL -> LR -> Effect.Task<S,Request.Permit,State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>> & ((LL & Maybe<&2,Sys.Completion<EL,OL>>) & (LR & Maybe<&2,Sys.Completion<ER,OR>>))>,mode:Parallel.Mode,admitted:Bool,+lm:Task.Meta<Left>,+rm:Task.Meta<Right>,ll:LL,lr:LR,+allowLeft:Bool,+allowRight:Bool,+leftTick:Tick.Tick,+rightTick:Tick.Tick,result:State.Administration<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>>) -> IO(PairResult<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Left,Right,EL,ER,OL,OR>):
  match result:
    case (admin,scope):
      IO.bind(State.Administration<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & (State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>> & ((LL & Maybe<&2,Sys.Completion<EL,OL>>) & (LR & Maybe<&2,Sys.Completion<ER,OR>>))),PairResult<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Left,Right,EL,ER,OL,OR>,Driver.run(~S,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~E,~(State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>> & ((LL & Maybe<&2,Sys.Completion<EL,OL>>) & (LR & Maybe<&2,Sys.Completion<ER,OR>>))),[],admin,execute(request_context(~Left,lm),request_context(~Right,rm),mode,allowLeft,allowRight,scope,rightTick,ll,lr)),result => IO.pure(PairResult<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Left,Right,EL,ER,OL,OR>,trusted_driven(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~EL,~ER,~OL,~OR,~Left,~Right,~restoreLeft,~restoreRight,admitted,lm,rm,allowLeft,allowRight,leftTick,rightTick,result)))

def trusted_right_entered(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~EL:Data,~ER:Data,~OL:Data,~OR:Data,~Left:Type,~Right:Type,~restoreLeft:Task.Meta<Left> -> LL -> Left,~restoreRight:Task.Meta<Right> -> LR -> Right,~execute:Request.Context -> Request.Context -> Parallel.Mode -> Bool -> Bool -> State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>> -> Tick.Tick -> LL -> LR -> Effect.Task<S,Request.Permit,State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>> & ((LL & Maybe<&2,Sys.Completion<EL,OL>>) & (LR & Maybe<&2,Sys.Completion<ER,OR>>))>,mode:Parallel.Mode,admitted:Bool,lm:Task.Meta<Left>,rm:Task.Meta<Right>,ll:LL,lr:LR,+allowLeft:Bool,+allowRight:Bool,+leftTick:Tick.Tick,result:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & Tick.Tick) -> IO(PairResult<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Left,Right,EL,ER,OL,OR>):
  match result:
    case (world,+rightTick):trusted_separated(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~EL,~ER,~OL,~OR,~Left,~Right,~restoreLeft,~restoreRight,~execute,mode,admitted,lm,rm,ll,lr,allowLeft,allowRight,leftTick,rightTick,State.separate(~S,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~E,world,leftTick))

def trusted_left_entered(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~EL:Data,~ER:Data,~OL:Data,~OR:Data,~Left:Type,~Right:Type,~restoreLeft:Task.Meta<Left> -> LL -> Left,~restoreRight:Task.Meta<Right> -> LR -> Right,~execute:Request.Context -> Request.Context -> Parallel.Mode -> Bool -> Bool -> State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>> -> Tick.Tick -> LL -> LR -> Effect.Task<S,Request.Permit,State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>> & ((LL & Maybe<&2,Sys.Completion<EL,OL>>) & (LR & Maybe<&2,Sys.Completion<ER,OR>>))>,mode:Parallel.Mode,admitted:Bool,lm:Task.Meta<Left>,rm:Task.Meta<Right>,ll:LL,lr:LR,+allowLeft:Bool,+allowRight:Bool,result:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & Tick.Tick) -> IO(PairResult<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Left,Right,EL,ER,OL,OR>):
  match result:
    case (world,leftTick):trusted_right_entered(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~EL,~ER,~OL,~OR,~Left,~Right,~restoreLeft,~restoreRight,~execute,mode,admitted,lm,rm,ll,lr,allowLeft,allowRight,leftTick,Task.enter(~S,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~E,allowRight,world))

def trusted_right_verified(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~EL:Data,~ER:Data,~OL:Data,~OR:Data,~Left:Type,~Right:Type,~restoreLeft:Task.Meta<Left> -> LL -> Left,~restoreRight:Task.Meta<Right> -> LR -> Right,~execute:Request.Context -> Request.Context -> Parallel.Mode -> Bool -> Bool -> State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>> -> Tick.Tick -> LL -> LR -> Effect.Task<S,Request.Permit,State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>> & ((LL & Maybe<&2,Sys.Completion<EL,OL>>) & (LR & Maybe<&2,Sys.Completion<ER,OR>>))>,mode:Parallel.Mode,lm:Task.Meta<Left>,rm:Task.Meta<Right>,ll:LL,lr:LR,gateRight:Bool,validLeft:Bool,+allowLeft:Bool,result:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & Bool) -> IO(PairResult<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Left,Right,EL,ER,OL,OR>):
  match result:
    case (world,+validRight):trusted_left_entered(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~EL,~ER,~OL,~OR,~Left,~Right,~restoreLeft,~restoreRight,~execute,mode,Bool.and(validLeft,validRight),lm,rm,ll,lr,allowLeft,Bool.and(gateRight,validRight),Task.enter(~S,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~E,allowLeft,world))

def trusted_left_verified(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~EL:Data,~ER:Data,~OL:Data,~OR:Data,~Left:Type,~Right:Type,~restoreLeft:Task.Meta<Left> -> LL -> Left,~restoreRight:Task.Meta<Right> -> LR -> Right,~execute:Request.Context -> Request.Context -> Parallel.Mode -> Bool -> Bool -> State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>> -> Tick.Tick -> LL -> LR -> Effect.Task<S,Request.Permit,State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>> & ((LL & Maybe<&2,Sys.Completion<EL,OL>>) & (LR & Maybe<&2,Sys.Completion<ER,OR>>))>,mode:Parallel.Mode,gateLeft:Bool,gateRight:Bool,lm:Task.Meta<Left>,+rm:Task.Meta<Right>,ll:LL,lr:LR,result:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & Bool) -> IO(PairResult<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Left,Right,EL,ER,OL,OR>):
  match result:
    case (world,+validLeft):trusted_right_verified(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~EL,~ER,~OL,~OR,~Left,~Right,~restoreLeft,~restoreRight,~execute,mode,lm,rm,ll,lr,gateRight,validLeft,Bool.and(gateLeft,validLeft),Task.verify(~S,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~E,~Right,rm,world))

def trusted_run(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~EL:Data,~ER:Data,~OL:Data,~OR:Data,~Left:Type,~Right:Type,~restoreLeft:Task.Meta<Left> -> LL -> Left,~restoreRight:Task.Meta<Right> -> LR -> Right,~execute:Request.Context -> Request.Context -> Parallel.Mode -> Bool -> Bool -> State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>> -> Tick.Tick -> LL -> LR -> Effect.Task<S,Request.Permit,State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>> & ((LL & Maybe<&2,Sys.Completion<EL,OL>>) & (LR & Maybe<&2,Sys.Completion<ER,OR>>))>,mode:Parallel.Mode,gateLeft:Bool,gateRight:Bool,+lm:Task.Meta<Left>,rm:Task.Meta<Right>,ll:LL,lr:LR,world:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>) -> IO(PairResult<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Left,Right,EL,ER,OL,OR>):
  trusted_left_verified(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~EL,~ER,~OL,~OR,~Left,~Right,~restoreLeft,~restoreRight,~execute,mode,gateLeft,gateRight,lm,rm,ll,lr,Task.verify(~S,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~E,~Left,lm,world))
