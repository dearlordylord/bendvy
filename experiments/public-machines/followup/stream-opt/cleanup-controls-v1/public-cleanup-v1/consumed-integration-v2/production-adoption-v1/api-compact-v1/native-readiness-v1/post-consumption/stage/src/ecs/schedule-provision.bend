import Base
import ../../experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/world.bend as W
import ../../experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/system.bend as Sys
import ./schedule.bend as Sch

# Schema authoring provisions nominal requirement tokens. Gameplay cannot turn
# these tokens into component/resource/service providers. Actual availability
# is observed from the owned application's provisioning record before any step.
type Requirement<S: Data> is Data:
  Component{id: U32}
  Resource{id: U32}
  Service{id: U32}
type Plan<S: Data> is Data:
  Empty{}
  Entry{step: Sch.Step,requirements: List<&2,Requirement<S>>}
  Sequence{left: Plan<S>,right: Plan<S>}
type Provisioned<S: Data,C: Type,R: Type,E: Data,H: Type> is Type:
  Provisioned{schedule: Sch.Schedule<S,C,R,E,H>,requirements: List<&2,Requirement<S>>}
type Build<S: Data,C: Type,R: Type,E: Data,H: Type> is Type:
  Built{schedule: Provisioned<S,C,R,E,H>}
  Invalid{owners: H}
type ProvisionResult<S: Data,C: Type,R: Type,E: Data,H: Type,Error: Data> is Type:
  Executed{result: Sch.RunResult<S,C,R,E,H,Error>,requirements: List<&2,Requirement<S>>}
  Missing{schedule: Provisioned<S,C,R,E,H>,world: W.World<S,C,R,E>,missing: List<&2,Requirement<S>>}

def same(~S: Data,a: Requirement<S>,b: Requirement<S>) -> Bool:
  match a b:
    case Component{a} Component{b}: U32.is_eq(a,b)
    case Resource{a} Resource{b}: U32.is_eq(a,b)
    case Service{a} Service{b}: U32.is_eq(a,b)
    case _ _: False{}

def contains(~S: Data,items: List<&2,Requirement<S>>,+item: Requirement<S>) -> Bool:
  match items:
    case []: False{}
    case head <> rest: Bool.or(same(~S,head,item),contains(~S,rest,item))

def unique_add(~S: Data,present: Bool,+item: Requirement<S>,rest: List<&2,Requirement<S>>) -> List<&2,Requirement<S>>:
  match present:
    case True{}: rest
    case False{}: item <> rest

def unique_seen(~S: Data,items: List<&2,Requirement<S>>,+seen: List<&2,Requirement<S>>) -> List<&2,Requirement<S>>:
  match items:
    case []: []
    case +head <> rest: unique_add(~S,contains(~S,seen,head),head,unique_seen(~S,rest,head <> seen))

def unique(~S: Data,items: List<&2,Requirement<S>>) -> List<&2,Requirement<S>>:
  unique_seen(~S,items,[])

def flatten(~S: Data,plan: Plan<S>) -> List<&2,Sch.Step>:
  match plan:
    case Empty{}: []
    case Entry{step,_}: [step]
    case Sequence{left,right}: List.append(&2,Sch.Step,flatten(~S,left),flatten(~S,right))

def requirements(~S: Data,plan: Plan<S>) -> List<&2,Requirement<S>>:
  match plan:
    case Empty{}: []
    case Entry{_,needs}: needs
    case Sequence{left,right}: List.append(&2,Requirement<S>,requirements(~S,left),requirements(~S,right))

def finish_build(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,built: Sch.Build<S,C,R,E,H>,needs: List<&2,Requirement<S>>) -> Build<S,C,R,E,H>:
  match built:
    case Sch.Invalid{owners}: Invalid{owners}
    case Sch.Built{schedule}: Built{Provisioned{schedule,needs}}

def build(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,+namespace: U32,+name: String,+plan: Plan<S>,catalog: List<&2,U32>,owners: H) -> Build<S,C,R,E,H>:
  finish_build(~S,~C,~R,~E,~H,Sch.build(~S,~C,~R,~E,~H,namespace,name,flatten(~S,plan),catalog,owners),unique(~S,requirements(~S,plan)))

def missing_next(~S: Data,present: Bool,item: Requirement<S>,next: List<&2,Requirement<S>>) -> List<&2,Requirement<S>>:
  match present:
    case False{}: item <> next
    case True{}: next

def missing_requirements(~S: Data,needs: List<&2,Requirement<S>>,+available: List<&2,Requirement<S>>) -> List<&2,Requirement<S>>:
  match needs:
    case []: []
    case +head <> rest: missing_next(~S,contains(~S,available,head),head,missing_requirements(~S,rest,available))

def run_checked(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,~dispatch: H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition: W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,missing: List<&2,Requirement<S>>,schedule: Sch.Schedule<S,C,R,E,H>,world: W.World<S,C,R,E>,needs: List<&2,Requirement<S>>) -> ProvisionResult<S,C,R,E,H,Error>:
  match missing:
    case first <> rest: Missing{Provisioned{schedule,needs},world,first <> rest}
    case []: Executed{Sch.run(~S,~C,~R,~E,~H,~Error,~dispatch,~condition,schedule,world),needs}

def run_available(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,~dispatch: H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition: W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,observed: W.World<S,C,R,E> & List<&2,Requirement<S>>,schedule: Sch.Schedule<S,C,R,E,H>,+needs: List<&2,Requirement<S>>) -> ProvisionResult<S,C,R,E,H,Error>:
  (world,available) = observed
  run_checked(~S,~C,~R,~E,~H,~Error,~dispatch,~condition,missing_requirements(~S,needs,available),schedule,world,needs)

def run(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,~dispatch: H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition: W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,~provision: W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,Requirement<S>>,schedule: Provisioned<S,C,R,E,H>,world: W.World<S,C,R,E>) -> ProvisionResult<S,C,R,E,H,Error>:
  match schedule:
    case Provisioned{schedule,needs}: run_available(~S,~C,~R,~E,~H,~Error,~dispatch,~condition,provision(world),schedule,needs)
