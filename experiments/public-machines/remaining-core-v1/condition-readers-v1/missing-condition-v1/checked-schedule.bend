import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch

def after_condition(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,~skip: H -> W.World<S,C,R,E> -> U32 -> H & W.World<S,C,R,E>,~dispatch: H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,next: H -> W.World<S,C,R,E> -> List<&2,Sch.Observation> -> Sch.RunResult<S,C,R,E,H,Error>,checked: W.World<S,C,R,E> & Result<Error,Bool>,owners: H,+namespace: U32,+name: String,+all: List<&2,Sch.Step>,+observations: List<&2,Sch.Observation>,+id: U32) -> Sch.RunResult<S,C,R,E,H,Error>:
  match checked:
    case (world,Fail{error}): Sch.Failed{Sch.Schedule{namespace,name,all,owners},world,error,observations}
    case (world,Done{allowed}): Sch.conditioned_skip(~S,~C,~R,~E,~H,~Error,~skip,~dispatch,next,allowed,owners,world,namespace,name,all,observations,id)

def execute_skip(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,~skip: H -> W.World<S,C,R,E> -> U32 -> H & W.World<S,C,R,E>,~dispatch: H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition: W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Result<Error,Bool>,steps: List<&2,Sch.Step>,owners: H,world: W.World<S,C,R,E>,+namespace: U32,+name: String,+all: List<&2,Sch.Step>,+observations: List<&2,Sch.Observation>) -> Sch.RunResult<S,C,R,E,H,Error>:
  match steps:
    case []: Sch.Finished{Sch.Schedule{namespace,name,all,owners},world,observations}
    case Sch.Phase{phase} <> rest: execute_skip(~S,~C,~R,~E,~H,~Error,~skip,~dispatch,~condition,rest,owners,world,namespace,name,all,List.append(&2,Sch.Observation,observations,[Sch.Entered{phase}]))
    case Sch.Barrier{} <> rest: execute_skip(~S,~C,~R,~E,~H,~Error,~skip,~dispatch,~condition,rest,owners,W.barrier(~S,~C,~R,~E,world),namespace,name,all,List.append(&2,Sch.Observation,observations,[Sch.Applied{}]))
    case Sch.System{+id,slot} <> rest: after_condition(~S,~C,~R,~E,~H,~Error,~skip,~dispatch,h => w => obs => execute_skip(~S,~C,~R,~E,~H,~Error,~skip,~dispatch,~condition,rest,h,w,namespace,name,all,obs),condition(world,slot),owners,namespace,name,all,observations,id)

def run_checked_skip(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,~skip: H -> W.World<S,C,R,E> -> U32 -> H & W.World<S,C,R,E>,~dispatch: H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition: W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Result<Error,Bool>,allowed: Bool,schedule: Sch.Schedule<S,C,R,E,H>,world: W.World<S,C,R,E>) -> Sch.RunResult<S,C,R,E,H,Error>:
  match allowed schedule:
    case False{} schedule: Sch.Rejected{schedule,world}
    case True{} Sch.Schedule{+namespace,+name,+steps,owners}: execute_skip(~S,~C,~R,~E,~H,~Error,~skip,~dispatch,~condition,steps,owners,world,namespace,name,steps,[])


def run_actual_skip(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,~skip: H -> W.World<S,C,R,E> -> U32 -> H & W.World<S,C,R,E>,~dispatch: H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition: W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Result<Error,Bool>,schedule: Sch.Schedule<S,C,R,E,H>,world: W.World<S,C,R,E>,+actual: U32) -> Sch.RunResult<S,C,R,E,H,Error>:
  match schedule:
    case Sch.Schedule{+namespace,+name,+steps,owners}: run_checked_skip(~S,~C,~R,~E,~H,~Error,~skip,~dispatch,~condition,U32.is_eq(namespace,actual),Sch.Schedule{namespace,name,steps,owners},world)

def run_namespace_skip(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,~skip: H -> W.World<S,C,R,E> -> U32 -> H & W.World<S,C,R,E>,~dispatch: H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition: W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Result<Error,Bool>,schedule: Sch.Schedule<S,C,R,E,H>,named: W.World<S,C,R,E> & U32) -> Sch.RunResult<S,C,R,E,H,Error>:
  (world,+actual) = named
  run_actual_skip(~S,~C,~R,~E,~H,~Error,~skip,~dispatch,~condition,schedule,world,actual)

def run_with_skip(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,~skip: H -> W.World<S,C,R,E> -> U32 -> H & W.World<S,C,R,E>,~dispatch: H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition: W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Result<Error,Bool>,schedule: Sch.Schedule<S,C,R,E,H>,world: W.World<S,C,R,E>) -> Sch.RunResult<S,C,R,E,H,Error>:
  run_namespace_skip(~S,~C,~R,~E,~H,~Error,~skip,~dispatch,~condition,schedule,W.namespace(~S,~C,~R,~E,world))
