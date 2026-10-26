import Base
import ./world.bend as W
import ./execution-system.bend as Sys
import ./execution-builder.bend as Build
import ./execution-declaration.bend as D
import ./execution-parallel.bend as Parallel
import ./execution-parallel-app.bend as AppPair
import ./execution-parallel-run.bend as Run
import ./execution-parallel-system.bend as Task
import ./execution-parallel-schedule.bend as Ready
import ./dependency-registration.bend as Reg
import ./dependency-plan.bend as Plan
import ./dependency-executor.bend as Exec
import ./owner-product.bend as Product
import ./string-equality.bend as SE

type Use is Data:
  Use{key:String,mode:D.Mode}
type Entry is Data:
  Entry{id:U32,uses:List<&2,Use>}
type Rules is Data:
  Rules{entries:List<&2,Entry>}
def uses(access:List<&2,D.Access>) -> List<&2,Use>:
  match access:
    case []:[]
    case D.Access{key,kind,mode,_} <> rest:Use{D.requirement_key(kind,key),mode} <> uses(rest)
def guard_uses(keys:List<&2,String>) -> List<&2,Use>:
  match keys:
    case []:[]
    case key <> rest:Use{key,D.Exclusive{}} <> guard_uses(rest)
def modes(left:D.Mode,right:D.Mode) -> Bool:
  match left right:
    case D.SharedView{} D.SharedView{}:True{}
    case _ _:False{}
def compatible_use(left:Use,right:Use) -> Bool:
  match left right:
    case Use{lk,lm} Use{rk,rm}:Bool.or(Bool.not(SE.equal(lk,rk)),modes(lm,rm))
def compatible_with(+left:Use,right:List<&2,Use>) -> Bool:
  match right:
    case []:True{}
    case first <> rest:Bool.and(compatible_use(left,first),compatible_with(left,rest))
def compatible_all(left:List<&2,Use>,+right:List<&2,Use>) -> Bool:
  match left:
    case []:True{}
    case first <> rest:Bool.and(compatible_with(first,right),compatible_all(rest,right))
def entry_selected(found:Bool,uses:List<&2,Use>,rest:List<&2,Use>) -> List<&2,Use>:
  match found:
    case True{}:uses
    case False{}:rest
def lookup(entries:List<&2,Entry>,+id:U32) -> List<&2,Use>:
  match entries:
    case []:[]
    case Entry{actual,uses} <> rest:entry_selected(U32.is_eq(actual,id),uses,lookup(rest,id))
def compatible(rules:Rules,left:U32,right:U32) -> Bool:
  match rules:
    case Rules{+entries}:compatible_all(lookup(entries,left),lookup(entries,right))
def member(ids:List<&2,U32>,+id:U32) -> Bool:
  match ids:
    case []:False{}
    case first <> rest:Bool.or(U32.is_eq(first,id),member(rest,id))
def meta_id(meta:Task.Meta) -> U32:
  match meta:
    case Task.Meta{_,id,_,_,_}:id

def invocation(~Error:Data,~Out:Data,value:Maybe<&2,Sys.Completion<Error,Out>>) -> Exec.Invocation<Error,Out>:
  match value:
    case None{}:Exec.AdmissionRefused{}
    case Some{Sys.Success{out}}:Exec.Completed{out}
    case Some{Sys.BodyError{error,out}}:Exec.BodyError{error,out}
def completed(~Error:Data,~Out:Data,selected:Bool,id:U32,value:Maybe<&2,Sys.Completion<Error,Out>>,rest:List<&2,Ready.Completed<Error,Out>>) -> List<&2,Ready.Completed<Error,Out>>:
  match selected:
    case False{}:rest
    case True{}:Ready.Completed{id,invocation(~Error,~Out,value)} <> rest

def returned(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~Error:Data,~Out:Data,~OpsL:Type -> Type,~OpsR:Type -> Type,~dl:Build.Program(~S,~CL,~RL,~OpsL),~dr:Build.Program(~S,~CR,~RR,~OpsR),~bl:@-H:Type -> @-caps:OpsL(H) -> H -> LL -> H & (LL & Sys.Completion<Error,Out>),~br:@-H:Type -> @-caps:OpsR(H) -> H -> LR -> H & (LR & Sys.Completion<Error,Out>),+ids:List<&2,U32>,+leftId:U32,+rightId:U32,result:Run.PairResult<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Sys.Owner<S,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,CR,RR,E,OpsR,LR,Error,Out,dr,br>,Error,Error,Out,Out>) -> Product.Owner<Sys.Owner<S,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,CR,RR,E,OpsR,LR,Error,Out,dr,br>> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>):
  match result:
    case Run.Finished{world,left,right,lc,rc}:(Product.Owner{left,right},(world,completed(~Error,~Out,member(ids,leftId),leftId,lc,completed(~Error,~Out,member(ids,rightId),rightId,rc,[]))))
def right_detached(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~Error:Data,~Out:Data,~OpsL:Type -> Type,~OpsR:Type -> Type,~dl:Build.Program(~S,~CL,~RL,~OpsL),~dr:Build.Program(~S,~CR,~RR,~OpsR),~bl:@-H:Type -> @-caps:OpsL(H) -> H -> LL -> H & (LL & Sys.Completion<Error,Out>),~br:@-H:Type -> @-caps:OpsR(H) -> H -> LR -> H & (LR & Sys.Completion<Error,Out>),mode:Parallel.Mode,world:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,+ids:List<&2,U32>,+lm:Task.Meta,ll:LL,result:Task.Meta & LR) -> Product.Owner<Sys.Owner<S,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,CR,RR,E,OpsR,LR,Error,Out,dr,br>> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>):
  match result:
    case (+rm,lr):returned(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~Error,~Out,~OpsL,~OpsR,~dl,~dr,~bl,~br,ids,meta_id(lm),meta_id(rm),AppPair.run_when(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~Error,~Error,~Out,~Out,~OpsL,~OpsR,~dl,~dr,~bl,~br,mode,member(ids,meta_id(lm)),member(ids,meta_id(rm)),AppPair.ParallelApp{world,Task.restored(~S,~CL,~RL,~E,~OpsL,~LL,~Error,~Out,~dl,~bl,lm,ll),Task.restored(~S,~CR,~RR,~E,~OpsR,~LR,~Error,~Out,~dr,~br,rm,lr)}))
def left_detached(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~Error:Data,~Out:Data,~OpsL:Type -> Type,~OpsR:Type -> Type,~dl:Build.Program(~S,~CL,~RL,~OpsL),~dr:Build.Program(~S,~CR,~RR,~OpsR),~bl:@-H:Type -> @-caps:OpsL(H) -> H -> LL -> H & (LL & Sys.Completion<Error,Out>),~br:@-H:Type -> @-caps:OpsR(H) -> H -> LR -> H & (LR & Sys.Completion<Error,Out>),mode:Parallel.Mode,world:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,ids:List<&2,U32>,right:Sys.Owner<S,CR,RR,E,OpsR,LR,Error,Out,dr,br>,result:Task.Meta & LL) -> Product.Owner<Sys.Owner<S,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,CR,RR,E,OpsR,LR,Error,Out,dr,br>> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>):
  match result:
    case (lm,ll):right_detached(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~Error,~Out,~OpsL,~OpsR,~dl,~dr,~bl,~br,mode,world,ids,lm,ll,Task.detached(~S,~CR,~RR,~E,~OpsR,~LR,~Error,~Out,~dr,~br,right))
def group(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~Error:Data,~Out:Data,~OpsL:Type -> Type,~OpsR:Type -> Type,~dl:Build.Program(~S,~CL,~RL,~OpsL),~dr:Build.Program(~S,~CR,~RR,~OpsR),~bl:@-H:Type -> @-caps:OpsL(H) -> H -> LL -> H & (LL & Sys.Completion<Error,Out>),~br:@-H:Type -> @-caps:OpsR(H) -> H -> LR -> H & (LR & Sys.Completion<Error,Out>),mode:Parallel.Mode,owners:Product.Owner<Sys.Owner<S,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,CR,RR,E,OpsR,LR,Error,Out,dr,br>>,world:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,ids:List<&2,U32>) -> Product.Owner<Sys.Owner<S,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,CR,RR,E,OpsR,LR,Error,Out,dr,br>> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>):
  match owners:
    case Product.Owner{left,right}:left_detached(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~Error,~Out,~OpsL,~OpsR,~dl,~dr,~bl,~br,mode,world,ids,right,Task.detached(~S,~CL,~RL,~E,~OpsL,~LL,~Error,~Out,~dl,~bl,left))
def group_native(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~Error:Data,~Out:Data,~OpsL:Type -> Type,~OpsR:Type -> Type,~dl:Build.Program(~S,~CL,~RL,~OpsL),~dr:Build.Program(~S,~CR,~RR,~OpsR),~bl:@-H:Type -> @-caps:OpsL(H) -> H -> LL -> H & (LL & Sys.Completion<Error,Out>),~br:@-H:Type -> @-caps:OpsR(H) -> H -> LR -> H & (LR & Sys.Completion<Error,Out>),owners:Product.Owner<Sys.Owner<S,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,CR,RR,E,OpsR,LR,Error,Out,dr,br>>,world:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,ids:List<&2,U32>) -> Product.Owner<Sys.Owner<S,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,CR,RR,E,OpsR,LR,Error,Out,dr,br>> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>):
  group(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~Error,~Out,~OpsL,~OpsR,~dl,~dr,~bl,~br,Parallel.Native{},owners,world,ids)
def single_status(~Error:Data,~Out:Data,completions:List<&2,Ready.Completed<Error,Out>>) -> Exec.Invocation<Error,Out>:
  match completions:
    case []:Exec.AdmissionRefused{}
    case Ready.Completed{_,value} <> _:value
def single_returned(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~Error:Data,~Out:Data,~OpsL:Type -> Type,~OpsR:Type -> Type,~dl:Build.Program(~S,~CL,~RL,~OpsL),~dr:Build.Program(~S,~CR,~RR,~OpsR),~bl:@-H:Type -> @-caps:OpsL(H) -> H -> LL -> H & (LL & Sys.Completion<Error,Out>),~br:@-H:Type -> @-caps:OpsR(H) -> H -> LR -> H & (LR & Sys.Completion<Error,Out>),result:Product.Owner<Sys.Owner<S,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,CR,RR,E,OpsR,LR,Error,Out,dr,br>> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>)) -> Product.Owner<Sys.Owner<S,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,CR,RR,E,OpsR,LR,Error,Out,dr,br>> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & Exec.Invocation<Error,Out>):
  match result:
    case (owners,(world,statuses)):(owners,(world,single_status(~Error,~Out,statuses)))
def dispatch(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~Error:Data,~Out:Data,~OpsL:Type -> Type,~OpsR:Type -> Type,~dl:Build.Program(~S,~CL,~RL,~OpsL),~dr:Build.Program(~S,~CR,~RR,~OpsR),~bl:@-H:Type -> @-caps:OpsL(H) -> H -> LL -> H & (LL & Sys.Completion<Error,Out>),~br:@-H:Type -> @-caps:OpsR(H) -> H -> LR -> H & (LR & Sys.Completion<Error,Out>),owners:Product.Owner<Sys.Owner<S,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,CR,RR,E,OpsR,LR,Error,Out,dr,br>>,world:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,id:U32) -> Product.Owner<Sys.Owner<S,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,CR,RR,E,OpsR,LR,Error,Out,dr,br>> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & Exec.Invocation<Error,Out>):
  single_returned(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~Error,~Out,~OpsL,~OpsR,~dl,~dr,~bl,~br,group(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~Error,~Out,~OpsL,~OpsR,~dl,~dr,~bl,~br,Parallel.Serial{},owners,world,[id]))

def right_registered(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~Error:Data,~Out:Data,~OpsL:Type -> Type,~OpsR:Type -> Type,~dl:Build.Program(~S,~CL,~RL,~OpsL),~dr:Build.Program(~S,~CR,~RR,~OpsR),~bl:@-H:Type -> @-caps:OpsL(H) -> H -> LL -> H & (LL & Sys.Completion<Error,Out>),~br:@-H:Type -> @-caps:OpsR(H) -> H -> LR -> H & (LR & Sys.Completion<Error,Out>),left:Sys.Owner<S,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,leftId:U32,right:Sys.Owner<S,CR,RR,E,OpsR,LR,Error,Out,dr,br>) -> Reg.Registry<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Product.Owner<Sys.Owner<S,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,CR,RR,E,OpsR,LR,Error,Out,dr,br>>,Error,Out,dispatch(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~Error,~Out,~OpsL,~OpsR,~dl,~dr,~bl,~br)>:
  match right:
    case Sys.Owner{namespace,+id,name,access,cursor,local}:Reg.Registry{Product.Owner{left,Sys.Owner{namespace,id,name,access,cursor,local}},[Plan.Node{leftId,D.requirement_keys(~S,~CL,~RL,~OpsL,Build.compile(~S,~CL,~RL,~OpsL,~dl))},Plan.Node{id,D.requirement_keys(~S,~CR,~RR,~OpsR,Build.compile(~S,~CR,~RR,~OpsR,~dr))}]}
def registry(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~Error:Data,~Out:Data,~OpsL:Type -> Type,~OpsR:Type -> Type,~dl:Build.Program(~S,~CL,~RL,~OpsL),~dr:Build.Program(~S,~CR,~RR,~OpsR),~bl:@-H:Type -> @-caps:OpsL(H) -> H -> LL -> H & (LL & Sys.Completion<Error,Out>),~br:@-H:Type -> @-caps:OpsR(H) -> H -> LR -> H & (LR & Sys.Completion<Error,Out>),owners:Product.Owner<Sys.Owner<S,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,CR,RR,E,OpsR,LR,Error,Out,dr,br>>) -> Reg.Registry<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Product.Owner<Sys.Owner<S,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,CR,RR,E,OpsR,LR,Error,Out,dr,br>>,Error,Out,dispatch(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~Error,~Out,~OpsL,~OpsR,~dl,~dr,~bl,~br)>:
  match owners:
    case Product.Owner{Sys.Owner{namespace,+id,name,access,cursor,local},right}:right_registered(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~Error,~Out,~OpsL,~OpsR,~dl,~dr,~bl,~br,Sys.Owner{namespace,id,name,access,cursor,local},id,right)

def condition_registry(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~Error:Data,~OpsL:Type -> Type,~OpsR:Type -> Type,~dl:Build.Program(~S,~CL,~RL,~OpsL),~dr:Build.Program(~S,~CR,~RR,~OpsR),~bl:@-H:Type -> @-caps:OpsL(H) -> H -> LL -> H & (LL & Sys.Completion<Error,Bool>),~br:@-H:Type -> @-caps:OpsR(H) -> H -> LR -> H & (LR & Sys.Completion<Error,Bool>),owners:Product.Owner<Sys.Owner<S,CL,RL,E,OpsL,LL,Error,Bool,dl,bl>,Sys.Owner<S,CR,RR,E,OpsR,LR,Error,Bool,dr,br>>) -> Reg.ConditionRegistry<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Product.Owner<Sys.Owner<S,CL,RL,E,OpsL,LL,Error,Bool,dl,bl>,Sys.Owner<S,CR,RR,E,OpsR,LR,Error,Bool,dr,br>>,Error,dispatch(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~Error,~Bool,~OpsL,~OpsR,~dl,~dr,~bl,~br)>:
  match owners:
    case Product.Owner{Sys.Owner{ln,+lid,lname,la,lc,ll},Sys.Owner{rn,+rid,rname,ra,rc,lr}}:Reg.ConditionRegistry{registry(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~Error,~Bool,~OpsL,~OpsR,~dl,~dr,~bl,~br,Product.Owner{Sys.Owner{ln,lid,lname,la,lc,ll},Sys.Owner{rn,rid,rname,ra,rc,lr}}),Plan.first_error(~String,Reg.condition_permission(D.read_only(D.requirements(~S,~CL,~RL,~OpsL,Build.compile(~S,~CL,~RL,~OpsL,~dl))),lid),Reg.condition_permission(D.read_only(D.requirements(~S,~CR,~RR,~OpsR,Build.compile(~S,~CR,~RR,~OpsR,~dr))),rid))}
