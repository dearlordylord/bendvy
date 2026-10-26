import Base
import ./world.bend as W
import ./execution-state.bend as State
import ./execution-parallel.bend as Parallel
import ./execution-parallel-scope.bend as Scope
import ./execution-parallel-scope-registry.bend as Tree
import ./execution-parallel-system.bend as Task
import ./execution-parallel-schedule.bend as Ready
import ./execution-parallel-registration.bend as Part
import ./dependency-registration.bend as Reg
import ./dependency-plan.bend as Plan
import ./dependency-executor.bend as Exec
import ./owner-product.bend as Product
import ./change-tick.bend as Tick

def leave(~S:Data,~C:Type,~R:Type,~E:Data,permits:List<&2,Scope.Permit>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E>:
  match permits:
    case []:world
    case Scope.Permit{_,allowed,_} <> rest:leave(~S,~C,~R,~E,rest,Task.leave(~S,~C,~R,~E,allowed,world))
def joined_right(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,lc:CL,lr:RL,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,left:L,leftOut:List<&2,Ready.Completed<Error,Out>>,right:State.Scope<S,CR,RR> & (R & List<&2,Ready.Completed<Error,Out>>)) -> State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>> & (Product.Owner<L,R> & List<&2,Ready.Completed<Error,Out>>):
  match right:
    case (State.Scope{rc,rr,_,_,_},(right,rightOut)):(State.Scope{Product.Owner{lc,rc},Product.Owner{lr,rr},handles,tick,prior},(Product.Owner{left,right},List.append(&2,Ready.Completed<Error,Out>,leftOut,rightOut)))
def joined(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,left:State.Scope<S,CL,RL> & (L & List<&2,Ready.Completed<Error,Out>>),right:State.Scope<S,CR,RR> & (R & List<&2,Ready.Completed<Error,Out>>)) -> State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>> & (Product.Owner<L,R> & List<&2,Ready.Completed<Error,Out>>):
  match left:
    case (State.Scope{lc,lr,handles,tick,prior},(left,leftOut)):joined_right(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,lc,lr,handles,tick,prior,left,leftOut,right)
def execute(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,mode:Parallel.Mode,leftInvoke:List<&2,Scope.Permit> -> State.Scope<S,CL,RL> -> L -> State.Scope<S,CL,RL> & (L & List<&2,Ready.Completed<Error,Out>>),rightInvoke:List<&2,Scope.Permit> -> State.Scope<S,CR,RR> -> R -> State.Scope<S,CR,RR> & (R & List<&2,Ready.Completed<Error,Out>>),+permits:List<&2,Scope.Permit>,scope:State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>>,owners:Product.Owner<L,R>) -> State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>> & (Product.Owner<L,R> & List<&2,Ready.Completed<Error,Out>>):
  match mode scope owners:
    case Parallel.Serial{} State.Scope{Product.Owner{lc,rc},Product.Owner{lr,rr},+handles,+tick,+prior} Product.Owner{left,right}:
      l = leftInvoke(permits,State.Scope{lc,lr,handles,tick,prior},left)
      r = rightInvoke(permits,State.Scope{rc,rr,handles,tick,prior},right)
      joined(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,l,r)
    case Parallel.Native{} State.Scope{Product.Owner{lc,rc},Product.Owner{lr,rr},+handles,+tick,+prior} Product.Owner{left,right}:
      l r = leftInvoke(permits,State.Scope{lc,lr,handles,tick,prior},left) rightInvoke(permits,State.Scope{rc,rr,handles,tick,prior},right)
      joined(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,l,r)
def finished(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,admin:State.Administration<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,permits:List<&2,Scope.Permit>,result:State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>> & (Product.Owner<L,R> & List<&2,Ready.Completed<Error,Out>>)) -> Product.Owner<L,R> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>):
  match result:
    case (scope,(owners,statuses)):(owners,(leave(~S,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~E,permits,State.reassemble(~S,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~E,admin,scope)),statuses))
def separated(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,mode:Parallel.Mode,leftInvoke:List<&2,Scope.Permit> -> State.Scope<S,CL,RL> -> L -> State.Scope<S,CL,RL> & (L & List<&2,Ready.Completed<Error,Out>>),rightInvoke:List<&2,Scope.Permit> -> State.Scope<S,CR,RR> -> R -> State.Scope<S,CR,RR> & (R & List<&2,Ready.Completed<Error,Out>>),+permits:List<&2,Scope.Permit>,owners:Product.Owner<L,R>,result:State.Administration<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>>) -> Product.Owner<L,R> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>):
  match result:
    case (admin,scope):finished(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,admin,permits,execute(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,mode,leftInvoke,rightInvoke,permits,scope,owners))
def clocked(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,mode:Parallel.Mode,leftInvoke:List<&2,Scope.Permit> -> State.Scope<S,CL,RL> -> L -> State.Scope<S,CL,RL> & (L & List<&2,Ready.Completed<Error,Out>>),rightInvoke:List<&2,Scope.Permit> -> State.Scope<S,CR,RR> -> R -> State.Scope<S,CR,RR> & (R & List<&2,Ready.Completed<Error,Out>>),permits:List<&2,Scope.Permit>,owners:Product.Owner<L,R>,result:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & Tick.Tick) -> Product.Owner<L,R> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>):
  match result:
    case (world,tick):separated(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,mode,leftInvoke,rightInvoke,permits,owners,State.separate(~S,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~E,world,tick))
def right_prepared(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,mode:Parallel.Mode,leftInvoke:List<&2,Scope.Permit> -> State.Scope<S,CL,RL> -> L -> State.Scope<S,CL,RL> & (L & List<&2,Ready.Completed<Error,Out>>),rightInvoke:List<&2,Scope.Permit> -> State.Scope<S,CR,RR> -> R -> State.Scope<S,CR,RR> & (R & List<&2,Ready.Completed<Error,Out>>),left:L,leftPermits:List<&2,Scope.Permit>,result:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & (R & List<&2,Scope.Permit>)) -> Product.Owner<L,R> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>):
  match result:
    case (world,(right,rightPermits)):clocked(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,mode,leftInvoke,rightInvoke,List.append(&2,Scope.Permit,leftPermits,rightPermits),Product.Owner{left,right},W.execution_clock(~S,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~E,world))
def left_prepared(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,mode:Parallel.Mode,leftInvoke:List<&2,Scope.Permit> -> State.Scope<S,CL,RL> -> L -> State.Scope<S,CL,RL> & (L & List<&2,Ready.Completed<Error,Out>>),rightInvoke:List<&2,Scope.Permit> -> State.Scope<S,CR,RR> -> R -> State.Scope<S,CR,RR> & (R & List<&2,Ready.Completed<Error,Out>>),rightPrepare:List<&2,U32> -> W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> -> R -> W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & (R & List<&2,Scope.Permit>),ids:List<&2,U32>,right:R,result:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & (L & List<&2,Scope.Permit>)) -> Product.Owner<L,R> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>):
  match result:
    case (world,(left,leftPermits)):right_prepared(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,mode,leftInvoke,rightInvoke,left,leftPermits,rightPrepare(ids,world,right))
def compiled(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,mode:Parallel.Mode,world:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,+ids:List<&2,U32>,left:Tree.Runtime<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,State.Scope<S,CL,RL>,L,Error,Out>,right:Tree.Runtime<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,State.Scope<S,CR,RR>,R,Error,Out>) -> Product.Owner<L,R> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>):
  match left right:
    case Tree.Runtime{l,_,_,_,_,_,_,lp,lv} Tree.Runtime{r,_,_,_,_,_,_,rp,rv}:left_prepared(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,mode,lv,rv,rp,ids,r,lp(ids,world,l))
def group(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,~left:Tree.Selection(~S,~Product.Owner<CL,CR>,~CL,~RL,~E,~Error,~Out,~L),~right:Tree.Selection(~S,~Product.Owner<CL,CR>,~CR,~RR,~E,~Error,~Out,~R),mode:Parallel.Mode,owners:Product.Owner<L,R>,world:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,ids:List<&2,U32>) -> Product.Owner<L,R> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>):
  match owners:
    case Product.Owner{l,r}:compiled(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,mode,world,ids,Tree.compile(~S,~CL,~RL,~E,~Error,~Out,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~L,~left,l),Tree.compile(~S,~CR,~RR,~E,~Error,~Out,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~R,~right,r))
def group_native(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,~left:Tree.Selection(~S,~Product.Owner<CL,CR>,~CL,~RL,~E,~Error,~Out,~L),~right:Tree.Selection(~S,~Product.Owner<CL,CR>,~CR,~RR,~E,~Error,~Out,~R),owners:Product.Owner<L,R>,world:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,ids:List<&2,U32>) -> Product.Owner<L,R> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>):
  group(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,~left,~right,Parallel.Native{},owners,world,ids)
def group_serial(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,~left:Tree.Selection(~S,~Product.Owner<CL,CR>,~CL,~RL,~E,~Error,~Out,~L),~right:Tree.Selection(~S,~Product.Owner<CL,CR>,~CR,~RR,~E,~Error,~Out,~R),owners:Product.Owner<L,R>,world:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,ids:List<&2,U32>) -> Product.Owner<L,R> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>):
  group(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,~left,~right,Parallel.Serial{},owners,world,ids)
def single_returned(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,result:Product.Owner<L,R> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>)) -> Product.Owner<L,R> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & Exec.Invocation<Error,Out>):
  match result:
    case (owners,(world,statuses)):(owners,(world,Part.single_status(~Error,~Out,statuses)))
def dispatch(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,~left:Tree.Selection(~S,~Product.Owner<CL,CR>,~CL,~RL,~E,~Error,~Out,~L),~right:Tree.Selection(~S,~Product.Owner<CL,CR>,~CR,~RR,~E,~Error,~Out,~R),owners:Product.Owner<L,R>,world:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,id:U32) -> Product.Owner<L,R> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & Exec.Invocation<Error,Out>):
  single_returned(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,group(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,~left,~right,Parallel.Serial{},owners,world,[id]))
type Facts<-Owners:Type> is Type:
  Facts{owners:Owners,nodes:List<&2,Plan.Node<String>>,entries:List<&2,Part.Entry>,invalid:Maybe<&2,Plan.Invalid<String>>,deferred:List<&2,U32>}
def gathered(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,left:Tree.Runtime<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,State.Scope<S,CL,RL>,L,Error,Out>,right:Tree.Runtime<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,State.Scope<S,CR,RR>,R,Error,Out>) -> Facts<Product.Owner<L,R>>:
  match left right:
    case Tree.Runtime{l,ln,le,li,ld,_,_,_,_} Tree.Runtime{r,rn,re,ri,rd,_,_,_,_}:Facts{Product.Owner{l,r},List.append(&2,Plan.Node<String>,ln,rn),List.append(&2,Part.Entry,le,re),Plan.first_error(~String,li,ri),List.append(&2,U32,ld,rd)}
def facts(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,~left:Tree.Selection(~S,~Product.Owner<CL,CR>,~CL,~RL,~E,~Error,~Out,~L),~right:Tree.Selection(~S,~Product.Owner<CL,CR>,~CR,~RR,~E,~Error,~Out,~R),owners:Product.Owner<L,R>) -> Facts<Product.Owner<L,R>>:
  match owners:
    case Product.Owner{l,r}:gathered(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,Tree.compile(~S,~CL,~RL,~E,~Error,~Out,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~L,~left,l),Tree.compile(~S,~CR,~RR,~E,~Error,~Out,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~R,~right,r))
def registered(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,~left:Tree.Selection(~S,~Product.Owner<CL,CR>,~CL,~RL,~E,~Error,~Out,~L),~right:Tree.Selection(~S,~Product.Owner<CL,CR>,~CR,~RR,~E,~Error,~Out,~R),facts:Facts<Product.Owner<L,R>>) -> Reg.Registry<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Product.Owner<L,R>,Error,Out,dispatch(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,~left,~right)>:
  match facts:
    case Facts{owners,nodes,_,_,_}:Reg.Registry{owners,nodes}
def registry(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,~left:Tree.Selection(~S,~Product.Owner<CL,CR>,~CL,~RL,~E,~Error,~Out,~L),~right:Tree.Selection(~S,~Product.Owner<CL,CR>,~CR,~RR,~E,~Error,~Out,~R),owners:Product.Owner<L,R>) -> Reg.Registry<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Product.Owner<L,R>,Error,Out,dispatch(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,~left,~right)>:
  registered(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,~left,~right,facts(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,~left,~right,owners))
def conditions_registered(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~L:Type,~R:Type,~left:Tree.Selection(~S,~Product.Owner<CL,CR>,~CL,~RL,~E,~Error,~Bool,~L),~right:Tree.Selection(~S,~Product.Owner<CL,CR>,~CR,~RR,~E,~Error,~Bool,~R),facts:Facts<Product.Owner<L,R>>) -> Reg.ConditionRegistry<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Product.Owner<L,R>,Error,dispatch(~S,~CL,~CR,~RL,~RR,~E,~Error,~Bool,~L,~R,~left,~right)>:
  match facts:
    case Facts{owners,nodes,_,invalid,_}:Reg.ConditionRegistry{Reg.Registry{owners,nodes},invalid}
def condition_registry(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~L:Type,~R:Type,~left:Tree.Selection(~S,~Product.Owner<CL,CR>,~CL,~RL,~E,~Error,~Bool,~L),~right:Tree.Selection(~S,~Product.Owner<CL,CR>,~CR,~RR,~E,~Error,~Bool,~R),owners:Product.Owner<L,R>) -> Reg.ConditionRegistry<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Product.Owner<L,R>,Error,dispatch(~S,~CL,~CR,~RL,~RR,~E,~Error,~Bool,~L,~R,~left,~right)>:
  conditions_registered(~S,~CL,~CR,~RL,~RR,~E,~Error,~L,~R,~left,~right,facts(~S,~CL,~CR,~RL,~RR,~E,~Error,~Bool,~L,~R,~left,~right,owners))
