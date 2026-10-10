import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-observable.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as N
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as IQ
type Observation<Rows:Data> is Data:
  Observation{rows:Rows,rendered:List<&2,String>}
type Product<L:Data,R:Data> is Data:
  Product{left:L,right:R}
# Private typed DTO; text presentation is a fixture view, not a wire contract.
type Binding<S:Data> is Data:
  Binding{namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:U32,slot:String,clauses:List<&2,N.Clause<S>>}
def lowered(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,result:I.Frame<S,C,R,E> & List<&2,IQ.ProjectedRow<S,V>>) -> W.World<S,C,R,E> & List<&2,IQ.ProjectedRow<S,V>>:
  match result:
    case (I.Frame{world,_},rows):(world,rows)
def render_row(~S:Data,~V:Data,~render:V -> String,row:IQ.ProjectedRow<S,V>) -> String:
  match row:
    case IQ.ProjectedRow{W.Handle{namespace,id},data}:U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ render(data)
def appended(~S:Data,~C:Type,~R:Type,~E:Data,~Rows:Data,~V:Data,~render:V -> String,previous:Rows,summaries:List<&2,String>,result:W.World<S,C,R,E> & List<&2,IQ.ProjectedRow<S,V>>) -> W.World<S,C,R,E> & Observation<Product<Rows,List<&2,IQ.ProjectedRow<S,V>>>>:
  match result:
    case (world,+rows):(world,Observation{Product{previous,rows},List.append(&2,String,summaries,[List.show(&2,IQ.ProjectedRow<S,V>,render_row(~S,~V,~render),rows)])})
def append_previous(~S:Data,~C:Type,~R:Type,~E:Data,~Rows:Data,~Ops:Type -> Type,~V:Data,~query:O.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,V>,~render:V -> String,result:W.World<S,C,R,E> & Observation<Rows>) -> W.World<S,C,R,E> & Observation<Product<Rows,List<&2,IQ.ProjectedRow<S,V>>>>:
  match result:
    case (world,Observation{previous,summaries}):appended(~S,~C,~R,~E,~Rows,~V,~render,previous,summaries,lowered(~S,~C,~R,~E,~V,IQ.each_composed(~I.Frame<S,C,R,E>,~S,~V,~O.inspect_query(~S,~C,~R,~E,~Q.Frame<S,C,R,E>,~Ops(Q.Frame<S,C,R,E>),~V,~query),I.Frame{world,0})))
