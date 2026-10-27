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
import ./dependency-executor.bend as Exec
import ./owner-product.bend as Product
import ./string-equality.bend as SE
import ./execution-composer-layout.bend as Layout
import ./execution-query-recipe.bend as Recipe
import ./execution-query-schema.bend as Schema

type Coordinates is Data:
  EmptyCoordinates{}
  LeafCoordinates{key:String}
  PairCoordinates{left:Coordinates,right:Coordinates}
type Use is Data:
  Use{key:String,mode:D.Mode}
  SelectedQuery{key:String,mode:D.Mode,route:Layout.Route,bound:Recipe.Bound,coordinates:Coordinates}
def uses(access:List<&2,D.Access>) -> List<&2,Use>:
  match access:
    case []:[]
    case D.Access{key,kind,mode,_} <> rest:Use{D.requirement_key(kind,key),mode} <> uses(rest)
def coordinates(layout:Layout.Layout) -> Coordinates:
  match layout:
    case Layout.EmptyLayout{}:EmptyCoordinates{}
    case Layout.LayoutLeaf{_,_,_,key,_}:LeafCoordinates{key}
    case Layout.ClassifiedLayoutLeaf{_,_,_,key,_,_}:LeafCoordinates{key}
    case Layout.LayoutPair{left,right}:PairCoordinates{coordinates(left),coordinates(right)}
def same_coordinates(left:Coordinates,right:Coordinates) -> Bool:
  match left right:
    case EmptyCoordinates{} EmptyCoordinates{}:True{}
    case LeafCoordinates{left} LeafCoordinates{right}:SE.equal(left,right)
    case PairCoordinates{ll,lr} PairCoordinates{rl,rr}:Bool.and(same_coordinates(ll,rl),same_coordinates(lr,rr))
    case _ _:False{}
def opposite(+route:Layout.Route,+present:Bool,right:Recipe.Bound) -> Bool:
  match right:
    case Recipe.With{other}:Bool.and(Bool.not(present),Schema.same_route(route,other))
    case Recipe.Without{other}:Bool.and(present,Schema.same_route(route,other))
    case Recipe.And{left,right}:Bool.or(opposite(route,present,left),opposite(route,present,right))
    case Recipe.Or{left,right}:Bool.and(opposite(route,present,left),opposite(route,present,right))
    case _:False{}
def separates(left:Recipe.Bound,+right:Recipe.Bound) -> Bool:
  match left:
    case Recipe.With{route}:opposite(route,True{},right)
    case Recipe.Without{route}:opposite(route,False{},right)
    case Recipe.And{a,b}:Bool.or(separates(a,right),separates(b,right))
    case Recipe.Or{a,b}:Bool.and(separates(a,right),separates(b,right))
    case _:False{}
def separated(+left:Recipe.Bound,+right:Recipe.Bound) -> Bool:
  Bool.or(separates(left,right),separates(right,left))
def same_access(left:D.Access,right:D.Access) -> Bool:
  match left right:
    case D.Access{lk,D.ComponentAccess{},D.SharedView{},D.ReadOnly{}} D.Access{rk,D.ComponentAccess{},D.SharedView{},D.ReadOnly{}}:SE.equal(lk,rk)
    case D.Access{lk,D.ComponentAccess{},D.Exclusive{},D.Writable{}} D.Access{rk,D.ComponentAccess{},D.Exclusive{},D.Writable{}}:SE.equal(lk,rk)
    case _ _:False{}
def restore_access(first:D.Access,result:Maybe<&2,List<&2,D.Access>>) -> Maybe<&2,List<&2,D.Access>>:
  match result:
    case None{}:None{}
    case Some{rest}:Some{first <> rest}
def removed_access(found:Bool,rest:List<&2,D.Access>,otherwise:Maybe<&2,List<&2,D.Access>>) -> Maybe<&2,List<&2,D.Access>>:
  match found:
    case True{}:Some{rest}
    case False{}:otherwise
def remove_access(+expected:D.Access,access:List<&2,D.Access>) -> Maybe<&2,List<&2,D.Access>>:
  match access:
    case []:None{}
    case +first <> +rest:removed_access(same_access(expected,first),rest,restore_access(first,remove_access(expected,rest)))
def validated_access(valid:Bool,expected:D.Access,access:Maybe<&2,List<&2,D.Access>>) -> Maybe<&2,List<&2,D.Access>>:
  match valid access:
    case True{} Some{access}:remove_access(expected,access)
    case _ _:None{}
def residual_uses(access:Maybe<&2,List<&2,D.Access>>) -> Maybe<&2,List<&2,Use>>:
  match access:
    case None{}:None{}
    case Some{access}:Some{uses(access)}
def selected_use(access:D.Access,route:Layout.Route,bound:Recipe.Bound,shape:Coordinates) -> Use:
  match access:
    case D.Access{key,kind,mode,_}:SelectedQuery{D.requirement_key(kind,key),mode,route,bound,shape}
def prepend_selected(first:Use,result:Maybe<&2,List<&2,Use>>) -> Maybe<&2,List<&2,Use>>:
  match result:
    case None{}:None{}
    case Some{rest}:Some{first <> rest}
def project_queries(~full:Layout.Layout,queries:List<&2,Recipe.Entry>,+shape:Coordinates,access:Maybe<&2,List<&2,D.Access>>) -> Maybe<&2,List<&2,Use>>:
  match queries:
    case []:residual_uses(access)
    case Recipe.Entry{+route,+kind,+bound,_} <> rest:prepend_selected(selected_use(Build.general_access(Layout.key(full,route),kind),route,bound,shape),project_queries(~full,rest,shape,validated_access(Bool.and(Layout.valid(full,route),Recipe.bound_valid(~full,bound)),Build.general_access(Layout.key(full,route),kind),access)))
def selected_or_plain(original:List<&2,D.Access>,result:Maybe<&2,List<&2,Use>>) -> List<&2,Use>:
  match result:
    case None{}:uses(original)
    case Some{selected}:selected
def selected_valid(valid:Bool,original:List<&2,D.Access>,result:Maybe<&2,List<&2,Use>>) -> List<&2,Use>:
  match valid:
    case False{}:uses(original)
    case True{}:selected_or_plain(original,result)
def selected_uses(~full:Layout.Layout,+access:List<&2,D.Access>,queries:List<&2,Recipe.Entry>) -> List<&2,Use>:
  selected_valid(Layout.unique(full),access,project_queries(~full,queries,coordinates(full),Some{access}))
type Entry is Data:
  Entry{id:U32,uses:List<&2,Use>}
type Rules is Data:
  Rules{entries:List<&2,Entry>}
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
    case Use{lk,lm} SelectedQuery{rk,rm,_,_,_}:Bool.or(Bool.not(SE.equal(lk,rk)),modes(lm,rm))
    case SelectedQuery{lk,lm,_,_,_} Use{rk,rm}:Bool.or(Bool.not(SE.equal(lk,rk)),modes(lm,rm))
    case SelectedQuery{lk,lm,lr,lb,lc} SelectedQuery{rk,rm,rr,rb,rc}:Bool.or(Bool.or(Bool.not(SE.equal(lk,rk)),modes(lm,rm)),Bool.and(same_coordinates(lc,rc),Bool.and(Schema.same_route(lr,rr),separated(lb,rb))))
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
def meta_id(~Owner:Type,meta:Task.Meta<Owner>) -> U32:
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

def returned(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~Error:Data,~Out:Data,~OpsL:Data -> Type -> Type,~OpsR:Data -> Type -> Type,~dl:Build.FrameworkProgram(~S,~Product.Owner<CL,CR>,~CL,~RL,~OpsL),~dr:Build.FrameworkProgram(~S,~Product.Owner<CL,CR>,~CR,~RR,~OpsR),~bl:Sys.Body(~S,~OpsL,~LL,~Error,~Out),~br:Sys.Body(~S,~OpsR,~LR,~Error,~Out),+ids:List<&2,U32>,+leftId:U32,+rightId:U32,result:Run.PairResult<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,Error,Out,dr,br>,Error,Error,Out,Out>) -> Product.Owner<Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,Error,Out,dr,br>> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>):
  match result:
    case Run.Finished{world,left,right,lc,rc}:(Product.Owner{left,right},(world,completed(~Error,~Out,member(ids,leftId),leftId,lc,completed(~Error,~Out,member(ids,rightId),rightId,rc,[]))))
    case Run.AdmissionRefused{world,left,right,lc,rc}:(Product.Owner{left,right},(world,completed(~Error,~Out,member(ids,leftId),leftId,lc,completed(~Error,~Out,member(ids,rightId),rightId,rc,[]))))
def right_detached(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~Error:Data,~Out:Data,~OpsL:Data -> Type -> Type,~OpsR:Data -> Type -> Type,~dl:Build.FrameworkProgram(~S,~Product.Owner<CL,CR>,~CL,~RL,~OpsL),~dr:Build.FrameworkProgram(~S,~Product.Owner<CL,CR>,~CR,~RR,~OpsR),~bl:Sys.Body(~S,~OpsL,~LL,~Error,~Out),~br:Sys.Body(~S,~OpsR,~LR,~Error,~Out),mode:Parallel.Mode,world:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,+ids:List<&2,U32>,+lm:Task.Meta<Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,Error,Out,dl,bl>>,ll:LL,result:Task.Meta<Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,Error,Out,dr,br>> & LR) -> IO(Product.Owner<Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,Error,Out,dr,br>> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>)):
  match result:
    case (+rm,lr):IO.bind(Run.PairResult<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,Error,Out,dr,br>,Error,Error,Out,Out>,Product.Owner<Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,Error,Out,dr,br>> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>),AppPair.kernel_when(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~Error,~Error,~Out,~Out,~OpsL,~OpsR,~dl,~dr,~bl,~br,mode,member(ids,meta_id(~Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,lm)),member(ids,meta_id(~Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,Error,Out,dr,br>,rm)),AppPair.ParallelApp{world,Task.restored(~S,~Product.Owner<CL,CR>,~CL,~RL,~E,~OpsL,~LL,~Error,~Out,~dl,~bl,lm,ll),Task.restored(~S,~Product.Owner<CL,CR>,~CR,~RR,~E,~OpsR,~LR,~Error,~Out,~dr,~br,rm,lr)}),result => IO.pure(Product.Owner<Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,Error,Out,dr,br>> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>),returned(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~Error,~Out,~OpsL,~OpsR,~dl,~dr,~bl,~br,ids,meta_id(~Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,lm),meta_id(~Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,Error,Out,dr,br>,rm),result)))
def left_detached(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~Error:Data,~Out:Data,~OpsL:Data -> Type -> Type,~OpsR:Data -> Type -> Type,~dl:Build.FrameworkProgram(~S,~Product.Owner<CL,CR>,~CL,~RL,~OpsL),~dr:Build.FrameworkProgram(~S,~Product.Owner<CL,CR>,~CR,~RR,~OpsR),~bl:Sys.Body(~S,~OpsL,~LL,~Error,~Out),~br:Sys.Body(~S,~OpsR,~LR,~Error,~Out),mode:Parallel.Mode,world:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,ids:List<&2,U32>,right:Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,Error,Out,dr,br>,result:Task.Meta<Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,Error,Out,dl,bl>> & LL) -> IO(Product.Owner<Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,Error,Out,dr,br>> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>)):
  match result:
    case (lm,ll):right_detached(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~Error,~Out,~OpsL,~OpsR,~dl,~dr,~bl,~br,mode,world,ids,lm,ll,Task.detached(~S,~Product.Owner<CL,CR>,~CR,~RR,~E,~OpsR,~LR,~Error,~Out,~dr,~br,right))
def group(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~Error:Data,~Out:Data,~OpsL:Data -> Type -> Type,~OpsR:Data -> Type -> Type,~dl:Build.FrameworkProgram(~S,~Product.Owner<CL,CR>,~CL,~RL,~OpsL),~dr:Build.FrameworkProgram(~S,~Product.Owner<CL,CR>,~CR,~RR,~OpsR),~bl:Sys.Body(~S,~OpsL,~LL,~Error,~Out),~br:Sys.Body(~S,~OpsR,~LR,~Error,~Out),mode:Parallel.Mode,owners:Product.Owner<Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,Error,Out,dr,br>>,world:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,ids:List<&2,U32>) -> IO(Product.Owner<Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,Error,Out,dr,br>> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>)):
  match owners:
    case Product.Owner{left,right}:left_detached(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~Error,~Out,~OpsL,~OpsR,~dl,~dr,~bl,~br,mode,world,ids,right,Task.detached(~S,~Product.Owner<CL,CR>,~CL,~RL,~E,~OpsL,~LL,~Error,~Out,~dl,~bl,left))
def group_native(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~Error:Data,~Out:Data,~OpsL:Data -> Type -> Type,~OpsR:Data -> Type -> Type,~dl:Build.FrameworkProgram(~S,~Product.Owner<CL,CR>,~CL,~RL,~OpsL),~dr:Build.FrameworkProgram(~S,~Product.Owner<CL,CR>,~CR,~RR,~OpsR),~bl:Sys.Body(~S,~OpsL,~LL,~Error,~Out),~br:Sys.Body(~S,~OpsR,~LR,~Error,~Out),owners:Product.Owner<Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,Error,Out,dr,br>>,world:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,ids:List<&2,U32>) -> IO(Product.Owner<Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,Error,Out,dr,br>> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>)):
  group(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~Error,~Out,~OpsL,~OpsR,~dl,~dr,~bl,~br,Parallel.Native{},owners,world,ids)
def single_status(~Error:Data,~Out:Data,completions:List<&2,Ready.Completed<Error,Out>>) -> Exec.Invocation<Error,Out>:
  match completions:
    case []:Exec.AdmissionRefused{}
    case Ready.Completed{_,value} <> _:value
def single_returned(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~Error:Data,~Out:Data,~OpsL:Data -> Type -> Type,~OpsR:Data -> Type -> Type,~dl:Build.FrameworkProgram(~S,~Product.Owner<CL,CR>,~CL,~RL,~OpsL),~dr:Build.FrameworkProgram(~S,~Product.Owner<CL,CR>,~CR,~RR,~OpsR),~bl:Sys.Body(~S,~OpsL,~LL,~Error,~Out),~br:Sys.Body(~S,~OpsR,~LR,~Error,~Out),result:Product.Owner<Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,Error,Out,dr,br>> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>)) -> Product.Owner<Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,Error,Out,dr,br>> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & Exec.Invocation<Error,Out>):
  match result:
    case (owners,(world,statuses)):(owners,(world,single_status(~Error,~Out,statuses)))
def dispatch(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~Error:Data,~Out:Data,~OpsL:Data -> Type -> Type,~OpsR:Data -> Type -> Type,~dl:Build.FrameworkProgram(~S,~Product.Owner<CL,CR>,~CL,~RL,~OpsL),~dr:Build.FrameworkProgram(~S,~Product.Owner<CL,CR>,~CR,~RR,~OpsR),~bl:Sys.Body(~S,~OpsL,~LL,~Error,~Out),~br:Sys.Body(~S,~OpsR,~LR,~Error,~Out),owners:Product.Owner<Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,Error,Out,dr,br>>,world:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,id:U32) -> IO(Product.Owner<Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,Error,Out,dr,br>> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & Exec.Invocation<Error,Out>)):
  IO.bind(Product.Owner<Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,Error,Out,dr,br>> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & List<&2,Ready.Completed<Error,Out>>),Product.Owner<Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,Error,Out,dr,br>> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & Exec.Invocation<Error,Out>),group(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~Error,~Out,~OpsL,~OpsR,~dl,~dr,~bl,~br,Parallel.Serial{},owners,world,[id]),result => IO.pure(Product.Owner<Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,Error,Out,dr,br>> & (W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & Exec.Invocation<Error,Out>),single_returned(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~Error,~Out,~OpsL,~OpsR,~dl,~dr,~bl,~br,result)))
