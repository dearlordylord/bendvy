import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-binding.bend as Binding
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/removals.bend as Rm

type Publication<A:Data,B:Data> is Data:
  Left{value:A}
  Right{value:B}
type Selection<S:Data,P:Type,E:Data,-inject:Identity.Declaration<S,P> -> W.Handle<S> -> E,-select:E -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,P>>>> is Data:
  Selection{identity:Identity.Declaration<S,P>}
def leaf_inject(~S:Data,~P:Type,identity:Identity.Declaration<S,P>,handle:W.Handle<S>) -> Rm.Record<S,Identity.Declaration<S,P>>:
  Rm.Removed{handle,identity}
def leaf_select(~S:Data,~P:Type,value:Rm.Record<S,Identity.Declaration<S,P>>) -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,P>>>:
  Some{value}
def leaf(~S:Data,~Store:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,binding:Binding.Binding<S,Store,Rest,P,V,Token,take,put,view>) -> Selection<S,P,Rm.Record<S,Identity.Declaration<S,P>>,leaf_inject(~S,~P),leaf_select(~S,~P)>:
  Selection{Binding.identity(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,binding)}
def left_inject(~S:Data,~P:Type,~A:Data,~B:Data,~inject:Identity.Declaration<S,P> -> W.Handle<S> -> A,identity:Identity.Declaration<S,P>,handle:W.Handle<S>) -> Publication<A,B>:
  Left{inject(identity,handle)}
def right_inject(~S:Data,~P:Type,~A:Data,~B:Data,~inject:Identity.Declaration<S,P> -> W.Handle<S> -> B,identity:Identity.Declaration<S,P>,handle:W.Handle<S>) -> Publication<A,B>:
  Right{inject(identity,handle)}
def left_select(~S:Data,~P:Type,~A:Data,~B:Data,~select:A -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,P>>>,value:Publication<A,B>) -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,P>>>:
  match value:
    case Left{value}:select(value)
    case Right{_}:None{}
def right_select(~S:Data,~P:Type,~A:Data,~B:Data,~select:B -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,P>>>,value:Publication<A,B>) -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,P>>>:
  match value:
    case Left{_}:None{}
    case Right{value}:select(value)
def left(~S:Data,~P:Type,~A:Data,~B:Data,~inject:Identity.Declaration<S,P> -> W.Handle<S> -> A,~select:A -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,P>>>,value:Selection<S,P,A,inject,select>) -> Selection<S,P,Publication<A,B>,left_inject(~S,~P,~A,~B,~inject),left_select(~S,~P,~A,~B,~select)>:
  match value:
    case Selection{identity}:Selection{identity}
def right(~S:Data,~P:Type,~A:Data,~B:Data,~inject:Identity.Declaration<S,P> -> W.Handle<S> -> B,~select:B -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,P>>>,value:Selection<S,P,B,inject,select>) -> Selection<S,P,Publication<A,B>,right_inject(~S,~P,~A,~B,~inject),right_select(~S,~P,~A,~B,~select)>:
  match value:
    case Selection{identity}:Selection{identity}
