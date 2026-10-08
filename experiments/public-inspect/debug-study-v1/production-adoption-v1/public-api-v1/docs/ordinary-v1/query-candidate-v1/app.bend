import Base
import ./declaration.bend as Query
import ./system.bend as System
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch

type Debug is Data:
  Enabled{}
  Disabled{}
type Entry<S:Data> is Data:
  Entry{id:U32,name:String,slot:String,clauses:List<&2,Query.Clause<S>>}
type Owners<-S:Data,-H:Type> is Type:
  Owners{debug:Debug,namespace:U32,catalog:List<&2,U32>,entries:List<&2,Entry<S>>,owners:H,valid:Bool}
type Application<-S:Data,C:Type,R:Type,E:Data,H:Type> is Type:
  Application{debug:Debug,entries:List<&2,Entry<S>>,schedule:SP.Provisioned<S,C,R,E,H>}
type Built<-S:Data,C:Type,R:Type,E:Data,H:Type> is Type:
  Built{app:Application<S,C,R,E,H>}
  Invalid{owners:H}
type Description<S:Data> is Data:
  Description{namespace:U32,name:String,steps:List<&2,Sch.Step>,systems:List<&2,Entry<S>>}
def entry_when_enabled(~S:Data,debug:Debug,entries:List<&2,Entry<S>>,id:U32,name:String,slot:String,clauses:List<&2,Query.Clause<S>>) -> List<&2,Entry<S>>:
  match debug:
    case Disabled{}:entries
    case Enabled{}:List.append(&2,Entry<S>,entries,[Entry{id,name,slot,clauses}])
def empty(~S:Data,namespace:U32,debug:Debug) -> Owners<S,Unit>:
  Owners{debug,namespace,[],[],Unit{},True{}}
def add(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Query.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),~H:Type,collected:Owners<S,H>,owner:System.Owner<S,Sys.Registry<S,C,R,E,A & U32,Q.Error<U>,List<&2,Out>,System.runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body)>>) -> Owners<S,H & System.Owner<S,Sys.Registry<S,C,R,E,A & U32,Q.Error<U>,List<&2,Out>,System.runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body)>>>:
  match collected owner:
    case Owners{+debug,+namespace,catalog,entries,owners,valid} System.Owner{Sys.Registry{+actual,+id,+name,+access,+cursor},+slot,+clauses}:
      Owners{debug,namespace,List.append(&2,U32,catalog,[id]),entry_when_enabled(~S,debug,entries,id,name,slot,clauses),(owners,System.Owner{Sys.Registry{actual,id,name,access,cursor},slot,clauses}),Bool.and(valid,U32.is_eq(namespace,actual))}
def built(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,debug:Debug,entries:List<&2,Entry<S>>,result:SP.Build<S,C,R,E,H>) -> Built<S,C,R,E,H>:
  match result:
    case SP.Invalid{owners}:Invalid{owners}
    case SP.Built{schedule}:Built{Application{debug,entries,schedule}}
def build(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,name:String,plan:SP.Plan<S>,collected:Owners<S,H>) -> Built<S,C,R,E,H>:
  match collected:
    case Owners{debug,namespace,catalog,entries,owners,False{}}:Invalid{owners}
    case Owners{debug,namespace,catalog,entries,owners,True{}}:built(~S,~C,~R,~E,~H,debug,entries,SP.build(~S,~C,~R,~E,~H,namespace,name,plan,catalog,owners))
def describe(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,app:Application<S,C,R,E,H>) -> Application<S,C,R,E,H> & Maybe<&2,Description<S>>:
  match app:
    case Application{Disabled{},entries,schedule}:(Application{Disabled{},entries,schedule},None{})
    case Application{Enabled{},+entries,SP.Provisioned{Sch.Schedule{+namespace,+name,+steps,owners},requirements}}:
      (Application{Enabled{},entries,SP.Provisioned{Sch.Schedule{namespace,name,steps,owners},requirements}},Some{Description{namespace,name,steps,entries}})
def run(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,app:Application<S,C,R,E,H>,world:W.World<S,C,R,E>) -> SP.ProvisionResult<S,C,R,E,H,Error> & (Debug & List<&2,Entry<S>>):
  match app:
    case Application{debug,entries,schedule}:(SP.run(~S,~C,~R,~E,~H,~Error,~dispatch,~condition,~provision,schedule,world),(debug,entries))
