import Base
import ./execution-prepared.bend as Prep
import ./execution-lifecycle-notices.bend as Notice
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

# Returned is an unqualified observation of an attempted invocation; it cannot be promoted to Prepared.
type Returned<-H:Type,-Owners:Type,P:Data,Status:Data> is Type:
  Returned{scope:H,owners:Owners,provenance:Prep.Provenance<P>,status:Status}
def returned(~H:Type,~World:Type,~Owners:Type,~P:Data,~Status:Data,result:Prep.Invocation<H,World,Owners,P,Status>) -> Returned<H,Owners,P,Status>:
  match result:
    case Prep.Invoked{scope,Prep.Prepared{_,owners,_,tree},status}:Returned{scope,owners,tree,status}
    case Prep.InvocationRefused{scope,Prep.Prepared{_,owners,_,tree},status}:Returned{scope,owners,tree,status}
    case Prep.InvocationInventoryRefused{scope,Prep.Inventory{owners,tree},status}:Returned{scope,owners,tree,status}
def leave(~S:Data,~C:Type,~R:Type,~E:Data,permits:List<&2,Prep.Permit<S,C>>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E>:
  match permits:
    case []:world
    case Prep.Permit{_,_,allowed,_} <> rest:leave(~S,~C,~R,~E,rest,Task.leave(~S,~C,~R,~E,allowed,world))
def status_id(~Error:Data,~Out:Data,value:Ready.Completed<Error,Out>) -> U32:
  match value:
    case Ready.Completed{id,_}:id
def has_status(~Error:Data,~Out:Data,+id:U32,values:List<&2,Ready.Completed<Error,Out>>) -> Bool:
  match values:
    case []:False{}
    case value <> rest:Bool.or(U32.is_eq(id,status_id(~Error,~Out,value)),has_status(~Error,~Out,id,rest))
def missing_status(~Error:Data,~Out:Data,found:Bool,id:U32,rest:List<&2,Ready.Completed<Error,Out>>) -> List<&2,Ready.Completed<Error,Out>>:
  match found:
    case True{}:rest
    case False{}:Ready.Completed{id,Exec.AdmissionRefused{}} <> rest
def missing_statuses(~Error:Data,~Out:Data,ids:List<&2,U32>,+values:List<&2,Ready.Completed<Error,Out>>) -> List<&2,Ready.Completed<Error,Out>>:
  match ids:
    case []:[]
    case +id <> rest:missing_status(~Error,~Out,has_status(~Error,~Out,id,values),id,missing_statuses(~Error,~Out,rest,values))
def complete_statuses(~Error:Data,~Out:Data,ids:List<&2,U32>,+values:List<&2,Ready.Completed<Error,Out>>) -> List<&2,Ready.Completed<Error,Out>>:
  List.append(&2,Ready.Completed<Error,Out>,values,missing_statuses(~Error,~Out,ids,values))
def joined(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,left:Returned<State.Scope<S,CL,RL>,L,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>,right:Returned<State.Scope<S,CR,RR>,R,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>) -> Returned<State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>>,Product.Owner<L,R>,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>:
  match left right:
    case Returned{State.Scope{lc,lr,handles,tick,prior,lifecycleView},left,lt,leftOut} Returned{State.Scope{rc,rr,_,_,_,_},right,rt,rightOut}:Returned{State.Scope{Product.Owner{lc,rc},Product.Owner{lr,rr},handles,tick,prior,lifecycleView},Product.Owner{left,right},Prep.Pair{lt,rt},List.append(&2,Ready.Completed<Error,Out>,leftOut,rightOut)}
def trusted_execute(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,mode:Parallel.Mode,leftInvoke:State.Scope<S,CL,RL> -> Prep.Prepared<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,L,Prep.Permit<S,Product.Owner<CL,CR>>> -> Prep.Invocation<State.Scope<S,CL,RL>,W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,L,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>,rightInvoke:State.Scope<S,CR,RR> -> Prep.Prepared<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,R,Prep.Permit<S,Product.Owner<CL,CR>>> -> Prep.Invocation<State.Scope<S,CR,RR>,W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,R,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>,scope:State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>>,prepared:Prep.Prepared<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Product.Owner<L,R>,Prep.Permit<S,Product.Owner<CL,CR>>>) -> Returned<State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>>,Product.Owner<L,R>,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>:
  match mode scope prepared:
    case Parallel.Serial{} State.Scope{Product.Owner{lc,rc},Product.Owner{lr,rr},+handles,+tick,+prior,+lifecycleView} Prep.Prepared{+namespace,Product.Owner{left,right},_,Prep.Pair{+lt,+rt}}:
      l = returned(~State.Scope<S,CL,RL>,~W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,~L,~Prep.Permit<S,Product.Owner<CL,CR>>,~List<&2,Ready.Completed<Error,Out>>,leftInvoke(State.Scope{lc,lr,handles,tick,prior,lifecycleView},Prep.Prepared{namespace,left,Prep.permits(~Prep.Permit<S,Product.Owner<CL,CR>>,lt),lt}))
      r = returned(~State.Scope<S,CR,RR>,~W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,~R,~Prep.Permit<S,Product.Owner<CL,CR>>,~List<&2,Ready.Completed<Error,Out>>,rightInvoke(State.Scope{rc,rr,handles,tick,prior,lifecycleView},Prep.Prepared{namespace,right,Prep.permits(~Prep.Permit<S,Product.Owner<CL,CR>>,rt),rt}))
      joined(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,l,r)
    case Parallel.Native{} State.Scope{Product.Owner{lc,rc},Product.Owner{lr,rr},+handles,+tick,+prior,+lifecycleView} Prep.Prepared{+namespace,Product.Owner{left,right},_,Prep.Pair{+lt,+rt}}:
      l r = returned(~State.Scope<S,CL,RL>,~W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,~L,~Prep.Permit<S,Product.Owner<CL,CR>>,~List<&2,Ready.Completed<Error,Out>>,leftInvoke(State.Scope{lc,lr,handles,tick,prior,lifecycleView},Prep.Prepared{namespace,left,Prep.permits(~Prep.Permit<S,Product.Owner<CL,CR>>,lt),lt})) returned(~State.Scope<S,CR,RR>,~W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,~R,~Prep.Permit<S,Product.Owner<CL,CR>>,~List<&2,Ready.Completed<Error,Out>>,rightInvoke(State.Scope{rc,rr,handles,tick,prior,lifecycleView},Prep.Prepared{namespace,right,Prep.permits(~Prep.Permit<S,Product.Owner<CL,CR>>,rt),rt}))
      joined(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,l,r)
    case _ scope Prep.Prepared{_,owners,_,Prep.Leaf{n,ps}}:Returned{scope,owners,Prep.Leaf{n,ps},[]}
    case _ scope Prep.Prepared{_,owners,_,Prep.Unprepared{}}:Returned{scope,owners,Prep.Unprepared{},[]}
def finished(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,ids:List<&2,U32>,admin:State.Administration<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,result:Returned<State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>>,Product.Owner<L,R>,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>) -> Product.Owner<L,R> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>):
  match result:
    case Returned{scope,owners,tree,statuses}:(owners,(leave(~S,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~E,Prep.permits(~Prep.Permit<S,Product.Owner<CL,CR>>,tree),State.reassemble(~S,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~E,admin,scope)),complete_statuses(~Error,~Out,ids,statuses)))
def separated(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,mode:Parallel.Mode,leftInvoke:State.Scope<S,CL,RL> -> Prep.Prepared<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,L,Prep.Permit<S,Product.Owner<CL,CR>>> -> Prep.Invocation<State.Scope<S,CL,RL>,W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,L,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>,rightInvoke:State.Scope<S,CR,RR> -> Prep.Prepared<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,R,Prep.Permit<S,Product.Owner<CL,CR>>> -> Prep.Invocation<State.Scope<S,CR,RR>,W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,R,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>,ids:List<&2,U32>,prepared:Prep.Prepared<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Product.Owner<L,R>,Prep.Permit<S,Product.Owner<CL,CR>>>,result:State.Administration<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>>) -> Product.Owner<L,R> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>):
  match result:
    case (admin,scope):finished(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,ids,admin,trusted_execute(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,mode,leftInvoke,rightInvoke,scope,prepared))
def clocked(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,mode:Parallel.Mode,leftInvoke:State.Scope<S,CL,RL> -> Prep.Prepared<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,L,Prep.Permit<S,Product.Owner<CL,CR>>> -> Prep.Invocation<State.Scope<S,CL,RL>,W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,L,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>,rightInvoke:State.Scope<S,CR,RR> -> Prep.Prepared<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,R,Prep.Permit<S,Product.Owner<CL,CR>>> -> Prep.Invocation<State.Scope<S,CR,RR>,W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,R,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>,ids:List<&2,U32>,prepared:Prep.Prepared<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Product.Owner<L,R>,Prep.Permit<S,Product.Owner<CL,CR>>>,result:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & Tick.Tick) -> Product.Owner<L,R> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>):
  match result:
    case (world,tick):separated(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,mode,leftInvoke,rightInvoke,ids,prepared,State.separate(~S,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~E,world,tick))
def prepared(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,mode:Parallel.Mode,leftInvoke:State.Scope<S,CL,RL> -> Prep.Prepared<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,L,Prep.Permit<S,Product.Owner<CL,CR>>> -> Prep.Invocation<State.Scope<S,CL,RL>,W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,L,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>,rightInvoke:State.Scope<S,CR,RR> -> Prep.Prepared<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,R,Prep.Permit<S,Product.Owner<CL,CR>>> -> Prep.Invocation<State.Scope<S,CR,RR>,W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,R,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>,ids:List<&2,U32>,result:Prep.Preparation<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Product.Owner<L,R>,Prep.Permit<S,Product.Owner<CL,CR>>>) -> Product.Owner<L,R> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>):
  match result:
    case Prep.PreparationReady{world,prepared}:clocked(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,mode,leftInvoke,rightInvoke,ids,prepared,W.execution_clock(~S,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~E,world))
    case Prep.PreparationRefused{world,Prep.Inventory{owners,tree}}:(owners,(leave(~S,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~E,Prep.permits(~Prep.Permit<S,Product.Owner<CL,CR>>,tree),world),complete_statuses(~Error,~Out,ids,[])))
def compiled(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,mode:Parallel.Mode,world:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,+ids:List<&2,U32>,left:Tree.Runtime<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Prep.Permit<S,Product.Owner<CL,CR>>,State.Scope<S,CL,RL>,L,Error,Out>,right:Tree.Runtime<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Prep.Permit<S,Product.Owner<CL,CR>>,State.Scope<S,CR,RR>,R,Error,Out>) -> Product.Owner<L,R> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>):
  match left right:
    case Tree.Runtime{l,_,_,_,_,_,_,lp,lv} Tree.Runtime{r,_,_,_,_,_,_,rp,rv}:prepared(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,mode,lv,rv,ids,Tree.trusted_prepare_pair(~W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,~L,~R,~Prep.Permit<S,Product.Owner<CL,CR>>,lp,rp,ids,world,Product.Owner{l,r}))
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
def gathered(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,left:Tree.Runtime<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Prep.Permit<S,Product.Owner<CL,CR>>,State.Scope<S,CL,RL>,L,Error,Out>,right:Tree.Runtime<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Prep.Permit<S,Product.Owner<CL,CR>>,State.Scope<S,CR,RR>,R,Error,Out>) -> Facts<Product.Owner<L,R>>:
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
