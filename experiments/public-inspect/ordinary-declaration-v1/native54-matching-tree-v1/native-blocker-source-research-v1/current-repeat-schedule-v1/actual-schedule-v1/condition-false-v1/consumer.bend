import Base
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/experiments/public-inspect/ordinary-declaration-v1/caller.bend as Caller
import /workspace/formal-proofs/bendvy-worktrees/native54-matching-tree-v1/experiments/public-inspect/ordinary-declaration-v1/native54-matching-tree-v1/native-blocker-source-research-v1/current-public-consumer-v1/observer.bend as Dump
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as N
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-binding.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch

import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-selections.bend as Selections
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-families.bend as Families
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-world.bend as QueryWorld
import /workspace/formal-proofs/bendvy/src/ecs/schedule-checked.bend as CheckedSchedule

# Exact read-only declaration used inside the original Caller.system_read runner.
def declaration(~S:Data) -> N.Declaration<S,Q.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Cap.Read<Q.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,U32>>:
  N.read(~S,~Caller.Payload,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Unit,~U32,~Caller.Token,~B.identity(~S,~Col.Column<S,Caller.Payload>,~Unit,~Caller.Payload,~U32,~Caller.Token,~Caller.take(~S),~Caller.put(~S),~Caller.view,Caller.binding(~S)),~Caller.view,~Caller.take(~S),~Caller.put(~S))
def access_names(~S:Data,clauses:List<&2,N.Clause<S>>) -> List<&2,String>:
  match clauses:
    case []:[]
    case N.Clause{name,_} <> tail:name <> access_names(~S,tail)
def runner_tx(~S:Data,+value:C.Access<U32>,tx:T.Tx<W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,U32>) -> Sys.Outcome<W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Unit,C.Access<U32>>:
  match tx:
    case T.Tx{world,_,_,_}:Sys.Succeeded{world,value}
def runner_observed(~S:Data,result:Q.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & C.Access<U32>) -> Sys.Outcome<W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Unit,C.Access<U32>>:
  match result:
    case (Q.Frame{tx,_,_,_},value):runner_tx(~S,value,tx)
def runner(~S:Data,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,handle:W.Handle<S>) -> Sys.Outcome<W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Unit,C.Access<U32>>:
  runner_observed(~S,Caller.system_read(~S,Q.Frame{T.begin(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~U32,world),handle,None{},0}))
type State<-S:Data> is Type:
  State{delivery:Caller.Delivery<S>,registry:Sys.Registry<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,W.Handle<S>,Unit,C.Access<U32>,runner(~S)>,status:String,output:Maybe<&2,C.Access<U32>>}
  Unexpected{delivery:Caller.Delivery<S>,reason:String}
def rebuilt(~S:Data,factory:W.Factory,+cursor:U32,+rows:List<&2,P.Row<S,U32>>,+clauses:List<&2,N.Clause<S>>,+access:C.Access<U32>,previous:Maybe<&1,Caller.Payload>,undo:List<(W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>)>,commands:List<(W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>)>,+events:List<&2,U32>,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>) -> Caller.Delivery<S>:
  Caller.Delivered{factory,I.Frame{world,cursor},rows,clauses,access,previous,undo,commands,events}
def registered(~S:Data,factory:W.Factory,cursor:U32,rows:List<&2,P.Row<S,U32>>,clauses:List<&2,N.Clause<S>>,access:C.Access<U32>,previous:Maybe<&1,Caller.Payload>,undo:List<(W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>)>,commands:List<(W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>)>,events:List<&2,U32>,result:Sys.RegistrationResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,W.Handle<S>,Unit,C.Access<U32>,runner(~S)>) -> State<S>:
  match result:
    case Sys.Registered{world,registry}:State{rebuilt(~S,factory,cursor,rows,clauses,access,previous,undo,commands,events,world),registry,"Registered",None{}}
    case Sys.RegistrationFailed{world}:Unexpected{rebuilt(~S,factory,cursor,rows,clauses,access,previous,undo,commands,events,world),"RegistrationFailed"}
def start(~S:Data,delivery:Caller.Delivery<S>) -> State<S>:
  match delivery:
    case Caller.Delivered{factory,I.Frame{world,cursor},rows,clauses,access,previous,undo,commands,events}:registered(~S,factory,cursor,rows,clauses,access,previous,undo,commands,events,Sys.register(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~W.Handle<S>,~Unit,~C.Access<U32>,~runner(~S),world,"ReadPosition",access_names(~S,N.clauses(~S,~Q.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~Cap.Read<Q.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,U32>,declaration(~S)))))
    case Caller.SetupRefused{factory,world,incoming,error}:Unexpected{Caller.SetupRefused{factory,world,incoming,error},"SetupRefused"}
    case Caller.Refused{factory,resource}:Unexpected{Caller.Refused{factory,resource},"Refused"}
def inspect_returned(~S:Data,factory:W.Factory,registry:Sys.Registry<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,W.Handle<S>,Unit,C.Access<U32>,runner(~S)>,status:String,output:Maybe<&2,C.Access<U32>>,access:C.Access<U32>,previous:Maybe<&1,Caller.Payload>,undo:List<(W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>)>,commands:List<(W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>)>,events:List<&2,U32>,result:I.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & (List<&2,P.Row<S,U32>> & List<&2,N.Clause<S>>)) -> State<S>:
  match result:
    case (owner,(rows,clauses)):State{Caller.Delivered{factory,owner,rows,clauses,access,previous,undo,commands,events},registry,status,output}
def inspect_delivery(~S:Data,registry:Sys.Registry<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,W.Handle<S>,Unit,C.Access<U32>,runner(~S)>,status:String,output:Maybe<&2,C.Access<U32>>,delivery:Caller.Delivery<S>) -> State<S>:
  match delivery:
    case Caller.Delivered{factory,owner,_,_,access,previous,undo,commands,events}:inspect_returned(~S,factory,registry,status,output,access,previous,undo,commands,events,Caller.inspector_read(~S,owner))
    case Caller.SetupRefused{factory,world,incoming,error}:Unexpected{Caller.SetupRefused{factory,world,incoming,error},"SetupRefused"}
    case Caller.Refused{factory,resource}:Unexpected{Caller.Refused{factory,resource},"Refused"}
def inspect(~S:Data,state:State<S>) -> State<S>:
  match state:
    case State{delivery,registry,status,output}:inspect_delivery(~S,registry,status,output,delivery)
    case Unexpected{delivery,reason}:Unexpected{delivery,reason}
def output_text(value:Maybe<&2,C.Access<U32>>) -> String:
  match value:
    case None{}:"None{}"
    case Some{value}:"Some{" ++ Dump.access(value) ++ "}"
def registry_join(~S:Data,+namespace:U32,+id:U32,+name:String,+access:List<&2,String>,+cursor:U32) -> Sys.Registry<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,W.Handle<S>,Unit,C.Access<U32>,runner(~S)> & String:
  (Sys.Registry{namespace,id,name,access,cursor},"Registry{" ++ U32.show(namespace) ++ "," ++ U32.show(id) ++ "," ++ name ++ "," ++ List.show(~&2,~String,~Dump.text,access) ++ "," ++ U32.show(cursor) ++ "}")
def registry(~S:Data,value:Sys.Registry<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,W.Handle<S>,Unit,C.Access<U32>,runner(~S)>) -> Sys.Registry<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,W.Handle<S>,Unit,C.Access<U32>,runner(~S)> & String:
  match value:
    case Sys.Registry{namespace,id,name,access,cursor}:registry_join(~S,namespace,id,name,access,cursor)
def observed_join(~S:Data,+status:String,+output:Maybe<&2,C.Access<U32>>,delivery:Caller.Delivery<S> & String,reg:Sys.Registry<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,W.Handle<S>,Unit,C.Access<U32>,runner(~S)> & String) -> State<S> & String:
  match delivery reg:
    case (delivery,dt),(reg,rt):(State{delivery,reg,status,output},dt ++ "|" ++ rt ++ "|status=" ++ status ++ "|output=" ++ output_text(output))
def observe(~S:Data,state:State<S>) -> State<S> & String:
  match state:
    case State{delivery,reg,status,output}:observed_join(~S,status,output,Dump.delivery(~S,delivery),registry(~S,reg))
    case Unexpected{delivery,+reason}:(Unexpected{delivery,reason},"UNEXPECTED:" ++ reason)
def row_handle(~S:Data,row:P.Row<S,U32>) -> W.Handle<S>:
  match row:
    case P.Row{entity,_}:entity
def actual_target(~S:Data,rows:List<&2,P.Row<S,U32>>) -> Maybe<&2,W.Handle<S>>:
  match rows:
    case []:None{}
    case row <> _:Some{row_handle(~S,row)}
def completed(~S:Data,factory:W.Factory,cursor:U32,rows:List<&2,P.Row<S,U32>>,clauses:List<&2,N.Clause<S>>,access:C.Access<U32>,previous:Maybe<&1,Caller.Payload>,undo:List<(W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>)>,commands:List<(W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>)>,events:List<&2,U32>,result:Sys.RunResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,W.Handle<S>,Unit,C.Access<U32>,runner(~S)>) -> State<S>:
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,output}}:State{rebuilt(~S,factory,cursor,rows,clauses,access,previous,undo,commands,events,world),registry,"Succeeded",Some{output}}
    case Sys.Completed{registry,Sys.Failed{world,_}}:State{rebuilt(~S,factory,cursor,rows,clauses,access,previous,undo,commands,events,world),registry,"Failed",None{}}
    case Sys.RegistrationRejected{registry,world,_}:State{rebuilt(~S,factory,cursor,rows,clauses,access,previous,undo,commands,events,world),registry,"RegistrationRejected",None{}}
type Owners<-S:Data> is Type:Owners{registry:Sys.Registry<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,W.Handle<S>,Unit,C.Access<U32>,runner(~S)>,target:W.Handle<S>,output:Maybe<&2,C.Access<U32>>}
type ConditionError is Data:
  Check{error:K.Error}
  System{}
def check_selection(~S:Data) -> P.DeclaredSelection<K.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,S,C.Access<U32>>:
  Selections.check_slot(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Unit,~Caller.Payload,~U32,~Caller.Token,~Caller.take(~S),~Caller.put(~S),~Caller.view,~Caller.binding(~S),~Families.Required{})
def check_query(~S:Data) -> Query.ComposedReadQuery<K.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,S,C.Access<U32>>:
  Query.grant_composed(~K.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~S,~C.Access<U32>,~check_selection(~S),~QueryWorld.check_world(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32))
def check_ops(~S:Data) -> Type -> Type:
  H => Query.ComposedReadQuery<H,S,C.Access<U32>>
def check_rows(~H:Type,~S:Data,result:H & List<&2,Query.ProjectedRow<S,C.Access<U32>>>) -> H & Bool:
  match result:
    case (owner,[]):(owner,False{})
    case (owner,Query.ProjectedRow{_,C.Found{value}} <> _):(owner,U32.is_eq(value,99))
    case (owner,_ <> _):(owner,False{})
def check_body(~S:Data,~H:Type,~caps:Query.ComposedReadQuery<H,S,C.Access<U32>>,_:Unit,owner:H) -> H & Bool:
  check_rows(~H,~S,Query.each_composed(~H,~S,~C.Access<U32>,~caps,owner))
def required(~S:Data,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>) -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & List<&2,String>:
  (world,[])
def check_plan(~S:Data) -> K.Plan<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,check_ops(~S)>:
  K.Plan{required(~S),check_query(~S)}
def condition_checked(~S:Data,checked:K.Checked<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>) -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & Result<ConditionError,Bool>:
  match checked:
    case K.Checked{world,Done{allowed}}:(world,Done{allowed})
    case K.Checked{world,Fail{error}}:(world,Fail{Check{error}})
def condition(~S:Data,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,_:U32) -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & Result<ConditionError,Bool>:
  condition_checked(~S,K.run(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~check_ops(~S),~Unit,~check_body(~S),~check_plan(~S),Unit{},world))
def skip(~S:Data,owners:Owners<S>,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,_:U32) -> Owners<S> & W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>:
  (owners,world)
def condition_error(error:ConditionError) -> String:
  match error:
    case Check{K.MissingRuntimeRequirements{resources}}:"MissingRuntimeRequirements{" ++ List.show(~&2,~String,~Dump.text,resources) ++ "}"
    case System{}:"System{}"
def schedule_observation(value:Sch.Observation) -> String:
  match value:
    case Sch.Entered{name}:"Entered{" ++ name ++ "}"
    case Sch.Ran{id}:"Ran{" ++ U32.show(id) ++ "}"
    case Sch.Skipped{id}:"Skipped{" ++ U32.show(id) ++ "}"
    case Sch.Applied{}:"Applied{}"
def dispatched(~S:Data,+target:W.Handle<S>,output:Maybe<&2,C.Access<U32>>,result:Sys.RunResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,W.Handle<S>,Unit,C.Access<U32>,runner(~S)>) -> Owners<S> & Sys.Outcome<W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,ConditionError,Unit>:
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,value}}:(Owners{registry,target,Some{value}},Sys.Succeeded{world,Unit{}})
    case Sys.Completed{registry,Sys.Failed{world,error}}:(Owners{registry,target,output},Sys.Failed{world,System{}})
    case Sys.RegistrationRejected{registry,world,_}:(Owners{registry,target,output},Sys.Failed{world,System{}})
def dispatch(~S:Data,owners:Owners<S>,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,_:U32) -> Owners<S> & Sys.Outcome<W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,ConditionError,Unit>:
  match owners:
    case Owners{registry,+target,output}:dispatched(~S,target,output,Sys.run_tracked(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~W.Handle<S>,~Unit,~C.Access<U32>,~runner(~S),registry,world,target))
def scheduled_result(~S:Data,factory:W.Factory,cursor:U32,rows:List<&2,P.Row<S,U32>>,clauses:List<&2,N.Clause<S>>,access:C.Access<U32>,previous:Maybe<&1,Caller.Payload>,undo:List<(W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>)>,commands:List<(W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>)>,events:List<&2,U32>,result:Sch.RunResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Owners<S>,ConditionError>) -> State<S>:
  match result:
    case Sch.Finished{Sch.Schedule{_,_,_,Owners{registry,_,output}},world,observations}:State{rebuilt(~S,factory,cursor,rows,clauses,access,previous,undo,commands,events,world),registry,"Finished:" ++ List.show(~&2,~Sch.Observation,~schedule_observation,observations),output}
    case Sch.Failed{Sch.Schedule{_,_,_,Owners{registry,_,output}},world,error,observations}:State{rebuilt(~S,factory,cursor,rows,clauses,access,previous,undo,commands,events,world),registry,"Failed{" ++ condition_error(error) ++ "}:" ++ List.show(~&2,~Sch.Observation,~schedule_observation,observations),output}
    case Sch.Rejected{Sch.Schedule{_,_,_,Owners{registry,_,output}},world}:State{rebuilt(~S,factory,cursor,rows,clauses,access,previous,undo,commands,events,world),registry,"Rejected",output}
def scheduled_built(~S:Data,factory:W.Factory,cursor:U32,rows:List<&2,P.Row<S,U32>>,clauses:List<&2,N.Clause<S>>,access:C.Access<U32>,previous:Maybe<&1,Caller.Payload>,undo:List<(W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>)>,commands:List<(W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>)>,events:List<&2,U32>,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,built:Sch.Build<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Owners<S>>) -> State<S>:
  match built:
    case Sch.Invalid{Owners{registry,_,output}}:State{rebuilt(~S,factory,cursor,rows,clauses,access,previous,undo,commands,events,world),registry,"Invalid",output}
    case Sch.Built{schedule}:scheduled_result(~S,factory,cursor,rows,clauses,access,previous,undo,commands,events,CheckedSchedule.run_with_skip(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Owners<S>,~ConditionError,~skip(~S),~dispatch(~S),~condition(~S),schedule,world))
def scheduled_registry(~S:Data,factory:W.Factory,cursor:U32,rows:List<&2,P.Row<S,U32>>,clauses:List<&2,N.Clause<S>>,access:C.Access<U32>,previous:Maybe<&1,Caller.Payload>,undo:List<(W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>)>,commands:List<(W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>)>,events:List<&2,U32>,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,registry:Sys.Registry<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,W.Handle<S>,Unit,C.Access<U32>,runner(~S)>,target:W.Handle<S>) -> State<S>:
  match registry:
    case Sys.Registry{+namespace,+id,name,accessNames,registeredCursor}:scheduled_built(~S,factory,cursor,rows,clauses,access,previous,undo,commands,events,world,Sch.build(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Owners<S>,namespace,"InspectRead",[Sch.Phase{"Update"},Sch.System{id,1}],[id],Owners{Sys.Registry{namespace,id,name,accessNames,registeredCursor},target,None{}}))
def execute_actual(~S:Data,factory:W.Factory,cursor:U32,rows:List<&2,P.Row<S,U32>>,clauses:List<&2,N.Clause<S>>,access:C.Access<U32>,previous:Maybe<&1,Caller.Payload>,undo:List<(W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>)>,commands:List<(W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>)>,events:List<&2,U32>,registry:Sys.Registry<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,W.Handle<S>,Unit,C.Access<U32>,runner(~S)>,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,target:Maybe<&2,W.Handle<S>>) -> State<S>:
  match target:
    case None{}:State{rebuilt(~S,factory,cursor,rows,clauses,access,previous,undo,commands,events,world),registry,"NoTarget",None{}}
    case Some{target}:scheduled_registry(~S,factory,cursor,rows,clauses,access,previous,undo,commands,events,world,registry,target)
def run_delivery(~S:Data,registry:Sys.Registry<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,W.Handle<S>,Unit,C.Access<U32>,runner(~S)>,delivery:Caller.Delivery<S>) -> State<S>:
  match delivery:
    case Caller.Delivered{factory,I.Frame{world,cursor},+rows,clauses,access,previous,undo,commands,events}:execute_actual(~S,factory,cursor,rows,clauses,access,previous,undo,commands,events,registry,world,actual_target(~S,rows))
    case Caller.SetupRefused{factory,world,incoming,error}:Unexpected{Caller.SetupRefused{factory,world,incoming,error},"SetupRefused"}
    case Caller.Refused{factory,resource}:Unexpected{Caller.Refused{factory,resource},"Refused"}
def run(~S:Data,state:State<S>) -> State<S>:
  match state:
    case State{delivery,registry,_,_}:run_delivery(~S,registry,delivery)
    case Unexpected{delivery,reason}:Unexpected{delivery,reason}
def fourth(~S:Data,first:String,second:String,third:String,result:State<S> & String) -> State<S> & String:
  match result:
    case (state,text):(state,"before1=" ++ first ++ "\nbefore2=" ++ second ++ "\nafter1=" ++ third ++ "\nafter2=" ++ text)
def third(~S:Data,first:String,second:String,result:State<S> & String) -> State<S> & String:
  match result:
    case (state,text):fourth(~S,first,second,text,observe(~S,inspect(~S,state)))
def second(~S:Data,first:String,result:State<S> & String) -> State<S> & String:
  match result:
    case (state,text):third(~S,first,text,observe(~S,inspect(~S,run(~S,state))))
def first(~S:Data,result:State<S> & String) -> State<S> & String:
  match result:
    case (state,text):second(~S,text,observe(~S,inspect(~S,state)))
def scenario(~S:Data) -> State<S> & String:first(~S,observe(~S,inspect(~S,start(~S,Caller.run(~S)))))
def detached(a:State<Caller.A> & String,b:State<Caller.Other> & String) -> String:
  match a b:
    case (_,a),(_,b):"A\n" ++ a ++ "\nOther\n" ++ b
def main() -> String:detached(scenario(~Caller.A),scenario(~Caller.Other))
