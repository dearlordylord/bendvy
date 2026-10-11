import Base
import /workspace/formal-proofs/bendvy/experiments/public-inspect/ordinary-declaration-v1/caller.bend as Caller
import /workspace/formal-proofs/bendvy-worktrees/native54-matching-tree-v1/experiments/public-inspect/ordinary-declaration-v1/native54-matching-tree-v1/native-blocker-source-research-v1/current-public-consumer-v1/observer.bend as Dump
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as N

import /workspace/formal-proofs/bendvy/src/ecs/ordinary-inspector-declaration.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as Query

# Terminal test serialization retains the actual Instance and complete Delivery.
type State<-S:Data> is Type:
  State{delivery:Caller.Delivery<S>,instance:I.Instance<S>,output:Maybe<&2,Result<&2,&2,Query.LookupError,P.Row<S,U32>>>}
def declaration(~S:Data) -> D.Declaration<S,I.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,U32>:
  D.read(~S,~Col.Column<S,Caller.Payload>,~Unit,~Caller.Payload,~U32,~Caller.Token,~Caller.take(~S),~Caller.put(~S),~Caller.view,~Array<U32>,~U32,~Caller.binding(~S))
def ops(~S:Data) -> Type -> Type:
  H => Query.ReadQuery<H,S,U32>
def plan(~S:Data) -> I.Plan<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,ops(~S)>:
  I.Plan{D.query(~S,~I.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~U32,declaration(~S))}
def body(~S:Data,~H:Type,~caps:Query.ReadQuery<H,S,U32>,target:W.Handle<S>,owner:H) -> H & Result<&2,&2,Query.LookupError,P.Row<S,U32>>:
  Query.get(~H,~S,~U32,~caps,owner,target)
def instance_join(~S:Data,+cursor:U32,+registeredAt:U32) -> I.Instance<S> & String:
  (I.Active{cursor,registeredAt},"Active{" ++ U32.show(cursor) ++ "," ++ U32.show(registeredAt) ++ "}")
def instance_text(~S:Data,value:I.Instance<S>) -> I.Instance<S> & String:
  match value:
    case I.Fresh{}:(I.Fresh{},"Fresh{}")
    case I.Active{cursor,registeredAt}:instance_join(~S,cursor,registeredAt)
def output_text(~S:Data,value:Maybe<&2,Result<&2,&2,Query.LookupError,P.Row<S,U32>>>) -> String:
  match value:
    case None{}:"None{}"
    case Some{Done{row}}:"Some{Done{" ++ Dump.row(~S,row) ++ "}}"
    case Some{Fail{Query.MissingEntity{id}}}:"Some{Fail{MissingEntity{" ++ U32.show(id) ++ "}}}"
    case Some{Fail{Query.QueryMismatch{id}}}:"Some{Fail{QueryMismatch{" ++ U32.show(id) ++ "}}}"
def observed_join(~S:Data,+output:Maybe<&2,Result<&2,&2,Query.LookupError,P.Row<S,U32>>>,delivery:Caller.Delivery<S> & String,instance:I.Instance<S> & String) -> State<S> & String:
  match delivery instance:
    case (delivery,dt),(instance,it):(State{delivery,instance,output},dt ++ "|instance=" ++ it ++ "|output=" ++ output_text(~S,output))
def observe(~S:Data,state:State<S>) -> State<S> & String:
  match state:
    case State{delivery,instance,output}:observed_join(~S,output,Dump.delivery(~S,delivery),instance_text(~S,instance))
def inspect_returned(~S:Data,factory:W.Factory,instance:I.Instance<S>,output:Maybe<&2,Result<&2,&2,Query.LookupError,P.Row<S,U32>>>,access:C.Access<U32>,previous:Maybe<&1,Caller.Payload>,undo:List<(W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>)>,commands:List<(W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>)>,events:List<&2,U32>,result:I.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & (List<&2,P.Row<S,U32>> & List<&2,N.Clause<S>>)) -> State<S>:
  match result:
    case (owner,(rows,clauses)):State{Caller.Delivered{factory,owner,rows,clauses,access,previous,undo,commands,events},instance,output}
def inspect(~S:Data,state:State<S>) -> State<S>:
  match state:
    case State{Caller.Delivered{factory,owner,_,_,access,previous,undo,commands,events},instance,output}:inspect_returned(~S,factory,instance,output,access,previous,undo,commands,events,Caller.inspector_read(~S,owner))
    case State{delivery,instance,output}:State{delivery,instance,output}
def returned(~S:Data,factory:W.Factory,cursor:U32,rows:List<&2,P.Row<S,U32>>,clauses:List<&2,N.Clause<S>>,access:C.Access<U32>,previous:Maybe<&1,Caller.Payload>,undo:List<(W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>)>,commands:List<(W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>)>,events:List<&2,U32>,observed:I.Observed<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Query.LookupError,P.Row<S,U32>>) -> State<S>:
  match observed:
    case I.Observed{world,instance,result}:State{Caller.Delivered{factory,I.Frame{world,cursor},rows,clauses,access,previous,undo,commands,events},instance,Some{result}}
def selected_target(~S:Data,mode:U32,target:W.Handle<S>) -> W.Handle<S>:
  match mode target:
    case 0 target:target
    case _ W.Handle{namespace,_}:W.Handle{namespace,99}
def execute(~S:Data,mode:U32,factory:W.Factory,cursor:U32,+rows:List<&2,P.Row<S,U32>>,clauses:List<&2,N.Clause<S>>,access:C.Access<U32>,previous:Maybe<&1,Caller.Payload>,undo:List<(W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>)>,commands:List<(W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>)>,events:List<&2,U32>,instance:I.Instance<S>,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>) -> State<S>:
  match rows:
    case []:State{Caller.Delivered{factory,I.Frame{world,cursor},[],clauses,access,previous,undo,commands,events},instance,None{}}
    case P.Row{+target,_} <> _:returned(~S,factory,cursor,rows,clauses,access,previous,undo,commands,events,I.run(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~ops(~S),~W.Handle<S>,~Query.LookupError,~P.Row<S,U32>,~plan(~S),~body(~S),instance,selected_target(~S,mode,target),world))
def run(~S:Data,mode:U32,state:State<S>) -> State<S>:
  match state:
    case State{Caller.Delivered{factory,I.Frame{world,cursor},rows,clauses,access,previous,undo,commands,events},instance,_}:execute(~S,mode,factory,cursor,rows,clauses,access,previous,undo,commands,events,instance,world)
    case State{delivery,instance,output}:State{delivery,instance,output}
def eighth(~S:Data,prefix:String,result:State<S> & String) -> State<S> & String:
  match result:
    case (state,text):(state,prefix ++ "\nerror2=" ++ text)
def seventh(~S:Data,prefix:String,result:State<S> & String) -> State<S> & String:
  match result:
    case (state,text):eighth(~S,prefix ++ "\nerror1=" ++ text,observe(~S,inspect(~S,state)))
def sixth(~S:Data,prefix:String,result:State<S> & String) -> State<S> & String:
  match result:
    case (state,text):seventh(~S,prefix ++ "\nrepeat2=" ++ text,observe(~S,inspect(~S,run(~S,1,state))))
def fifth(~S:Data,prefix:String,result:State<S> & String) -> State<S> & String:
  match result:
    case (state,text):sixth(~S,prefix ++ "\nrepeat1=" ++ text,observe(~S,inspect(~S,state)))
def fourth(~S:Data,prefix:String,result:State<S> & String) -> State<S> & String:
  match result:
    case (state,text):fifth(~S,prefix ++ "\nfresh2=" ++ text,observe(~S,inspect(~S,run(~S,0,state))))
def third(~S:Data,prefix:String,result:State<S> & String) -> State<S> & String:
  match result:
    case (state,text):fourth(~S,prefix ++ "\nfresh1=" ++ text,observe(~S,inspect(~S,state)))
def second(~S:Data,prefix:String,result:State<S> & String) -> State<S> & String:
  match result:
    case (state,text):third(~S,prefix ++ "\nbefore2=" ++ text,observe(~S,inspect(~S,run(~S,0,state))))
def first(~S:Data,result:State<S> & String) -> State<S> & String:
  match result:
    case (state,text):second(~S,"before1=" ++ text,observe(~S,inspect(~S,state)))
def scenario(~S:Data) -> State<S> & String:
  first(~S,observe(~S,inspect(~S,State{Caller.run(~S),I.Fresh{},None{}})))
def detached(a:State<Caller.A> & String,b:State<Caller.Other> & String) -> String:
  match a b:
    case (_,a),(_,b):"A\n" ++ a ++ "\nOther\n" ++ b
def main() -> String:
  detached(scenario(~Caller.A),scenario(~Caller.Other))
