import Base
import ./world.bend as W
import ./system.bend as Sys

# Static plans contain no runtime closures. H holds heterogeneous affine
# registered runner owners; closed templates thread that owner through each step.
# Detached static sequence: System holds a registered id and condition slot;
# Phase is an observation label and Barrier is an explicit pending-work boundary.
# A phase label alone does not flush commands or execute a gameplay callback.
type Step is Data:
  System{id: U32,condition: U32}
  Phase{name: String}
  Barrier{}
# Ordered progress records for entered phases, dispatched/skipped systems and
# applied barriers. Ran includes a system that failed; inspect RunResult as well.
type Observation is Data:
  Entered{name: String}
  Ran{id: U32}
  Skipped{id: U32}
  Applied{}
# Affine registered-owner bundle plus detached static steps and World namespace.
# Raw construction is trusted setup; build validates ids against its supplied catalog.
type Schedule<S: Data,C: Type,R: Type,E: Data,H: Type> is Type:
  Schedule{namespace: U32,name: String,steps: List<&2,Step>,owners: H}
# Build result preserving the actual heterogeneous owners on invalid plans.
# Built retains those owners inside Schedule, not copied reusable runtime closures.
type Build<S: Data,C: Type,R: Type,E: Data,H: Type> is Type:
  Built{schedule: Schedule<S,C,R,E,H>}
  Invalid{owners: H}
# Every result returns Schedule with actual runner owners and World. Failed stops
# at the first failed dispatch and keeps observations through that system; earlier
# successful systems are not rolled back as one schedule-wide transaction. Rejected
# is namespace admission refusal and runs no steps.
type RunResult<S: Data,C: Type,R: Type,E: Data,H: Type,Error: Data> is Type:
  Finished{schedule: Schedule<S,C,R,E,H>,world: W.World<S,C,R,E>,observations: List<&2,Observation>}
  Failed{schedule: Schedule<S,C,R,E,H>,world: W.World<S,C,R,E>,error: Error,observations: List<&2,Observation>}
  Rejected{schedule: Schedule<S,C,R,E,H>,world: W.World<S,C,R,E>}

def contains(ids: List<&2,U32>,+id: U32) -> Bool:
  match ids:
    case []: False{}
    case +head <> rest: Bool.or(U32.is_eq(head,id),contains(rest,id))

def valid(steps: List<&2,Step>,+catalog: List<&2,U32>,+seen: List<&2,U32>) -> Bool:
  match steps:
    case []: True{}
    case Phase{_} <> rest: valid(rest,catalog,seen)
    case Barrier{} <> rest: valid(rest,catalog,seen)
    case System{+id,_} <> rest: Bool.and(contains(catalog,id),Bool.and(Bool.not(contains(seen,id)),valid(rest,catalog,id <> seen)))

def build_checked(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,allowed: Bool,+namespace: U32,+name: String,+steps: List<&2,Step>,owners: H) -> Build<S,C,R,E,H>:
  match allowed:
    case False{}: Invalid{owners}
    case True{}: Built{Schedule{namespace,name,steps,owners}}

# Validate that each System id occurs in the supplied catalog and appears at most
# once in steps. Return Invalid with owners otherwise. Condition slots and catalog
# provenance are trusted setup here; this is not a scheduler conflict analysis.
def build(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,+namespace: U32,+name: String,+steps: List<&2,Step>,catalog: List<&2,U32>,owners: H) -> Build<S,C,R,E,H>:
  build_checked(~S,~C,~R,~E,~H,valid(steps,catalog,[]),namespace,name,steps,owners)

# Continuations keep recursion structurally decreasing on the plan, rather
# than moving affine owners into runtime closures stored in the schedule.
def after_outcome(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,next: H -> W.World<S,C,R,E> -> List<&2,Observation> -> RunResult<S,C,R,E,H,Error>,outcome: Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,owners: H,+namespace: U32,+name: String,+all: List<&2,Step>,+observations: List<&2,Observation>,+id: U32) -> RunResult<S,C,R,E,H,Error>:
  match outcome:
    case Sys.Failed{world,error}: Failed{Schedule{namespace,name,all,owners},world,error,List.append(&2,Observation,observations,[Ran{id}])}
    case Sys.Succeeded{world,_}: next(owners,world,List.append(&2,Observation,observations,[Ran{id}]))

def after_dispatch(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,next: H -> W.World<S,C,R,E> -> List<&2,Observation> -> RunResult<S,C,R,E,H,Error>,result: H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,+namespace: U32,+name: String,+all: List<&2,Step>,+observations: List<&2,Observation>,+id: U32) -> RunResult<S,C,R,E,H,Error>:
  (owners,outcome) = result
  after_outcome(~S,~C,~R,~E,~H,~Error,next,outcome,owners,namespace,name,all,observations,id)

def conditioned(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,~dispatch: H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,next: H -> W.World<S,C,R,E> -> List<&2,Observation> -> RunResult<S,C,R,E,H,Error>,allowed: Bool,owners: H,world: W.World<S,C,R,E>,+namespace: U32,+name: String,+all: List<&2,Step>,+observations: List<&2,Observation>,+id: U32) -> RunResult<S,C,R,E,H,Error>:
  match allowed:
    case False{}: next(owners,world,List.append(&2,Observation,observations,[Skipped{id}]))
    case True{}: after_dispatch(~S,~C,~R,~E,~H,~Error,next,dispatch(owners,world,id),namespace,name,all,observations,id)

def after_condition(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,~dispatch: H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,next: H -> W.World<S,C,R,E> -> List<&2,Observation> -> RunResult<S,C,R,E,H,Error>,checked: W.World<S,C,R,E> & Bool,owners: H,+namespace: U32,+name: String,+all: List<&2,Step>,+observations: List<&2,Observation>,+id: U32) -> RunResult<S,C,R,E,H,Error>:
  (world,allowed) = checked
  conditioned(~S,~C,~R,~E,~H,~Error,~dispatch,next,allowed,owners,world,namespace,name,all,observations,id)

def after_skip(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,next: H -> W.World<S,C,R,E> -> List<&2,Observation> -> RunResult<S,C,R,E,H,Error>,returned: H & W.World<S,C,R,E>,observations: List<&2,Observation>) -> RunResult<S,C,R,E,H,Error>:
  (owners,world) = returned
  next(owners,world,observations)

def default_barrier(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,owners:H,world:W.World<S,C,R,E>) -> H & W.World<S,C,R,E>:
  (owners,W.barrier(~S,~C,~R,~E,world))
def execute_with_barrier(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,~dispatch: H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition: W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,~barrier:H -> W.World<S,C,R,E> -> H & W.World<S,C,R,E>,steps: List<&2,Step>,owners: H,world: W.World<S,C,R,E>,+namespace: U32,+name: String,+all: List<&2,Step>,+observations: List<&2,Observation>) -> RunResult<S,C,R,E,H,Error>:
  match steps:
    case []: Finished{Schedule{namespace,name,all,owners},world,observations}
    case Phase{phase} <> rest: execute_with_barrier(~S,~C,~R,~E,~H,~Error,~dispatch,~condition,~barrier,rest,owners,world,namespace,name,all,List.append(&2,Observation,observations,[Entered{phase}]))
    case Barrier{} <> rest: after_skip(~S,~C,~R,~E,~H,~Error,h => w => obs => execute_with_barrier(~S,~C,~R,~E,~H,~Error,~dispatch,~condition,~barrier,rest,h,w,namespace,name,all,obs),barrier(owners,world),List.append(&2,Observation,observations,[Applied{}]))
    case System{+id,slot} <> rest: after_condition(~S,~C,~R,~E,~H,~Error,~dispatch,h => w => obs => execute_with_barrier(~S,~C,~R,~E,~H,~Error,~dispatch,~condition,~barrier,rest,h,w,namespace,name,all,obs),condition(world,slot),owners,namespace,name,all,observations,id)

def execute(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,~dispatch: H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition: W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,steps: List<&2,Step>,owners: H,world: W.World<S,C,R,E>,+namespace: U32,+name: String,+all: List<&2,Step>,+observations: List<&2,Observation>) -> RunResult<S,C,R,E,H,Error>:
  execute_with_barrier(~S,~C,~R,~E,~H,~Error,~dispatch,~condition,~default_barrier(~S,~C,~R,~E,~H),steps,owners,world,namespace,name,all,observations)

def run_checked(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,~dispatch: H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition: W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,allowed: Bool,schedule: Schedule<S,C,R,E,H>,world: W.World<S,C,R,E>) -> RunResult<S,C,R,E,H,Error>:
  match allowed schedule:
    case False{} schedule: Rejected{schedule,world}
    case True{} Schedule{+namespace,+name,+steps,owners}: execute(~S,~C,~R,~E,~H,~Error,~dispatch,~condition,steps,owners,world,namespace,name,steps,[])


def run_actual(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,~dispatch: H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition: W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,schedule: Schedule<S,C,R,E,H>,world: W.World<S,C,R,E>,+actual: U32) -> RunResult<S,C,R,E,H,Error>:
  match schedule:
    case Schedule{+namespace,+name,+steps,owners}: run_checked(~S,~C,~R,~E,~H,~Error,~dispatch,~condition,U32.is_eq(namespace,actual),Schedule{namespace,name,steps,owners},world)

def run_namespace(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,~dispatch: H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition: W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,schedule: Schedule<S,C,R,E,H>,named: W.World<S,C,R,E> & U32) -> RunResult<S,C,R,E,H,Error>:
  (world,+actual) = named
  run_actual(~S,~C,~R,~E,~H,~Error,~dispatch,~condition,schedule,world,actual)

# Run static steps in order after matching Schedule and World namespaces.
# Evaluate condition by its slot; false records Skipped without dispatch. True
# threads the actual H through dispatch, stopping on Sys.Failed. Barriers call
# W.barrier; no implicit final barrier is added. Callbacks are trusted closed
# providers, not arbitrary capabilities inferred from ids. See ordinary App
# schedule setup in examples/scheduled-health/application.bend.
def run(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,~dispatch: H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition: W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,schedule: Schedule<S,C,R,E,H>,world: W.World<S,C,R,E>) -> RunResult<S,C,R,E,H,Error>:
  run_namespace(~S,~C,~R,~E,~H,~Error,~dispatch,~condition,schedule,W.namespace(~S,~C,~R,~E,world))

# Additive runner with owner-preserving condition-false reader lifecycle hook.
def conditioned_skip(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,~skip: H -> W.World<S,C,R,E> -> U32 -> H & W.World<S,C,R,E>,~dispatch: H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,next: H -> W.World<S,C,R,E> -> List<&2,Observation> -> RunResult<S,C,R,E,H,Error>,allowed: Bool,owners: H,world: W.World<S,C,R,E>,+namespace: U32,+name: String,+all: List<&2,Step>,+observations: List<&2,Observation>,+id: U32) -> RunResult<S,C,R,E,H,Error>:
  match allowed:
    case False{}: after_skip(~S,~C,~R,~E,~H,~Error,next,skip(owners,world,id),List.append(&2,Observation,observations,[Skipped{id}]))
    case True{}: after_dispatch(~S,~C,~R,~E,~H,~Error,next,dispatch(owners,world,id),namespace,name,all,observations,id)

def after_condition_skip(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,~skip: H -> W.World<S,C,R,E> -> U32 -> H & W.World<S,C,R,E>,~dispatch: H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,next: H -> W.World<S,C,R,E> -> List<&2,Observation> -> RunResult<S,C,R,E,H,Error>,checked: W.World<S,C,R,E> & Bool,owners: H,+namespace: U32,+name: String,+all: List<&2,Step>,+observations: List<&2,Observation>,+id: U32) -> RunResult<S,C,R,E,H,Error>:
  (world,allowed) = checked
  conditioned_skip(~S,~C,~R,~E,~H,~Error,~skip,~dispatch,next,allowed,owners,world,namespace,name,all,observations,id)

def execute_skip(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,~skip: H -> W.World<S,C,R,E> -> U32 -> H & W.World<S,C,R,E>,~dispatch: H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition: W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,steps: List<&2,Step>,owners: H,world: W.World<S,C,R,E>,+namespace: U32,+name: String,+all: List<&2,Step>,+observations: List<&2,Observation>) -> RunResult<S,C,R,E,H,Error>:
  match steps:
    case []: Finished{Schedule{namespace,name,all,owners},world,observations}
    case Phase{phase} <> rest: execute_skip(~S,~C,~R,~E,~H,~Error,~skip,~dispatch,~condition,rest,owners,world,namespace,name,all,List.append(&2,Observation,observations,[Entered{phase}]))
    case Barrier{} <> rest: execute_skip(~S,~C,~R,~E,~H,~Error,~skip,~dispatch,~condition,rest,owners,W.barrier(~S,~C,~R,~E,world),namespace,name,all,List.append(&2,Observation,observations,[Applied{}]))
    case System{+id,slot} <> rest: after_condition_skip(~S,~C,~R,~E,~H,~Error,~skip,~dispatch,h => w => obs => execute_skip(~S,~C,~R,~E,~H,~Error,~skip,~dispatch,~condition,rest,h,w,namespace,name,all,obs),condition(world,slot),owners,namespace,name,all,observations,id)

def run_checked_skip(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,~skip: H -> W.World<S,C,R,E> -> U32 -> H & W.World<S,C,R,E>,~dispatch: H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition: W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,allowed: Bool,schedule: Schedule<S,C,R,E,H>,world: W.World<S,C,R,E>) -> RunResult<S,C,R,E,H,Error>:
  match allowed schedule:
    case False{} schedule: Rejected{schedule,world}
    case True{} Schedule{+namespace,+name,+steps,owners}: execute_skip(~S,~C,~R,~E,~H,~Error,~skip,~dispatch,~condition,steps,owners,world,namespace,name,steps,[])


def run_actual_skip(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,~skip: H -> W.World<S,C,R,E> -> U32 -> H & W.World<S,C,R,E>,~dispatch: H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition: W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,schedule: Schedule<S,C,R,E,H>,world: W.World<S,C,R,E>,+actual: U32) -> RunResult<S,C,R,E,H,Error>:
  match schedule:
    case Schedule{+namespace,+name,+steps,owners}: run_checked_skip(~S,~C,~R,~E,~H,~Error,~skip,~dispatch,~condition,U32.is_eq(namespace,actual),Schedule{namespace,name,steps,owners},world)

def run_namespace_skip(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,~skip: H -> W.World<S,C,R,E> -> U32 -> H & W.World<S,C,R,E>,~dispatch: H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition: W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,schedule: Schedule<S,C,R,E,H>,named: W.World<S,C,R,E> & U32) -> RunResult<S,C,R,E,H,Error>:
  (world,+actual) = named
  run_actual_skip(~S,~C,~R,~E,~H,~Error,~skip,~dispatch,~condition,schedule,world,actual)

# As run, but a false condition invokes skip(owners,world,id) before continuing.
# Use the provider-defined hook for skipped-reader lifecycle; the hook itself
# returns both actual owners and World and is not assumed to be a pure no-op.
def run_with_skip(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,~skip: H -> W.World<S,C,R,E> -> U32 -> H & W.World<S,C,R,E>,~dispatch: H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition: W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,schedule: Schedule<S,C,R,E,H>,world: W.World<S,C,R,E>) -> RunResult<S,C,R,E,H,Error>:
  run_namespace_skip(~S,~C,~R,~E,~H,~Error,~skip,~dispatch,~condition,schedule,W.namespace(~S,~C,~R,~E,world))

def run_barrier_checked(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,~barrier:H -> W.World<S,C,R,E> -> H & W.World<S,C,R,E>,allowed:Bool,schedule:Schedule<S,C,R,E,H>,world:W.World<S,C,R,E>) -> RunResult<S,C,R,E,H,Error>:
  match allowed schedule:
    case False{} schedule:Rejected{schedule,world}
    case True{} Schedule{+namespace,+name,+steps,owners}:execute_with_barrier(~S,~C,~R,~E,~H,~Error,~dispatch,~condition,~barrier,steps,owners,world,namespace,name,steps,[])
def run_barrier_actual(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,~barrier:H -> W.World<S,C,R,E> -> H & W.World<S,C,R,E>,schedule:Schedule<S,C,R,E,H>,world:W.World<S,C,R,E>,+actual:U32) -> RunResult<S,C,R,E,H,Error>:
  match schedule:
    case Schedule{+namespace,+name,+steps,owners}:run_barrier_checked(~S,~C,~R,~E,~H,~Error,~dispatch,~condition,~barrier,U32.is_eq(namespace,actual),Schedule{namespace,name,steps,owners},world)
def run_barrier_named(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,~barrier:H -> W.World<S,C,R,E> -> H & W.World<S,C,R,E>,schedule:Schedule<S,C,R,E,H>,named:W.World<S,C,R,E> & U32) -> RunResult<S,C,R,E,H,Error>:
  match named:
    case (world,actual):run_barrier_actual(~S,~C,~R,~E,~H,~Error,~dispatch,~condition,~barrier,schedule,world,actual)
# As namespace-checked run, with a caller-supplied barrier threading H and World
# at each explicit Barrier step. This supports owned runtime synchronization;
# its effects are trusted and no automatic final barrier or schedule rollback
# is added. Condition-false handling is the ordinary skip-without-dispatch path.
def run_with_barrier(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,~barrier:H -> W.World<S,C,R,E> -> H & W.World<S,C,R,E>,schedule:Schedule<S,C,R,E,H>,world:W.World<S,C,R,E>) -> RunResult<S,C,R,E,H,Error>:
  run_barrier_named(~S,~C,~R,~E,~H,~Error,~dispatch,~condition,~barrier,schedule,W.namespace(~S,~C,~R,~E,world))
