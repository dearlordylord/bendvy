import Base
import health.bend as F
import types.bend as T
import ../../../../src/ecs/ordinary-system.bend as Ordinary
import ../../../../src/ecs/ordinary-query-declaration.bend as Decl
import ../../../../src/ecs/compose.bend as Q
import ../../../../src/ecs/transaction.bend as Tx
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/world.bend as W

type Audit is Data:
  Audit{values:List<&2,U32>,readsum:U32,updated:Nat}
type Status is Data:
  Succeeded{}
  Failed{error:Q.Error<Unit>}
  Rejected{cursor:U32}
type State is Type:
  State{world:F.World(),owner:F.Owner(),audit:List<&2,Audit>,statuses:List<&2,Status>}
def total(values:List<&2,U32>) -> U32:
  match values:
    case []:0
    case head <> tail:U32.add(head,total(tail))
def finished(audit:List<&2,Audit>,statuses:List<&2,Status>,slot:String,clauses:List<&2,Decl.Clause<T.HealthSchema>>,result:Sys.RunResult<T.HealthSchema,F.Store(),F.Resources(),Nat,Unit & U32,Q.Error<Unit>,List<&2,U32>,Ordinary.runner(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~F.Ops,~Unit,~Unit,~U32,~F.declaration(),~F.body)>) -> State:
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,+values}}:State{world,Ordinary.Owner{registry,slot,clauses},List.append(&2,Audit,audit,[Audit{values,total(values),List.length(&2,U32,values)}]),List.append(&2,Status,statuses,[Succeeded{}])}
    case Sys.Completed{registry,Sys.Failed{world,error}}:State{world,Ordinary.Owner{registry,slot,clauses},audit,List.append(&2,Status,statuses,[Failed{error}])}
    case Sys.RegistrationRejected{registry,world,(_,cursor)}:State{world,Ordinary.Owner{registry,slot,clauses},audit,List.append(&2,Status,statuses,[Rejected{cursor}])}
def ran(audit:List<&2,Audit>,statuses:List<&2,Status>,observed:Sys.RunResult<T.HealthSchema,F.Store(),F.Resources(),Nat,Unit & U32,Q.Error<Unit>,List<&2,U32>,Ordinary.runner(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~F.Ops,~Unit,~Unit,~U32,~F.declaration(),~F.body)> & (String & List<&2,Decl.Clause<T.HealthSchema>>)) -> State:
  match observed:
    case (result,(slot,clauses)):finished(audit,statuses,slot,clauses,result)
def step(state:State) -> State:
  match state:
    case State{world,owner,audit,statuses}:ran(audit,statuses,Ordinary.run(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~F.Ops,~Unit,~Unit,~U32,~F.declaration(),~F.body,owner,world,Unit{}))
def loops(fuel:Nat,state:State) -> State:
  match fuel:
    case 0n:state
    case 1n+rest:loops(rest,step(state))
