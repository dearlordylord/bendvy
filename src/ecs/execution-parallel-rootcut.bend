import Base
import ./execution-reservation-task.bend as Effect
import ./execution-reservation-authority.bend as RuntimePermit
import ./execution-reservation-driver.bend as Driver
import ./execution-system.bend as Sys
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
def returned(~H:Type,~World:Type,~P:Data,~Status:Data,-Owners:Type,result:Prep.Invocation<H,World,Owners,P,Status>) -> Returned<H,Owners,P,Status>:
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
def allowed_ids(~S:Data,~C:Type,permits:List<&2,Prep.Permit<S,C>>) -> List<&2,U32>:
  match permits:
    case []:[]
    case Prep.Permit{_,id,True{},_} <> rest:id <> allowed_ids(~S,~C,rest)
    case Prep.Permit{_,_,False{},_} <> rest:allowed_ids(~S,~C,rest)
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
def joined(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,-L:Type,-R:Type,left:Returned<State.Scope<S,CL,RL>,L,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>,right:Returned<State.Scope<S,CR,RR>,R,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>) -> Returned<State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>>,Product.Owner<L,R>,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>:
  match left right:
    case Returned{State.Scope{lc,lr,handles,tick,prior,lifecycleView},left,lt,leftOut} Returned{State.Scope{rc,rr,_,_,_,_},right,rt,rightOut}:Returned{State.Scope{Product.Owner{lc,rc},Product.Owner{lr,rr},handles,tick,prior,lifecycleView},Product.Owner{left,right},Prep.Pair{lt,rt},List.append(&2,Ready.Completed<Error,Out>,leftOut,rightOut)}
def paired_tasks(~S:Data,-L:Type,-R:Type,-Out:Type,join:L -> R -> Out,mode:Parallel.Mode,left:Effect.Task<S,RuntimePermit.Permit,L>,right:Effect.Task<S,RuntimePermit.Permit,R>) -> Effect.Task<S,RuntimePermit.Permit,Out>:
  match mode:
    case Parallel.Serial{}:Effect.bind(S,RuntimePermit.Permit,L,Out,left,l => Sys.map(S,RuntimePermit.Permit,R,Out,right,r => join(l,r)))
    case Parallel.Native{}:Effect.TFork{L,R,left,right,l => r => Effect.TDone{join(l,r)}}
def joined_invocations(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,-L:Type,-R:Type,left:Prep.Invocation<State.Scope<S,CL,RL>,W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,L,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>,right:Prep.Invocation<State.Scope<S,CR,RR>,W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,R,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>) -> Returned<State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>>,Product.Owner<L,R>,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>:
  joined(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,L,R,returned(~State.Scope<S,CL,RL>,~W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,~Prep.Permit<S,Product.Owner<CL,CR>>,~List<&2,Ready.Completed<Error,Out>>,L,left),returned(~State.Scope<S,CR,RR>,~W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,~Prep.Permit<S,Product.Owner<CL,CR>>,~List<&2,Ready.Completed<Error,Out>>,R,right))
def trusted_execute(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,-L:Type,-R:Type,mode:Parallel.Mode,leftInvoke:State.Scope<S,CL,RL> -> Prep.Prepared<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,L,Prep.Permit<S,Product.Owner<CL,CR>>> -> Effect.Task<S,RuntimePermit.Permit,Prep.Invocation<State.Scope<S,CL,RL>,W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,L,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>>,rightInvoke:State.Scope<S,CR,RR> -> Prep.Prepared<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,R,Prep.Permit<S,Product.Owner<CL,CR>>> -> Effect.Task<S,RuntimePermit.Permit,Prep.Invocation<State.Scope<S,CR,RR>,W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,R,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>>,scope:State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>>,prepared:Prep.Prepared<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Product.Owner<L,R>,Prep.Permit<S,Product.Owner<CL,CR>>>) -> Effect.Task<S,RuntimePermit.Permit,Returned<State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>>,Product.Owner<L,R>,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>>:
  match scope prepared:
    case State.Scope{Product.Owner{lc,rc},Product.Owner{lr,rr},+handles,+tick,+prior,+lifecycleView} Prep.Prepared{+namespace,Product.Owner{left,right},_,Prep.Pair{+lt,+rt}}:paired_tasks(~S,Prep.Invocation<State.Scope<S,CL,RL>,W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,L,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>,Prep.Invocation<State.Scope<S,CR,RR>,W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,R,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>,Returned<State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>>,Product.Owner<L,R>,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>,joined_invocations(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,L,R),mode,leftInvoke(State.Scope{lc,lr,handles,tick,prior,lifecycleView},Prep.Prepared{namespace,left,Prep.permits(Prep.Permit<S,Product.Owner<CL,CR>>,lt),lt}),rightInvoke(State.Scope{rc,rr,handles,tick,prior,lifecycleView},Prep.Prepared{namespace,right,Prep.permits(Prep.Permit<S,Product.Owner<CL,CR>>,rt),rt}))
    case scope Prep.Prepared{_,owners,_,Prep.Leaf{n,ps}}:Effect.TDone{Returned{scope,owners,Prep.Leaf{n,ps},[]}}
    case scope Prep.Prepared{_,owners,_,Prep.Unprepared{}}:Effect.TDone{Returned{scope,owners,Prep.Unprepared{},[]}}
def finished(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,-L:Type,-R:Type,ids:List<&2,U32>,admin:State.Administration<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,result:Returned<State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>>,Product.Owner<L,R>,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>) -> Product.Owner<L,R> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>):
  match result:
    case Returned{scope,owners,tree,statuses}:(owners,(leave(~S,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~E,Prep.permits(Prep.Permit<S,Product.Owner<CL,CR>>,tree),State.reassemble(~S,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~E,admin,scope)),complete_statuses(~Error,~Out,ids,statuses)))
def finished_driven(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,-L:Type,-R:Type,ids:List<&2,U32>,result:State.Administration<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & Returned<State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>>,Product.Owner<L,R>,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>) -> IO(Product.Owner<L,R> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>)):
  match result:
    case (admin,result):IO.pure(Product.Owner<L,R> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>),finished(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,L,R,ids,admin,result))
def separated(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,-L:Type,-R:Type,mode:Parallel.Mode,leftInvoke:State.Scope<S,CL,RL> -> Prep.Prepared<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,L,Prep.Permit<S,Product.Owner<CL,CR>>> -> Effect.Task<S,RuntimePermit.Permit,Prep.Invocation<State.Scope<S,CL,RL>,W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,L,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>>,rightInvoke:State.Scope<S,CR,RR> -> Prep.Prepared<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,R,Prep.Permit<S,Product.Owner<CL,CR>>> -> Effect.Task<S,RuntimePermit.Permit,Prep.Invocation<State.Scope<S,CR,RR>,W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,R,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>>,ids:List<&2,U32>,prepared:Prep.Prepared<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Product.Owner<L,R>,Prep.Permit<S,Product.Owner<CL,CR>>>,result:State.Administration<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>>) -> IO(Product.Owner<L,R> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>)):
  match prepared result:
    case Prep.Prepared{namespace,owners,+permits,provenance}, (admin,scope):IO.bind(State.Administration<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & Returned<State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>>,Product.Owner<L,R>,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>,Product.Owner<L,R> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>),Driver.run(~S,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~E,Returned<State.Scope<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>>,Product.Owner<L,R>,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>,allowed_ids(~S,~Product.Owner<CL,CR>,permits),admin,trusted_execute(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,L,R,mode,leftInvoke,rightInvoke,scope,Prep.Prepared{namespace,owners,permits,provenance})),result => finished_driven(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,L,R,ids,result))
def clocked(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,-L:Type,-R:Type,mode:Parallel.Mode,leftInvoke:State.Scope<S,CL,RL> -> Prep.Prepared<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,L,Prep.Permit<S,Product.Owner<CL,CR>>> -> Effect.Task<S,RuntimePermit.Permit,Prep.Invocation<State.Scope<S,CL,RL>,W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,L,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>>,rightInvoke:State.Scope<S,CR,RR> -> Prep.Prepared<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,R,Prep.Permit<S,Product.Owner<CL,CR>>> -> Effect.Task<S,RuntimePermit.Permit,Prep.Invocation<State.Scope<S,CR,RR>,W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,R,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>>,ids:List<&2,U32>,prepared:Prep.Prepared<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Product.Owner<L,R>,Prep.Permit<S,Product.Owner<CL,CR>>>,result:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & Tick.Tick) -> IO(Product.Owner<L,R> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>)):
  match result:
    case (world,tick):separated(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,L,R,mode,leftInvoke,rightInvoke,ids,prepared,State.separate(~S,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~E,world,tick))
def prepared(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,-L:Type,-R:Type,mode:Parallel.Mode,leftInvoke:State.Scope<S,CL,RL> -> Prep.Prepared<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,L,Prep.Permit<S,Product.Owner<CL,CR>>> -> Effect.Task<S,RuntimePermit.Permit,Prep.Invocation<State.Scope<S,CL,RL>,W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,L,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>>,rightInvoke:State.Scope<S,CR,RR> -> Prep.Prepared<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,R,Prep.Permit<S,Product.Owner<CL,CR>>> -> Effect.Task<S,RuntimePermit.Permit,Prep.Invocation<State.Scope<S,CR,RR>,W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,R,Prep.Permit<S,Product.Owner<CL,CR>>,List<&2,Ready.Completed<Error,Out>>>>,ids:List<&2,U32>,result:Prep.Preparation<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Product.Owner<L,R>,Prep.Permit<S,Product.Owner<CL,CR>>>) -> IO(Product.Owner<L,R> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>)):
  match result:
    case Prep.PreparationReady{world,prepared}:clocked(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,L,R,mode,leftInvoke,rightInvoke,ids,prepared,W.execution_clock(~S,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~E,world))
    case Prep.PreparationRefused{world,Prep.Inventory{owners,tree}}:IO.pure(Product.Owner<L,R> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>),(owners,(leave(~S,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~E,Prep.permits(Prep.Permit<S,Product.Owner<CL,CR>>,tree),world),complete_statuses(~Error,~Out,ids,[]))))
def restored(~World:Type,~Status:Data,-L:Type,-R:Type,-HL:Type,-HR:Type,left:HL -> L,right:HR -> R,result:Product.Owner<HL,HR> & (World & Status)) -> IO(Product.Owner<L,R> & (World & Status)):
  match result:
    case (held,result):IO.pure(Product.Owner<L,R> & (World & Status),(Tree.restore_pair(L,R,HL,HR,left,right,held),result))
def compiled(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,-L:Type,-R:Type,mode:Parallel.Mode,world:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,+ids:List<&2,U32>,left:Tree.Runtime<S,W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Prep.Permit<S,Product.Owner<CL,CR>>,State.Scope<S,CL,RL>,L,Error,Out>,right:Tree.Runtime<S,W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Prep.Permit<S,Product.Owner<CL,CR>>,State.Scope<S,CR,RR>,R,Error,Out>) -> IO(Product.Owner<L,R> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>)):
  match left right:
    case Tree.Runtime{HL,restoreLeft,l,_,_,_,_,_,_,lp,lv} Tree.Runtime{HR,restoreRight,r,_,_,_,_,_,_,rp,rv}:IO.bind(Product.Owner<HL,HR> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>),Product.Owner<L,R> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>),prepared(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,HL,HR,mode,lv,rv,ids,Tree.trusted_prepare_pair(W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,HL,HR,Prep.Permit<S,Product.Owner<CL,CR>>,lp,rp,ids,world,Product.Owner{l,r})),result => restored(~W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,~List<&2,Ready.Completed<Error,Out>>,L,R,HL,HR,restoreLeft,restoreRight,result))
def group(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,~left:Tree.Selection(~S,~Product.Owner<CL,CR>,~CL,~RL,~E,~Error,~Out,~L),~right:Tree.Selection(~S,~Product.Owner<CL,CR>,~CR,~RR,~E,~Error,~Out,~R),mode:Parallel.Mode,owners:Product.Owner<L,R>,world:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,ids:List<&2,U32>) -> IO(Product.Owner<L,R> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>)):
  match owners:
    case Product.Owner{l,r}:compiled(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,L,R,mode,world,ids,Tree.compile(~S,~CL,~RL,~E,~Error,~Out,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~L,~left,l),Tree.compile(~S,~CR,~RR,~E,~Error,~Out,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~R,~right,r))
def group_native(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,~left:Tree.Selection(~S,~Product.Owner<CL,CR>,~CL,~RL,~E,~Error,~Out,~L),~right:Tree.Selection(~S,~Product.Owner<CL,CR>,~CR,~RR,~E,~Error,~Out,~R),owners:Product.Owner<L,R>,world:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,ids:List<&2,U32>) -> IO(Product.Owner<L,R> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>)):
  group(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,~left,~right,Parallel.Native{},owners,world,ids)
def group_serial(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,~left:Tree.Selection(~S,~Product.Owner<CL,CR>,~CL,~RL,~E,~Error,~Out,~L),~right:Tree.Selection(~S,~Product.Owner<CL,CR>,~CR,~RR,~E,~Error,~Out,~R),owners:Product.Owner<L,R>,world:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,ids:List<&2,U32>) -> IO(Product.Owner<L,R> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>)):
  group(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,~left,~right,Parallel.Serial{},owners,world,ids)
type Facts<-Owners:Type> is Type:
  Facts{owners:Owners,nodes:List<&2,Plan.Node<String>>,entries:List<&2,Part.Entry>,invalid:Maybe<&2,Plan.Invalid<String>>,deferred:List<&2,U32>}
def gathered(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,left:Tree.Runtime<S,W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Prep.Permit<S,Product.Owner<CL,CR>>,State.Scope<S,CL,RL>,L,Error,Out>,right:Tree.Runtime<S,W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Prep.Permit<S,Product.Owner<CL,CR>>,State.Scope<S,CR,RR>,R,Error,Out>) -> Facts<Product.Owner<L,R>>:
  match left right:
    case Tree.Runtime{HL,restoreLeft,l,ln,le,li,ld,_,_,_,_} Tree.Runtime{HR,restoreRight,r,rn,re,ri,rd,_,_,_,_}:Facts{Tree.restore_pair(L,R,HL,HR,restoreLeft,restoreRight,Product.Owner{l,r}),List.append(&2,Plan.Node<String>,ln,rn),List.append(&2,Part.Entry,le,re),Plan.first_error(~String,li,ri),List.append(&2,U32,ld,rd)}
def facts(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,~left:Tree.Selection(~S,~Product.Owner<CL,CR>,~CL,~RL,~E,~Error,~Out,~L),~right:Tree.Selection(~S,~Product.Owner<CL,CR>,~CR,~RR,~E,~Error,~Out,~R),owners:Product.Owner<L,R>) -> Facts<Product.Owner<L,R>>:
  match owners:
    case Product.Owner{l,r}:gathered(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,Tree.compile(~S,~CL,~RL,~E,~Error,~Out,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~L,~left,l),Tree.compile(~S,~CR,~RR,~E,~Error,~Out,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~R,~right,r))
