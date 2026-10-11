import Base
import ../../fixture.bend as F
import ../../observer.bend as Dump
import ../../resource-provision.bend as Provision
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-inspector-resource.bend as Resource
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Rows
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C

type Values is Data:
  Values{first:U32,second:U32}

def Frame(~S:Data) -> Type:I.Frame<S,Col.Column<S,F.Payload>,F.Resources(),U32>
def First(~S:Data,~H:Type) -> Type:Resource.Read<S,Array<U32>,Provision.first_identity(~S),H,U32>
def Second(~S:Data,~H:Type) -> Type:Resource.Read<S,Array<U32>,Provision.second_identity(~S),H,U32>
def first(~S:Data) -> Resource.Declaration<S,Frame(~S),First(~S,~Frame(~S))>:
  Resource.bind(~S,~Col.Column<S,F.Payload>,~F.Resources(),~U32,~Array<U32>,~Unit & Array<U32>,~U32,~Provision.first_lens(),~Provision.first_identity(~S),~F.binding(~S),~Provision.view)
def second(~S:Data) -> Resource.Declaration<S,Frame(~S),Second(~S,~Frame(~S))>:
  Resource.bind(~S,~Col.Column<S,F.Payload>,~F.Resources(),~U32,~Array<U32>,~Unit & Array<U32>,~U32,~Provision.second_lens(),~Provision.second_identity(~S),~Provision.second_binding(~S),~Provision.view)
def joined(~H:Type,+left:U32,result:H & U32) -> H & Values:
  match result:
    case (owner,right):(owner,Values{left,right})
def after_first(~S:Data,~H:Type,~second:Second(~S,~H),result:H & U32) -> H & Values:
  match result:
    case (owner,left):joined(~H,left,Resource.get(~S,~Array<U32>,~Provision.second_identity(~S),~H,~U32,~second,owner))
def body(~S:Data,~H:Type,~first:First(~S,~H),~second:Second(~S,~H),owner:H) -> H & Values:
  after_first(~S,~H,~second,Resource.get(~S,~Array<U32>,~Provision.first_identity(~S),~H,~U32,~first,owner))
type State<-S:Data> is Type:
  State{delivery:F.Delivery<S>,result:Maybe<&2,Values>}
def returned(~S:Data,factory:W.Factory,rows:List<&2,Rows.Row<S,U32>>,clauses:List<&2,Q.Clause<S>>,access:C.Access<U32>,previous:Maybe<&1,F.Payload>,undo:List<(W.World<S,Col.Column<S,F.Payload>,F.Resources(),U32> -> W.World<S,Col.Column<S,F.Payload>,F.Resources(),U32>)>,commands:List<(W.World<S,Col.Column<S,F.Payload>,F.Resources(),U32> -> W.World<S,Col.Column<S,F.Payload>,F.Resources(),U32>)>,events:List<&2,U32>,result:Frame(~S) & Values) -> State<S>:
  match result:
    case (owner,value):State{F.Delivered{factory,owner,rows,clauses,access,previous,undo,commands,events},Some{value}}
def read(~S:Data,state:State<S>) -> State<S>:
  match state:
    case State{F.Delivered{factory,owner,rows,clauses,access,previous,undo,commands,events},_}:returned(~S,factory,rows,clauses,access,previous,undo,commands,events,body(~S,~Frame(~S),~Resource.grant(~S,~Frame(~S),~First(~S,~Frame(~S)),first(~S)),~Resource.grant(~S,~Frame(~S),~Second(~S,~Frame(~S)),second(~S)),owner))
    case State{delivery,result}:State{delivery,result}
def result_text(value:Maybe<&2,Values>) -> String:
  match value:
    case None{}:"None{}"
    case Some{Values{left,right}}:"Some{" ++ U32.show(left) ++ "," ++ U32.show(right) ++ "}"
def observed(~S:Data,+result:Maybe<&2,Values>,delivery:F.Delivery<S> & String) -> State<S> & String:
  match delivery:
    case (delivery,text):(State{delivery,result},text ++ "|resourceRead=" ++ result_text(result) ++ "|firstClauses=" ++ List.show(~&2,~Q.Clause<S>,~Dump.clause(~S),Resource.clauses(~S,~Frame(~S),~First(~S,~Frame(~S)),first(~S))) ++ "|secondClauses=" ++ List.show(~&2,~Q.Clause<S>,~Dump.clause(~S),Resource.clauses(~S,~Frame(~S),~Second(~S,~Frame(~S)),second(~S))))
def observe(~S:Data,state:State<S>) -> State<S> & String:
  match state:
    case State{delivery,result}:observed(~S,result,Dump.delivery(~S,delivery))
def fourth(~S:Data,prefix:String,result:State<S> & String) -> State<S> & String:
  match result:
    case (state,text):(state,prefix ++ "\nafter2=" ++ text)
def third(~S:Data,prefix:String,result:State<S> & String) -> State<S> & String:
  match result:
    case (state,text):fourth(~S,prefix ++ "\nafter1=" ++ text,observe(~S,read(~S,state)))
def second_observation(~S:Data,prefix:String,result:State<S> & String) -> State<S> & String:
  match result:
    case (state,text):third(~S,prefix ++ "\nbefore2=" ++ text,observe(~S,read(~S,state)))
def first_observation(~S:Data,result:State<S> & String) -> State<S> & String:
  match result:
    case (state,text):second_observation(~S,"before1=" ++ text,observe(~S,state))
def scenario(~S:Data) -> State<S> & String:first_observation(~S,observe(~S,State{F.run(~S),None{}}))
def detached(a:State<F.A> & String,b:State<F.Other> & String) -> String:
  match a b:
    case (_,a),(_,b):"A\n" ++ a ++ "\nOther\n" ++ b
def main() -> String:detached(scenario(~F.A),scenario(~F.Other))
