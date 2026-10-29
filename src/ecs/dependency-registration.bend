import Base
import ./dependency-plan.bend as Plan
import ./dependency-executor.bend as Exec

type Registry<-World:Type,-Owners:Type,-Error:Data,-Out:Data,-dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Error,Out>)> is Type:
  Registry{owners:Owners,nodes:List<&2,Plan.Node<String>>}

type Product<L:Type,R:Type> is Type:
  Product{left:L,right:R,leftIds:List<&2,U32>}
def ids(nodes:List<&2,Plan.Node<String>>) -> List<&2,U32>:
  match nodes:
    case []:[]
    case Plan.Node{id,_} <> rest:id <> ids(rest)
def contains(ids:List<&2,U32>,+id:U32) -> Bool:
  match ids:
    case []:False{}
    case first <> rest:Bool.or(U32.is_eq(first,id),contains(rest,id))

def left_returned(~World:Type,~L:Type,~R:Type,~Error:Data,~Out:Data,~leftDispatch:L -> World -> U32 -> L & (World & Exec.Invocation<Error,Out>),~rightDispatch:R -> World -> U32 -> R & (World & Exec.Invocation<Error,Out>),returned:L & (World & Exec.Invocation<Error,Out>),right:R,leftIds:List<&2,U32>) -> Product<L,R> & (World & Exec.Invocation<Error,Out>):
  match returned:
    case (left,(world,status)):(Product{left,right,leftIds},(world,status))
def right_returned(~World:Type,~L:Type,~R:Type,~Error:Data,~Out:Data,~leftDispatch:L -> World -> U32 -> L & (World & Exec.Invocation<Error,Out>),~rightDispatch:R -> World -> U32 -> R & (World & Exec.Invocation<Error,Out>),returned:R & (World & Exec.Invocation<Error,Out>),left:L,leftIds:List<&2,U32>) -> Product<L,R> & (World & Exec.Invocation<Error,Out>):
  match returned:
    case (right,(world,status)):(Product{left,right,leftIds},(world,status))
def paired_selected(~World:Type,~L:Type,~R:Type,~Error:Data,~Out:Data,~leftDispatch:L -> World -> U32 -> L & (World & Exec.Invocation<Error,Out>),~rightDispatch:R -> World -> U32 -> R & (World & Exec.Invocation<Error,Out>),selected:Bool,left:L,right:R,leftIds:List<&2,U32>,world:World,id:U32) -> Product<L,R> & (World & Exec.Invocation<Error,Out>):
  match selected:
    case True{}:left_returned(~World,~L,~R,~Error,~Out,~leftDispatch,~rightDispatch,leftDispatch(left,world,id),right,leftIds)
    case False{}:right_returned(~World,~L,~R,~Error,~Out,~leftDispatch,~rightDispatch,rightDispatch(right,world,id),left,leftIds)
def paired_dispatch_actual(~World:Type,~L:Type,~R:Type,~Error:Data,~Out:Data,~leftDispatch:L -> World -> U32 -> L & (World & Exec.Invocation<Error,Out>),~rightDispatch:R -> World -> U32 -> R & (World & Exec.Invocation<Error,Out>),owners:Product<L,R>,world:World,+id:U32) -> Product<L,R> & (World & Exec.Invocation<Error,Out>):
  match owners:
    case Product{left,right,+leftIds}:paired_selected(~World,~L,~R,~Error,~Out,~leftDispatch,~rightDispatch,contains(leftIds,id),left,right,leftIds,world,id)
def paired_dispatch(~World:Type,~L:Type,~R:Type,~Error:Data,~Out:Data,~leftDispatch:L -> World -> U32 -> L & (World & Exec.Invocation<Error,Out>),~rightDispatch:R -> World -> U32 -> R & (World & Exec.Invocation<Error,Out>),owners:Product<L,R>,world:World,id:U32) -> Product<L,R> & (World & Exec.Invocation<Error,Out>):
  paired_dispatch_actual(~World,~L,~R,~Error,~Out,~leftDispatch,~rightDispatch,owners,world,id)
def paired(~World:Type,~L:Type,~R:Type,~Error:Data,~Out:Data,~leftDispatch:L -> World -> U32 -> L & (World & Exec.Invocation<Error,Out>),~rightDispatch:R -> World -> U32 -> R & (World & Exec.Invocation<Error,Out>),left:Registry<World,L,Error,Out,leftDispatch>,right:Registry<World,R,Error,Out,rightDispatch>) -> Registry<World,Product<L,R>,Error,Out,paired_dispatch(~World,~L,~R,~Error,~Out,~leftDispatch,~rightDispatch)>:
  match left right:
    case Registry{left,+ln} Registry{right,rn}:Registry{Product{left,right,ids(ln)},List.append(&2,Plan.Node<String>,ln,rn)}

def empty_dispatch(~World:Type,~Error:Data,~Out:Data,owners:Unit,world:World,_:U32) -> Unit & (World & Exec.Invocation<Error,Out>):
  (owners,(world,Exec.AdmissionRefused{}))
def empty(~World:Type,~Error:Data,~Out:Data) -> Registry<World,Unit,Error,Out,empty_dispatch(~World,~Error,~Out)>:
  Registry{Unit{},[]}

type ConditionRegistry<-World:Type,-Owners:Type,-Error:Data,-dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Error,Bool>)> is Type:
  ConditionRegistry{registry:Registry<World,Owners,Error,Bool,dispatch>,invalid:Maybe<&2,Plan.Invalid<String>>}
def condition_permission(allowed:Bool,id:U32) -> Maybe<&2,Plan.Invalid<String>>:
  match allowed:
    case True{}:None{}
    case False{}:Some{Plan.InvalidCondition{id}}
def empty_conditions(~World:Type,~Error:Data) -> ConditionRegistry<World,Unit,Error,empty_dispatch(~World,~Error,~Bool)>:
  ConditionRegistry{empty(~World,~Error,~Bool),None{}}
def paired_conditions(~World:Type,~L:Type,~R:Type,~Error:Data,~leftDispatch:L -> World -> U32 -> L & (World & Exec.Invocation<Error,Bool>),~rightDispatch:R -> World -> U32 -> R & (World & Exec.Invocation<Error,Bool>),left:ConditionRegistry<World,L,Error,leftDispatch>,right:ConditionRegistry<World,R,Error,rightDispatch>) -> ConditionRegistry<World,Product<L,R>,Error,paired_dispatch(~World,~L,~R,~Error,~Bool,~leftDispatch,~rightDispatch)>:
  match left right:
    case ConditionRegistry{left,li} ConditionRegistry{right,ri}:ConditionRegistry{paired(~World,~L,~R,~Error,~Bool,~leftDispatch,~rightDispatch,left,right),Plan.first_error(~String,li,ri)}
