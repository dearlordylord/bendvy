import Base
import ../trace-force.bend as Force
import ../trace-value.bend as J
import ../trace-rows.bend as Rows
import ../trace-public.bend as Public
import ../../../../../src/ecs/commands.bend as Cmd
import ../../../../../src/ecs/relation-types.bend as G
import ../../../../../src/ecs/relation-providers.bend as P
import ../../../../../src/ecs/relation-reorder.bend as R
import ../../../../../src/ecs/relation-commands.bend as A
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/transaction.bend as X
import ../../../../../src/ecs/system.bend as Sys
import ../../../../../src/ecs/component.bend as Cmp
import ../../../../../src/ecs/capabilities.bend as Cap
import ../../../promotion-stage/application/next-version/v1/owned-world.bend as O
import ../../../../../src/ecs/relation-query.bend as RQ
import ../trace-query.bend as Q
import ../../../promotion-stage/application/next-version/v1/cleanup-client.bend as C
import ../trace-application.bend as App
import operations.bend as Ops
import ../../../../../src/ecs/string-equality.bend as SE
import input.bend as I


def appended(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & J.Value,records:List<&2,J.Value>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & List<&2,J.Value>:
  (world,record) = result
  (world,List.append(&2,J.Value,records,[record]))
def queued(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & J.Value,+root:String,+phase:U32,+retained:J.Value,count:Nat,input:I.Input,records:List<&2,J.Value>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & List<&2,J.Value>:
  (world,record) = result
  appended(~S,App.observed(~S,W.barrier(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,world),root,"applied-" ++ U32.show(phase),retained,None{},count),List.append(&2,J.Value,records,[record]))
def written(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & Maybe<&2,U32>,+root:String,+phase:U32,+retained:J.Value,+count:Nat,input:I.Input,records:List<&2,J.Value>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & List<&2,J.Value>:
  (world,status) = result
  queued(~S,App.observed(~S,world,root,"queued-" ++ U32.show(phase),retained,status,count),root,phase,retained,count,input,records)
def step(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & List<&2,J.Value>,root:String,+phase:U32,retained:J.Value,count:Nat,+input:I.Input) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & List<&2,J.Value>:
  (world,records) = result
  written(~S,Ops.write(~S,world,Ops.Args{phase,input}),root,phase,retained,count,input,records)
def finished(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & List<&2,J.Value>,root:String) -> J.Value:
  (_,records) = result
  J.Object{[J.Field{"root",J.Text{root}},J.Field{"records",J.Items{records}}]}
# Reuse the actual initial optional query result. No additional capture query.
def optional_selected(same:Bool,value:J.Value,next:Unit -> J.Value) -> J.Value:
  match same:
    case True{}:value
    case False{}:next(Unit{})
def optional_field(fields:List<&2,J.Field>) -> J.Value:
  match fields:
    case []:J.Text{"MISSING_OPTIONAL_QUERY"}
    case J.Field{name,+value} <> rest:optional_selected(SE.equal(name,"optional"),value,_ => optional_field(rest))
def first_record(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & J.Value,+root:String,+retained:J.Value,+population:U32,+input:I.Input) -> J.Value:
  finished(~S,step(~S,step(~S,step(~S,step(~S,step(~S,step(~S,step(~S,appended(~S,result,[]),root,0,retained,U32.to_nat(population),input),root,1,retained,U32.to_nat(population),input),root,2,retained,U32.to_nat(population),input),root,5,retained,U32.to_nat(population),input),root,6,retained,U32.to_nat(U32.add(population,1)),input),root,3,retained,U32.to_nat(U32.add(population,1)),input),root,4,retained,U32.to_nat(U32.add(population,1)),input),root)
def first_retained(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,rows:List<&2,J.Field>,+root:String,+population:U32,+input:I.Input,+retained:J.Value) -> J.Value:
  first_record(~S,App.record_graphs(~S,Public.graphs(~S,App.descriptors(~S),world,U32.to_nat(population)),root,"initial",rows,retained,None{}),root,retained,population,input)
def first_rows(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & List<&2,J.Field>,+root:String,+population:U32,+input:I.Input) -> J.Value:
  (world,+rows) = result
  first_retained(~S,world,rows,root,population,input,optional_field(rows))
def run(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,root:String,+input:I.Input) -> J.Value:
  match input:
    case I.Input{family,+population,span,seed}:first_rows(~S,Q.registered_world(~S,world,"query-initial"),root,population,I.Input{family,population,span,seed})
