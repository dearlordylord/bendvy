import Base
import ./world.bend as W
import ./execution-system.bend as Sys
import ./execution-declaration.bend as D
import ./dependency-plan.bend as Plan
import ./dependency-executor.bend as Exec

type Registry<-World:Type,-Owners:Type,-Error:Data,-Out:Data,-dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Error,Out>)> is Type:
  Registry{owners:Owners,nodes:List<&2,Plan.Node<String>>}

def leaf_returned(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:D.Declaration<S,C,R,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),result:Sys.RunResult<W.World<S,C,R,E>,Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>) -> Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body> & (W.World<S,C,R,E> & Exec.Invocation<Error,Out>):
  match result:
    case Sys.Refused{world,system}:(system,(world,Exec.AdmissionRefused{}))
    case Sys.Executed{world,system,Sys.Success{output}}:(system,(world,Exec.Completed{output}))
    case Sys.Executed{world,system,Sys.BodyError{error,output}}:(system,(world,Exec.BodyError{error,output}))
def leaf_selected(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:D.Declaration<S,C,R,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),selected:Bool,owner:Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,world:W.World<S,C,R,E>) -> Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body> & (W.World<S,C,R,E> & Exec.Invocation<Error,Out>):
  match selected:
    case False{}:(owner,(world,Exec.AdmissionRefused{}))
    case True{}:leaf_returned(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,Sys.run(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,owner,world))
def leaf_dispatch_actual(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:D.Declaration<S,C,R,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),owner:Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,world:W.World<S,C,R,E>,+id:U32) -> Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body> & (W.World<S,C,R,E> & Exec.Invocation<Error,Out>):
  match owner:
    case Sys.Owner{namespace,+actual,name,access,cursor,local}:leaf_selected(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,U32.is_eq(actual,id),Sys.Owner{namespace,actual,name,access,cursor,local},world)
def leaf_dispatch(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:D.Declaration<S,C,R,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),owner:Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,world:W.World<S,C,R,E>,id:U32) -> Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body> & (W.World<S,C,R,E> & Exec.Invocation<Error,Out>):
  leaf_dispatch_actual(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,owner,world,id)
# Registration identity and requirements come from the actual declared System.
# Detached nodes are scheduling facts and cannot construct gameplay authority.
def leaf(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:D.Declaration<S,C,R,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),owner:Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>) -> Registry<W.World<S,C,R,E>,Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out,leaf_dispatch(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body)>:
  match owner:
    case Sys.Owner{namespace,+id,name,+access,cursor,local}:Registry{Sys.Owner{namespace,id,name,access,cursor,local},[Plan.Node{id,access}]}

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
