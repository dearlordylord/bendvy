import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-system.bend as System
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-observable.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as N
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as IQ

type Product<L:Data,R:Data> is Data:
  Product{left:L,right:R}
type Binding<S:Data> is Data:
  Binding{namespace:U32,id:U32,name:String,access:List<&2,String>,slot:String,clauses:List<&2,N.Clause<S>>}
type ApplicationType<-S:Data,-C:Type,-R:Type,-E:Data,-H:Type,-Rows:Data,-fold:W.World<S,C,R,E> -> W.World<S,C,R,E> & Rows> is Type:
  Application{world:W.World<S,C,R,E>,owners:H,bindings:List<&2,Binding<S>>,debug:Bool}

def empty_fold(~S:Data,~C:Type,~R:Type,~E:Data,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & Unit:
  (world,Unit{})
def empty(~S:Data,~C:Type,~R:Type,~E:Data,world:W.World<S,C,R,E>) -> ApplicationType<S,C,R,E,Unit,Unit,empty_fold(~S,~C,~R,~E)>:
  Application{world,Unit{},[],False{}}
def enable_debug(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~fold:W.World<S,C,R,E> -> W.World<S,C,R,E> & Rows,app:ApplicationType<S,C,R,E,H,Rows,fold>,enabled:Bool) -> ApplicationType<S,C,R,E,H,Rows,fold>:
  match app:
    case Application{world,owners,bindings,_}:Application{world,owners,bindings,enabled}
def lowered(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,result:I.Frame<S,C,R,E> & List<&2,IQ.ProjectedRow<S,V>>) -> W.World<S,C,R,E> & List<&2,IQ.ProjectedRow<S,V>>:
  match result:
    case (I.Frame{world,_},rows):(world,rows)
def appended(~S:Data,~C:Type,~R:Type,~E:Data,~Rows:Data,~V:Data,previous:Rows,result:W.World<S,C,R,E> & List<&2,IQ.ProjectedRow<S,V>>) -> W.World<S,C,R,E> & (Product<Rows,List<&2,IQ.ProjectedRow<S,V>>>):
  match result:
    case (world,rows):(world,Product{previous,rows})
def append_previous(~S:Data,~C:Type,~R:Type,~E:Data,~Rows:Data,~Ops:Type -> Type,~V:Data,~query:O.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,V>,result:W.World<S,C,R,E> & Rows) -> W.World<S,C,R,E> & (Product<Rows,List<&2,IQ.ProjectedRow<S,V>>>):
  match result:
    case (world,previous):appended(~S,~C,~R,~E,~Rows,~V,previous,lowered(~S,~C,~R,~E,~V,IQ.each_composed(~I.Frame<S,C,R,E>,~S,~V,~O.inspect_query(~S,~C,~R,~E,~Q.Frame<S,C,R,E>,~Ops(Q.Frame<S,C,R,E>),~V,~query),I.Frame{world,0})))
def append_fold(~S:Data,~C:Type,~R:Type,~E:Data,~Rows:Data,~fold:W.World<S,C,R,E> -> W.World<S,C,R,E> & Rows,~Ops:Type -> Type,~V:Data,~query:O.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,V>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & (Product<Rows,List<&2,IQ.ProjectedRow<S,V>>>):
  append_previous(~S,~C,~R,~E,~Rows,~Ops,~V,~query,fold(world))
def snapshot_rows(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~fold:W.World<S,C,R,E> -> W.World<S,C,R,E> & Rows,owners:H,+bindings:List<&2,Binding<S>>,result:W.World<S,C,R,E> & Rows) -> ApplicationType<S,C,R,E,H,Rows,fold> & Maybe<&2,Product<List<&2,Binding<S>>,Rows>>:
  match result:
    case (world,rows):(Application{world,owners,bindings,True{}},Some{Product{bindings,rows}})
def snapshot(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~fold:W.World<S,C,R,E> -> W.World<S,C,R,E> & Rows,app:ApplicationType<S,C,R,E,H,Rows,fold>) -> ApplicationType<S,C,R,E,H,Rows,fold> & Maybe<&2,Product<List<&2,Binding<S>>,Rows>>:
  match app:
    case Application{world,owners,bindings,True{}}:snapshot_rows(~S,~C,~R,~E,~H,~Rows,~fold,owners,bindings,fold(world))
    case Application{world,owners,bindings,False{}}:(Application{world,owners,bindings,False{}},None{})
# Registration failure returns the existing App; no inspection refusal policy.
type Registration<-Before:Type,-After:Type> is Type:
  Registered{app:After}
  Failed{app:Before}
def retained(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~V:Data,~query:O.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,V>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),~H:Type,~Rows:Data,~fold:W.World<S,C,R,E> -> W.World<S,C,R,E> & Rows,owners:H,+bindings:List<&2,Binding<S>>,debug:Bool,result:System.Defined<S,W.World<S,C,R,E>,Sys.Registry<S,C,R,E,A & U32,Q.Error<U>,List<&2,Out>,System.observable_runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body)>>) -> Registration<ApplicationType<S,C,R,E,H,Rows,fold>,ApplicationType<S,C,R,E,H & System.Owner<S,Sys.Registry<S,C,R,E,A & U32,Q.Error<U>,List<&2,Out>,System.observable_runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body)>>,Product<Rows,List<&2,IQ.ProjectedRow<S,V>>>,append_fold(~S,~C,~R,~E,~Rows,~fold,~Ops,~V,~query)>>:
  match result:
    case System.Rejected{world}:Failed{Application{world,owners,bindings,debug}}
    case System.Defined{world,System.Owner{Sys.Registry{+namespace,+id,+name,+access,cursor},+slot,+clauses}}:
      registry=Sys.Registry{namespace,id,name,access,cursor}
      owner=System.Owner{registry,slot,clauses}
      Registered{Application{world,(owners,owner),List.append(&2,Binding<S>,bindings,[Binding{namespace,id,name,access,slot,clauses}]),debug}}
def register(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~V:Data,~query:O.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,V>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),~H:Type,~Rows:Data,~fold:W.World<S,C,R,E> -> W.World<S,C,R,E> & Rows,app:ApplicationType<S,C,R,E,H,Rows,fold>,name:String,slot:String) -> Registration<ApplicationType<S,C,R,E,H,Rows,fold>,ApplicationType<S,C,R,E,H & System.Owner<S,Sys.Registry<S,C,R,E,A & U32,Q.Error<U>,List<&2,Out>,System.observable_runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body)>>,Product<Rows,List<&2,IQ.ProjectedRow<S,V>>>,append_fold(~S,~C,~R,~E,~Rows,~fold,~Ops,~V,~query)>>:
  match app:
    case Application{world,owners,bindings,debug}:retained(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body,~H,~Rows,~fold,owners,bindings,debug,System.observable_define(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body,world,name,slot))
