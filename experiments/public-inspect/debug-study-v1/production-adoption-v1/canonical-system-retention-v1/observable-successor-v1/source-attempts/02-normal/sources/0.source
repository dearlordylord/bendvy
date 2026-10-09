import Base
import /workspace/formal-proofs/bendvy-worktrees/ordinary-system-retention/src/ecs/ordinary-query-observable.bend as O
import /workspace/formal-proofs/bendvy-worktrees/ordinary-system-retention/src/ecs/inspector.bend as I
import ../../../../../../../../src/ecs/ordinary-schema.bend as Normal
import ./retained-schema.bend as Schema
import ../../../../../../../../src/ecs/schema-fragments.bend as Fragment
import ../../../../../../../../src/ecs/ordinary-query-declaration.bend as Query
import ../../../../../../../../src/ecs/ordinary-system.bend as System
import ../../../../../../../../src/ecs/compose.bend as Q
import ../../../../../../../../src/ecs/world.bend as W
import ../../../../../../../../src/ecs/system.bend as Sys
import ../../../../../../../../src/ecs/transaction.bend as T
import ../../../../../../../../src/ecs/schedule-provision.bend as SP
import ../../../../../../../../src/ecs/schedule.bend as Sch

type Debug is Data:
  Enabled{}
  Disabled{}
type Entry<S:Data> is Data:
  Entry{id:U32,name:String,access:List<&2,String>,slot:String,clauses:List<&2,Query.Clause<S>>}
# Normal bindings are the same registry/query declarations needed to provision IDs.
# Description.Entry copies are created only by enabled projection.
type Binding<S:Data> is Data:
  Binding{namespace:U32,id:U32,name:String,access:List<&2,String>,slot:String,clauses:List<&2,Query.Clause<S>>}
type Owners<-S:Data,-C:Type,-R:Type,-H:Type> is Type:
  Owners{schema:Normal.Schema<S,C,R>,debug:Debug,namespace:U32,bindings:List<&2,Binding<S>>,owners:H,valid:Bool}
type Application<-S:Data,C:Type,R:Type,E:Data,H:Type> is Type:
  Application{schema:Normal.Schema<S,C,R>,debug:Debug,bindings:List<&2,Binding<S>>,schedule:SP.Provisioned<S,C,R,E,H>}
type Built<-S:Data,C:Type,R:Type,E:Data,H:Type> is Type:
  Built{app:Application<S,C,R,E,H>}
  Invalid{owners:H}
type Description<S:Data> is Data:
  Description{schema:List<&2,Fragment.Entry<S>>,namespace:U32,name:String,steps:List<&2,Sch.Step>,systems:List<&2,Entry<S>>}
def ids(~S:Data,bindings:List<&2,Binding<S>>) -> List<&2,U32>:
  match bindings:
    case []:[]
    case Binding{_,id,_,_,_,_} <> rest:id <> ids(~S,rest)
def entries(~S:Data,bindings:List<&2,Binding<S>>) -> List<&2,Entry<S>>:
  match bindings:
    case []:[]
    case Binding{_,id,name,access,slot,clauses} <> rest:Entry{id,name,access,slot,clauses} <> entries(~S,rest)
def empty(~S:Data,~C:Type,~R:Type,namespace:U32,debug:Debug,schema:Normal.Schema<S,C,R>) -> Owners<S,C,R,Unit>:
  Owners{schema,debug,namespace,[],Unit{},True{}}
def add(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~IV:Data,~query:O.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,IV>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),~H:Type,collected:Owners<S,C,R,H>,owner:System.Owner<S,Sys.Registry<S,C,R,E,A & U32,Q.Error<U>,List<&2,Out>,System.observable_runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~IV,~query,~body)>>) -> Owners<S,C,R,H & System.Owner<S,Sys.Registry<S,C,R,E,A & U32,Q.Error<U>,List<&2,Out>,System.observable_runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~IV,~query,~body)>>>:
  match collected owner:
    case Owners{schema,+debug,+namespace,bindings,owners,valid} System.Owner{Sys.Registry{+actual,+id,+name,+access,+cursor},+slot,+clauses}:
      Owners{schema,debug,namespace,List.append(&2,Binding<S>,bindings,[Binding{actual,id,name,access,slot,clauses}]),(owners,System.Owner{Sys.Registry{actual,id,name,access,cursor},slot,clauses}),Bool.and(valid,U32.is_eq(namespace,actual))}
def built(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,schema:Normal.Schema<S,C,R>,debug:Debug,bindings:List<&2,Binding<S>>,result:SP.Build<S,C,R,E,H>) -> Built<S,C,R,E,H>:
  match result:
    case SP.Invalid{owners}:Invalid{owners}
    case SP.Built{schedule}:Built{Application{schema,debug,bindings,schedule}}
def build(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,name:String,plan:SP.Plan<S>,collected:Owners<S,C,R,H>) -> Built<S,C,R,E,H>:
  match collected:
    case Owners{schema,debug,namespace,bindings,owners,False{}}:Invalid{owners}
    case Owners{schema,debug,namespace,+bindings,owners,True{}}:built(~S,~C,~R,~E,~H,schema,debug,bindings,SP.build(~S,~C,~R,~E,~H,namespace,name,plan,ids(~S,bindings),owners))
def describe(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,app:Application<S,C,R,E,H>) -> Application<S,C,R,E,H> & Maybe<&2,Description<S>>:
  match app:
    case Application{schema,Disabled{},bindings,schedule}:(Application{schema,Disabled{},bindings,schedule},None{})
    case Application{+schema,Enabled{},+bindings,SP.Provisioned{Sch.Schedule{+namespace,+name,+steps,owners},requirements}}:
      (Application{schema,Enabled{},bindings,SP.Provisioned{Sch.Schedule{namespace,name,steps,owners},requirements}},Some{Description{Schema.entries(~S,~C,~R,schema),namespace,name,steps,entries(~S,bindings)}})
def run(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,app:Application<S,C,R,E,H>,world:W.World<S,C,R,E>) -> SP.ProvisionResult<S,C,R,E,H,Error> & (Normal.Schema<S,C,R> & (Debug & List<&2,Binding<S>>)):
  match app:
    case Application{schema,debug,bindings,schedule}:(SP.run(~S,~C,~R,~E,~H,~Error,~dispatch,~condition,~provision,schedule,world),(schema,(debug,bindings)))
